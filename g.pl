
% adj(1, 2). adj (2, 3). adj(3, 4).
% adj(2, 5). adj(5, 2).

:- table pth/2.
pth(A, B) :- adj(A, B).
pth(A, B) :- adj(A, C), pth(C, B).

%loop_like(X) :-
%    findall(Y, scc(X, Y), Bg),
%    maplist(prog, Bg, Bodies),
%    findall(
%        ift(Cond, Th, El),
%        member(_-ift(Cond, Th, El), Bodies),
%        Ifjmps),
%    length(Ifjmps, 1).
%
