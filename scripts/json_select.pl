#!/usr/bin/perl
use JSON;
use Data::Dumper;

$json = <STDIN>;

$structure  = decode_json($json);

if ( $ARGV[0] eq "dump" ) {
  $Data::Dumper::Sortkeys=1;
  print Dumper($structure);
  shift @ARGV;
} elsif ($ARGV[0] eq "list" || $ARGV[0] eq "keys") {
    shift @ARGV;
    eval ("print( join \"\n\", sort keys( %{ \$structure->" . $ARGV[0] . " } ), \"\\n\");");
} elsif ($ARGV[0] eq "count") {
    shift @ARGV;
    eval ("print( scalar( \@{ \$structure->" . $ARGV[0] . " } ), \"\\n\");");
} else {
    eval ("print \$structure->" . $ARGV[0] . ", \"\\n\";");
}


