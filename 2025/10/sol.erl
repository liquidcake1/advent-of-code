-module(sol).

-export([solve/1]).

-compile([export_all]).

solve(Filename) ->
	Self = self(),
	spawn(fun () -> timer:sleep(1000), io:format("~p~n", [erlang:process_info(Self, current_stacktrace)]) end),
	{ok, Raw} = file:read_file(Filename),
	Parsed = parse(Raw),
	io:format("~p~n", [solve_part1(Parsed)]),
	io:format("~p~n", [solve_part2(Parsed)]),
	init:stop().

solve_part1(Inputs) ->
	lists:sum(lists:map(fun solve_part1_input/1, Inputs)).

solve_part1_input({Indicators, Wirings, _Joltage}) ->
	Pushings = gen_pushings(Wirings),
	ValidPushings = [Pushing || Pushing <- Pushings, all_off(push_buttons(Pushing, Indicators))],
	lists:min([length(Pushing) || Pushing <- ValidPushings]).

gen_pushings(Wirings) ->
	[Subset || Subset <- gen_subsets(Wirings)].

gen_subsets([]) -> [[]];
gen_subsets([Head|Tail]) ->
       Children = gen_subsets(Tail),
       Children ++ [[Head] ++ Pushing || Pushing <- Children].


push_buttons([Pushing|Rest], Indicators) ->
	push_buttons(Rest, flip_indicators(Pushing, Indicators));
push_buttons([], Indicators) -> Indicators.

flip_indicators([Idx|Rest], Indicators) ->
	flip_indicators(Rest, erlang:setelement(Idx, Indicators, not element(Idx, Indicators)));
flip_indicators([], Indicators) -> Indicators.

all_off(Indicators) -> not lists:any(fun (X) -> X end, tuple_to_list(Indicators)).




solve_part2(Inputs) ->
	lists:sum(lists:map(fun solve_part2_input/1, Inputs)).

-record(state, {
	  best = undefined
	 }).

products(I, N) when I > N -> 1;
products(N, N) -> N;
products(I, N) when I < N -> I * products(I + 1, N).

ncr(N, R) ->
	% N!/R!/(N-R)!
	products(R + 1, N) div products(1, N - R).

pcr(N, R) -> ncr(N + R - 1, R).

solve_part2_input({_Indicators, Wirings, Joltage}) ->
	%io:format("Combs: ~p ~p~n", [lists:min([count_combs(I, Wirings, Joltage) || I <- lists:seq(1, tuple_size(Joltage))]), Joltage]),
	io:format("Combs after elim: ~p~n", [count_combs_after_elim(Wirings, Joltage)]),
	%State = #state{},
	%solve_part2_idx(1, Wirings, Joltage, State).
	Matrix = make_matrix(Wirings, Joltage),
	%Reduced = lists:reverse(lists:sort(row_reduce(1, Matrix, length(Wirings)))),
	Reduced = row_reduce(1, Matrix, length(Wirings)),
	WithNoZeros = lists:filter(fun (L) -> lists:any(fun (X) -> X /= 0 end, L) end, Reduced),
	io:format("Reduced: ~p~n", [WithNoZeros]),
	FirstNonZeros = lists:map(fun (L) -> {Start, _Rest} = lists:splitwith(fun (X) -> X==0 end, L), length(Start) + 1 end, WithNoZeros),
	io:format("Non-Free Vars: ~p~n", [lists:sort(FirstNonZeros)]),
	FreeVars = lists:seq(1, length(Wirings)) -- FirstNonZeros,
	io:format("Free Vars: ~w~n", [FreeVars]),
	BiggestJoltage = lists:max(tuple_to_list(Joltage)),
	{Ans, Best} = check(FreeVars, BiggestJoltage, [], WithNoZeros, BiggestJoltage * 1000, none),
	io:format("Best sum: ~p with ~p~n", [Ans, Best]),
	Ans.

check([], _, CandidateVals, Matrix, Best, BestPushes) ->
   	Vars = lists:foldl(
	  fun ({N, Val}, Acc) -> setelement(N, Acc, Val) end,
	  erlang:make_tuple(length(hd(Matrix)), none),
	  CandidateVals
	),
	VarsWithConst = setelement(length(hd(Matrix)), Vars, -1),
	{FinalVars, Valid} =
	lists:foldl(
	  fun (Row, {PushCounts, Valid}) ->
			  % Acc is tuple of vals
			  %io:format("Row: ~p~n", [Row]),
			  {Zeros, [Mul|Rest]} = lists:splitwith(fun (X) -> X==0 end, Row),
			  RowWithoutCol = Zeros ++ [0|Rest],
			  %io:format("RowWithoutCol: ~p~n", [RowWithoutCol]),
			  %io:format("PushCounts: ~p~n", [PushCounts]),
			  Sum = lists:sum([ case X /= 0 of true -> X * Y; false -> 0 end || {X, Y} <- lists:zip(RowWithoutCol, tuple_to_list(PushCounts))]),
			  true = Mul > 0,
			  %io:format("Sum: ~p~n", [Sum]),
			  NewValid = Valid andalso Sum rem Mul == 0 andalso Sum =< 0,
			  %io:format("NewValid: ~p~n", [NewValid]),
			  %io:format("Mul: ~p~n", [Mul]),
			  NewRow = setelement(length(Zeros) + 1, PushCounts, -Sum div Mul),
			  %io:format("NewRow: ~p~n", [NewRow]),
			  {NewRow, NewValid}
	  end,
	  {VarsWithConst, true},
	  Matrix
	 ),
	TotalPushes = lists:sum(tuple_to_list(FinalVars)) + 1,
	NewBest =
	case Valid andalso TotalPushes < Best of
		true -> {TotalPushes, FinalVars};
		false -> {Best, BestPushes}
	end,
	NewBest;
