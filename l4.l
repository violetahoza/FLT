%{
#include <stdlib.h>
#include "list.h"
#include "y.tab.h"
%}

%%

[0-9]+	{
		yylval.ival = atoi(yytext);
		return INTEGER;
	}

"CONS" return CONS;
"CAR" return CAR;
"CDR" return CDR;
"APPEND" return APPEND;


[+()\'\n]	return *yytext;

[ \t]+          ;
