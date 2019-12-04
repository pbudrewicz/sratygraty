#!/usr/bin/perl

sub module_fuel () {
  $mf = 0;
  $fuel = int($_[0] / 3 ) - 2;
  while ($fuel > 0) {
    $mf += $fuel;
    $fuel = int($fuel / 3) - 2;
  }
  return $mf;
}

while (<>) {
  $sum += &module_fuel( $_ );
}

print $sum, "\n";
