#!/usr/bin/perl -CioS

$| = 1;
while (<STDIN>) {
    print;
    print STDERR ('\\', '|', '/', '-')[ ($pos += 1) % 4 ], "\010";
}
print STDERR "$pos $ARGV[1]\n" if $ARGV[0] eq '-v';
