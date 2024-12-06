def while(cond; update): def _while: if cond then (update | _while) else empty end; _while;
[split("\n") | .[] |
	select(. != "") |
	split("")
] |
. as $grid |
map(to_entries) | to_entries |
.[] |
(
	. as $row |
	(
		.value[] |
		select(.value == "^") | . as $col |
		[$row.key, $col.key]
	)) as $coords |
[
($grid | length), $coords]| debug|
$grid | length as $len|
[$grid[] | [.[]|0]] as $visited |
0 as $count |
[$coords, [-1, 0], $count, $visited]|
while(
	.[0]|.[0] > -1 and .[0] < $len and .[1] > -1 and .[1] < $len
;
	. as $in |
	.[1] as $dir |
	.[0] | . as $coord |
	if $grid[.[0]][.[1]] == "#" then
		[.[0] - $dir[0],.[1] - $dir[1]] |
		[., [$dir[1], -$dir[0]], $in[2], $in[3]]
	else
		if $in[3][.[0]][.[1]] == 0 then $in[2] + 1 else $in[2] end | . as $newcount | debug |
		$coord | [$coord,$in[3][.[0]][.[1]], .] | #debug |
		($in[3] | .[$coord[0]][$coord[1]] |= 1) as $newvisited |
		$coord |
		[.[0] + $dir[0],.[1] + $dir[1]] |
		. as $coord |
		[., $in[1], $newcount, $newvisited]
	end #| debug
)
