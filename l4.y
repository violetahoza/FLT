%{
#include <stdio.h>
#include <stdlib.h>
#include "list.h"

void yyerror(const char *s);
int yylex();
int yyparse();
%}

// Define the union that holds either an integer or a List*
%union {
    int ival;
    List* lval;
}

// Tokens
%token <ival> INTEGER
%token CONS CAR CDR APPEND

// Nonterminal types
%type <ival> expression i_form i_command
%type <lval> l_form l_command enum

%left '+'
%left '\n'

%%

// Main program handling expressions and lists
program : program expression '\n'  { printf("%d\n", $2); }
        | program l_form '\n'      { print_list($2); }
        | /* NULL */
        ;

expression : INTEGER                  { $$ = $1; }
           | expression '+' expression { $$ = $1 + $3; }
           | '(' expression ')'        { $$ = $2; }
           ;

i_form : '(' i_command ')' { $$ = $2; }
       | INTEGER           { $$ = $1; }
       ;

i_command : CAR l_form       { $$ = car($2); }
          | '+' i_form i_form { $$ = $2 + $3; }
          ;

l_form : '(' l_command ')'  { $$ = $2; }
       | '\'' '(' enum ')'  { $$ = $3; }
       ;

l_command : CDR l_form           { $$ = cdr($2); }
          | CONS i_form l_form   { $$ = cons($2, $3); }
          | APPEND l_form l_form { $$ = append($2, $3); }
          ;

enum : INTEGER enum { $$ = cons($1, $2); }
     | INTEGER      { $$ = cons($1, NULL); }
     ;

%%

// List operations
// Creates a new list node (CONS operation)
List* cons(int value, List* list) {
    List* new_node = (List*)malloc(sizeof(List));
    new_node->value = value;
    new_node->next = list;
    return new_node;
}

// Returns the first element of the list (CAR operation)
int car(List* list) {
    if (list == NULL) {
        fprintf(stderr, "Error: CAR of empty list\n");
        return 0;
    }
    return list->value;
}

// Returns the rest of the list after the first element (CDR operation)
List* cdr(List* list) {
    if (list == NULL) {
        fprintf(stderr, "Error: CDR of empty list\n");
        return NULL;
    }
    return list->next;
}

// Appends two lists together (APPEND operation)
List* append(List* l1, List* l2) {
    if (l1 == NULL) return l2;
    List* head = l1;
    while (l1->next != NULL) {
        l1 = l1->next;
    }
    l1->next = l2;
    return head;
}

// Prints a list
void print_list(List* list) {
    printf("(");
    while (list != NULL) {
        printf("%d ", list->value);
        list = list->next;
    }
    printf(")\n");
}

// Error handling function
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter expressions:\n");
    yyparse();
    return 0;
}

