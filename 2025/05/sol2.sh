#!/bin/bash
set -o pipefail -o nounset
input_filename="$1"
shift
rm -rf tmp
mkdir tmp
curmaxnoninc=0
curmin=0
count=0
while IFS=- read MIN MAX; do
	#echo "  $MIN $MAX (prev=$prev curmax=$curmax)"
	if [ -z "$MIN" ] || [ -z "$MAX" ]; then
		continue
	else
		if [ "$MIN" -gt "$curmaxnoninc" ]; then
			count=$((count + curmaxnoninc - curmin))
			curmin="$MIN"
			curmaxnoninc=0 # fixed later
		fi
		if [ "$MAX" -ge "$curmaxnoninc" ]; then
			curmaxnoninc=$((MAX + 1))
		fi
	fi
done < <(sort -n "$input_filename")
count=$((count + curmaxnoninc - curmin))
echo $count
