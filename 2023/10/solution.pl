main :-
	part1('input10.txt').

init(Filename, Lines, X, Y) :-
    file_line(Filename, Lines),
    write(Lines), nl,
    find_s(Lines, 0, X, Y),
    write(X), nl,
    write(Y), nl.

solution(Filename) :-
    init(Filename, Lines, X, Y),
	write('part1'), nl,
    explore('S', '', X, Y, '+', 0, 0, Lines, L, A),
    Sol is L / 2,
    write("Sol 1 is "), write(Sol), nl,
    Sol2 is abs(A),
    write("Sol 2 is "), write(Sol2), nl,
    nl
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

explore(DLast, DFirst, X, Y, Sgn, C, A, Lines, L, Area) :-
	lup(Lines, X, Y, T),
	write('Explore '), write(C), write(' '), write(X), write(' '), write(Y), write(' '), write(DLast), write(' '), write(T), nl,
	(
		T = 'S', C > 0,
		add_area(DLast, DFirst, X, Sgn, Sgn1, ADiff),
		write('Endlore '), write(X), write(' '), write(Y), write(' '), write(DLast), write(' '), write(DFirst), write(' '), write(ADiff), write(' '), write(Sgn), write(' '), write(Sgn1), nl,
		Area is A + ADiff,
		L = C, !
	;
		reversed(DLast, DCheck),
		permissable(T, DCheck),
		permissable(T, DNext),
		\+ DCheck = DNext,
		nextd(DNext, XD, YD),
		write('add_area '), write(X), write(' '), write(Y), write(' '), write(DLast), write(' '), write(DNext), write(' '), write(Sgn), nl,
		add_area(DLast, DNext, X, Sgn, Sgn1, ADiff),
		record_first(DFirst, DNext, DFirst1),
		XNext is X + XD,
		YNext is Y + YD,
		A1 is A + ADiff,
		C1 is C + 1,
		write('Rxplore '), write(X), write(' '), write(Y), write(' '), write(DLast), write(' '), write(DNext), write(' '), write(ADiff), write(' '), write(Sgn), write(' '), write(Sgn1), nl,
		explore(DNext, DFirst1, XNext, YNext, Sgn1, C1, A1, Lines, L, Area)
	).

record_first('', DNext, DNext).
record_first(DFirst, _, DFirst) :-
	\+ DFirst = ''.

add_area('S', _, _, S, S, 0).
add_area('R', 'R', _, S, S, 0).
add_area('L', 'L', _, S, S, 0).
add_area('U', 'U', X, '+', '+', NewArea) :-
	add_area2('-', X, NewArea).
add_area('D', 'D', X, '+', '+', NewArea) :-
	add_area2('+', X, NewArea).
add_area(O, N, X, '+', '+', NewArea) :-
	chirality(O, N, Chi),
	rotate('+', Chi, O, N, S),
	write('Rotate '), write(Chi), write(' '), write(S), nl,
	add_area2(S, X, NewArea).

add_area2('+', X, NewArea) :-
	NewArea is X - 1.
add_area2('-', X, NewArea) :-
	NewArea is -X.
add_area2('0', _, 0).

chirality('D', 'L', '+').
chirality('L', 'U', '+').
chirality('U', 'R', '+').
chirality('R', 'D', '+').
chirality('L', 'D', '-').
chirality('U', 'L', '-').
chirality('R', 'U', '-').
chirality('D', 'R', '-').

% ExpChi, Chi, ODir, NewDir,
% A corner with expected Chi is 0.
rotate(Chi, Chi, _, _, '0').
% Otherwise, right edges are +, left edges are -.
rotate('+', _OC, 'L', 'D', '+').
rotate('+', _OC, 'D', 'R', '+').
rotate('+', _OC, 'R', 'U', '-').
rotate('+', _OC, 'U', 'L', '-').

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
reversed('S', 'D').
reversed('S', 'U').
reversed('S', 'R').
reversed('S', 'L').

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
    stream_line(In, Rest), !.
stream_line(_, []).
