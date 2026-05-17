:- use_module(library(charsio)).
:- set_prolog_flag(double_quotes, chars).
:- use_module(library(dcg/high_order)


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
ws --> 
    [C],
    {C = ' '; C = '\t'; C = '\n'},
    ws.
ws --> [].
typedecl(X-Tp) --> ws, symb(X), ws, "::", ws, symb(Tp), ws, ".", ws.
tdecls([Td |Tl]) --> ws, typedecl(Td), ws, tdecls(Tl).
tdecls([]) --> [].
idecls([Td |Tl]) --> ws, inpdecl(Td), ws, idecls(Tl).
idecls([]) --> [].
inpdecl(X) --> ws, "in", wso, symb(X), ws, ".".
outdecl(X) --> ws, "out", wso, symb(X), ws, ".".

lis([C|Cs]) --> [C], lis(Cs).
lis([]) --> [].

%using the hack
:- table expr//1.
expr(ope(plus, A, B)) -->  expr(A), ws, "+", ws, expr(B).
expr(ope(mul, A, B)) --> expr(A), ws, "*", ws, expr(B).
expr(ope(minus, A, B)) --> expr(A), ws, "-", ws, expr(B).
expr(ope(div, A, B)) --> expr(A), ws, "/", ws, expr(B).
expr(i(C)) -->  nlitn(C).
expr(rf(V)) --> symb(V).
expr(u) --> "_".


stmt(assn(rf(V), E)) --> symb(V), ws, ":=", ws, expr(E), ws, ";".
stmt(lift(V)) --> "lift", ws, symb(V), ws, ";".
stmt(alloc(rf(V), N)) -->
    "alloc(", 
    ws, symb(V), ws, ",", ws,
    expr(N), ws,
    ")", ws, ";", ws.

stmt(free(rf(V))) -->
    "free(", 
    ws, symb(V), ws,
    ")", ws, ";".


body([St|Stmts]) --> ws, stmt(St), ws, body(Stmts).
body([]) --> [].

brnch(hlt) --> "hlt", ws, ".".
brnch(jmp(Target)) --> "jmp", wso, symb(Target), ws,".".

brnch(ift(E, Th, El)) --> "if",
                    wso, expr(E), wso, "then", wso, symb(Th),
                    wso, "else", wso, symb(El), ws, ".".



arglist([Arg | Args]) --> symb(Args), ws, ",", ws, arglist(Args).
arglist([Arg]) --> symb(Arg), ws, ")".
arglist([]) --> [].
proc(Name-Args-Body) --> "proc", wso,
    symb(Name), arglist(Args),
    ":", ws, body(Body).

block(Lbl-Body-Jmp) -->
    ws,
    symb(Lbl),
    ws, ":", ws,
    body(Body),
    ws,
    brnch(Jmp),ws.

pprog([Block|Blocks]) --> ws, block(Block), ws, pprog(Blocks).
pprog([]) --> [].

fullprog(Types-Inps-Out-Prog) -->
    tdecls(Types), 
    idecls(Inps),
    outdecl(Out),
    pprog(Prog).



