-module(sol1).

-export([main/1]).

main(Args) ->
	try
		io:format("~p", [Args]),
		{ok, Contents} = file:read_file(atom_to_list(hd(Args))),
		Blocks = binary:split(Contents, <<"\n\n">>, [global]),
		Prizes = lists:map(fun solve_block/1, Blocks),
		io:format("~p~n", [lists:sum(Prizes)])
	catch X:Y:S ->
		io:format("~p", [{X,Y,S}])
	after
		init:stop()
	end.

solve_block(Block) ->
	Input = {{AX, AY}, {BX, BY}, { PX, PY}} = parse_block(Block),
	% Need n * A + m * B = Prize
	% AX * n + BX * m = PX
	% AY * n + BY * m = PY
	% n = (PX - BX * m) / AX
	% AY * ((PX - BX * m) / AX) + BY * m = PY
	% AY * -BX / AX * m + BY * m = PY - AY * PX / AX
	% m = (PY - AY * PX / AX) / (AY * -BX / AX + BY)
	% n = (PX - BX * m) / AX
	M = (PY - AY * PX / AX) / (AY * -BX / AX + BY),
	N = (PX - BX * M) / AX,
	case abs(M-round(M)) < 0.000001 andalso abs(N-round(N)) < 0.000001 of
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
