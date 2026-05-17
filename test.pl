:- [grmmr, pe_heap, compression, toc].

chars_from_file(Fname, Chars) :- 
    phrase_from_file(lis(L), Fname),
    maplist(char_code, Chars, L).

test(1, S) :-
    chars_from_file('stmt.flc', Chs),
    phrase(stmt(S), Chs, _).

test(2, B) :-
    chars_from_file('body.flc', Chs),
    once(phrase(body(B), Chs, _)).

test(3, Br) :-
    chars_from_file('branch.flc', Chs),
    phrase(brnch(Br), Chs, _).

test(4, Nb) :-
    chars_from_file('block.flc', Chs), 
    once(phrase(block(Bl), Chs, _)), 
    Bl = Nm-Body-Jmp,
    emp(Store), emp(Heap),
    rb(Body, Nb, Store-Heap, Stn).

test(5, Store-Heap) :-
    chars_from_file('alloc.flc', Chs),
    once(phrase(pprog(Prog), Chs, _)),
    program(Prog),
    emp(Store), emp(Heap),
    pe(init, Store-Heap).
    
test(6, Prog) :- 
    chars_from_file('block.flc', Chs),
    once(phrase(pprog(Prog), Chs, _)),
    program(Prog),
    emp(Store), emp(Heap),
    pe(init, Store-Heap)
    .

test(7, Prog) :- 
    chars_from_file('block.flc', Chs),
    once(phrase(pprog(Prog), Chs, _)),
    program(Prog).

