set -o errexit
for i in tests/*.txt; do
	head -n -2 "$i" > /tmp/input
	output="$(./run.sh "$1" /tmp/input | tail -n 4 | head -n 2)"
	diff -u --label "$i" <(tail -n 2 "$i") --label out <(echo "$output" | tr -d ' ')
done
