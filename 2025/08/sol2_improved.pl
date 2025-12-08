use warnings;
use strict;
use Time::HiRes qw/gettimeofday/;
print "Start... @{[gettimeofday()]}\n";
$_ = <>;
my $count;
if (length($_) < 13) {
	$count = 10;
} else {
	$count = 1000;
}
my @coords;
print "Read input... @{[gettimeofday()]}\n";
do {
	chomp;
	push @coords, [split /,/];
} while <>;

my @circuit; # id -> circuit (set) (or null)
for (0..$#coords) {
	push @circuit, {ORIG => $_, $_ => 1};
}
my $last2;
my $links = 0;
sub link_nodes {
	my ($i, $j) = @_;
	($i, $j) = ($j, $i) if keys %{$circuit[$j]} > keys %{$circuit[$i]};
	my $newcircuit = $circuit[$i];
	for (keys %{$circuit[$j]}) {
		next if $_ eq "ORIG";
		$newcircuit->{$_} = 1;
		$circuit[$_] = $newcircuit;
	}
	$links++;
}

# Idea: Take the 998 shortest links, and prelink them.
# Then run union merge thing over the prelinked sets only.
# This means less work in sort, which _was_ the slowest step.
# (But we need more work in distance computation.)

my @mins;
print "Computing distances... @{[gettimeofday()]}\n";
for my $i (0..$#coords) {
	my ($x1, $y1, $z1) = @{$coords[$i]};
	my ($minj, $min);
	for my $j (0..$i-1) {
		my ($x2, $y2, $z2) = @{$coords[$j]};
		my $xd = $x1 - $x2;
		my $yd = $y1 - $y2;
		my $zd = $z1 - $z2;
		my $dist = $xd * $xd + $yd * $yd + $zd * $zd;
		if (!defined $mins[$i] || $dist < $mins[$i][2]) {
			$mins[$i] = [$i, $j, $dist];
		}
		if (!defined $mins[$j] || $dist < $mins[$j][2]) {
			$mins[$j] = [$j, $i, $dist];
		}
	}
}
print "Prelinking... @{[gettimeofday()]}\n";
@mins = sort { $a->[2] <=> $b->[2] } @mins;
my $prelinks = 0;
for(@mins[0..$#mins-2]) {
	if ($circuit[$_->[0]] ne $circuit[$_->[1]]) {
		link_nodes($_->[0], $_->[1]);
		$prelinks++;
	}
}
print "Prelinked $prelinks times\n";
print "Computing distances (pass 2)... @{[gettimeofday()]}\n";
my @pairs;
my $circuits = 0;
for my $i (0..$#coords) {
	next if $circuit[$i]{ORIG} != $i;
	$circuits++;
	for my $j (0..$#coords) {
		next if $circuit[$j]{ORIG} != $j;
		next if $i >= $j;
		my $minpair;
		for my $in (keys %{$circuit[$i]}) {
			next if $in eq "ORIG";
			my ($x1, $y1, $z1) = @{$coords[$in]};
			for my $jn (keys %{$circuit[$j]}) {
				next if $jn eq "ORIG";
				my ($x2, $y2, $z2) = @{$coords[$jn]};
				my $xd = $x1 - $x2;
				my $yd = $y1 - $y2;
				my $zd = $z1 - $z2;
				my $dist = $xd * $xd + $yd * $yd + $zd * $zd;
				if (!defined $minpair || $minpair->[2] > $dist) {
					$minpair = [$in, $jn, $dist];
				}
			}
		}
		if ($minpair) {
			push @pairs, $minpair;
		}
	}
}
print "Distances computed. @{[gettimeofday()]} Circuits=$circuits Pairs=@{[scalar @pairs]}\n";
@pairs = sort { $a->[2] <=> $b->[2] } @pairs;
print "Sorted. @{[gettimeofday()]} @{[scalar @pairs]}\n";
for (@pairs) {
	my ($i, $j) = @{$_};
	if ($circuit[$i] ne $circuit[$j]) {
		#print "Linking @{$coords[$i]} ($i: $circuit[$i]{ORIG}) to @{$coords[$j]} ($j: $circuit[$j]{ORIG})\n";
		#print "New circuit: $newcircuit->{ORIG}: " . join(", ", keys %{$circuit[$j]}) . "\n";
		#print "Vals $circuit[$i]->{ORIG} $circuit[$j]->{ORIG}\n";
		link_nodes($i, $j);
		$last2 = [$i, $j];
		last if $links == $#coords;
	} else {
		#print "Skipping @{$coords[$i]} to @{$coords[$j]}\n";
	}
	--$count;
}
print "Algorithm ran. @{[gettimeofday()]}\n";
my $distance = $coords[$last2->[0]][0] * $coords[$last2->[1]][0];
print "Part 2: $distance ($links / $count)\n";



# For part 1: Rather than a full sort, use a bounded heap of size $count. This is O($count*@coords*log$count). rather than sorting @coords**2 elements.
