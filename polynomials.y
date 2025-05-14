%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define MAX_DEGREE 10

    typedef struct _term {
        int coeff;
        int x_exp;
        int y_exp;
        struct _term *next;
    } Term;

    typedef struct _polynom {
        Term *terms;
    } Polynomial;

    Polynomial *initialize_polynomial(void);
    void print_polynomial(const Polynomial *p);
    void add_term(Polynomial *p, int coeff, int x_exp, int y_exp);
    void add_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void subtract_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void multiply_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void derivative_polynomial(Polynomial *result, const Polynomial *p, char var);
    int evaluate_polynomial(const Polynomial *p, int x, int y);
    void free_polynomial(Polynomial *p);
    Term *create_term(int coeff, int x_exp, int y_exp);
    void combine_like_terms(Polynomial *p);

    int yylex(void);
    void yyerror(const char *s) { fprintf(stderr,"Parser error: %s\n",s); }
%}

%union {
    int ival;
    struct _polynom *poly;
    char var;
}

%token XVAR YVAR
%token VALUE
%token <ival> NUMBER
%left '+' '-'
%left '*' '^'
%left '\''
%type <poly> expr monom
%type <var> VARIABLE

%%

input :
      | input expr '\n' {
            printf("= ");
            print_polynomial($2);
            printf("\n");
            free_polynomial($2);
        }
    ;

expr : expr '+' expr {
            Polynomial *r = initialize_polynomial();
            add_polynomials(r, $1, $3);
            $$ = r;
            free_polynomial($1); free_polynomial($3);
        }
        | expr '-' expr {
            Polynomial *r = initialize_polynomial();
            subtract_polynomials(r, $1, $3);
            $$ = r;
            free_polynomial($1); free_polynomial($3);
        }
        | expr '*' expr {
            Polynomial *r = initialize_polynomial();
            multiply_polynomials(r, $1, $3);
            $$ = r;
            free_polynomial($1); free_polynomial($3);
        }
        | '(' expr ')' '\'' VARIABLE {
            Polynomial *r = initialize_polynomial();
            derivative_polynomial(r, $2, $5);
            $$ = r;
            free_polynomial($2);
        }
        | VALUE '[' expr ',' NUMBER ',' NUMBER ']' {
            int result = evaluate_polynomial($3, $5, $7);
            printf("> %d\n", result);
            // Create a constant polynomial with the result
            Polynomial *r = initialize_polynomial();
            add_term(r, result, 0, 0);
            $$ = r;
            free_polynomial($3);
        }
        | '(' expr ')'    { $$ = $2; }
        | monom           { $$ = $1; }
        ;

