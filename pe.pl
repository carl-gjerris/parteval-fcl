:- use_module(library(reif)).


gptr(P) :- gensym(p, P).
gsv(X) :- gensym(x, X).
fim(X) :- X = rf(_);  X = i(_).
flat(op(_, X, Y)) :- fim(X), fim(Y).
thac(assn(X, E), [assn(X, E)]) :- flat(E), !.
emps(A) :- list_to_assoc([], A).

ev_aux(i(I), St, I).
ev_aux(rf(V), St, I) :- get_assoc(V, St, i(I)).
ev_aux(ope(Op, L, R), St, V) :-
    ev_aux(L, St, Lv),
    ev_aux(R, St, Rv),
    (
        Op = plus, V is Lv + Rv
    ;
        Op = minus, V is Lv - Rv
    ;
        Op = mul, V is Lv * Rv
    ;
        Op = div, V is Lv / Rv
    ).

ev(E, St, i(V)) :- ev_aux(E, St, V), !.
ev(E, St, u).
mgx(Pat-O, I, On) :- copy_term(Pat-O, P-On), I = P.

rb([], [], St, St).

rb([lift(V)|Stms], Stms, St, Stn) :- put_assoc(V, St, u, Stn).

rb([assn(V, E)|Stms0], Nstms, St, Stn) :-
    ev(E, St, Val),
    (
        Val = u, Nstms = [assn(V, E)|Stms]
    ; 
        Val = i(I), Nstms = [assn(V, Val)|Stms]
    ),
    put_assoc(V, St, Val, Stn0),
    rb(Stms0, Stms, Stn0, Stn).

:- dynamic residue/2.
sname(Label, Store, Name) :-
    assoc_to_list(Store, L),
    term_to_atom(L, Ln), atom_concat(Label, Ln, Name).

:- table rnm/2.
rnm(Lbl, Sym) :- gensym(blk, Sym), residue(Lbl, _).

rnmresidue(Blk, Body-jmp(T)) :-
    residue(Lbl, Body-jmp(Jlbl)),
    rnm(Lbl, Blk), rnm(Jlbl, T).

rnmresidue(Blk, Body-hlt) :-
    residue(Lbl, Body-hlt),
    rnm(Lbl, Blk).

rnmresidue(Blk, Body-ift(E, Th, El)) :-
    residue(Lbl, Body-ift(E, Thl, Ell)),
    rnm(Lbl, Blk), rnm(Thl, Th), rnm(Ell, El).

prog(main, [assn(v, ope(plus, i(1), i(2)))]-ift(rf(v), pl1, pl2)).
prog(pl1, [assn(w, rf(v))]-hlt).
prog(pl2, [assn(w, i(1))]-hlt).

expr_vars(rf(V), [V]).
expr_vars(i(V), []).
expr_vars(u, []).
expr_vars(op(_, L, R), Vs) :-
    expr_vars(L, Lv),
    expr_vars(R, Rv),
    flatten(Lv, Rv, Vs).

bl_loads([], []).
bl_loads([assn(V, E)|Stmts], Loads) :-
    expr_vars(E, Vs), bl_loads(Stms, Loads0),
    append(Vs, Loads0, Loads).

bl_stores([], []).
bl_stores([assn(V, E)|Stmts], [V|Rest]) :- bl_stores(Stmts, Rest).


pe(Label, Store) :-
    sname(Label, Store, Name),
    residue(Name, _), !.

pe(Label, Store) :-
    prog(Label, Body-Jump),
    rb(Body, Nbody, Store, Stn),
    sname(Label, Store, Name),
    (
        Jump = ift(E, Th, El),
        ev(E, Stn, V), V = u,
        sname(Th, Stn, Thn), sname(El, Stn, Eln),
        assertz(residue(Name, Nbody-ift(E, Thn, Eln))),
        pe(Th, Stn), pe(El, Stn)
    ;
        Jump = ift(E, Th, El),
        ev(E, Stn, i(I)), I \= 0,
        sname(Th, Stn, Thn),
        assertz(residue(Name, Nbody-jmp(Thn))),
        pe(Th, Stn)
    ;
        Jump = ift(E, Th, El),
        ev(E, Stn, i(0)),
        sname(El, Stn, Eln),
        assertz(residue(Name, Nbody-jmp(Eln))),
        pe(El, Stn)
    ;
        Jump = jmp(Lbl),
        pe(Lbl, Stn), sname(Lbl, Stn, Lbln),
        assertz(residue(Name, Nbody-jmp(Lbln)))
    ;
        Jump = hlt,
        assertz(residue(Name, Nbody-hlt))
    ).
