#!/usr/bin/perl
use JSON;
use Data::Dumper;

$json = <STDIN>;

$structure  = decode_json($json);

$Data::Dumper::Sortkeys=1;
print Dumper($structure);
eval ("print \$structure->" . $ARGV[0] . ", \"\\n\";");


