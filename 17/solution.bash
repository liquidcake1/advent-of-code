declare -a lines
# call with filename 1 3 or filename 4 10
f=$1
minmove=$2
maxmove=$3
lines=( $(cat $f|grep -o .) )
lc=$(wc -l < $f)
qpos=-1
rm -rf q
mkdir q
echo 0 0 0 >> q/0
echo 0 0 1 >> q/0
declare -A shortests
for y in $(seq 0 $((lc - 1))); do
	for x in $(seq 0 $((lc - 1))); do
		shortests[$((y * lc * 2 + x * 2))]=1000
		shortests[$((y * lc * 2 + x * 2 + 1))]=1000
	done
done
shortests[0]=0
shortests[1]=0
# part 1
#minmove=1
#maxmove=3
# part 2
#minmove=4
#maxmove=10
while [ $(ls q|wc -l) -gt 0 ]; do
	((qpos+=1))
	if [ ! -e q/$qpos ]; then
		continue
	fi
	echo "At $qpos"
	while read x y d; do
		#echo "dequeue" $x $y $d
		if [ $d = 0 ]; then
			dirx=1
			diry=0
		else
			dirx=0
			diry=1
		fi
		for dirm in -1 1; do
			nx=$x
			ny=$y
			pos=$(($ny*$lc*2+$nx*2+$d))
			newscore=${shortests[$pos]}
			if [ $newscore -lt $qpos ]; then
				#echo "Repeat!! $newscore $pos"
				break
			fi
			for((cnt=1; cnt<=maxmove; cnt++)); do
				((nx += dirx * dirm))
				((ny += diry * dirm))
				if [ $nx -lt 0 -o $ny -lt 0 -o $ny -ge $lc -o $nx -ge $lc ]; then 
					#echo "too big" $nx $ny
					break
				fi
				((posl = ny * lc + nx))
				((newscore += lines[posl]))
				if [ $cnt -lt $minmove ]; then
					#echo "too short" $nx $ny
					continue
				fi
				#echo "consider" nx=$nx ny=$ny d=$d posl=$posl dirm=$dirm newscore=$newscore
				opos=$((posl * 2 + 1 - d))
				oldscore=${shortests[$opos]}
				if [ $oldscore -gt $newscore ]; then
					shortests[$opos]=$newscore
					#echo "queue" nx=$nx ny=$ny ndir=$((1 - d)) posl=$posl opos=$opos newscore=$newscore oldscore=$oldscore now=${shortests[$opos]}
					echo $nx $ny $((1 - d)) >> q/$newscore
				fi
			done
		done
	done < <(cat q/$qpos|sort -u)
	rm q/$qpos
done
br0=$(( lc*lc*2-2 ))
br1=$(( lc*lc*2-1 ))
echo ${shortests[$br0]} ${shortests[$br1]}
for y in $(seq 0 $((lc - 1))); do
	continue
	echo -n "| "
	for x in $(seq 0 $((lc - 1))); do
		pos0=$((y * lc * 2 + x * 2))
		pos1=$((pos0 + 1))
       		printf "%4i,%4i | " ${shortests[$pos0]} ${shortests[$pos1]}
	done
	echo
done
