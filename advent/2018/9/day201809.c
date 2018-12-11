#include <stdio.h>
#include <stdlib.h>

typedef struct marble {
  int  number;
  int clockwise, anticlockwise;
} marble;

int /* returns nuber of points */
add_marble( int *current, int number, struct marble *ring ) {
  int left, right, i;
  int points;

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
    points += 23;
    for (i=0; i<7; i++) 
      *current=ring[*current].anticlockwise; 
    points += ring[*current].number;
    ring[ring[*current].anticlockwise].clockwise = ring[*current].clockwise;
    ring[ring[*current].clockwise].anticlockwise = ring[*current].anticlockwise;
    *current=ring[*current].clockwise;
  }
  return points;   
}

int
take () {
  static int free;
  return free++;
}

void
show_ring(struct marble *ring, int count) {
  int i,c;
  c=0;
  for (i=0,c=0; i<=count; i++, c=ring[c].clockwise )
    printf ("%3d", ring[c].number );
  printf( "\n" );
  
}

int
main( int count, char** argv) {

  struct marble *ring;
  int            current_marble;
  int            player;
  int           *points;     
  int            player_count;
  int            marble_count;
  int            m_no;
  int            pts;

  scanf( "%d", &player_count );
  scanf( "%d", &marble_count );

  ring = calloc( marble_count+1, sizeof( struct marble ) );    
  points = calloc( player_count+1, sizeof( int ) );
  
  current_marble = take();
  ring[current_marble].number = 0; 
  ring[current_marble].clockwise = current_marble;
  ring[current_marble].anticlockwise = current_marble;

  player=1;
  pts=0;

  for (m_no=1; m_no <= marble_count; m_no++ ) {
    printf ("marble: %d, player: %d (current: %d)\n", m_no, player % player_count, current_marble);
    pts = add_marble( &current_marble, m_no, ring );
    points[player] += pts;
    player=(player + 1) % player_count;
#    show_ring(ring, m_no );
  }

  for (player=0; player<player_count; player++)
    printf ( "%d\t%d\n", player, points[player] );

}
