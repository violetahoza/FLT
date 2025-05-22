%{
#include <stdio.h>

#define NUMBER 256
#define NODE 257
#define LF 258
#define INSERT 259
#define COUNT 260

int yylval;

%}

%%

"Node"      { return NODE; }
"Lf"        { return LF;   }
"insert"    { return INSERT; }
"count"     { return COUNT; }

[0-9]+      {yylval = atoi(yytext); return NUMBER; }
[()\n]      { return *yytext; }
[ \t]+      {}
.           {}

%%




