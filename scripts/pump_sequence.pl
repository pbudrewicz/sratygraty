#!/usr/bin/perl
$steps = 10;
$line = <>;
($prevx,$prevy,$prevb) = split ' ', $line;
printf STDERR "x=%f y=%f b=%f\n", $prevx, $prevy, $prevb;
while (<>) {
  ($x, $y, $b) = split ' ';
  for ($i=0; $i<$steps; $i++ ) {
        printf STDERR "%f-%f, %f-%f, %f-%f\n", $x, $prevx, $y, $prevy, $b, $prevb;
	printf "%f %f %d \n", 
            ($x - $prevx)/$steps * $i + $prevx,
            ($y - $prevy)/$steps * $i + $prevy,
            ($b - $prevb)/$steps * $i + $prevb;
  }
  ($prevx, $prevy, $prevb) = ($x, $y, $b);
}