check([FreeVar|Rest], BiggestJoltage, CandidateVals, Matrix, Best, BestPushes) ->
	lists:foldl(
	  fun (Val, {AccBest, AccPushes}) ->
			  check(Rest, BiggestJoltage, [{FreeVar, Val}|CandidateVals], Matrix, AccBest, AccPushes)
	  end,
	  {Best, BestPushes},
	  lists:seq(0, BiggestJoltage)
	 ).



count_combs(I, Wirings, Joltage) ->
	N = element(I, Joltage),
	R = length(lists:filter(fun (Wiring) -> lists:member(I, Wiring) end, Wirings)),
	pcr(N, R).


count_combs_after_elim(Wirings, Joltage) ->
	Free = length(Wirings) - tuple_size(Joltage),
	Vals = lists:max(tuple_to_list(Joltage)),
	{Vals, Free, math:pow(Vals, Free)}.

solve_part2_idx(Idx, Wirings, _Joltage, _State = #state{}) ->
	TrimmedWirings = [lists:filter(fun (X) -> X >= Idx end, Wiring) || Wiring <- Wirings],
	FilteredWirings = lists:filter(fun (X) -> X /= [] end, TrimmedWirings),
	io:format("Filtered Wirings: ~p~n", [FilteredWirings]),
	%TrimmedJoltage = erlang:delete_element(Id
	0.

make_matrix(Wirings, Joltage) ->
	% Wiring1      0   Jo
	% Wiring2      0   lt
	% Wiring3      0   ag
	% Wiring4      0   e
	% ...              ...
	% -1 -1 ... -1 Sum ???
	%BaseCol = setelement(tuple_size(Joltage) + 1, erlang:make_tuple(tuple_size(Joltage) + 1, 0), 1),
	BaseCol = erlang:make_tuple(tuple_size(Joltage), 0),
	io:format("~p~n", [BaseCol]),
	WiresPlusZero = [ expand_wiring(Wiring, BaseCol) || Wiring <- Wirings ],
	io:format("~p~n", [WiresPlusZero]),
	%SumCol = lists:duplicate(tuple_size(Joltage), 0) ++ [-1],
	%JoltageCol = tuple_to_list(Joltage) ++ [0],
	JoltageCol = tuple_to_list(Joltage),
	%MainCols = WiresPlusZero ++ [SumCol, JoltageCol],
	MainCols = WiresPlusZero ++ [JoltageCol],
	io:format("~p~n", [MainCols]),
	%InitAcc = lists:duplicate(tuple_size(Joltage) + 1, []),
	InitAcc = lists:duplicate(tuple_size(Joltage), []),
	MainRows = transpose(MainCols, InitAcc),
	io:format("~p~n", [MainRows]),
	MainRows.


% 0,0,0,0,1,1,3
% 0,1,0,0,0,1,5
% 0,0,1,1,1,0,4
% 1,1,0,1,0,0,7
% 
% 0,0,0,0,1,1,3
% 0,1,0,0,0,1,5
% 0,0,1,1,1,0,4
% 1,0,0,1,0,-1,2
% 
% 0,0,0,0,1,1,3
% 0,1,0,0,0,1,5
% 0,0,1,1,1,0,4
% 1,0,0,1,0,-1,2
% 
% 0,0,0,0,1,1,3
% 0,1,0,0,0,1,5
% 0,0,1,1,1,0,4
% 1,0,-1,0,-1,-1,-2
% 
% 1,0,-1,0,-1,-1,-2
% 0,1,0,0,0,1,5
% 0,0,1,1,1,0,4
% 0,0,0,0,1,1,3

% Build accumulator from the right of rows
transpose([], Acc) -> [ lists:reverse(A) || A <- Acc ];
transpose([Firsts|Matrix], Acc) ->
	NewAcc = [ [First | A] || {First, A} <- lists:zip(Firsts, Acc) ],
	transpose(Matrix, NewAcc).

expand_wiring([Idx|Rest], Acc) ->
	expand_wiring(Rest, setelement(Idx, Acc, 1));
expand_wiring([], Acc) -> tuple_to_list(Acc).

row_mult(Factor, Row) -> [ Factor * X || X <- Row ].
row_add(Row1, Row2) -> [ X + Y || {X, Y} <- lists:zip(Row1, Row2) ].

row_reduce(ColIdx, Matrix, ColCount) when ColIdx > ColCount ->
	Matrix;
row_reduce(ColIdx, Matrix, ColCount) ->
	io:format("Matrix: ~p~nColIdx: ~p~nColCount: ~p~n", [Matrix, ColIdx, ColCount]),
	case rows_with_nonzero(1, ColIdx, Matrix, -1, none) of
		none ->
			row_reduce(ColIdx + 1, Matrix, ColCount);
		RowIdx when is_integer(RowIdx) ->
			NewMatrix = reduce_with(ColIdx, RowIdx, Matrix),
			row_reduce(ColIdx + 1, NewMatrix, ColCount)
	end.

rows_with_nonzero(_, _, [], _, Best) -> Best;
rows_with_nonzero(Idx, ColIdx, [Head|Tail], BestZeroCount, Best) ->
	case lists:nth(ColIdx, Head) of
		0 -> rows_with_nonzero(Idx + 1, ColIdx, Tail, BestZeroCount, Best);
		_ -> {Zeros, _} = lists:splitwith(fun (X) -> X==0 end, Head),
			 case length(Zeros) == ColIdx - 1 of
				 true -> Idx;
				 false -> rows_with_nonzero(Idx + 1, ColIdx, Tail, BestZeroCount, Best)
			 end
	end.

reduce_with(ColIdx, RowIdxToReduceWith, Matrix) ->
	{RowsBefore, [RowToReduceWith|RowsAfter]} = lists:split(RowIdxToReduceWith - 1, Matrix),
	Negated =
	case lists:nth(ColIdx, RowToReduceWith) < 0 of
		true -> row_mult(-1, RowToReduceWith);
		false -> RowToReduceWith
	end,
	reduce_with_row(ColIdx, Negated, RowsBefore) ++ [Negated|reduce_with_row(ColIdx, Negated, RowsAfter)].

reduce_with_row(_ColIdx, _RowToReduceWith, []) -> [];
reduce_with_row(ColIdx, RowToReduceWith, [Row|Rest]) ->
	Val = lists:nth(ColIdx, Row),
	NewRow = 
	case Val of
		0 ->
			Row;
		_ ->
			RedVal = lists:nth(ColIdx, RowToReduceWith),
			%io:format("Reducing using Val=~w, RedVal=~p~nRowToReduceWith: ~w~nRow: ~p~n", [Val, RedVal, RowToReduceWith, Row]),
			Lcm = lcm(Val, RedVal),
			row_add(row_mult(Lcm div Val, Row), row_mult(-Lcm div RedVal, RowToReduceWith))
	end,
	[
	 NewRow
	 |reduce_with_row(ColIdx, RowToReduceWith, Rest)
	].


gcd(A,B) when B < 0 -> gcd(A, -B);
gcd(A,B) when A < 0 -> gcd(-A, B);
gcd(A,B) when A == 0; B == 0 -> 0;
gcd(A,B) when A == B -> A;
gcd(A,B) when A > B -> gcd(A-B, B);
gcd(A,B) -> gcd(A, B-A).

lcm(A,B) -> (A*B) div gcd(A, B).

% 0  1 10
% 1  1 20
% 1  0 30

% 0  1 10
% 1  1 20
% 0 -1 10
%
% 0  1 10
% 1  0 10
% 1  0  0

% 1 1 1 1 1
% 1 0 1 1 1
% 1 0 0 1 1

% 1 1 1 1 1
% 1 0 1 1 1
% 1 0 0 1 1

% 1 1 1 1 1
% 1 0 1 1 1
% 1 0 0 1 1

% PARSING JUNK

parse(Raw) ->
	Lines = binary:split(Raw, <<"\n">>, [global, trim]),
	[parse_line(Line) || Line <- Lines].

parse_line(Line) ->
	[IndicatorsRaw|Words] = binary:split(Line, <<" ">>, [global]),
	Indicators = parse_indicators(IndicatorsRaw),
	{Wirings, Joltage} = parse_rest(Words, []),
	{Indicators, Wirings, Joltage}.

get_middle(Bin) ->
	binary:part(Bin, 1, erlang:byte_size(Bin) - 2).

split_wrapped_bin_to_int(Bin) ->
	[binary_to_integer(I) || I <- binary:split(get_middle(Bin), <<",">>, [global])].
	

parse_rest([JoltageRaw], ParsedWirings) ->
	{
	 lists:reverse(ParsedWirings),
	 list_to_tuple(split_wrapped_bin_to_int(JoltageRaw))
	};
parse_rest([RawWiring|Rest], Acc) ->
	parse_rest(Rest, [[I+1 || I <- split_wrapped_bin_to_int(RawWiring)]|Acc]).

parse_indicators(IndicatorsRaw) ->
	list_to_tuple([Bit =:= $# || <<Bit>> <= get_middle(IndicatorsRaw), Bit /= $] ]).
