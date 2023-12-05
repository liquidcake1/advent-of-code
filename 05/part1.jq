[
	. as $in|
	split("\n\n")[0]|
	split(" ")|del(.[0])[]|
	tonumber as $n|

	$in|
	[
		split("\n\n")|
		del(.[0])[]|
		[
			split("\n")|
			del(.[0])[]|
			[split(" ")[]|tonumber]
		]
	] as $maps|$maps|
	reduce .[] as $map (
		$n ;
		debug|
		. as $m|[
			$map[]|
			debug|
			if $m >= .[1] and $m < .[1] + .[2] then
				$m - .[1] + .[0]
			else
				null
			end
		]|
		debug|
		[(.[]|select(.)),$m]|
		debug|
		.[0]
	)|
	debug
]|
min
