:- [grmmr].



wr([]).
wr([Hd|Tl]) :- write(Hd), wr(Tl).

