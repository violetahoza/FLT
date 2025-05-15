%{
#include <stdio.h>
#include <stdlib.h>
#define NUMBER  256

int yylval;
%}

%%

[0-9]+      { yylval = atoi(yytext); return NUMBER; }
[-+()\n]    { return *yytext;}
[ \t]   {;}
.           { }

%%