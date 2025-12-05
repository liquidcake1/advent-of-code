#!/bin/bash
set -o pipefail -o nounset
input_filename="$1"
shift
rm -rf tmp
mkdir tmp
curmax=0
count=0
prev=0
while IFS=- read MIN MAX; do
	#echo "  $MIN $MAX (prev=$prev curmax=$curmax)"
	if [ -z "$MIN" ]; then
		continue
	elif [ -z "$MAX" ]; then
		if [ "$MIN" -le "$curmax" ]; then
			#echo "GOOD: $MIN"
			count=$((count+1))
		fi
		prev="$MIN"
	else
		if [ "$MIN" -eq "$prev" ]; then
			#echo "EDGE: $prev"
			count=$((count+1))
		fi
		if [ "$MAX" -ge "$curmax" ]; then
			curmax=$MAX
		fi
	fi
done < <(sort -n "$input_filename")
echo $count
