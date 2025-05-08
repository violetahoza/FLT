%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%
[0-9]+  { 
        yylval.str = strdup(yytext); 
        return NUMBER; 
    }

[a-zA-Z]+ {
            yylval.str = strdup(yytext); 
            return VAR; 
        }

[+\-*/^()\n] { return *yytext; }

[ \t]   { }
.       { return yytext[0]; }

%%
int yywrap() { return 1;}

