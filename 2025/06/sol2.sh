#!/bin/bash
input="$1"
(
	width=$(head -n 1 "$input" | tr -d '\n' | wc -c)
	echo width=$width
	getbits() {
		grep -o . "$input" | grep -n ^ | grep -v ' $' | tr ':' ' '
	}
getbits | grep \ [0-9] | sed 's/\(.*\) \(.*\)/nums[$(((\1-1)%$width))]="${nums[$(((\1-1)%$width))]}\2"/'
	(
		echo width=$width
		echo s=$((width-1))
		echo op=+
		getbits | grep -v \ [0-9]
		echo "$((width + 2)) _"
	) | \
		sed 's/\(.*\) \(.*\)/tot=0;[ "$op" = "*" ] \&\& tot=1;echo tot=$tot;echo "for((i=$((s%$width));i<$(((\1-2)%$width?(\1-2)%$width:$width));i++)){ tot=\\\$((tot $op \\\${nums[\\\$((\\\$i%$width))]})); } ;echo \\\$tot";op=\2;s=$((\1-1))/' | tee sol2_inter1.sh | bash
) | tee sol2_inter2.sh | bash | paste -sd+ | bc
