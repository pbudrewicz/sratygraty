#!/usr/bin/perl
use JSON;
use Data::Dumper;

sub json2struct {
    $json = <STDIN>;
    $structure  = decode_json($json);
}

if ( $ARGV[0] eq "dump" ) {
    &json2struct;
    $Data::Dumper::Sortkeys=1;
    print Dumper($structure);
} elsif ($ARGV[0] eq "list" || $ARGV[0] eq "keys") {
    &json2struct;
    eval ("print( join \"\n\", sort keys( %{ \$structure->" . $ARGV[1] . " } ), \"\\n\");");
} elsif ($ARGV[0] eq "count") {
    &json2struct;
    eval ("print( scalar( \@{ \$structure->" . $ARGV[1] . " } ), \"\\n\");");
} elsif ($ARGV[0] eq "show")  {
    &json2struct;
    eval ("print \$structure->" . $ARGV[1] . ", \"\\n\";");
} else {
    print <<"EOF";

  Usage: $0 (list|keys|count|show) selector

      list|keys   -- list keys in HASH
      count       -- show count of elements in ARRAY
      show        -- show element (scalar value, ARRAY, HASH)
      
      selector    -- valid datastructure selector, perl syntax
                  e.g. {mambers}[3]{gender}
EOF

}

    

