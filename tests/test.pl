:- ['../load.pl'].


test(X) :-
    atom_concat(test, X, Inp),
    atom_concat(test_pe, X, Out),
    pe_file(Inp, Out).



