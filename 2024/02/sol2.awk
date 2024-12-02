{
	split($0, A);
	print $0
	for(j=0; j<=NF; j++) {
		bad = up = down = 0;
		if (j == 1) {
			last = A[2];
			start = 3;
		} else {
			last = A[1];
			start = 2;
		}
		for(i=start; i<=NF; i++) {
			if (i == j) continue;
			if (last > A[i]) {
				if (up || last > A[i] + 3) {
					bad = bad + 1;
				} else {
					down = 1;
				}
			} else if (last < A[i]) {
				if (down || last < A[i] - 3) {
					bad = bad + 1;
				} else {
					up = 1;
				}
			} else {
				bad = bad + 1;
			}
			last = A[i];
		}
		if (bad) { print "up" up "down" down "bad" bad "line" $0}
		else {
			num_safe += 1;
			break;
		}
       	}
}
END { print num_safe }
