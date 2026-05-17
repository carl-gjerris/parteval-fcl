
state([A]), [A] --> [A].
state(S0, S1) --> 
zip([], [] ,[]).
zip([Hd | Tl], [H | T] ,[Hd-H | Nt]) :- zip(Tl, T, Nt).
mgx(Temp, Var, Arg, Ntemp) :- copy_term(Temp-Var, Ntemp-V), V = Arg.


lgen(lbl(B)) --> {gensym(lbl, B)}, [B].

test --> [a], [a], [b].
lower(if(Cond, Then, Else)) -->
    [ift(Cond, T, E)],
    lgen(T), 
    lower(Then),
    lgen(E),
    lower(Else).


lower(while(Cond, Body)) -->
    [ift(Cond, B, E)],
    lgen(B),
    lower(Body),
    lgen(E).

lower([Hd | Tl]) --> lower(Hd), lower(Tl).

lower(assn(X, E)) --> [assn(X, E)].

lower([]) --> [].

lower(call(P, Args)) -->
    push(Args),
    [jmp(P)],
    pop(Args).

rnm_arg(Args, Arg stack(Ind)) :-
    nth0(Ind, Args, Arg).

rnm_arg(Args, Body, Nbody) :- 
    mapsubterm(rnm_arg(Args), Body, Nbody).

lower(proc(Nm, Args, Body)) -->
    [lbl(Nm)],
    {rnm_args(Args, Body, Nbody)},
    lower(Nbody),
    [return].

genblock([lbl(L)|Body], Jmp) :-
    assertz(prog(L, Body-Jmp)).

lift([Hd | Tl], Acc) :-
    (Hd = jmp(_); Hd = ift(_, _, _), Hd = return),
    genblock(Acc, Hd), !.

lift([Hd | Tl], Acc) :-
    lift(Tl, [Hd|Acc]).

