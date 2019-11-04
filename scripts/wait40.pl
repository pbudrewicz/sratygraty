#!/usr/bin/perl

###  This is (or is intended to be) a universal tool for waiting
###  until something reaches zero. It tries to estimate how long your
###  job is going to take to finish. You have to have some means to
###  measure amount of job left to do, be it rows, files, megabytes etc.
###  The point is you need to know the number that decreases to zero
###  and pass it to this script as a standard output of supplied command.
###  This script was written by pdb. 

die "Usage: $0 [-r] -p|-s command|-m [-l count ] [ interval [ multiplier ]]
  This utility takes a command as a parameter and optionally a number.
  It might be a shell command (preceded by -s).
  It might be a perl command (preceded by -p).
  The command should return a number to stdout.
  This number is treated as a measure of work left to do.
  The utility calculates estimation of time needed for the number to reach zero.
  Next parameter is an interval for updates in seconds. 
  It defaults to 30 seconds.
  If you precede it with '-l count' phrase estimation will done according to
  last {count} measurements.  Might be good for processes speeding up.  
  You may specify a multiplier for converting the measure to different units.
  (eg. to convert 512B blocks to KiB it would be 0.5)
  If you use -r switch stats are reset when amount of work increases.
  Stats are reset anyway if amount of work exceeds initial value.\n" 
  
  unless $ARGV[0] eq '-p' or $ARGV[0] eq '-s' or $ARGV[0] eq '-r' or $ARGV[0] eq '-m';

$| = 1;


$DORESET='off';
if ($ARGV[0] eq '-r')
{
  shift @ARGV;
  $DORESET='on';
}

$TYPE=shift @ARGV;

if ($TYPE eq '-m') {
  $CMD="your estimation of work done";
} else {
  $CMD=shift @ARGV ;
}

$LOCALMEAN=0;
if ($ARGV[0] eq '-l')
{
    shift @ARGV;
    $LOCALMEAN=shift @ARGV;
}

$INTERVAL=30; $WAITSLEEP=5;
$INTERVAL=$ARGV[0] unless $ARGV[0] == 0;

$START=time;
$SECS=5;

if ($TYPE eq '-s')
{
    open( DATA, "$CMD|" ); $CNT=<DATA>;close DATA;chomp $CNT;
}
elsif ($TYPE eq '-m')
{
   print "\nHow much work left? "; 
   $CNT=<STDIN>; chomp $CNT;
}
else
{
    $CNT=eval($CMD);
}

$CNT *= $ARGV[1] if $ARGV[1] != 0;

$SCNT=$CNT;

$CNT =~ m/\d+\.(\d+)/;
#$UFMT = sprintf "%%.%df", length($1);
$UFMT = sprintf "%%1.%dg", length($CNT)>7 ? 2 : length($CNT);
$SFMT = "%d";

$PREVTIME = $START;
$PREVCNT = $CNT;

foreach $i (1..$LOCALMEAN-1) { $LOCALTIME[$i-1]=$START; $LOCALMEAN[$i-1]=$CNT}

