:- module(pp, [pp//1]).

:- set_prolog_flag(double_quotes, chars).


digit(C) --> [C], {char_type(C, digit)}.
nlit(C) --> digit(C).
nlit(N) --> digit(C), nlit(Ns), {atom_concat(C, Ns, N)}.
nlitn(Lit) --> nlit(N), {atom_number(N, Lit)}.
symb(Smb) -->
    [S], {char_type(S, alpha)}, symb(Mb), 
    {atom_concat(S, Mb, Smb)}.

symb(S) --> [S], {char_type(S, alpha)}.

wso --> 
    [C],
    {C = ' '; C = '\t'; C = '\n'},
    ws.
ws --> [].
ws --> 
    [C],
    {C = ' '; C = '\t'; C = '\n'}, !,
    ws.




pp(rf(V)) --> pp(V).
pp(mem(rf(Ptr), Ind)) --> pp(rf(Ptr)), "[", pp(Ind), "]".

pp(op(Sym, [L, R])) --> "(", pp(L), Sym, pp(R), ")".

pp(while(Cond, Body)) --> "while",
    wso, expr(Cond), wso,
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
    ")",  ";".

pp([St|Stmts]) --> ws, pp(St), ws, pp(Stmts), ws.
pp([]) --> [].

pp(hlt) --> "hlt", ".\n".
pp(jmp(Target)) --> "jmp", " ", pp(Target), ".\n".

pp(ift(E, Th, El)) --> "if",
                    " ", pp(E), " ", "then", " ", pp(Th),
                    " ", "else", " ", pp(El), ".\n".

pp(X) --> [X].
