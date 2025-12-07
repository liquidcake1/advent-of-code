#!/bin/bash
input="$1"
(
	native_width=$(head -n 1 "$input" | tr -d '\n' | wc -c)
	expanded_width=$(echo "$native_width" | sed '{s/./0/g;s/^/1/}')
	width=$expanded_width
	width_width=$(echo "$expanded_width" | tail -c +3 | wc -c)
	concat_sed_cmds="$(yes 's/([0-9]+) ([0-9]+)\n\1 ([0-9]+)/\1 \2\3/g;' | head -n "$(wc -l < "$input")" | tr -d '\n' )"
	sum_sed_cmds="$(yes 's/([+*]) ([0-9]+) ([0-9]+)/\1 \2 \1 \3/g;' | head -n "$(wc -l < "$input")" | tr -d '\n' )"
	< "$input" awk "{printf \"%-${expanded_width}s\\n\", \$0}" | grep -o . | grep -n ^ | grep -v ' $' | tr ':' ' ' | sed -E 's/^(.*) (.*)$/\1 \1 \2/;s/.(.{'"$width_width"'})( .* .*)/\1\2/;s/^0*//' | sort -k1n -k2n | cut -d' ' -f1,3 | sed -zE "$concat_sed_cmds" | sed 's/\(.*\) //' | tr '\n' ' ' | sed -E 's/([0-9]+) ([*+])/+ \1 \2/g;'"$sum_sed_cmds"'s/^/0 /;s/ $/\n/'
) | bc