printf "According to %s:\n", $CMD, $CNT;
while ($CNT > 0)
{
    $SLEEP = ($INTERVAL < $SECS || $SECS < 0 ) ? $INTERVAL : $SECS;
    sleep ( $SLEEP >= 1 ? $SLEEP : 1); 
    if ($TYPE eq '-s')
    {
	open( DATA, "$CMD|" ); $CNT=<DATA>;close DATA;chomp $CNT;
    }
    elsif ($TYPE eq '-m')
    {
       print "\nHow much work left? "; 
       $CNT=<STDIN>; chomp $CNT;
    }
    else
    {
	$CNT=eval($CMD);
    }
    $CNT *= $ARGV[3] if $ARGV[3] != 0;
    if ((($CNT > $PREVCNT) and ($DORESET eq 'on')) or ($CNT > $SCNT))
    {
	print "More work to do - resetting statistics.\n";
	$START = $PREVTIME;
	$PREVCNT = $CNT;
	$SCNT=$CNT;
        $WAITSLEEP=5;
	foreach $i 
	    (1..$LOCALMEAN-1) 
	{ $LOCALTIME[$i-1]=$START; $LOCALMEAN[$i-1]=$CNT}
    }

    if ($CNT == $SCNT)
    {
	print "No change in amount of work - waiting...\n" unless $SKIPPED;
	print $WAITSLEEP % 10;
        sleep $WAITSLEEP;
        $WAITSLEEP++ if $WAITSLEEP < 300;
	$SKIPPED = 1;
	next;	
      }
    
    $NOW = time;
    $LTIME = $NOW - $PREVTIME; $PREVTIME=$NOW;
    $LCNT = $PREVCNT - $CNT;
    if ($LCNT > 0) 
    {
      $PREV_NZERO_TIME = $LAST_NZERO_TIME;
      $LAST_NZERO_TIME = $NOW 
    }
    push @LOCALMEAN, $CNT;
    push @LOCALTIME, $NOW;
    $PREVCNT = $CNT;
    $TIME = $NOW - $START;
    if ($LOCALMEAN)
    {
	if ($LOCALMEAN[0] == $CNT )
	{
	    $SECS = -1;
	}
	else
	{
	    $SECS = $CNT / ( ( $LOCALMEAN[0] - $CNT ) / ($NOW - $LOCALTIME[0]) );
	}
    }
    else
    {
	$SECS = $CNT / ( ( $SCNT - $CNT ) / $TIME  );
    }
    
    $LSECS = (($LCNT != 0 && $LTIME != 0) ? $CNT / ( $LCNT / $LTIME ) : 0);
    #$INTERVAL=$SECS if $SECS < $INTERVAL;
    $STALL = 1;
    foreach  $i  
	(1..$LOCALMEAN-1) 
    { $STALL &&= ($LOCALMEAN[$i-1] == $LOCALMEAN[$i]); }
    if ($STALL * 0)
    {
	if ($WAITSLEEP < 300)
	{
	    print "No change in amount of work - increasing sleep time...\n" unless $SKIPPED;
	    $WAITSLEEP += $WAITSLEEP / 10 + 1 ;
	}
        sleep $WAITSLEEP;
	$SKIPPED = 1;
	shift @LOCALMEAN;    
	shift @LOCALTIME;    
#	next;	
    }
    print "\n" if $SKIPPED;
    $SKIPPED = 0;
    printf "Time: %s, units left: $UFMT, time left: %s, speed: %s(%s)                 \r", 
    &timestr($TIME), $CNT, 
    &timestr($SECS), # szacowanie ze sredniej predkosci
    # &timestr($LSECS), # szacowanie z predkosci chwilowej
    # &timestr(2/(1/$SECS + 1/$LSECS)), # srednia harmoniczna szacowan
    &speedstr($LOCALMEAN ? $LOCALMEAN[0]-$CNT:$SCNT-$CNT,$LOCALMEAN ? ($NOW - $LOCALTIME[0] ) : $TIME), 
    # &speedstr($LCNT, $LTIME); # pr. chwilowa ostatniego interwalu
    &speedstr($LCNT, $NOW - $PREV_NZERO_TIME); # pr. chwilowa od ostatniego przyrostu
    shift @LOCALMEAN;    
    shift @LOCALTIME;    
  }
printf "Done. Speed: %s\n", &speedstr( $SCNT, $TIME );

sub timestr ($)
{
    my $secs = $_[0];
    my ($YEARS,$DAYS,$HOURS, $MINS, $SECS);

    return 'unknown' if $secs < 0;

    $MINS=int($secs/60);
    $HOURS=int($MINS/60);
    $MINS=$MINS-$HOURS * 60;
    $DAYS=int($secs/60/60/24);
    $HOURS=$HOURS-$DAYS * 24;
    $YEARS=int($secs/60/60/24/365);
    $DAYS=$DAYS-$YEARS * 365;
    $S=$secs-(((($YEARS*365+$DAYS)*24+$HOURS)*60)+$MINS)*60;    


    
    return 
	($YEARS>0 
	 ? (sprintf "%04dy", $YEARS): "")
	. (($DAYS>0) 
	   ? (sprintf "%02dd", $DAYS):"")
	. (($HOURS>0 && $YEARS < 1) 
	   ? (sprintf "%02d:", $HOURS):"") 
	. (($YEARS < 1) 
	   ? (sprintf "%02d", $MINS ):"")
	. (($DAYS<1 && $YEARS < 1) 
	   ? (sprintf ":%02d", $S ):"");
}

sub speedstr ($$)
  {
    my ($cnt, $time) = @_;

    return 'unknown' if $time == 0;

    if ($cnt / $time > 5000000000)
    {
	return (sprintf $SFMT, $cnt/1000000000/$time) .  "Gu/s";
    }
    elsif ($cnt / $time > 5000000)
    {
	return (sprintf $SFMT, $cnt/1000000/$time) .  "Mu/s";
    }
    elsif ($cnt / $time > 5000)
    {
	return (sprintf $SFMT, $cnt/1000/$time) .  "ku/s";
    }
    elsif ($cnt / $time > 5)
    {
	return (sprintf $SFMT, $cnt/$time) .  "u/s";
    }
    elsif ($cnt / $time > 5/60)
    {
	return (sprintf $SFMT, $cnt*60/$time) . "u/m";
    }
    elsif ($cnt / $time > 5/60/60)
    {
	return (sprintf $SFMT, $cnt*60*60/$time) . "u/h";
    }
    elsif ($cnt / $time > 5/60/60/24)
    {
	return (sprintf $SFMT, $cnt*60*60*24/$time) . "u/day";
    }
    elsif ($cnt / $time > 5/60/60/24/7)
    {
	return (sprintf $SFMT, $cnt*60*60*24*7/$time) . "u/week";
    }
    elsif ($cnt / $time > 5/60/60/24/31)
    {
	return (sprintf $SFMT, $cnt*60*60*24*31/$time) . "u/month";
    }
    elsif ($cnt / $time > 5/60/60/24/365)
    {
	return (sprintf $SFMT, $cnt*60*60*24*365/$time) . "u/year";
    }
    elsif ($cnt == 0)
    {
	return 'stop';
    }
    else
    {
	return 'slow';
    }
  }
