%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}

%%

[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }
"value"     { return VALUE; }
"Y"         { return VARIABLE; }
[-+*/()'\[\],\^\n] { return *yytext; }
[ \t]+      { /* ignore whitespace */ }
.           { /* ignore any other characters */ }

%%

int yywrap() {
    return 1;
}

