#!/bin/bash
input="$1"
(
	native_width=$(head -n 1 "$input" | tr -d '\n' | wc -c)
	#expanded_width=$(echo "$native_width" | sed '/^[2-9]\|.[1-9]/{s/./0/g;s/^/1/}')
	expanded_width=$(echo "$native_width" | sed '{s/./0/g;s/^/1/}')
	width=$expanded_width
	width_width=$(echo "$expanded_width" | tail -c +3 | wc -c)
	concat_sed_cmds="$(yes 's/([0-9]+) ([0-9]+)\n\1 ([0-9]+)/\1 \2\3/g;' | head -n "$(wc -l < "$input")" | tr -d '\n' )"
	sum_sed_cmds="$(yes 's/([0-9]+) ([*+])\n([0-9]+) ([0-9]+)/${nums[\1]} \2 \3 \2/g;' | head -n "$(wc -l < "$input")" | tr -d '\n' )"
	getbits() {
		< "$input" awk "{printf \"%-${expanded_width}s\\n\", \$0}" | grep -o . | grep -n ^ | grep -v ' $' | tr ':' ' ' | sed -E 's/^(.*) (.*)$/\1 \1 \2/;s/.(.{'"$width_width"'})( .* .*)/\1\2/;s/^0*//'
	}
	getbits | sort -k1n -k2n | cut -d' ' -f1,3 | sed -zE "$concat_sed_cmds" | sed '/[*+]/d;s/\(.*\) \(.*\)/nums[\1]=\2/'
	echo -n 'echo $(('
	getbits | cut -d' ' -f1,3 | sort -n | uniq -w "$width_width" | sed -zE "$sum_sed_cmds"'s/([0-9]+) ([*+])\n/${nums[\1]} + /g;s/$/0/'
	echo '))'
) | tee sol2_inter2.sh | bash | paste -sd+ | bc
