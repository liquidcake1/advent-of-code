{
	split($0, A);
	print $0
	bad = up = down = 0;
	for(i=1; i<NF; i++) {
		print A[i]
		if (A[i] > A[i+1]) {
			down = 1;
			if (A[i] > A[i+1] + 3) bad = 1;
		} else if (A[i] < A[i+1]) {
			up = 1;
			if (A[i] < A[i+1] - 3) bad = 1;
		} else bad = 1;
	}
	if (up && down || bad) { print "up" up "down" down "bad" bad "line" $0}
	else num_safe += 1;
}
END { print num_safe }
