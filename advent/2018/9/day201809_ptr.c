#include <stdio.h>
#include <stdlib.h>

typedef struct marble {
  long number;
  struct marble *clockwise, *anticlockwise;
} marble;

long /* returns number of points */
add_marble( struct marble **current, long number ) {
  struct marble *left, *right;
  long points, i;

  points = 0;
  if (number % 23 != 0) {
    left = (*current)->clockwise;
    right = left->clockwise;
    *current = malloc( sizeof( struct marble ) );
    if (*current == NULL) {
       printf ( "no memory\n" );
       exit(0);
    }
    (*current)->number = number;
    (*current)->clockwise = right;
    right->anticlockwise = *current;
    (*current)->anticlockwise = left;
    left->clockwise = *current;
  } else {
    points += number;
    for (i=0; i<7; i++) 
      *current=(*current)->anticlockwise; 
    points += (*current)->number;
    (*current)->anticlockwise->clockwise = (*current)->clockwise;
    (*current)->clockwise->anticlockwise = (*current)->anticlockwise;
    *current=(*current)->clockwise;
  }
  return points;   
}

void
show_ring(struct marble *current, long count) {
  long i,c;
  for (i=0,c=0; i<=count; i++, current=current->clockwise )
    printf ("%3ld", current->number );
  printf( "\n" );
  
}

int
main( int count, char** argv) {

  struct marble *current_marble;
  long            player;
  long           *points;     
  long            player_count;
  long            marble_count;
  long            m_no;
  long            max;

  scanf( "%ld", &player_count );
  scanf( "%ld", &marble_count );

  points = calloc( player_count+1, sizeof( long ) );
  
  current_marble = malloc( sizeof( struct marble ) );
  current_marble->number = 0; 
  current_marble->clockwise = current_marble;
  current_marble->anticlockwise = current_marble;

  player=1;

  for (m_no=1;  m_no < marble_count; m_no++ ) {
    /* printf ("marble: %d, player: %d (current: %d)\n", m_no, player % player_count, current_marble->number); */
    points[player] += add_marble( &current_marble, m_no );
    player=(player + 1) % player_count;
  }

  max = 0;
  for (player=0; player<player_count; player++)
    if (points[player] > max) max = points[player];
  printf ( "%ld\n", max );

}
