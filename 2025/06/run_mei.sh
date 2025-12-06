#!/bin/bash

ps aux | grep 'tail -f vm_output' | grep -v grep | awk '{print $2}' | xargs -r kill
(
	outs=0
	while read type val; do
		echo "$type $val"
		if [ "$type" = "Output:" ] && [ "$val" = "0" ]; then
			((outs++))
			if [ "$outs" -gt 1 ]; then
				echo "done!!"
				break
			fi
		fi
	done < <(tail -n 0 -f vm_output | grep --line-buffered "Sending\|Output")
) &
pid=$!
#trap 'echo Killing; kill $pid' exit TERM PIPE
(
	echo -n '{"Command": {"data": ["input", "2", "lqc", "lqc", "F0F", "!vm halt clear write '
	sed 's/#.*//' "$1" | tr '\n' ' '
	echo '! restart"]}}'
) > vm_input
wait "$pid"
echo "Done."
