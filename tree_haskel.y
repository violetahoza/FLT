%{
#include <stdio.h>
#include <stdlib.h>

typedef struct _node {
    int key;
    struct _node *left, *right;
} node;

node* create_node(int key, node* left, node* right);
node* insert_node(int key, node* tree);
node* delete_node(int key, node* tree);
int count_nodes(node* tree);
int find_node(int key, node* tree);
int is_balanced(node* tree);
void print_tree(node* tree);

void yyerror(const char* s);
extern int yylex(void);
%}

%union {
    int ival;
    struct _node *btree;
}

%token <ival> NUMBER
%token NODE LF INSERT COUNT FIND DELETE BALANCED

%type <btree> tree t_expr
%type <ival> i_expr

%left '(' ')'

%%

input   : /* empty */
        | input line
        ;
        
line    : expr '\n'    
        | expr       
        ;
        
expr    : i_expr     { 
            if (!yylval.ival) {
                /* Skip printing for boolean operations that already printed their result */
            } else {
                printf("> %d\n", $1); 
            }
          } 
        | t_expr     { printf("> "); print_tree($1); printf("\n"); } 
        ;

i_expr  : COUNT t_expr       { $$ = count_nodes($2); yylval.ival = 1; }
        | '(' i_expr ')'     { $$ = $2; }
        | NUMBER             { $$ = $1; yylval.ival = 1; }
        | FIND NUMBER t_expr { 
            printf("> %s\n", find_node($2, $3) ? "true" : "false"); 
            yylval.ival = 0; 
            $$ = 0; 
          }
        | BALANCED t_expr    { 
            printf("> %s\n", is_balanced($2) ? "true" : "false"); 
            yylval.ival = 0; 
            $$ = 0; 
          }
        ; 

t_expr  : INSERT i_expr t_expr   { $$ = insert_node($2, $3); }
        | '(' t_expr ')'         { $$ = $2; }
        | tree                   { $$ = $1; }
        | DELETE NUMBER t_expr   { $$ = delete_node($2, $3); }
        ;

tree    : NODE LF NUMBER LF                      { $$ = create_node($3, NULL, NULL); }
        | NODE '(' tree ')' NUMBER LF            { $$ = create_node($5, $3, NULL); }
        | NODE LF NUMBER '(' tree ')'            { $$ = create_node($3, NULL, $5); }
        | NODE '(' tree ')' NUMBER '(' tree ')'  { $$ = create_node($5, $3, $7); }
        | '(' tree ')'                           { $$ = $2; }
        | LF                                     { $$ = NULL; }
        ;

%%

node* create_node(int key, node* left, node* right) {
    node* new_node = (node*)malloc(sizeof(node));
    if (!new_node) {
        fprintf(stderr, "Memory allocation error\n");
        exit(1);
    }
    new_node->key = key;
    new_node->left = left;
    new_node->right = right;
    return new_node;
}

node* insert_node(int key, node* tree) {
    if (tree == NULL) {
        return create_node(key, NULL, NULL);
    }
    if (key < tree->key) {
        tree->left = insert_node(key, tree->left);
    } else if (key > tree->key) {
        tree->right = insert_node(key, tree->right);
    }
    return tree;
}

int count_nodes(node* tree) {
    if (tree == NULL) {
        return 0;
    }
    return 1 + count_nodes(tree->left) + count_nodes(tree->right);
}

int find_node(int key, node* tree) {
    // find 12 (Node (Node Lf 2 Lf) 10 (Node Lf 12 Lf)) 
    if (tree == NULL) {
        return 0;
    }
    if (key == tree->key) {
        return 1;
    } else if (key < tree->key) {
        return find_node(key, tree->left);
    } else {
        return find_node(key, tree->right);
    }
}

void print_tree(node* tree) {
    if (tree == NULL) {
        printf("Lf");
        return;
    }

    printf("Node ");
    
    if (tree->left == NULL) {
        printf("Lf");
    } else {
        printf("(");
        print_tree(tree->left);
        printf(")");
    }
    
    printf(" %d ", tree->key);
    
    if (tree->right == NULL) {
        printf("Lf");
    } else {
        printf("(");
        print_tree(tree->right);
        printf(")");
    }
}

int height(node* tree) {
    if (tree == NULL) {
        return 0;
    }

    int left_height = height(tree->left);
    int right_height = height(tree->right);

    return (left_height > right_height) ? left_height + 1 : right_height + 1;
}

int is_balanced(node* tree) {
    // balanced (Node (Node Lf 2 Lf) 10 (Node Lf 12 Lf)) 
    if (tree == NULL) {
        return 1; 
    }

    int left_height = height(tree->left);
    int right_height = height(tree->right);

    if (abs(left_height - right_height) <= 1 && 
        is_balanced(tree->left) && 
        is_balanced(tree->right)) {
        return 1; 
    }

    return 0; 
}

node* delete_node(int key, node* tree) {
    // delete 12 (Node (Node Lf 2 Lf) 10 (Node Lf 12 Lf)) 
    if (tree == NULL) {
        return NULL;
    }

    if (key < tree->key) {
        tree->left = delete_node(key, tree->left);
    } else if (key > tree->key) {
        tree->right = delete_node(key, tree->right);
    } else {
        if(tree->left == NULL && tree->right == NULL) { // leaf node
            free(tree);
            return NULL;
        } 

        if (tree->left == NULL) { // one child
            node* temp = tree->right;
            free(tree);
            return temp;
        } 
        
        if (tree->right == NULL) { // one child
            node* temp = tree->left;
            free(tree);
            return temp;
        }

        // two children
        node* successor_parent = tree;
        node* successor = tree->right;
        
        // find the leftmost node in the right subtree
        while (successor->left != NULL) {
            successor_parent = successor;
            successor = successor->left;
        }
        
        // copy successor's key to current node
        tree->key = successor->key;
        
        // remove the successor
        if (successor_parent == tree) {
            successor_parent->right = successor->right;
        } else {
            successor_parent->left = successor->right;
        }
        
        free(successor);
        return tree;
    }
    return tree;
}

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Binary Tree Interpreter (Haskell syntax)\n");
    yyparse();
    return 0;
}