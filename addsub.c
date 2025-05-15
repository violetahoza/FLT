#include <stdio.h>
#include <stdlib.h>

#define NUMBER 256

void Z(); 
void E();
void E1();
void T();
int yylex();
void next_symbol();

extern int yylval;
int symbol;

void next_symbol() { 
    symbol = yylex(); 
} 

void Z() {
    E();
}

void E() {
    T();
    E1();
}

void E1() {
    if (symbol == '+') {
        printf("Found %c\n", symbol);
        next_symbol();
        T();
        E1();
    } else if (symbol == '-') {
        printf("Found %c\n", symbol);
        next_symbol();
        T();
        E1();
    } 
}

void T() {
    if (symbol == NUMBER) {
        printf("Found %d\n", yylval);
        next_symbol();
    } else if (symbol == '(') {
        printf("Found %c\n", symbol);
        next_symbol();
        E();
        if (symbol == ')') {
            printf("Found %c\n", symbol);
            next_symbol();
        } 
    } 
}

int main(){
    next_symbol();
    while(1) {
        Z();
    }
}