#!/usr/bin/perl -n
sub evolve {
	my $s = $_[0];
	my $l = length $s;
	if ($l % 2 == 0) {
		return int(substr($s, 0, $l/2)) . " " . int(substr($s, $l/2, $l/2));
	} elsif ($s == 0) {
		return 1;
	} else {
		return $s * 2024;
	}
}
chomp;
print "$_\n";
for my $loop (1..25) {
	s{(\d+)}{evolve$1}eg;
	#print "$_\n";
	print "$loop\n";
	$ans = split / /;
	print "$ans\n";
}
