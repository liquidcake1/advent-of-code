undef$/;
$input = <>;
for(split /\n\n/, $input) {
	print "$_\n";
	@lines = split /\n/, $_;
	my $horiz;
	for $i (1..length($lines[0])-1) {
		# Test horizontal
		$horiz = $i;
		print "$#lines $i\n";
		sub rev {
			my $rev = join '', reverse split //, $_[0];
			print "$rev\n";
			my $res = quotemeta(substr($rev, 0, length($_) - pos()));
			print "$res\n";
			return $res;
		}
		for (@lines) {
			print "Test: $_ $i\n";
			if (!/^(.{$i})(??{rev($1)})/) {
				print "Nope.\n";
				undef $horiz;
			}
		}
		if (defined $horiz) {
			print("horiz $i\n");
			last;
		}
	}
	my $vert;
	print "$_\n";
	for $i (1..@lines-1) {
		print("Test $i\n");
		$vert = $i;
		for(my $j=0; $i-$j-1>=0 && $i+$j<@lines; $j++) {
			print("Testl $j\n");
			print("$lines[$i-$j-1]\n");
			print("$lines[$i+$j]\n");
			if ($lines[$i-$j-1] ne $lines[$i+$j]) {
				print("fail\n");
				undef $vert;
				last;
			}
		}
		if (defined $vert) {
			print("vert $i\n");
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
}
