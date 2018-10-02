#!/usr/bin/perl
use JSON;
use Data::Dumper;

$json = <>;

$structure  = decode_json($json);

$Data::Dumper::Sortkeys=1;
print Dumper($structure);
