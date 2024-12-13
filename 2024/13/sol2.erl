-module(sol2).

-export([main/1]).

main(Args) ->
	try
		io:format("~p", [Args]),
		{ok, Contents} = file:read_file(atom_to_list(hd(Args))),
		Blocks = binary:split(Contents, <<"\n\n">>, [global]),
		io:format("Part 1: ~p~n", [lists:sum(lists:map(fun (Block) -> solve_block(Block, 0) end, Blocks))]),
		io:format("Part 2: ~p~n", [lists:sum(lists:map(fun (Block) -> solve_block(Block, 10000000000000) end, Blocks))]),
		ok
	catch X:Y:S ->
		io:format("~p", [{X,Y,S}])
	after
		init:stop()
	end.

solve_block(Block, Offset) ->
	Input = {{AX, AY}, {BX, BY}, {OPX, OPY}} = parse_block(Block),
	{PX, PY} = {OPX + Offset, OPY + Offset},
	% Need n * A + m * B = Prize
	% AX * n + BX * m = PX
	% AY * n + BY * m = PY
	% n = (PX - BX * m) / AX
	% AY * ((PX - BX * m) / AX) + BY * m = PY
	% AY * -BX / AX * m + BY * m = PY - AY * PX / AX
	% m = (PY - AY * PX / AX) / (AY * -BX / AX + BY)
	% n = (PX - BX * m) / AX
	%M = PY * AX / (AY * -BX + BY * AX) - AY * PX / (AX * BY - AY * BX),
	%M = PY / (AY * -BX / AX + BY) - AY * PX / (AX * BY - AY * BX),
	%M = PY * AX / (AY * -BX + BY * AX) - AY * PX / (AX * BY - AY * BX),
	M = (PY * AX * (AX * BY - AY * BX) - AY * PX * (AY * -BX + BY * AX)) / ((AY * -BX + BY * AX) * (AX * BY - AY * BX)),
	N = (PX - BX * M) / AX,
	EndX = round(N) * AX + round(M) * BX,
	EndY = round(N) * AY + round(M) * BY,
	Part2 = case M >= 0 andalso N >= 0 andalso {EndX, EndY} == {PX, PY} of
		true ->
			3 * round(N) + round(M);
		false ->
			0
	end.

parse_block(Block) ->
	[A, B, Prize|_] = binary:split(Block, <<"\n">>, [global]),
	{parse_button(A), parse_button(B), parse_prize(Prize)}.

parse_button(Line) ->
	[<<"Button ", _, ": X+", XBit/binary>>, <<" Y+", YBit/binary>>] = binary:split(Line, <<",">>),
	{binary_to_integer(XBit), binary_to_integer(YBit)}.

parse_prize(Line) ->
	[<<"Prize: X=", XBit/binary>>, <<" Y=", YBit/binary>>] = binary:split(Line, <<",">>),
	{binary_to_integer(XBit), binary_to_integer(YBit)}.
