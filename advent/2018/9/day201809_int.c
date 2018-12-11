#include <stdio.h>
#include <stdlib.h>

typedef struct marble {
  long  number;
  long clockwise, anticlockwise;
} marble;

long
take () {
  static long free;
  return free++;
}

long /* returns nuber of polongs */
add_marble( long *current, long number, struct marble *ring ) {
  long left, right, i;
  long points;

  points = 0;
  if (number % 23 != 0) {
    left = ring[*current].clockwise;
    right = ring[left].clockwise;
    *current = take();
    ring[*current].number = number;
    ring[*current].clockwise = right;
    ring[right].anticlockwise = *current;
    ring[*current].anticlockwise = left;
    ring[left].clockwise = *current;
  } else {
    points += number;
    for (i=0; i<7; i++) 
      *current=ring[*current].anticlockwise; 
    points += ring[*current].number;
    ring[ring[*current].anticlockwise].clockwise = ring[*current].clockwise;
    ring[ring[*current].clockwise].anticlockwise = ring[*current].anticlockwise;
    *current=ring[*current].clockwise;
  }
  return points;   
}

void
show_ring(struct marble *ring, long count) {
  long i,c;
  c=0;
  for (i=0,c=0; i<=count; i++, c=ring[c].clockwise )
    printf ("%3ld", ring[c].number );
  printf( "\n" );
  
}

int
main( int count, char** argv) {

  struct marble *ring;
  long            current_marble;
  long            player;
  long           *points;     
  long            player_count;
  long            marble_count;
  long            m_no;
  long            max;

  scanf( "%ld", &player_count );
  scanf( "%ld", &marble_count );

  ring = calloc( marble_count+1, sizeof( struct marble ) );    
  points = calloc( player_count+1, sizeof( long ) );
  
  current_marble = take();
  ring[current_marble].number = 0; 
  ring[current_marble].clockwise = current_marble;
  ring[current_marble].anticlockwise = current_marble;

  player=1;

  for (m_no=1; m_no <= marble_count; m_no++ ) {
    /* printf ("marble: %ld, player: %ld (current: %ld)\n", m_no, player % player_count, current_marble); */
    points[player] += add_marble( &current_marble, m_no, ring );
    player=(player + 1) % player_count;
    /* show_ring(ring, m_no ); */
  }
  max = 0;
  for (player=0; player<player_count; player++)
    if (points[player] > max) max = points[player];
  printf ( "%ld\n", max );

}
