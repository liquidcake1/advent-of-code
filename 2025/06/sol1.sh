#!/bin/bash
input="$1"
(
	echo width=$(wc -l < "$input")
	getbits() {
		grep -ow '[^ ]*' "$input" | grep -n .
	}
	getbits | grep :[0-9] | sed 's/\(.*\):\(.*\)/sums[$((\1%$width))]=$((sums[$((\1%$width))] + \2));muls[$((\1%$width))]=$(((muls[$((\1%$width))] ? muls[$((\1%$width))] : 1)*\2))/'
	getbits | grep -v :[0-9] | sed 's/\(.*\):\(.*\)/[ "\2" = "+" ] \&\& echo "${sums[$((\1%$width))]}" || echo "${muls[$((\1%$width))]}"/'
) | bash | paste -sd+ | bc
