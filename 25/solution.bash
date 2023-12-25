# Find things to disconnect with:
# (echo 'graph {'; cat input25.txt | while read I J; do echo $J | grep -o '[^ ]*' | while read J; do echo $I -- $J; done; done; echo '}') | tr -d : | dot -Tpng -Kneato > graph.png
# Put breaks in breaks.txt
f="$1"
cp "input$f.txt" "processed$f.txt"
while read i j; do
	sed -i "/^\($i\|$j\)/s/ \($i\|$j\)//" "processed$f.txt"
done < "breaks$f.txt"
lines="$(grep -o '[^: ]*' < processed$f.txt|sort -u|wc -l)"
regex="^\\($(head breaks$f.txt|head -n 1|cut -d' ' -f2)\\)"
echo "$regex"
while grep "$regex" "processed$f.txt" > regex.txt; do
	echo "Sedding: $regex"
	sed -i "/$regex/d" "processed$f.txt"
	cat processed$f.txt
	regex="$(cat regex.txt|cut -d' ' -f2-|tr '\n' ' '|tr -d :|sed 's/ $//;s/ /\\|/g')"
	echo "New: $regex"
done
linesnow="$(grep -o '[^: ]*' < processed$f.txt|sort -u|wc -l)"
echo $(((lines - linesnow) * linesnow))
