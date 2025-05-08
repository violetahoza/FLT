%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

%}

%%

"Node"      { return NODE; }
"Lf"        { return LF;   }
"insert"    { return INSERT; }
"delete"    { return DELETE; }
"find"      { return FIND; }
"count"     { return COUNT; }
"balanced"  { return BALANCED; }

[0-9]+      {yylval.ival = atoi(yytext); return NUMBER; }
[(),\n]      { return *yytext; }
[ \t]+    {}
.           {}

%%

int yywrap() {
    return 1;
}



