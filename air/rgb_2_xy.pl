#!/usr/bin/perl


$RGB = $ARGV[0];

$RGB ne "" or die "Usage: $0 RGB\n  example: $0 1428a0\n";

($r, $g, $b ) = ((hex $1)/255.0, (hex $2)/255.0, (hex $3)/255.0) if $RGB =~ m/#?(..)(..)(..)/;

$r = ($r > 0.04045) ? (($r + 0.055) / (1.0 + 0.055)) ** 2.4 : ($r / 12.92); 
$g = ($g > 0.04045) ? (($g + 0.055) / (1.0 + 0.055)) ** 2.4 : ($g / 12.92); 
$b = ($b > 0.04045) ? (($b + 0.055) / (1.0 + 0.055)) ** 2.4 : ($b / 12.92);

$X = $r * 0.649926 + $g * 0.103455 + $b * 0.197109;
$Y = $r * 0.234327 + $g * 0.743075 + $b * 0.022598;
$Z = $r * 0.0000000 + $g * 0.053077 + $b * 1.035763;

$x = $X / ($X + $Y + $Z);

$y = $Y / ($X + $Y + $Z);


#printf "R: %f, G: %f, B: %f\n", $r, $g, $b;
$x = $r * 0.490 + $g * 0.31 + $b * 0.200;
$y = $r * 0.17697 + $g * 0.81240 + $b * 0.01063;

printf "%f %f", $x, $y;




