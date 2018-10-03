#!/usr/bin/perl
use JSON;
use Data::Dumper;

$json = <STDIN>;

$structure  = decode_json($json);

if ( $ARGV[0] eq "-v" ) {
  $Data::Dumper::Sortkeys=1;
  print Dumper($structure);
  shift @ARGV;
}
eval ("print \$structure->" . $ARGV[0] . ", \"\\n\";");


