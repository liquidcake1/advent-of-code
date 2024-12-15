main:-
    read_file('input', Map, Dirs, RRowI, RColI),
    write([RRowI, RColI]), nl,
    write([RRowI, RColI, Map]), nl,
    execute_many(Dirs, Map, RRowI, RColI, NewMap, NewRRowI, NewRColI),
    write([NewRRowI, NewRColI, NewMap]), nl,
    write(Dirs), nl,
    !,
    gps_sum(NewMap, 0, GPSSum),
    !,
    write(['GPSSum', GPSSum]), nl.

gps_sum([], _, 0).
gps_sum([Line|Rest], RowI, Sum) :-
    gps_sum_line(Line, RowI, 0, RowSum),
    NewRowI is RowI + 1,
    write('foo'), nl,
    write(['foo', RowSum]), nl,
    gps_sum(Rest, NewRowI, SumOfRest),
    Sum is SumOfRest + RowSum.

gps_sum_line([], _RowI, _ColI, 0).
gps_sum_line(['O'|Rest], RowI, ColI, Sum) :-
    NewColI is ColI + 1,
    gps_sum_line(Rest, RowI, NewColI, SumOfRest),
    Sum is ColI + RowI * 100 + SumOfRest.
gps_sum_line([Item|Rest], RowI, ColI, Sum) :-
    Item \== 'O',
    NewColI is ColI + 1,
    gps_sum_line(Rest, RowI, NewColI, Sum).

execute_many([], Map, RRowI, RColI, Map, RRowI, RColI).
execute_many([Dir|Rest], Map, RRowI, RColI, NewMap, NewRRowI, NewRColI) :-
    %write(['execute_many', Map, RRowI, RColI, Dir]), nl,
    execute(Map, RRowI, RColI, Dir, TempMap, TempRRowI, TempRColI),
    !,
    %write(['post_execute', TempMap, TempRRowI, TempRColI]), nl,
    length(Rest, L),
    write([Dir, L]), nl,
    execute_many(Rest, TempMap, TempRRowI, TempRColI, NewMap, NewRRowI, NewRColI).


execute(Map, RRowI, RColI, '<', NewMap, RRowI, NewRColI) :-
    executeh(Map, RRowI, RColI, '<', NewMap, NewRColI).
execute(Map, RRowI, RColI, '>', NewMap, RRowI, NewRColI) :-
    executeh(Map, RRowI, RColI, '>', NewMap, NewRColI).
execute(Map, RRowI, RColI, '^', NewMap, NewRRowI, RColI) :-
    transpose(Map, TMap),
    executeh(TMap, RColI, RRowI, '<', TNewMap, NewRRowI),
    transpose(TNewMap, NewMap).
execute(Map, RRowI, RColI, 'v', NewMap, NewRRowI, RColI) :-
    transpose(Map, TMap),
    executeh(TMap, RColI, RRowI, '>', TNewMap, NewRRowI),
    transpose(TNewMap, NewMap).

executeh([Row|Map], 1, RColI, Dir, [NewRow|NewMap], NewRColI) :-
    execute_on_row(Row, Dir, NewRow, MoveAmount),
    NewRColI is RColI + MoveAmount,
    executeh(Map, 0, RColI, Dir, NewMap, NewRColI).
executeh([Row|Map], RRowI, RColI, Dir, [Row|NewMap], NewRColI) :-
    RRowI \== 1,
    NewRRowI is RRowI - 1,
    executeh(Map,  NewRRowI, RColI, Dir, NewMap, NewRColI).
executeh([], _, _, _, [], _).

execute_on_row(Row, '<', NewRow, MoveAmount) :-
    push_left([], Row, NewRow, MoveAmount).
execute_on_row(Row, '>', NewRow, MoveAmount) :-
    push_right([], Row, NewRow, MoveAmount).

transpose([X], XTransposed) :-
    wrapped(X, XTransposed).
transpose([X|Rest], TransposeWithX) :-
    Rest \== [],
    % X is a list.
    % RHS must have elts of X at the start, in turn.
    every_start(X, TransposeWithoutX, TransposeWithX),
    transpose(Rest, TransposeWithoutX).

