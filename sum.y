%{
  #include <stdio.h>
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
  | Expression END { printf("> %d\n", $1); }
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
  exit(0);
}

int main(int argc, char *argv[]) {
  yyparse();
}
