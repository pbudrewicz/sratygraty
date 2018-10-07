#!/usr/bin/perl
$steps = ($ARGV[0] eq "") ? 10 : $ARGV[0];
$line = <STDIN>;
chomp $line;
@prevflds = split ' ', $line;
print STDOUT join( " ", @prevflds), "\n";
printf STDERR "x=%f y=%f b=%f\n", $prevx, $prevy, $prevb;
while (<STDIN>) {
    chomp;
    @flds = split ' ';
    for ($i=1; $i<$steps; $i++ ) {
	for ($f=0; $f < scalar(@flds); $f++) {
	    print STDOUT ($flds[$f] - $prevflds[$f])/$steps * $i + $prevflds[$f], " ";
	}
	print STDOUT "\n";
	
    }
    @prevflds=@flds;
    print STDOUT join( " ", @prevflds), "\n";
}
