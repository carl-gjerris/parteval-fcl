:- [pe_heap].

test(1, Stn) :-
    emp(Store),
    emp(Heap),
    rb([alloc(rf(x), 10), free(rf(x))], _, Store-Heap, Stn).

