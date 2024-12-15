(
while true; do
	clear
	date
	(time ./run.sh "$@") | tee outtest &
	pid="$!"
	trap 'kill $pid' exit
	inotifywait -e modify -e move_self -q run.sh "$@" || break
	echo kill "$pid"
	kill "$pid"
	sleep 0.5
done
wait
)
