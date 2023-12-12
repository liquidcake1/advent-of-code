# Pipe in the input, pass 1 or 5 as first param.
# Force a regular expression to backtrack and count the solutions.
use re 'eval';
my $reps = $ARGV[0];
print "Using $reps reps\n";
my %cache;
our $depth;
our @counts;
sub pcounts {
	my $r = "";
	$r .= " $$_" for @counts;
	$r
}
my $cache = qr{(??{
	my $pkey = $key;
	local $key = pos() . " $depth";
	my $prev = $cache{$key};
	$cache{$key} ||= 0;
	local @counts = (@counts, \$cache{$key});
	#printf "pos=%g depth=%g key=%s @{[pcounts()]}\n", pos(), $depth, $key;
	my $continue = "";
	if (defined $prev) {
		$$_ += $prev for @counts;
		#print "cached\n";
		$continue = "no";
	}
	return $continue;
	})};
my $descend = qr{(?{
	#print "desc\n";
	local $depth = $depth + 1
	})};
my $end = qr{(??{
	$$_ += 1 for @counts;
	#print "end $key $cache{$key} @{[pcounts()]}\n"; 
	"no"
	})};
while(<STDIN>) {
	chomp;
	print "$_\n";
	my ($str1, $mints) = split / /;
	my @match1 = split /,/, $mints;
	my @match = ();
	push @match, @match1 for (1..$reps);
	my $str = $str1;
	$str .= "?$str1" for 2..$reps;
	print "@match $mints $str\n";
	my $matcher = qr{^$cache};
	my $needdots = 0;
	for my $foo (@match) {
		$matcher .= qr{(?:[.?]$cache){$needdots,}[#?]{$foo}$descend};
		$needdots = 1;
	}
	$matcher .= qr{[.?]*(?:$)$end};
	%cache = ();
	$depth = 0;
	#print "The regular expression is:\n$matcher\n";
	if ($str =~ /$matcher/) { die "match\n" } # Should always backtrack, never match.
	$sum += $cache{"0 0"};
	print "$cache{'0 0'} $sum\n";
	#for (sort keys %cache) {
	#	print "m$_\m $cache{$_}\n";
	#}
}
