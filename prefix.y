%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(); 
void yyerror(const char *s); 

// Stack for conversion
char* stack[100];
int top = -1;

void push(char* str) {
    if (top < 99) {
        stack[++top] = str;
    }
}

char* pop() {
    if (top >= 0) {
        return stack[top--];
    }
    return NULL;
}
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

input: expr '\n' { 
    printf("Prefix: %s\n", $1); 
    free($1);  // Free dynamically allocated memory
}
| input expr '\n' { 
    printf("Prefix: %s\n", $2); 
    free($2);  // Free dynamically allocated memory
}
;

expr: NUMBER { 
    $$ = $1; 
    push($$);
}
| VAR { 
    $$ = $1; 
    push($$);
}
| expr expr '+' { 
    char* right = pop();
    char* left = pop();
    asprintf(&$$, "+ %s %s", left, right);
    push($$);
    free(left);
    free(right);
}
| expr expr '-' { 
    char* right = pop();
    char* left = pop();
    asprintf(&$$, "- %s %s", left, right);
    push($$);
    free(left);
    free(right);
}
| expr expr '*' { 
    char* right = pop();
    char* left = pop();
    asprintf(&$$, "* %s %s", left, right);
    push($$);
    free(left);
    free(right);
}
| expr expr '/' { 
    char* right = pop();
    char* left = pop();
    asprintf(&$$, "/ %s %s", left, right);
    push($$);
    free(left);
    free(right);
}
| expr expr '^' { 
    char* right = pop();
    char* left = pop();
    asprintf(&$$, "^ %s %s", left, right);
    push($$);
    free(left);
    free(right);
}
| expr '-' %prec UMINUS { 
    char* operand = pop();
    asprintf(&$$, "- %s", operand);
    push($$);
    free(operand);
}
;

%%

int main() {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}