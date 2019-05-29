%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define YYSTYPE double
%}

%token NUMBER
%token MINUS
%token PLUS
%token SEPARATOR
%token LEFT_BRACKET RIGHT_BRACKET
%token END

%left SEPARATOR
%left NEG

%start Input
%%

Input:

     | Input Line
;

Line:
     END
     | Expression END { printf("> %f\n", $1); }
;

Expression:
     NUMBER { $$=$1; }
| Expression SEPARATOR Expression { $$=$1+$3; }
| MINUS Expression %prec NEG { $$=0; }
| PLUS Expression %prec NEG { $$=$2; }
| LEFT_BRACKET Expression RIGHT_BRACKET { $$=$2; }
| LEFT_BRACKET RIGHT_BRACKET { $$=0; }
;
%%

int yyerror(char *s) {
  printf("%s\n", s);
}

int main() {
  if (yyparse())
     fprintf(stderr, "Successful parsing.\n");
  else
     fprintf(stderr, "error found.\n");
}
