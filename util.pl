
chars_from_stream(Stream, [C|Chars]) :-
    get_char(Stream, C),
    C \= end_of_file, !, chars_from_stream(Stream, Chars).
 
chars_from_stream(Stream, []) :- 
    get_char(Stream, C), C = end_of_file.

file_chars(Fname, Chars) :-
    open(Fname, read, Stream),
    chars_from_stream(Stream, Chars).

write_chars(Stream, [C | Chars]) :-
    write(Stream, C), write_chars(Stream, Chars).

write_chars(_, []).

write_file(Chars, Fname) :-
    open(Fname, write, Stream),
    write_chars(Stream, Chars).

