#!/usr/bin/perl -n
sub evolve {
	my $s = $_[0];
	my $l = length $s;
	if ($l % 2 == 0) {
		return int(substr($s, 0, $l/2)), int(substr($s, $l/2, $l/2));
	} elsif ($s == 0) {
		return 1;
	} else {
		return $s * 2024;
	}
}
chomp;
my %a;
$a{$_} = 1 for split;
for my $loop (1..75) {
	my %b;
	for my $k (keys %a) {
		$b{$_} += $a{$k} for evolve $k;
	}
	my $ans;
	$ans += $_ for values %b;
	%a = %b;
	print "Loop: $loop; Ans: $ans\n" if $loop == 25 or $loop == 75;
}
