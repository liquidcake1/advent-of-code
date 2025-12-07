#!/bin/bash
input="$1"
(
	native_width=$(head -n 1 "$input" | tr -d '\n' | wc -c)
	#expanded_width=$(echo "$native_width" | sed '/^[2-9]\|.[1-9]/{s/./0/g;s/^/1/}')
	expanded_width=$(echo "$native_width" | sed '{s/./0/g;s/^/1/}')
	width=$expanded_width
	width_width=$(echo "$expanded_width" | tail -c +3 | wc -c)
	getbits() {
		< "$input" awk "{printf \"%-${expanded_width}s\\n\", \$0}" | grep -o . | grep -n ^ | grep -v ' $' | tr ':' ' ' | grep -oE ".{1,$width_width} .*" | sed 's/^0*//'
	}
	sed_cmds="$(yes 's/([0-9]+) ([*+])\n([0-9]+) ([0-9]+)/${nums[\1]} \2 \3 \2/g;' | head -n "$(wc -l < "$input")" | tr -d '\n' )"
	getbits | grep \ [0-9] | sed 's/\(.*\) \(.*\)/nums[\1]="${nums[\1]}\2"/'
	echo -n 'echo $(('
	getbits | sort -n | uniq -w "$width_width" | sed -zE "$sed_cmds"'s/([0-9]+) ([*+])\n/${nums[\1]} + /g;s/$/0/'
	echo '))'
) | tee sol2_inter2.sh | bash | paste -sd+ | bc
