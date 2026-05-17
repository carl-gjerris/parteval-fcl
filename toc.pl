
to_atom([], '').
to_atom([H|Tl], R) :- to_atom(Tl, Rest),  atom_concat(H, Rest, R) .

intersperse([H], _, [H]).
intersperse([H | Tl], Sep, [H, Sep | Ntl]) :-
    intersperse(Tl, Sep, Ntl).

write_expr(i(I), I).
write_expr(rf(V), V).
write_expr(mem(rf(V), Ind), Expr) :-
    write_expr(Ind, Ie), to_atom([V, '[', Ie, ']'], Expr).

write_expr(ope(Op, L, R), Expr) :- 
    write_expr(L, La),
    write_expr(R, Ra),
    (
        Op = plus, Inf = +
    ;
        Op = minus, Inf = -
    ;
        Op = mul, Inf = *
    ;
        Op = div, Inf = / 
    ),
    to_atom(['(', La, Inf, Ra, ')'], Expr)
    .

write_stmt(alloc(rf(X), E), A) :-
    write_expr(E, N),
    ctype(X, Tp), objecttype(Tp, T),
    to_atom([X, '=',
            'malloc(',
            N, '*', 'sizeof(', T, '))'
            ], A).

write_stmt(free(rf(X)), A) :- to_atom(['free(', X, ');\n']).

write_stmt(assn(rf(X), E), A) :-
    write_expr(E, Rh),
    to_atom([X, '=', Rh, ';'], A).

write_stmt(assn(mem(rf(X), Ind), E), A) :-
    write_expr(mem(rf(X), Ind), Lh),
    write_expr(E, Rh),
    to_atom([Lh, '=', Rh, ';'], A).

write_stmt(lift(_), '').

write_block([], '').

write_block([Assn | Assns], Bl) :-
    write_block(Assns, Stmts),
    write_stmt(Assn, S),
    to_atom([S, '\n', Stmts], Bl).

write_jmp(jmp(Dest), Goto) :- 
    to_atom(['goto ', Dest, ';\n'], Goto).

write_jmp(ift(Cond, Th, El), Goto) :- 
    write_expr(Cond, Ce),
    to_atom(['if(', Ce, ')\n',
                '  goto ', Th, ';\nelse\n',
                '  goto ', El, ';\n'], Goto).

write_jmp(hlt, 'goto hlt;').

write_lbl(Stage, Lbl, L) :- 
    call(Stage, Lbl, Body-Jmp),
    write_block(Body, Stmts),
    write_jmp(Jmp, Goto),
    to_atom([Lbl, ':\n', Stmts, Goto], L).