wrapped([], []).
wrapped([X|Rest], [[X]|WRest]) :- wrapped(Rest, WRest).

every_start([X|XRest], [RHS|RHSRest], RHSWithX) :-
    RHSWithX = [[X|RHS]|RHSAfterX],
    every_start(XRest, RHSRest, RHSAfterX).
every_start([], [], []).

push_right(Buffer, RobotRow, NewRobotRow, MoveAmount) :-
    reverse(RevRobotRow, RobotRow),
    push_left(Buffer, RevRobotRow, NewRevRobotRow, NegMoveAmount),
    reverse(NewRevRobotRow, NewRobotRow),
    MoveAmount is -NegMoveAmount.

push_left(_Buffer, [], [], _MoveAmount).
push_left(Buffer, [Sym|RobotRow], NewRobotRow, MoveAmount) :-
    (
        %write(['push_left',Sym, Buffer, RobotRow]), nl,
        (
            Sym == '#' ->
            %write(['HASH', Sym, Buffer, RobotRow]), nl,
            Buffer \== ['.'],
            %write(['HASH_postbuffer', Sym, Buffer, RobotRow]), nl,
            NewRobotRow = ['#'|Rest],
            push_left([], RobotRow, Rest, MoveAmount)
        ;
            Sym == '.' ->
            (
                Buffer == [],
                %write(['dot_buffer', Sym, Buffer, RobotRow]), nl,
                push_left(['.'], RobotRow, NewRobotRow, MoveAmount)
            ;   
                Buffer \== ['.'],
                NewRobotRow = ['.'|Rest],
                %write(['dot_nonbuffer', Sym, Buffer, RobotRow]), nl,
                push_left([], RobotRow, Rest, MoveAmount)
            )
        ;
            Sym == 'O' ->
            NewRobotRow = ['O'|Rest],
            %write(['O', Sym, Buffer, RobotRow]), nl,
            push_left(Buffer, RobotRow, Rest, MoveAmount)
        ;
            Sym == '@' ->
            (
                Buffer == [],
                %write(['@_nonbuffer', Sym, Buffer, RobotRow]), nl,
                MoveAmount is 0,
                NewRobotRow = ['@'|Rest],
                push_left(['@'], RobotRow, Rest, MoveAmount)
            ;
                nth(1, Buffer, '.'),
                %write(['@_buffer', Sym, Buffer, RobotRow]), nl,
                MoveAmount is -1,
                NewRobotRow = ['@', '.'|Rest],
                push_left(['@'], RobotRow, Rest, MoveAmount)
            )
        )
    ).


read_file(File, Rows, Dirs, RRowI, RColI) :-
    open(File, read, Stream),
    get_char(Stream, Char),
    read_map(Stream, Char, Rows, RRowI, RColI, 1),
    get_char(Stream, Char2),
    read_dirs(Stream, Char2, Dirs),
    close(Stream).

read_map(Stream, Char, Rows, RRowI, RColI, RowI) :-
    (   Char == '\n' ->
        Rows = []
    ;   read_map_line(Stream, Char, Row, RRowI, RowI, RColI, 1),
        Rows = [Row|Rest],
        get_char(Stream, Next),
        read_map(Stream, Next, Rest, RRowI, RColI, RowI + 1)
    ).

read_map_line(Stream, Char, Chars, RRowI, RowI, RColI, ColI) :-
    (   Char == '\n' ->
        Chars = []
    ;   Char == '@' ->
        Chars = [Char| Rest],
        RRowI is RowI,
        RColI is ColI,
        get_char(Stream, Next),
        read_map_line(Stream, Next, Rest, RRowI, RowI, RColI, ColI + 1)
    ;   Chars = [Char| Rest],
        get_char(Stream, Next),
        read_map_line(Stream, Next, Rest, RRowI, RowI, RColI, ColI + 1)
    ).

read_dirs(Stream, Char, Chars) :-
    (   Char == end_of_file ->
        Chars = []
    ;   Char == '\n' ->
        get_char(Stream, Next),
        read_dirs(Stream, Next, Chars)
    ;   Chars = [Char| Rest],
        get_char(Stream, Next),
        read_dirs(Stream, Next, Rest)
    ).
