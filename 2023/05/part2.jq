#!/usr/bin/jq -CRscf
. as $in|[
	split("\n\n")[0]|
	split(" ")|
	del(.[0])[]|
	tonumber
]|
[recurse(.[2:];length>1)[0:2]]|
[.[]|{"s": .[0], "e": (.[0] + .[1])}] as $ns|
debug|
$in|
[
	split("\n\n")|
	del(.[0])[]|
	[
		split("\n")|
		del(.[0])[]|
		[split(" ")[]|tonumber]|
		select(length>0)|
		{"s": .[1], "e": (.[1] + .[2]), "o": (.[0] - .[1])}
	]
]|
["maps", .]|debug|.[1]|
reduce .[] as $map (
	$ns ;
		["input", ., $map]|debug|.[1]|
		reduce $map[] as $splitter (
			{"inbits": ., "outbits": []};
			.|
			.outbits as $lastout|
			["inner input", ., $splitter]|debug|.[1]|
			[
				.inbits[]|
				["map loop", ., $splitter]|debug|.[1]|
				if .e > $splitter.s and .s < $splitter.e then
					{
						"inbits": [
							if .s < $splitter.s then {"s": .s, "e": $splitter.s} else null end,
							if .e > $splitter.e then {"s": $splitter.e, "e": .e} else null end
						|debug|
						select(.)],
						"outbits": [{"s": ([.s, $splitter.s]|max + $splitter.o), "e": ([.e, $splitter.e]|min + $splitter.o)}]
					}
				else
					{ "inbits": [.], "outbits": [] }
				end|
				["map loop out", .]|debug|.[1]|
				.
			]|
			["map out", .]|debug|.[1]|
			{"inbits": [.[]|.inbits[]], "outbits": [$lastout[], (.[]|.outbits[])]}
		)|
		["inner reduce out", .]|debug|.[1]|
		[.inbits[], .outbits[]]|
		["inner reduce out", .]|debug|.[1]
)|
debug|
[.[]|.s]|min