monom : NUMBER '*' VARIABLE '^' NUMBER {
            Polynomial *r = initialize_polynomial();
            if ($5 <= MAX_DEGREE) {
                if ($3 == 'X') add_term(r, $1, $5, 0);
                else add_term(r, $1, 0, $5);
            }
            else fprintf(stderr,"Degree too high: %d\n",$5);
            $$ = r;
        }
        | NUMBER VARIABLE '^' NUMBER    /* Allow NUMBER VARIABLE without * */ {
            Polynomial *r = initialize_polynomial();
            if ($4 <= MAX_DEGREE) {
                if ($2 == 'X') add_term(r, $1, $4, 0);
                else add_term(r, $1, 0, $4);
            }
            else fprintf(stderr,"Degree too high: %d\n",$4);
            $$ = r;
        }
        | VARIABLE '^' NUMBER {
            Polynomial *r = initialize_polynomial();
            if ($3 <= MAX_DEGREE) {
                if ($1 == 'X') add_term(r, 1, $3, 0);
                else add_term(r, 1, 0, $3);
            }
            else fprintf(stderr,"Degree too high: %d\n",$3);
            $$ = r;
        }
        | NUMBER '*' VARIABLE {
            Polynomial *r = initialize_polynomial();
            if ($3 == 'X') add_term(r, $1, 1, 0);
            else add_term(r, $1, 0, 1);
            $$ = r;
        }
        | NUMBER VARIABLE    /* Allow NUMBER VARIABLE without * */ {
            Polynomial *r = initialize_polynomial();
            if ($2 == 'X') add_term(r, $1, 1, 0);
            else add_term(r, $1, 0, 1);
            $$ = r;
        }
        | VARIABLE {
            Polynomial *r = initialize_polynomial();
            if ($1 == 'X') add_term(r, 1, 1, 0);
            else add_term(r, 1, 0, 1);
            $$ = r;
        }
        | NUMBER '*' VARIABLE '*' VARIABLE {
            Polynomial *r = initialize_polynomial();
            if ($3 == 'X' && $5 == 'Y') add_term(r, $1, 1, 1);
            else if ($3 == 'Y' && $5 == 'X') add_term(r, $1, 1, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER VARIABLE VARIABLE    /* Allow NUMBER VARIABLE VARIABLE without * */ {
            Polynomial *r = initialize_polynomial();
            if ($2 == 'X' && $3 == 'Y') add_term(r, $1, 1, 1);
            else if ($2 == 'Y' && $3 == 'X') add_term(r, $1, 1, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER '*' VARIABLE '*' VARIABLE '^' NUMBER {
            Polynomial *r = initialize_polynomial();
            if ($3 == 'X' && $5 == 'Y') add_term(r, $1, 1, $7);
            else if ($3 == 'Y' && $5 == 'X') add_term(r, $1, $7, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER VARIABLE VARIABLE '^' NUMBER    /* Allow without * */ {
            Polynomial *r = initialize_polynomial();
            if ($2 == 'X' && $3 == 'Y') add_term(r, $1, 1, $5);
            else if ($2 == 'Y' && $3 == 'X') add_term(r, $1, $5, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | VARIABLE '*' VARIABLE {
            Polynomial *r = initialize_polynomial();
            if ($1 == 'X' && $3 == 'Y') add_term(r, 1, 1, 1);
            else if ($1 == 'Y' && $3 == 'X') add_term(r, 1, 1, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | VARIABLE VARIABLE    /* Allow VARIABLE VARIABLE without * */ {
            Polynomial *r = initialize_polynomial();
            if ($1 == 'X' && $2 == 'Y') add_term(r, 1, 1, 1);
            else if ($1 == 'Y' && $2 == 'X') add_term(r, 1, 1, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | VARIABLE '*' VARIABLE '^' NUMBER {
            Polynomial *r = initialize_polynomial();
            if ($1 == 'X' && $3 == 'Y') add_term(r, 1, 1, $5);
            else if ($1 == 'Y' && $3 == 'X') add_term(r, 1, $5, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | VARIABLE VARIABLE '^' NUMBER    /* Allow without * */ {
            Polynomial *r = initialize_polynomial();
            if ($1 == 'X' && $2 == 'Y') add_term(r, 1, 1, $4);
            else if ($1 == 'Y' && $2 == 'X') add_term(r, 1, $4, 1);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER '*' VARIABLE '^' NUMBER '*' VARIABLE '^' NUMBER {
            Polynomial *r = initialize_polynomial();
            if ($3 == 'X' && $7 == 'Y') add_term(r, $1, $5, $9);
            else if ($3 == 'Y' && $7 == 'X') add_term(r, $1, $9, $5);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER VARIABLE '^' NUMBER VARIABLE '^' NUMBER    /* Allow without * */ {
            Polynomial *r = initialize_polynomial();
            if ($2 == 'X' && $5 == 'Y') add_term(r, $1, $4, $7);
            else if ($2 == 'Y' && $5 == 'X') add_term(r, $1, $7, $4);
            else fprintf(stderr, "Invalid variable combination\n");
            $$ = r;
        }
        | NUMBER {
            Polynomial *r = initialize_polynomial();
            add_term(r, $1, 0, 0);
            $$ = r;
        }
        ;

VARIABLE : XVAR { $$ = 'X'; }
         | YVAR { $$ = 'Y'; }
         ;

%%

Polynomial *initialize_polynomial(void)
{
    Polynomial *p = malloc(sizeof *p);
    if (!p) { perror("malloc"); exit(EXIT_FAILURE); }
    p->terms = NULL;
    return p;
}

Term *create_term(int coeff, int x_exp, int y_exp)
{
    Term *t = malloc(sizeof(Term));
    if (!t) { perror("malloc"); exit(EXIT_FAILURE); }
    t->coeff = coeff;
    t->x_exp = x_exp;
    t->y_exp = y_exp;
    t->next = NULL;
    return t;
}

void add_term(Polynomial *p, int coeff, int x_exp, int y_exp)
{
    Term *new_term = create_term(coeff, x_exp, y_exp);
    
    if (p->terms == NULL) {
        p->terms = new_term;
    } else {
        Term *last = p->terms;
        while (last->next != NULL) {
            last = last->next;
        }
        last->next = new_term;
    }
}

void print_polynomial(const Polynomial *p)
{
    if (p->terms == NULL) {
        printf("0");
        return;
    }

    Term *current = p->terms;
    int first = 1;

    while (current != NULL) {
        if (!first) {
            printf(" %c ", current->coeff >= 0 ? '+' : '-');
        } else if (current->coeff < 0) {
            printf("-");
        }

        int abs_coeff = abs(current->coeff);
        int printed_coeff = 0;

        if (abs_coeff != 1 || (current->x_exp == 0 && current->y_exp == 0)) {
            printf("%d", abs_coeff);
            printed_coeff = 1;
        }

        if (current->x_exp > 0) {
            if (printed_coeff) printf("*");
            printf("X");
            if (current->x_exp > 1) {
                printf("^%d", current->x_exp);
            }
            printed_coeff = 1;
        }

        if (current->y_exp > 0) {
            if (printed_coeff) printf("*");
            printf("Y");
            if (current->y_exp > 1) {
                printf("^%d", current->y_exp);
            }
        }

        first = 0;
        current = current->next;
    }
}

void combine_like_terms(Polynomial *p)
{
    Term *current = p->terms;
    while (current != NULL) {
        Term *runner = current->next;
        Term *prev = current;
        
        while (runner != NULL) {
            if (current->x_exp == runner->x_exp && current->y_exp == runner->y_exp) {
                current->coeff += runner->coeff;
                prev->next = runner->next;
                free(runner);
                runner = prev->next;
            } else {
                prev = runner;
                runner = runner->next;
            }
        }
        
        // Remove this term if coefficient became zero
        if (current->coeff == 0) {
            Term *to_remove = current;
            current = current->next;
            if (p->terms == to_remove) {
                p->terms = current;
            } else {
                // Need to find previous term
                Term *prev = p->terms;
                while (prev != NULL && prev->next != to_remove) {
                    prev = prev->next;
                }
                if (prev != NULL) {
                    prev->next = current;
                }
            }
            free(to_remove);
        } else {
            current = current->next;
        }
    }
}

void add_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    Term *current = p1->terms;
    while (current != NULL) {
        add_term(result, current->coeff, current->x_exp, current->y_exp);
        current = current->next;
    }
    
    current = p2->terms;
    while (current != NULL) {
        add_term(result, current->coeff, current->x_exp, current->y_exp);
        current = current->next;
    }
    
    combine_like_terms(result);
}

void subtract_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    Term *current = p1->terms;
    while (current != NULL) {
        add_term(result, current->coeff, current->x_exp, current->y_exp);
        current = current->next;
    }
    
    current = p2->terms;
    while (current != NULL) {
        add_term(result, -current->coeff, current->x_exp, current->y_exp);
        current = current->next;
    }
    
    combine_like_terms(result);
}

void multiply_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    Term *t1 = p1->terms;
    while (t1 != NULL) {
        Term *t2 = p2->terms;
        while (t2 != NULL) {
            int new_coeff = t1->coeff * t2->coeff;
            int new_x_exp = t1->x_exp + t2->x_exp;
            int new_y_exp = t1->y_exp + t2->y_exp;
            
            if (new_x_exp <= MAX_DEGREE && new_y_exp <= MAX_DEGREE) {
                add_term(result, new_coeff, new_x_exp, new_y_exp);
            } else {
                fprintf(stderr, "Degree too high in multiplication\n");
            }
            
            t2 = t2->next;
        }
        t1 = t1->next;
    }
    
    combine_like_terms(result);
}

void derivative_polynomial(Polynomial *result, const Polynomial *p, char var)
{
    Term *current = p->terms;
    while (current != NULL) {
        if (var == 'X') {
            if (current->x_exp > 0) {
                int new_coeff = current->coeff * current->x_exp;
                int new_x_exp = current->x_exp - 1;
                add_term(result, new_coeff, new_x_exp, current->y_exp);
            }
            // Terms with x_exp = 0 (no X) are treated as constants and disappear
        }
        else if (var == 'Y') {
            if (current->y_exp > 0) {
                int new_coeff = current->coeff * current->y_exp;
                int new_y_exp = current->y_exp - 1;
                add_term(result, new_coeff, current->x_exp, new_y_exp);
            }
            // Terms with y_exp = 0 (no Y) are treated as constants and disappear
        }
        current = current->next;
    }
}

int evaluate_polynomial(const Polynomial *p, int x, int y)
{
    int result = 0;
    Term *current = p->terms;
    
    while (current != NULL) {
        int term_value = current->coeff;
        
        // Calculate X part
        if (current->x_exp > 0) {
            int x_pow = 1;
            for (int i = 0; i < current->x_exp; i++) {
                x_pow *= x;
            }
            term_value *= x_pow;
        }
        
        // Calculate Y part
        if (current->y_exp > 0) {
            int y_pow = 1;
            for (int i = 0; i < current->y_exp; i++) {
                y_pow *= y;
            }
            term_value *= y_pow;
        }
        
        result += term_value;
        current = current->next;
    }
    
    return result;
}

void free_polynomial(Polynomial *p)
{
    Term *current = p->terms;
    while (current != NULL) {
        Term *next = current->next;
        free(current);
        current = next;
    }
    free(p);
}

int main(void)
{
    return yyparse();
}
