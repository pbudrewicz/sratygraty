#!/usr/bin/perl -CioS


$/ = ',';

@DATA=();

while (<>) {
  printf "pos %d: code: %d\n", $i++, $_;
  push @DATA, $_; 
}


sub incomp () {

    for ($i=0; $i<int(@DATA); $i++) {
        $MEMORY[$i] = $DATA[$i];
    }
    
    $MEMORY[1] = $_[0];
    $MEMORY[2] = $_[1];
    
    local $pc=0;
    while ($MEMORY[$pc] != 99) {
        #printf "PC: %d, OP=%d\n", $pc, $MEMORY[$pc];
        if ($MEMORY[$pc] == 1) {
            $MEMORY[$MEMORY[$pc+3]] = $MEMORY[$MEMORY[$pc+1]] + $MEMORY[$MEMORY[$pc+2]];
            $pc += 4;
        }	
        if ($MEMORY[$pc] == 2) {
            $MEMORY[$MEMORY[$pc+3]] = $MEMORY[$MEMORY[$pc+1]] * $MEMORY[$MEMORY[$pc+2]];
            $pc += 4;
        }	
    }
    return $MEMORY[0];
}


for $noun (0..99) {
    for $verb (0..99) {
        
        printf "out: %d\n", 100 * $noun + $verb if &incomp($noun, $verb) == 19690720 ;
    }
}



