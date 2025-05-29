#include <stdio.h>
#include <stdlib.h>

#define NUMBER 256
#define CONCAT 257
#define TAKE   258
#define DROP   259
#define CONS   260

extern int yylval;
int symbol;
int yylex();
void next_symbol();

typedef struct {
    int *items;
    int length;
} List;

List Enum();
List L1();
List L();
List E();

List empty_list();
List make_list(int *items, int length);
List concat(List a, List b);
List take(List list, int n);
List drop(List list, int n);
void print_list(List list);

List empty_list() {
    List l = {NULL, 0};
    return l;
}

List make_list(int *items, int length) {
    List l;
    l.items = malloc(length * sizeof(int));
    l.length = length;
    for (int i = 0; i < length; i++) {
        l.items[i] = items[i];
    }
    return l;
}

List concat(List a, List b) {
    List result;
    result.length = a.length + b.length;
    result.items = malloc(result.length * sizeof(int));
    for (int i = 0; i < a.length; i++) {
        result.items[i] = a.items[i];
    }
    for (int i = 0; i < b.length; i++) {
        result.items[a.length + i] = b.items[i];
    }
    return result;
}

List take(List list, int n) {
    if (n > list.length) n = list.length;
    return make_list(list.items, n);
}

List drop(List list, int n) {
    if (n > list.length) n = list.length;
    return make_list(list.items + n, list.length - n);
}

void print_list(List list) {
    printf("[");
    for (int i = 0; i < list.length; i++) {
        if (i > 0) printf(", ");
        printf("%d", list.items[i]);
    }
    printf("]");
}

void next_symbol() { 
    symbol = yylex(); 
}

void error(const char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
    exit(1);
}

List Enum() {
    List list = empty_list();
    if (symbol == NUMBER) {
        int items[100];
        items[0] = yylval;
        int count = 1;
        next_symbol();
        
        while (symbol == ',') {
            next_symbol();
            if (symbol != NUMBER) error("Expected number after comma");
            items[count++] = yylval;
            next_symbol();
        }
        
        list = make_list(items, count);
    }
    return list;
}

List L1() {
    List list;
    switch (symbol) {
        case TAKE:
            next_symbol();
            list = E();
            if (symbol != NUMBER) error("Expected number after take");
            list = take(list, yylval);
            next_symbol();
            break;
            
        case DROP:
            next_symbol();
            list = E();
            if (symbol != NUMBER) error("Expected number after drop");
            list = drop(list, yylval);
            next_symbol();
            break;
            
        case '(':
            next_symbol();
            list = E();
            if (symbol != ')') error("Expected ')'");
            next_symbol();
            break;
            
        case '[':
            next_symbol();
            list = Enum();
            if (symbol != ']') error("Expected ']'");
            next_symbol();
            break;
            
        default:
            error("Expected take, drop, parentheses or list");
    }
    return list;
}

List L() {
    List list;
    if (symbol == NUMBER) {
        int head = yylval;
        next_symbol();
        if (symbol != CONS) error("Expected ':'");
        next_symbol();
        list = L();
        List new_list;
        new_list.length = list.length + 1;
        new_list.items = malloc(new_list.length * sizeof(int));
        new_list.items[0] = head;
        for (int i = 0; i < list.length; i++) {
            new_list.items[i+1] = list.items[i];
        }
        free(list.items);
        list = new_list;
    } else {
        list = L1();
    }
    return list;
}

List E() {
    List list = L();
    if (symbol == CONCAT) {
        next_symbol();
        List right = E();
        list = concat(list, right);
        free(right.items);
    }
    return list;
}

int main() {    
    while (1) {
        printf("> ");
        next_symbol();
        
        if (symbol == 0) {
            printf("\n");
            break;
        }
        
        if (symbol == '\n') {
            continue;
        }
        
        List result = E();
        
        if (symbol != '\n') {
            error("Unexpected input at end of expression");
        }
        
        print_list(result);
        printf("\n");
        free(result.items);
    }
    
    return 0;
}