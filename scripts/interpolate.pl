#!/usr/bin/perl
$steps = ($ARGV[0] eq "") ? 10 : $ARGV[0];
shift @ARGV;
$line = <STDIN>;
chomp $line;
@prevflds = split ' ', $line;
print STDOUT join( " ", @prevflds), "\n";
while (<STDIN>) {
    chomp;
    @flds = split ' ';
    for ($i=1; $i<$steps; $i++ ) {
	for ($f=0; $f < scalar(@flds); $f++) {
		$fmt = $ARGV[$f];
		if ($fmt =~ /^\*/) { 
			$fmt =~ s/\*//; 
                        printf STDOUT $fmt, ((($flds[$f] / $prevflds[$f])**(1.0/$steps)) ** $i) * $prevflds[$f];
		} else {
		       	$fmt = "%f" if $fmt eq "";
                        printf STDOUT $fmt, ($flds[$f] - $prevflds[$f])/$steps * $i + $prevflds[$f];
		}
	        print STDOUT " ";
	}
	print STDOUT "\n";
	
    }
    @prevflds=@flds;
    print STDOUT join( " ", @prevflds), "\n";
}
