
same(X, Y) :- X = Y.

touches(T, Bg) :-
    findall(
        X,
        (
            sub_term(X, T), X = rf(V)
        ; 
            sub_term(X, T), X = mem(Ptr, Ind)),
        Bg).

bl_loads([], []).
bl_loads([assn(_, E)|Stmts], Loads) :-
    touches(E, Vs), bl_loads(Stmts, Loads0),
    append(Vs, Loads0, Loads).

writes(assn(X, E), X).
reads(assn(X, E), Places) :- touches(E, Places).

different(rf(X), rf(Y)) :- X \= Y.
different(rf(_), mem(_, _)).
different(mem(_, _), rf(_)).
different(mem(P, I), mem(Q, J)) :-
    P \= Q, !
;
    I = i(Iv), J = i(Jv), Iv \= Jv.

dependency_aux(A, B, w-w, X-Y) :-
        writes(A, X), writes(B, Y), same(X, Y).

dependency_aux(A, B, w-r, X-Y) :-
       writes(A, X), reads(B, Places),
       member(Y, Places),
       same(X, Y).

dependency_aux(A, B, r-w, X-Y) :-
       reads(A, Places), writes(B, X),
       member(Y, Places),
       same(X, Y).

no_dependency(A, B) :-
    writes(A, X),
    reads(A, Aplaces),
    writes(B, Y),
    reads(B, Bplaces),
    different(X, Y),
    maplist(different(X), Bplaces),
    maplist(different(Y), Aplaces).

dependency(A, B, Type) :- 
    dependency_aux(A, B, Type), !
;
    \+ no_dependency(A, B),
    Type = *
    .
