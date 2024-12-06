# BROKEN
def while(cond; update): def _while: if cond then (update | _while) else . end; _while;
def whileret(cond; update; return): def _while: if cond then (update | _while) else return end; _while;
def diri: (.[0] + 1 + (.[1]+1)*3-1)/2;
def debugg: .;
def rotate: [.[1], -.[0]];
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
($grid | length), $coords]| debugg|
$grid | length as $len|
([$grid[] | [.[]|0]] | .[$coords[0]][$coords[1]] |= 1) as $visited |
[$grid[] | [.[]|[0,0,0,0]]] as $visited2 |
0 as $count |
[$coords, [-1, 0], [], 0, $visited]|
while(
	.[0]|.[0] > -1 and .[0] < $len and .[1] > -1 and .[1] < $len
;
	. as [$coord, $dir, $count, $steps, $visited] |
	#([$steps, ($count|length)]|debug) |
	[$coord[0] + $dir[0], $coord[1] + $dir[1]] |
	. as $newcoord |
	if $grid[.[0]][.[1]] == "#" then
		[$coord, ($dir|rotate), $count, $steps, $visited]
	elif $visited[.[0]][.[1]] == 0 then
		($grid|debugg) as $fake|
		($newcoord as [$row,$col]|$grid|.[$row][$col] |= "#") as $newgrid |
		($newcoord|debugg)|
		#$grid as $newgrid |
		($dir | rotate) as $newdir | # Rotate
		[$coord, $newdir, 0, $visited2] |
		([$coord, $newdir]|debugg) as $t|
		whileret(
			. as [$coord, $dir, $count, $visited2]|
			(["check",$coord,$dir,($dir|diri)]|debugg)|
			$coord|.[0] > -1 and .[0] < $len and .[1] > -1 and .[1] < $len and
			$visited2[.[0]][.[1]][$dir|diri] == 0|
			.
		;
			. as [$coord, $dir, $count, $visited2] |
			([$dir,($dir|diri)]|debugg)|
			($visited2|.[$coord[0]][$coord[1]][$dir|diri] |= 1) as $newvisited2 |
			$coord |
			[.[0] + $dir[0],.[1] + $dir[1]] as $newcoord |
			if $newgrid[$newcoord[0]][$newcoord[1]] == "#" then
				[$coord, ($dir|rotate), $count, $newvisited2]
			else
				[$newcoord, $dir, $count + 1, $newvisited2]
			end|
			.
		;
			. as [$coord, $dir, $count, $visited2] |
			.[0]|.[0] > -1 and .[0] < $len and .[1] > -1 and .[1] < $len |
			. as $ans |
			if . then [$steps, $newcoord, $count]|debug else . end|
			$ans
		) |
		(if . then [$newcoord,$count[]] else $count end) as $newcount |
		($visited|.[$newcoord[0]][$newcoord[1]] |= 1) as $newvisited |
		[$newcoord, $dir, $newcount, $steps + 1, $newvisited]
	else
		[$newcoord, $dir, $count, $steps, $visited]
	end
) | .[2] | length
