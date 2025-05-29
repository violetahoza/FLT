#include <stdio.h>
#include <stdlib.h>

#define NUMBER 256
#define NODE 257
#define LF 258
#define INSERT 259
#define COUNT 260

typedef struct _tree {
    int key;
    struct _tree *left, *right;
} tree;

extern int yylval;
int symbol;

void E();
int IE();
tree* TE();
tree* T();
int yylex();
void next_symbol();

int count_nodes(tree* root);
tree* insert_node(tree* root, int key);
void print_tree(tree* root);

void next_symbol() { 
    symbol = yylex(); 
} 

void E() {
    if (symbol == COUNT || symbol == '(' || symbol == NUMBER) {
        IE();
    } else if (symbol == INSERT || symbol == '(' || symbol == NODE || symbol == LF) {
        TE();
    } 
}

int IE() {
    if (symbol == COUNT) {
        printf("Found 'COUNT'\n");
        next_symbol();
        tree* root = TE();
        int c = count_nodes(root);
        printf("Node count: %d\n", c);
        return c;
    } else if (symbol == '(') {
        printf("Found '('\n");
        next_symbol();
        int val = IE();
        if (symbol == ')') {
            printf("Found ')'\n");
            next_symbol();
        } 
        return val;
    } else if (symbol == NUMBER) {
        int val = yylval;
        printf("Found NUMBER: %d\n", val);
        next_symbol();
        return val;
    } 
}

tree* TE() {
    if (symbol == INSERT) {
        printf("Found 'INSERT'\n");
        next_symbol();
        int key = IE();
        tree* root = TE();
        return insert_node(root, key);
    } else if (symbol == '(') {
        printf("Found '('\n");
        next_symbol();
        tree* t = TE();
        if (symbol == ')') {
            printf("Found ')'\n");
            next_symbol();
        }
        return t;
    } else if (symbol == NODE || symbol == LF) {
        return T();
    } 
}

tree* T() {
    if (symbol == NODE) {
        printf("Found 'NODE'\n");
        next_symbol();
        tree* left = T();
        if (symbol == NUMBER) {
            int key = yylval;
            printf("Found NUMBER: %d\n", key);
            next_symbol();
            tree* right = T();
            tree* node = (tree*)malloc(sizeof(tree));
            node->key = key;
            node->left = left;
            node->right = right;
            return node;
        } 
    } else if (symbol == '(') {
        printf("Found '('\n");
        next_symbol();
        tree* t = T();
        if (symbol == ')') {
            printf("Found ')'\n");
            next_symbol();
        }
        return t;
    } else if (symbol == LF) {
        printf("Found 'LF'\n");
        next_symbol();
        return NULL;
    } 
}

int count_nodes(tree* root) {
    if (!root) return 0;
    return 1 + count_nodes(root->left) + count_nodes(root->right);
}

tree* insert_node(tree* root, int key) {
    if (!root) {
        tree* new_node = (tree*)malloc(sizeof(tree));
        new_node->key = key;
        new_node->left = NULL;
        new_node->right = NULL;
        return new_node;
    }
    if (key < root->key) {
        root->left = insert_node(root->left, key);
    } else {
        root->right = insert_node(root->right, key);
    }
    return root;
}

void print_tree(tree* tree) {
    if (tree == NULL) {
        printf("Lf");
        return;
    }

    printf("Node ");

    if (tree->left == NULL) {
        printf("Lf ");
    } else {
        printf("(");
        print_tree(tree->left);
        printf(") ");
    }

    printf("%d ", tree->key);

    if (tree->right == NULL) {
        printf("Lf");
    } else {
        printf("(");
        print_tree(tree->right);
        printf(")");
    }
}

int main() {
    next_symbol();
    while (symbol != 0) {
        E();
    }
    return 0;
}
