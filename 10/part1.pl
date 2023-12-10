main :-
	part1('input10.txt').

init(Filename, Lines, X, Y) :-
    file_line(Filename, Lines),
    write(Lines), nl,
    find_s(Lines, 0, X, Y),
    write(X), nl,
    write(Y), nl.

part1(Filename) :-
    init(Filename, Lines, X, Y),
    explore('S', X, Y, 0, Lines, L),
    Sol is L / 2,
    write(Sol), nl
    .

find_s([Line|Lines], I, X, Y) :-
	find_s2(Line, 0, X), I = Y, !
;
	IN is I + 1,
	find_s(Lines, IN, X, Y)
.

find_s2([C|Cs], I, X) :-
	C = 'S', I = X, !
;
	IN is I + 1,
	find_s2(Cs, IN, X)
.

explore(DLast, X, Y, C, Lines, L) :-
	lup(Lines, X, Y, T),
	(
		T = 'S', C > 0, L = C, !
	;
		reversed(DLast, DCheck),
		permissable(T, DCheck),
		permissable(T, DNext),
		\+ DCheck = DNext,
		nextd(DNext, XD, YD),
		XNext is X + XD,
		YNext is Y + YD,
		write(XNext), write(' '), write(YNext), nl,
		C1 is C + 1,
		explore(DNext, XNext, YNext, C1, Lines, L)
	).

lup([Line|_], X, 0, T) :-
	lup2(Line, X, T).
lup([_|Lines], X, Y, T) :-
	Y1 is Y - 1,
	lup(Lines, X, Y1, T).

lup2([C|_], 0, T) :-
	C = T, !.
lup2([_|Line], X, T) :-
	X1 is X - 1,
	lup2(Line, X1, T).

permissable('S', 'U').
permissable('S', 'D').
permissable('S', 'R').
permissable('S', 'L').
permissable('F', 'R').
permissable('F', 'D').
permissable('J', 'L').
permissable('J', 'U').
permissable('L', 'U').
permissable('L', 'R').
permissable('7', 'L').
permissable('7', 'D').
permissable('-', 'L').
permissable('-', 'R').
permissable('|', 'U').
permissable('|', 'D').

reversed('U', 'D').
reversed('D', 'U').
reversed('L', 'R').
reversed('R', 'L').
reversed('S', _).

nextd('U', 0, -1).
nextd('D', 0, 1).
nextd('R', 1, 0).
nextd('L', -1, 0).


file_line(File, Lines) :-
    setup_call_cleanup(open(File, read, In),
        stream_line(In, Lines),
        close(In)).

stream_line(In, [Line|Rest]) :-
    read_line_to_string(In, Line1),
    Line1 \== end_of_file,
    string_chars(Line1, Line),
    stream_line(In, Rest).
stream_line(_, []).
