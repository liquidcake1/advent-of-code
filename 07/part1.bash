tr AKQJT EDCBA > tmp
regexes=(
	'(.)\1\1\1\1'
	'(.)(.*\1){3}'
	'(?=\S*(\S)\S*(?!\1)(\S))(\1|\2){5}'
	'(.)(.*\1){2}'
	'(?=\S*(\S)(?=\S*\1)\S*(\S)(?=\S*\2))(.*(\1|\2)){4}'
	'(.).*\1'
	''
)
rm sorted
i=1
for regex in "${regexes[@]}"; do
	regex="^.*$regex.* "
	echo "$regex:"
	grep -P "$regex" tmp | sort -r | tee -a sorted | tee rank$i
	i=$((i + 1))
	grep -vP "$regex" < tmp > tmp2
	mv tmp2 tmp
	echo
done
tac sorted | grep -n '' | tr ':' ' ' | while read rank hand bid; do
	total=$(( total + rank * bid ))
	echo $total $rank $bid
done
echo $total
