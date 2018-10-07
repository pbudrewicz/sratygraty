#!/usr/bin/perl
use JSON;
use Data::Dumper;

sub json2struct {
    if (-t STDIN)
    {
	&usage;
	exit 0;
    }
    $json = <STDIN>;
    $structure  = decode_json($json);
}

&json2struct;

if ( $ARGV[1] eq "" ) {
    $query = "";
} else {
    $query = "->$ARGV[1]";
}

if ( $ARGV[0] eq "dump" ) {
    $Data::Dumper::Sortkeys=1;
    print Dumper($structure);
} elsif ($ARGV[0] eq "list" || $ARGV[0] eq "keys") {
    eval ("print( join (\"\n\", sort keys( %{ \$structure" . $query . " } )), \"\\n\");");
} elsif ($ARGV[0] eq "count" || $ARGV[0] eq "size") {
    eval ("print( scalar( \@{ \$structure" . $query . " } ), \"\\n\");");
} elsif ($ARGV[0] eq "show")  {
    eval ("\$out=  \$structure" . $query . ";");    
    print "$out\n";
    eval ("print( scalar( \@{ \$structure" . $query . " } ), \"\\n\");") 
	if $out =~ m/^ARRAY/;
    eval ("print( join (\"\n\", sort keys( %{ \$structure" . $query . " } )), \"\\n\");") 
	if $out =~m/^HASH/;
} elsif ($ARGV[0] eq "get")  {
    eval ("print \$structure" . $query . ";");    
} else {
    &usage;
}

sub usage {
    print <<"EOF";

  Usage: $0 (get|list|keys|count|size|show) selector

      list|keys   -- list keys in HASH
      count|size  -- show count of elements in ARRAY
      show        -- show element 
      get         -- get just the field value
      
      selector    -- valid datastructure selector, perl syntax
                  e.g. '{mambers}[3]{gender}' OR '' for root node. 
EOF

}

    

