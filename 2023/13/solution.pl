undef$/;
$input = <>;
for(split /\n\n/, $input) {
	@lines = split /\n/, $_;
	my $horiz;
	#print "$_\n";
	for $i (1..length($lines[0])-1) {
		# Test horizontal
		$horiz = $i;
		#print "$#lines $i\n";
		sub rev {
			my $rev = join '', reverse split //, $_[0];
			#print "$rev\n";
			my $res = quotemeta(substr($rev, 0, length($_) - pos()));
			#print "$res\n";
			return $res;
		}
		for (@lines) {
			#print "Test: $_ $i\n";
			if (!/^(.{$i})(??{rev($1)})/) {
				print "Nope.\n";
				undef $horiz;
			}
		}
		if (defined $horiz) {
			#print("horiz $i\n");
			last;
		}
	}
	my $vert;
	#print "$_\n";
	for $i (1..@lines-1) {
		#print("Test $i\n");
		$vert = $i;
		for(my $j=0; $i-$j-1>=0 && $i+$j<@lines; $j++) {
			#print("Testl $j\n");
			#print("$lines[$i-$j-1]\n");
			#print("$lines[$i+$j]\n");
			if ($lines[$i-$j-1] ne $lines[$i+$j]) {
				print("fail\n");
				undef $vert;
				last;
			}
		}
		if (defined $vert) {
			#print("vert $i\n");
			last;
		}
	}
	my $horiz2;
	print "$_\n";
	for $i (1..length($lines[0])-1) {
		next if $i == $horiz;
		# Test horizontal
		print "$#lines $i\n";
		my $diffs = 0;
		for (@lines) {
			for(my $j=0; $i-$j-1>=0 && $i+$j<length $_; $j++) {
				if (substr($_, $i-$j-1, 1) ne substr($_, $i+$j, 1)) {
					$diffs += 1;
				}
			}
		}
		if ($diffs == 1) {
			print("horiz $i\n");
			$horiz2 = $i;
			last;
		}
	}
	my $vert2;
	print "$_\n";
	for $i (1..@lines-1) {
		next if $i == $vert;
		print("Test $i\n");
		my $diffs = 0;
		for(my $j=0; $i-$j-1>=0 && $i+$j<@lines; $j++) {
			print("Testl $j\n");
			print("$lines[$i-$j-1]\n");
			print("$lines[$i+$j]\n");
			for(my $k=0; $k<length $lines[0]; $k++) {
				if (substr($lines[$i-$j-1], $k, 1) ne substr($lines[$i+$j], $k, 1)) {
					$diffs += 1;
				}
			}
		}
		if ($diffs == 1) {
			print("vert $i\n");
			$vert2 = $i;
			last;
		}
	}
	if (defined($horiz) && defined($vert)) {
		die "Oops";
	} elsif ((!defined $horiz) && (!defined $vert)) {
		die "Oops2 $horiz $vert";
	} elsif ($horiz) {
		$sum += $horiz;
	} elsif ($vert) {
		$sum += 100 * $vert;
	}
	print "RESULT: horiz=$horiz vert=$vert sum=$sum\n";
	if (defined($horiz2) && defined($vert2)) {
		die "Oops";
	} elsif ((!defined $horiz2) && (!defined $vert2)) {
		die "Oops2 $horiz2 $vert2";
	} elsif ($horiz2) {
		$sum2 += $horiz2;
	} elsif ($vert2) {
		$sum2 += 100 * $vert2;
	}
	print "RESULT2: horiz=$horiz2 vert=$vert2 sum=$sum2\n";
}
