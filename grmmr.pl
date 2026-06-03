:- use_module(library(charsio)).
:- set_prolog_flag(double_quotes, chars).
:- use_module(library(dcg/high_order)).


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
    {C = ' '; C = '\t'; C = '\n'}, !,
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

:- dynamic operator/3.
operator("=", 1500, r).
operator("\\=", 1500, r).
operator("<", 1500, r).
operator(">", 1500, r).
operator("-", 1000, l).
operator("+", 1000, l).
operator("*", 500, l).
operator("/", 500, l).
operator("<<", 500, l).
operator(">>", 500, l).

pos(rf(V)) --> symb(V).
pos(mem(rf(Ptr), Ind)) --> symb(Ptr), "[", ws, expr(Ind), ws, "]".

l(i(C)) -->  nlitn(C).
l(X) --> pos(X).
l(u) --> "_".
le(X) --> l(X).
new(X, S, op(S, [X, Y]), Y) :-
    X = rf(_); X = i(_); X = mem(_, _).

new(op(S, X), Sym, op(Sym, [t(S, X), Y]), Y) :-
    operator(S, Slvl, A),
    operator(Sym, Symlvl, _),
    (Slvl < Symlvl; Slvl = Symlvl, A = l).

new(op(S, [L, R]), Sym, op(S, [L, Nr]), Y) :-
    operator(S, Slvl, A),
    operator(Sym, Symlvl, _),
    (Slvl > Symlvl; Slvl = Symlvl, A = r),
    new(R, Sym, Nr, Y).

sym(S) :- operator(S, _, _).

expr(start, Res) --> le(E), expr(E, Res).
expr(E, Ne) -->
    {sym(Sym)},ws, Sym, ws, {new(E, Sym, E0, Y)}, le(Y), expr(E0, Ne).
expr(St, St) --> [].

expr(X) --> expr(start, X).


%using the hack
%expr(ope(plus, A, B)) -->  expr(A), ws, "+", ws, expr(B).
%expr(ope(mul, A, B)) --> expr(A), ws, "*", ws, expr(B).
%expr(ope(minus, A, B)) --> expr(A), ws, "-", ws, expr(B).
%expr(ope(div, A, B)) --> expr(A), ws, "/", ws, expr(B).
%expr(ope(eq, A, B)) --> expr(A), ws, "=", ws, expr(B).
%expr(ope(lt, A, B)) --> expr(A), ws, "<", ws, expr(B).
%expr(ope(gt, A, B)) --> expr(A), ws, ">", ws, expr(B).
%expr(ope(or, A, B)) --> expr(A), ws, "||", ws, expr(B).
%expr(ope(and, A, B)) --> expr(A), ws, "&&", ws, expr(B).
%expr(i(C)) -->  nlitn(C).
%expr(rf(V)) --> symb(V).
%expr(mem(Ptr, Ind)) --> symb(Ptr),"[", expr(Ind), "]".
%expr(u) --> "_".
%


stmt(while(Cond, Body)) --> ws, "while",
    wso, expr(Cond), ws,
    "{", body(Body), "}", ws.


stmt(assn(X, E)) --> ws, pos(X), ws, ":=", ws, expr(E), ws, ";".
stmt(lift(V)) --> "lift", ws, symb(V), ws, ";".
stmt(alloc(X, N)) -->
    "alloc(", 
    ws, pos(X), ws, ",", ws,
    expr(N), ws,
    ")", ws, ";", ws.

stmt(free(X)) -->
    "free(", 
    ws, pos(X), ws,
    ")", ws, ";".
stmt(if(Cond, Then, Else)) --> 
    ws, "if", wso, expr(Cond), ws,
    "{", ws, body(Then), ws, "}", ws,
    "else", ws, "{", ws, body(Else), ws, "}".
stmt(if(Cond, [Body])) --> 
    ws, "if", wso, expr(Cond), ws,
    stmt(Body).
stmt(if(Cond, [Body])) --> 
    ws, "if", wso, expr(Cond), ws,
    "{", ws, body(Body), ws, "}", ws.

stmt(switch(Expr, Cases)) -->
    ws, "switch", wso, expr(Expr), ws, "{", ws, 
    case(Cases), ws, "}", ws.

body([St|Stmts]) --> ws, stmt(St), ws, body(Stmts), ws.
body([]) --> [].

bodyf([St|Stmts]) --> ws, (stmt(St) | brnch(St)), ws, bodyf(Stmts), ws.
bodyf([]) --> [].

brnch(hlt) --> "hlt", ws, ".".
brnch(jmp(Target)) --> "jmp", wso, symb(Target), ws,".".

brnch(ift(E, Th, El)) --> "if",
                    wso, expr(E), wso, "then", wso, symb(Th),
                    wso, "else", wso, symb(El), ws, ".".


case(V-Body) --> (symb(V) | nlitn(V)), ws, "->", ws, body(Body).
cases([C | Cases]) --> ws, case(C), ws, ",", cases(Cases).
cases([C]) --> ws, case(C), ws.

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

