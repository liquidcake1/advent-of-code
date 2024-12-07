recurse() {
	# recurse prefix_equation remaining_numbers
	#echo recurse "$@" >&2
	local path="$1"
	shift
	local pre="$1"
	shift
	local next="$1"
	shift
	if [ -n "$next" ]; then
		for op in '+' '*'; do
			recurse "path $pre $op $next" "$(($pre "$op" $next))" "$@"
		done
	else
		echo "$pre" "$path"
	fi
}
while read I Js; do
	I=${I%:}
	declare -a J
	J=( $Js )
	echo "${J[@]}"
	while read ans path; do
		if [ "$ans" = "$I" ]; then
			echo "$ans" "$path"
			total=$((total + ans))
			break
		fi
	done < <(recurse "path" "${J[@]}")
	echo
done
echo "$total"
