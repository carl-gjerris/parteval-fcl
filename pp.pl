:- module(pp, [pp//1]).

:- set_prolog_flag(double_quotes, chars).





pp(rf(V)) --> pp(V).
pp(mem(rf(Ptr), Ind)) --> pp(rf(Ptr)), "[", pp(Ind), "]".

pp(op(Sym, [L, R])) --> "(", pp(L), Sym, pp(R), ")".

pp(while(Cond, Body)) --> "while",
    " ", expr(Cond), " ",
    "{", body(Body), "}", "\n".


pp(assn(X, E)) --> pp(X), " := ", pp(E),  ";\n".
pp(alloc(X, N)) -->
    "alloc(", 
    pp(X), ",", 
    pp(N),
    ")", ";\n".

pp(free(X)) -->
    "free(", 
    pp(X), 
    ")",  ";\n".

pp([St|Stmts]) --> pp(St), pp(Stmts).
pp([]) --> [].

pp(hlt) --> "hlt", ".\n".
pp(jmp(Target)) --> "jmp", " ", pp(Target), ".\n".

pp(ift(E, Th, El)) --> "if",
                    " ", pp(E), " ", "then", " ", pp(Th),
                    " ", "else", " ", pp(El), ".\n".

pp(X) --> [X].

ppe([St|Stmts]) --> ppe(St), ppe(Stmts).
ppe([]) --> [].
ppe(Lbl-Body-Jump) -->
    [Lbl], ":\n", pp(Body), pp(Jump).



