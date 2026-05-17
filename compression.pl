


compression(Bl1-Jmp1, Bl2-Jmp2, Bl-Jmp2) :- append(Bl1, Bl2).

single_source(Lbl) :-
    findall(Jmp,
        (residue(_, Body-Jmp),
            (
                Jmp = jmp(Lbl)
            ;
                Jmp = ift(_, Th, El), (Th = Lbl; El = Lbl))
            ),
        Bg),
    length(Bg, L),
    L = 1.

:- dynamic compressed/2.

compress_aux(Lbl, Block) :- 
    residue(Lbl, Body-Jump),
    Jump = jmp(Dest),
    compress_aux(Dest, Destblock),
    append(Body, Destblock, Block).

compress_aux(Lbl, Body-Jump) :- 
    residue(Lbl, Body-Jump),
    (Jump = ift(Cond, Th, El); Jump = hlt).

:- dynamic mark/3.

compress(Lbl) :-
    compress_aux(Lbl, Body-Jump),
    assertz(compressed, Body-Jump),
    (
        Jump = ift(Cond, Th, El),
        \+ mark(Cond, Th, El),
        assertz(mark(Cond, Th, El)),
        compress(Th),
        compress(El)
    ;
        Jump = hlt
    ).




