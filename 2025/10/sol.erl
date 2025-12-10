-module(sol).

-export([solve/2]).

solve(Filename, Part) ->
	{ok, Raw} = file:read_file(Filename),
	Parsed = parse(Raw),
	io:format("~p~n", [solve_real(Parsed, Part)]),
	init:stop().

solve_real(Parsed, "1") ->
	solve_part1(Parsed).

solve_part1(Inputs) ->
	lists:sum(lists:map(fun solve_part1_input/1, Inputs)).

solve_part1_input({Indicators, Wirings, _Joltage}) ->
	Pushings = gen_pushings(Wirings),
	io:format("~p~n", [Wirings]),
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
	 split_wrapped_bin_to_int(JoltageRaw)
	};
parse_rest([RawWiring|Rest], Acc) ->
	parse_rest(Rest, [[I+1 || I <- split_wrapped_bin_to_int(RawWiring)]|Acc]).

parse_indicators(IndicatorsRaw) ->
	list_to_tuple([Bit =:= $# || <<Bit>> <= get_middle(IndicatorsRaw), Bit /= $] ]).
