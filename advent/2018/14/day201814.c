#include <stdio.h>
#include <stdlib.h>


struct recipe {
  int score;
  struct recipe *link;
} recipe;
  
static struct recipe *recipes = NULL;

static struct recipe *add_recipe( int ascore ) {
  struct recipe *new_recipe, *tmp;
  if (recipes == NULL ) {
    recipes = malloc( sizeof (struct recipe) ); 
    recipes->link = recipes;
    recipes->score = ascore;
    return recipes;
  } else { 
    new_recipe= malloc( sizeof (struct recipe) );
    new_recipe->score = ascore;
    tmp=recipes->link;
    recipes->link = new_recipe;
    new_recipe->link=tmp;
    recipes=new_recipe;
    return new_recipe;
  }
}

int main(int c, char *argv[] ) {
 
  struct recipe *elf[2],*ptr;
  int elf0, elf1;
  int i;
  int new_score = 0;

  elf[0] = add_recipe( 3 );
  elf[1] = add_recipe( 7 );
   
  i=2; 
  while ( 1 ) {
       new_score = elf[0]->score + elf[1]->score;
       if (new_score > 9) {
         add_recipe( 1 ); 
         printf( "%d\n", recipes->score ); 
         i++;
       }
/*       for (ptr=recipes->link; ptr != recipes; ptr=ptr->link) { printf ("%d ", ptr->score ); } 
       printf( "\n" );*/
       add_recipe( new_score % 10 );
       printf( "%d\n", recipes->score ); 
       i++;
/*       for (ptr=recipes->link; ptr != recipes; ptr=ptr->link) { printf ("%d ", ptr->score ); }
       printf( "\n" );*/
       elf0 = elf[0]->score + 1;
       while (elf0 > 0)  { elf[0] = elf[0]->link; elf0--; } 
       elf1 = elf[1]->score + 1;
       while (elf1 > 0)  { elf[1] = elf[1]->link; elf1--; }
  }	    
}
