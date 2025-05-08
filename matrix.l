%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%%
[A-Z]        { yylval.ival = yytext[0] - 'A'; return VAR; }
[0-9]+       { yylval.ival = atoi(yytext); return NUMBER; }
"i"          { return 'i'; } 
[\n+-=;*|()]   { return *yytext; }
"^"          { return '^'; }  
[ \t]+       /* Ignore whitespace */
.            { printf("Unknown character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}