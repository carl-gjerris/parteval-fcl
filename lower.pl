

just(X, Y, X, Y).
subst(X, Y, T, T0) :- mapsubterms(just(X, Y), T, T0).

zip([], [] ,[]).
zip([Hd | Tl], [H | T] ,[Hd-H | Nt]) :- zip(Tl, T, Nt).
mgx(Temp, Var, Arg, Ntemp) :- copy_term(Temp-Var, Ntemp-V), V = Arg.

lgen(B) --> {gensym(lbl, B)}, [lbl(B)].

test --> [a], [a], [b].
lower(if(Cond, Then, Else)) -->
    [ift(Cond, T, E)],
    lgen(T), 
    lower(Then),
    [jmp(Exit)],
    lgen(E),
    lower(Else),
    [jmp(Exit)],
    lgen(Exit).

lower(if(Cond, Then)) -->
    [ift(Cond, T, E)],
    lgen(T), 
    lower(Then),
    [jmp(E)],
    lgen(E).

lower(while(Cond, Body)) -->
    [ift(Cond, B, E)],
    lgen(B),
    lower(Body),
    [ift(Cond, B, E)],
    lgen(E).

lower(X) -->
    {X = alloc(_, _); X = assn(_, _);
    X = free(_); X = lift(_)},
    [X].

lower([Hd | Tl]) --> lower(Hd), lower(Tl).

lower([]) --> [].

genblock([lbl(L)|Body], Jmp) :-
    assertz(prog(L, Body-Jmp)).

lift(Prog) :- lift([lbl(ss__) | Prog], []).

deli(i(V), V).

lift([Hd | Tl], Acc) :-
    (Hd = jmp(_); Hd = ift(_, _, _); Hd = return; Hd = hlt),
    reverse(Acc, Acc0),
    genblock(Acc0, Hd), !, lift(Tl, []).

lift([Hd | Tl], Acc) :-
    lift(Tl, [Hd|Acc]).

lift([], Acc) :-
    reverse(Acc, Acc0),
    genblock(Acc0, hlt).

   
