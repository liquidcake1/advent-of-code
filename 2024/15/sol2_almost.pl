main(A) :-
    write(A), nl,
    main.
main:-
    read_file('/dev/stdin', Map, Dirs, RRowI, RColI),
    write([RRowI, RColI]), nl,
    write([RRowI, RColI, Map]), nl,
    execute_many(Dirs, Map, RRowI, RColI, NewMap, NewRRowI, NewRColI),
    write([NewRRowI, NewRColI]), nl,
    %write(Dirs), nl,
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
gps_sum_line(['['|Rest], RowI, ColI, Sum) :-
    NewColI is ColI + 1,
    gps_sum_line(Rest, RowI, NewColI, SumOfRest),
    Sum is ColI + RowI * 100 + SumOfRest.
gps_sum_line([Item|Rest], RowI, ColI, Sum) :-
    Item \== '[',
    NewColI is ColI + 1,
    gps_sum_line(Rest, RowI, NewColI, Sum).

execute_many([], Map, RRowI, RColI, Map, RRowI, RColI).
execute_many([Dir|Rest], Map, RRowI, RColI, NewMap, NewRRowI, NewRColI) :-
    write(['execute_many', RRowI, RColI, Dir]), nl,
    write_grid(Map),
    execute(Map, RRowI, RColI, Dir, TempMap, TempRRowI, TempRColI),
    !,
    write(['post_execute', TempRRowI, TempRColI]), nl,
    write_grid(TempMap),
    length(Rest, L),
    write([Dir, TempRRowI, TempRColI, L]), nl,
    execute_many(Rest, TempMap, TempRRowI, TempRColI, NewMap, NewRRowI, NewRColI),
    !.


execute(Map, RRowI, RColI, '<', NewMap, RRowI, NewRColI) :-
    executeh(Map, RRowI, RColI, '<', NewMap, NewRColI).
execute(Map, RRowI, RColI, '>', NewMap, RRowI, NewRColI) :-
    executeh(Map, RRowI, RColI, '>', NewMap, NewRColI).
execute(Map, RRowI, RColI, '^', NewMap, NewRRowI, RColI) :-
    push_up(Map, RRowI, NewMap, NewRRowI).
execute(Map, RRowI, RColI, 'v', NewMap, NewRRowI, RColI) :-
    push_down(Map, RRowI, NewMap, MoveAmount),
    NewRRowI is RRowI + MoveAmount.

push_up(Map, RRowI, NewMap, NewRRowI) :-
    reverse(Map, RMap),
    length(Map, L),
    RRRowI is L - RRowI + 1,
    push_down(RMap, RRRowI, RNewMap, MoveAmount),
    NewRRowI is RRowI - MoveAmount,
    reverse(RNewMap, NewMap).

write_grid([H|Map]) :-
    write(H), nl,
    write_grid(Map).
write_grid([]).

push_down([Row|Map], 1, [NewRow|NewMap], MoveAmount) :-
    write(['push_down_mask row', Row, NewRow]), nl,
    robot_row_to_mask(Row, NewRow, Mask),
    write(['push_down_mask mask', Mask]), nl,
    push_down_mask(Map, Mask, NewMap),
    write(['push_down_mask new_map', NewMap]), nl,
    MoveAmount is 1,
    !.
push_down(Map, 1, Map, 0).
push_down([Row|Map], RRowI, [Row|NewMap], MoveAmount) :-
    RRowI \== 1,
    NextRRowI is RRowI - 1,
    push_down(Map, NextRRowI, NewMap, MoveAmount).

push_down_mask([Row|Map], Mask, [NewRow|NewMap]) :-
    write(['push_down_mask', Row, Mask]), nl,
    row_to_mask(Row, Mask, NewRow, NewMask),
    write(['pushed_down_mask', NewRow, NewMask]), nl,
    push_down_mask(Map, NewMask, NewMap).
push_down_mask([], _, []).


robot_row_to_mask(['@'|RRest], ['.'|NewRow], ['@'|NewMask]) :-
    robot_row_to_mask(RRest, NewRow, NewMask),
    !.
robot_row_to_mask([Sym|RRest], [Sym|NewRow], ['.'|NewMask]) :-
    Sym \== '@',
    robot_row_to_mask(RRest, NewRow, NewMask),
    !.
robot_row_to_mask([], [], []).

row_to_mask(['.', '.'|RRest], ['[', ']'|MRest], ['[', ']'|NewRow], ['.', '.'|NewMask]) :-
    !,
    row_to_mask(RRest, MRest, NewRow, NewMask).
row_to_mask(['.'|RRest], ['@'|MRest], ['@'|NewRow], ['.'|NewMask]) :-
    !,
    row_to_mask(RRest, MRest, NewRow, NewMask).
row_to_mask([Sym|RRest], ['.'|MRest], [Sym|NewRow], ['.'|NewMask]) :-
    !,
    row_to_mask(RRest, MRest, NewRow, NewMask).
row_to_mask(['#'|_RRest], [Sym|_MRest], _, _) :-
    Sym \== '.',
    !,
    write(['row_to_mask hash case']), nl,
    fail.
row_to_mask(['[', ']'|RRest], [S1, S2|MRest], [S1, S2|NewRow], ['[', ']'|NewMask]) :-
    !,
    row_to_mask(RRest, MRest, NewRow, NewMask).
row_to_mask([], [], [], []).
row_to_mask(Rest, MRest, NewRow, NewMask) :-
    write(['row_to_mask fail',Rest, MRest, NewRow, NewMask]), nl,
    fail.


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
            Sym == '[' ->
            NewRobotRow = [Sym|Rest],
            %write(['O', Sym, Buffer, RobotRow]), nl,
            push_left(Buffer, RobotRow, Rest, MoveAmount)
        ;
            Sym == ']' ->
            NewRobotRow = [Sym|Rest],
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
                Buffer == ['.'],
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
        Chars = ['@', '.'| Rest],
        RRowI is RowI,
        RColI is ColI,
        get_char(Stream, Next),
        read_map_line(Stream, Next, Rest, RRowI, RowI, RColI, ColI + 2)
    ;   Char == 'O' ->
        Chars = ['[', ']'| Rest],
        get_char(Stream, Next),
        read_map_line(Stream, Next, Rest, RRowI, RowI, RColI, ColI + 2)
    ;   Chars = [Char, Char| Rest],
        get_char(Stream, Next),
        read_map_line(Stream, Next, Rest, RRowI, RowI, RColI, ColI + 2)
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
