dfs() {
	# recurse prefix_equation remaining_numbers
	#echo recurse "$@" >&2
	local target="$1"
	shift
	local first="$1"
	shift
	local maxdepth="${#@}"
	# Always the full list of numbers
	local -a rest
	rest=("$@")
	# List of ops we picked
	local -a nextops
	nextops=('+')
	# List of partial application values from ops in ops
	# eg. nextops=('*' '||')
	#     intermediates=( $first $(($first + $second)) $(( ($first + $second) * $third)) )
	local -a intermediates
	intermediates=( $first )
	local depth=0
	while true; do
		#echo "loop depth='$depth' max='$maxdepth' nextops='${nextops[*]}' intermediates='${intermediates[*]}'"
		# Get next action, either:
		#       * Descend, adding a + to next level, or
		#       * If at bottom, test if equal to target and:
		#       	* Return, or
		#       	* Ascend, incrementing upper op (looping up)
		if [[ $depth -lt $maxdepth && ${intermediates[$depth]} -le $target ]]; then
			op="${nextops[$depth]}"
			prevnum="${intermediates[$depth]}"
			nextnum="${rest[$depth]}"
			depth=$((depth + 1))
			nextops+=( '+' )
			if [[ $op = "||" ]]; then
				nextint="$prevnum$nextnum"
			else
				#echo "next is $prevnum $op $nextnum"
			       	#echo "	= $(( $prevnum $op $nextnum ))"
				nextint=$(( $prevnum $op $nextnum ))
			fi
			intermediates+=($nextint)
		elif [[ $depth = $maxdepth && ${intermediates[$depth]} = $target ]]; then
			echo "found $target"
			return 0
		else
			while true; do
				#echo "up depth='$depth' max='$maxdepth' nextops='${nextops[*]}' intermediates='${intermediates[*]}'"
				local next
				unset intermediates[$depth]
				unset nextops[$depth]
				depth=$((depth - 1))
				op="${nextops[$depth]}"
				case "$op" in
					"+")
						next="*"
						;;
					"*")
						next="||"
						;;
					"||")
						next=""
						;;
					*)
						echo "Bad next op" >&2
						exit 1
				esac
				if [[ -n $next ]]; then
					nextops[$depth]="$next"
					break
				else
					unset nextops[$depth]
				fi
				if [[ $depth -le 0 ]]; then
					return 1
				fi
			done
		fi
	done
}
while read target Js; do
	target=${target%:}
	declare -a J
	J=( $Js )
	echo "target=$target vals=${J[*]}"
	if dfs "$target" "${J[@]}"; then
		total=$((total + target))
	fi
	echo
done
echo "$total"
