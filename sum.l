%{
#define YYSTYPE double
#include "sum.tab.h"
#include <stdlib.h>
%}

whitespace [ \t]+
numbers [0-9]
integer {numbers}+
exponent [eE][+-]?{integer}

%%

{whitespace} {}
{integer} {
  yylval=atof(yytext);
  return NUMBER;
}

"-" return MINUS;
"+" return PLUS;
"," return SEPARATOR;
"(" return LEFT_BRACKET;
")" return RIGHT_BRACKET;
"\n" return END;
