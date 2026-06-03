:- [grmmr, lower, pe_heap, compression, util].
:- use_module('pp.pl').



take(0, _, []).
take(N, [H | Tl], [H | Res]) :- N > 0, M is N - 1, take(M, Tl, Res).

pe_file(Fname, Outname) :-
    file_chars(Fname, C), 
    phrase(bodyf(B), C), phrase(lower(B), Prog),
    write('partially evaluating\n'),
    mapsubterms(deli, Prog, Prog0), lift(Prog0), once(pe()),
    write('compressing\n'),
    compress('ss__[][]'), 
    findall(Lbl-Body-Jump, compressed(Lbl, Body-Jump), Bg),
    write('writing\n'),
    phrase(pp:ppe(Bg), Pretty),
    write_file(Pretty, Outname).
 
pe_file(Fname, _) :-
    file_chars(Fname, C), 
    phrase(bodyf(B), C), phrase(lower(B), _, R),
    write('parse error at: '),
    take(10, R, R0), write(R0), nl.
