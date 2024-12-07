recurse() {
	# recurse prefix_equation remaining_numbers
	#echo recurse "$@" >&2
	local target="$1"
	shift
	#local path="$1"
	#shift
	local pre="$1"
	shift
	local next="$1"
	shift
	if [ -n "$next" ]; then
		for op in '+' '*'; do
			newans="$(($pre "$op" $next))"
			if [[ $newans -le $target ]]; then
				#recurse "$target" "$path $op $next" "$newans" "$@" || return 1
				recurse "$target" "$newans" "$@" || return 1
			#else echo "$newans > $target; bailing on $path $*" >&2
			fi
		done
		newans="$pre$next"
		if [[ $newans -le $target ]]; then
			#recurse "$target" "$path || $next" "$newans" "$@" || return 1
			recurse "$target" "$newans" "$@" || return 1
		#else echo "$newans > $target; bailing on $path $*" >&2
		fi
	else
		if [[ $newans -eq $target ]]; then
			#echo "$pre" "$path"
			echo "$pre"
			return 1
		fi
	fi
}
while read target Js; do
	target=${target%:}
	declare -a J
	J=( $Js )
	echo "${J[@]}"
	while read ans path; do
		if [ "$ans" = "$target" ]; then
			echo "$ans" "$path"
			total=$((total + ans))
			break
		fi
	#done < <(recurse "$target" "path ${J[0]}" "${J[@]}")
	done < <(recurse "$target" "${J[@]}")
	echo
done
echo "$total"
