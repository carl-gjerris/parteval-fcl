:- use_module(library(reif)).

rep(_, u, u).
rep(_, 0, []).
rep(X, I, [X|Tl]) :- I > 0, J is I - 1, rep(X, J, Tl).




setnth(0, X, [_|Tl], [X|Tl]).
setnth(I, X, [El|Tl], [El|Res]) :-
    J is I - 1, 
    setnth(J, X, Tl, Res).

gptr(P) :- gensym(p, P).
gsv(X) :- gensym(x, X).

emp(E) :- list_to_assoc([], E).

ev_aux(rf(V), St-_, I) :- get_assoc(V, St, I).
ev_aux(mem(Ptr, Ind), St-Heap, I) :-
    Heap = u, I = u
    ;
    ev(Ptr, St-Heap, Ptrval),
    ev(Ind, St-Heap, Indval),
    (
        (Ptrval = u; Indval = u),
        I = u
    ;
        get_assoc(Ptr, Heap, Block),
        (nth0(Ind, Block, I); Block = u, I = u)
    ).

ev_aux(op(Op, [L, R]), St, V) :-
    ev_aux(L, St, Lv),
    ev_aux(R, St, Rv),
    ((Rv = u; Lv = u), V = u  
    ;
    (
        Op = "+", V is Lv + Rv
    ;
        Op = "-", V is Lv - Rv
    ;
        Op = "*", V is Lv * Rv
    ;
        Op = "/", V is Lv / Rv
    ;
        Op = "<", (Lv < Rv, V = 1, !; V = 0)
    ;
        Op = ">", (Lv < Rv, V = 1, !; V = 0)
    ;
        Op = "=", (Lv = Rv, V = 1, !; V = 0)
    )), !.

ev_aux(I, _, I).

ev(E, St, V) :- ev_aux(E, St, V), !.
ev(E, St, u) :- ev_aux(E, St, u), !.
ev(_, _, u).

set(X, Val, St-Heap, Stn) :-
    X = rf(V),
    put_assoc(V, St, Val, St0),
    Stn = St0-Heap, !
;
    X = mem(Ptr, Ind),
    Stn = St-Heap0,
    ev(Ptr, St-Heap, Ptrval),
    ev(Ind, St-Heap, Indval),
    (
        Ptrval = u,
        Heap0 = u, !
    ;
        Indval = u,
        get_assoc(Ptrval, Heap, Mem),
        length(Mem, K),
        rep(Val, K, Mem0),
        put_assoc(Ptrval, Heap, Mem0, Heap0)
    ;
        get_assoc(Ptrval, Heap, Mem),
        setnth(Indval, Val, Mem, Mem0),
        put_assoc(Ptrval, Heap, Mem0, Heap0)
    ).


uninit(N, Heap, Ptr, Heap0) :-
    (var(Ptr), gptr(Ptr), !; true),
(
    N \= u,
    rep(u, N, Uninit),
    put_assoc(Ptr, Heap, Uninit, Heap0), !
;
    N = u,
    put_assoc(Ptr, Heap, u, Heap0)).



rb([], [], St, St). 

rb([alloc(X, E)|Stms], Nstms, St-Heap, Stn) :-
    ev(E, St-Heap, Ev),
    uninit(Ev, Heap, Ptr, Heap0),
    set(X, Ptr,St-Heap0, Store0),
    Nstms = [alloc(X, E) | Stms0],
    rb(Stms, Stms0, Store0, Stn).

rb([free(X)|Stms], Nstms, St-Heap, Stn) :-
    ev(X, St-Heap, Ptr),
    del_assoc(Ptr, Heap, _, Heap0),
    Nstms = [free(rf(X)) | Stms0],
    rb(Stms, Stms0, St-Heap0, Stn).

rb([free(X)|Stms], Nstms, St-Heap, Stn) :-
    ev(X, St-Heap, Ptr),
    Ptr = u,
    write('WARNING: freeing unknown\n'),
    Nstms = [free(rf(X)) | Stms0],
    rb(Stms, Stms0, St-u, Stn).

rb([free(rf(V))|Stms], Nstms, St-Heap, Stn) :-
    Heap = u,
    Nstms = [free(rf(V)) | Stms0],
    rb(Stms, Stms0, St-u, Stn).

rb([assn(X, E)|Stms0], Nstms, Store, Final) :-
    ev(E, Store, Val),
    (
        Val = u, Nstms = [assn(X, E)|Stms], !
    ;
        Val \= u, Nstms = [assn(X, Val)|Stms]
    ),
    set(X, Val, Store, Store0),
    rb(Stms0, Stms, Store0, Final).



rb(Block, Nblock, Stn) :- 
    emp(St), emp(Heap), rb(Block, Nblock, St-Heap, Stn).

:- dynamic residue/2.
:- dynamic prog/2.

program([]) :- !.
program([Lbl-Body-Jmp | Rest]) :-
    assertz(prog(Lbl, Body-Jmp)),
    program(Rest).

sname(Label, Store-Heap, Name) :-
    assoc_to_list(Store, SL),
    assoc_to_list(Heap, HL),
    term_to_atom(SL, Ln),
    term_to_atom(HL, Hn),
    atom_concat(Label, Ln, Name0),
    atom_concat(Name0, Hn, Name).

:- table rnm/2.
rnm(Lbl, Sym) :-
    Lbl = 'ss__[][]', Sym = ss__, !
;
    gensym(blk, Sym), residue(Lbl, _).

rnmresidue(Blk, Body-jmp(T)) :-
    residue(Lbl, Body-jmp(Jlbl)),
    rnm(Lbl, Blk), rnm(Jlbl, T).

rnmresidue(Blk, Body-hlt) :-
    residue(Lbl, Body-hlt),
    rnm(Lbl, Blk).

rnmresidue(Blk, Body-ift(E, Th, El)) :-
    residue(Lbl, Body-ift(E, Thl, Ell)),
    rnm(Lbl, Blk), rnm(Thl, Th), rnm(Ell, El).

pe(Label, Store) :-
    sname(Label, Store, Name),
    residue(Name, _), !.

pe(Label, Store) :-
    prog(Label, Body-Jump),
    rb(Body, Nbody, Store, Stn),
    (Label = init, Name = init; sname(Label, Store, Name)),
    (
        Jump = ift(E, Th, El),
        ev(E, Stn, V), V = u,
        sname(Th, Stn, Thn), sname(El, Stn, Eln),
        assertz(residue(Name, Nbody-ift(E, Thn, Eln))),
        pe(Th, Stn), pe(El, Stn)
    ;
        Jump = ift(E, Th, _),
        ev(E, Stn, I), I \= 0,
        sname(Th, Stn, Thn),
        assertz(residue(Name, Nbody-jmp(Thn))),
        pe(Th, Stn)
    ;
        Jump = ift(E, _, El),
        ev(E, Stn, Null), (Null = 0; Null = null),
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


pe() :- emp(St), emp(Heap), pe(ss__, St-Heap).
