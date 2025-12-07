my $a = $*IN.lines;
my @state;
my $count = 0;
for (@$a) {
	my @chars = .split: "", :skip-empty;
	my @zipped = roundrobin(@chars, @state);
	# Surely there's a better way using lazy operators or something?
	# Extend to length and surround by Falses
	@zipped[@zipped.elems] = (".", False);
	@zipped.unshift((".", False)); # Surely there is a lazy thing here?!!?!
	@state = do for (roundrobin(@zipped[0..*-3], @zipped[1..*-2], @zipped[2..*-1])) {
		my ($left, $middle, $right) = $_;
		$count += $middle[0] eq "^" && $middle[1];
		$middle[0] ne "^" && (
			$middle[0] eq "S" ||
			$middle[1] ||
			($left[0] eq "^" && $left[1]) ||
			($right[0] eq "^" && $right[1]))
	}
}
say $count;
