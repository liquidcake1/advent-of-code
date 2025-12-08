use warnings;
use strict;
$_ = <>;
my $count;
if (length($_) < 13) {
	$count = 10;
} else {
	$count = 1000;
}
my @coords;
do {
	chomp;
	push @coords, [split /,/];
} while <>;
my @pairs;
sub dist2 {
	my ($x1, $y1, $z1) = @{$_[0]};
	my ($x2, $y2, $z2) = @{$_[1]};
	($x1 - $x2) ** 2 + ($y1 - $y2) ** 2 + ($z1 - $z2) ** 2
}
for my $i (0..$#coords) {
	for my $j (0..$i-1) {
		continue if $i == $j;
		push @pairs, [$i, $j, dist2($coords[$i], $coords[$j])];
	}
}
@pairs = sort { $a->[2] <=> $b->[2] } @pairs;
my @circuit; # id -> circuit (set) (or null)
for (0..$#coords) {
	push @circuit, {ORIG => $_, $_ => 1};
}
my $last2;
for (@pairs) {
	my ($i, $j) = @{$_};
	if ($circuit[$i]{ORIG} != $circuit[$j]{ORIG}) {
		#print "Linking @{$coords[$i]} ($i: $circuit[$i]{ORIG}) to @{$coords[$j]} ($j: $circuit[$j]{ORIG})\n";
		my $newcircuit = $circuit[$i];
		for (keys %{$circuit[$j]}) {
			next if $_ eq "ORIG";
			#print "Sublinking $i to $_\n";
			$newcircuit->{$_} = 1;
			$circuit[$_] = $newcircuit;
		}
		#print "New circuit: $newcircuit->{ORIG}: " . join(", ", keys %{$circuit[$j]}) . "\n";
		#print "Vals $circuit[$i]->{ORIG} $circuit[$j]->{ORIG}\n";
		$last2 = [$i, $j];
	} else {
		#print "Skipping @{$coords[$i]} to @{$coords[$j]}\n";
	}
	if (--$count == 0) {
		my %circuitsizes;
		$circuitsizes{$_->{ORIG}} = scalar(%{$_}) - 1 for @circuit;
		my @sortedsizes = sort { $b <=> $a } values %circuitsizes;
		my $ans = 1;
		$ans *= $_ for @sortedsizes[0..2];
		print "Part 1: $ans\n";
	}
}
my $distance = $coords[$last2->[0]][0] * $coords[$last2->[1]][0];
print "Part 2: $distance\n"
