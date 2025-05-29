%{
#include <stdio.h>

#define NUMBER 256
#define CONCAT 257
#define TAKE   258
#define DROP   259
#define CONS   260

int yylval;

%}

%%

"++"          { return CONCAT; }
"take"        { return TAKE; }
"drop"        { return DROP; }
":"           { return CONS; }

[0-9]+        { yylval = atoi(yytext); return NUMBER; }
[\[\](),\n]     { return *yytext; }
[ \t]+        { }
.             { printf("Unknown character: %s\n", yytext); }

%%

