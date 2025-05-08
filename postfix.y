%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *s);
%}

%union {
    char* str;
}

%token <str> NUMBER VAR
%left '+' '-'
%left '*' '/'
%right '^'
%left '(' ')'
%right UMINUS  // Unary minus precedence
%type <str> expr

%%

input: expr '\n' { printf("Postfix: %s\n", $1); }
     | input expr '\n' { printf("Postfix: %s\n", $2); }
     ;

expr: NUMBER { $$ = $1; }
    | VAR { $$ = $1; }
    | expr '+' expr { asprintf(&$$, "%s %s +", $1, $3); }
    | expr '-' expr { asprintf(&$$, "%s %s -", $1, $3); }
    | expr '*' expr { asprintf(&$$, "%s %s *", $1, $3); }
    | expr '/' expr { asprintf(&$$, "%s %s /", $1, $3); }
    | expr '^' expr { asprintf(&$$, "%s %s ^", $1, $3); }
    | '-' expr %prec UMINUS { asprintf(&$$, "%s -", $2); }  // Unary minus
    | '(' expr ')' { $$ = $2; }
    ;

%%

int main() {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
