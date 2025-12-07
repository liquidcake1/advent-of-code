my $a = $*IN.lines;
my @state;
for (@$a) {
	my @chars = .split: "", :skip-empty;
	my @zipped = ((".", 0), slip(roundrobin(@chars, @state)), (".", 0));
	@state = do for (roundrobin(@zipped[0..*-3], @zipped[1..*-2], @zipped[2..*-1])) {
		my ($left, $middle, $right) = $_;
		given $middle[0] {
			when "^" { 0 }
			when "S" { 1 }
			when "." {
				($middle[1] || 0)
				+ ($left[0] eq "^" ?? $left[1] !! 0)
				+ ($right[0] eq "^" ?? $right[1] !! 0)
			}
		}
	}
}
say @state.sum
