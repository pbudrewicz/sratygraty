#!/usr/bin/perl
$steps = ($ARGV[0] eq "") ? 10 : $ARGV[0];
$line = <STDIN>;
($prevx,$prevy,$prevb) = split ' ', $line;
printf "%f %f %d \n", $prevx, $prevy, $prevb;
printf STDERR "x=%f y=%f b=%f\n", $prevx, $prevy, $prevb;
while (<STDIN>) {
  ($x, $y, $b) = split ' ';
  for ($i=1; $i<$steps; $i++ ) {
        printf STDERR "%f-%f, %f-%f, %f-%f\n", $x, $prevx, $y, $prevy, $b, $prevb;
	printf "%f %f %d \n", 
            ($x - $prevx)/$steps * $i + $prevx,
            ($y - $prevy)/$steps * $i + $prevy,
            ($b - $prevb)/$steps * $i + $prevb;
  }
  ($prevx, $prevy, $prevb) = ($x, $y, $b);
  printf "%f %f %d \n", $prevx, $prevy, $prevb;
}
