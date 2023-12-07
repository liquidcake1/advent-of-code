tr AKQJT EDC1A > tmp
regexes=(
	'(?=\S*([^1 ]))(\1|1){5}|1{5}' # 5
	'(?=\S*([^1 ])\S*\1)(.*(\1|1)){4}|(.*1){3}' # 4
	'(?=\S*([^1 ])\S*\1)(?=\S*(?!\1)(\S)\S*\2)(1|\1|\2){5}' # FH
	'(?=\S*([^1 ])\S*\1)(.*(\1|1)){3}|(.*1){2}' # 3
	'(?=\S*([^1 ])\S*\1)(?=\S*(?!\1)(\S)\S*\2)(.*(J|\1|\2)){4}' # 2P
	'(.).*\1|1' # P
	''
)
rm sorted
i=1
for regex in "${regexes[@]}"; do
	regex="^.*(?:$regex).* "
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
