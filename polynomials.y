%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define MAX_DEGREE 10

    typedef struct _polynom {
        int coeffs[MAX_DEGREE + 1];
    } Polynomial;

    Polynomial *initialize_polynomial(void);
    void print_polynomial(const Polynomial *p);
    void add_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void subtract_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void multiply_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2);
    void derivative_polynomial(Polynomial *result, const Polynomial *p);
    int evaluate_polynomial(const Polynomial *p, int x);

    int yylex(void);
    void yyerror(const char *s) { fprintf(stderr,"Parser error: %s\n",s); }
%}

%union {
    int ival;
    struct _polynom  *poly;
}

%token VARIABLE
%token VALUE
%token <ival> NUMBER
%left '+' '-'
%left '*'
%left '\''
%type <poly> expr monom

%%

input
        :
        | input expr '\n'
              {
                  printf("= ");
                  print_polynomial($2);
                  printf("\n");
                  free($2);
              }
        ;

expr
        : expr '+' expr
              {
                  Polynomial *r = initialize_polynomial();
                  add_polynomials(r, $1, $3);
                  $$ = r;
                  free($1); free($3);
              }
        | expr '-' expr
              {
                  Polynomial *r = initialize_polynomial();
                  subtract_polynomials(r, $1, $3);
                  $$ = r;
                  free($1); free($3);
              }
        | expr '*' expr
              {
                  Polynomial *r = initialize_polynomial();
                  multiply_polynomials(r, $1, $3);
                  $$ = r;
                  free($1); free($3);
              }
        | '(' expr ')' '\''
           {
                Polynomial *r = initialize_polynomial();
                derivative_polynomial(r, $2);
                $$ = r;
                free($2);
            }
        | VALUE '[' expr ',' NUMBER ']'
            {
                int result = evaluate_polynomial($3, $5);
                printf("> %d\n", result);
                // Create a constant polynomial with the result
                Polynomial *r = initialize_polynomial();
                r->coeffs[0] = result;
                $$ = r;
                free($3);
            }
        | '(' expr ')'    { $$ = $2; }
        | monom           { $$ = $1; }
        ;

monom
        : NUMBER '*' VARIABLE '^' NUMBER
              {
                  Polynomial *r = initialize_polynomial();
                  if ($5 <= MAX_DEGREE)      r->coeffs[$5] = $1;
                  else fprintf(stderr,"Degree too high: %d\n",$5);
                  $$ = r;
              }
        | VARIABLE '^' NUMBER
              {
                  Polynomial *r = initialize_polynomial();
                  if ($3 <= MAX_DEGREE)      r->coeffs[$3] = 1;
                  else fprintf(stderr,"Degree too high: %d\n",$3);
                  $$ = r;
              }
        | NUMBER '*' VARIABLE
              {
                  Polynomial *r = initialize_polynomial();
                  r->coeffs[1] = $1;
                  $$ = r;
              }
        | VARIABLE
              {
                  Polynomial *r = initialize_polynomial();
                  r->coeffs[1] = 1;
                  $$ = r;
              }
        | NUMBER
              {
                  Polynomial *r = initialize_polynomial();
                  r->coeffs[0] = $1;
                  $$ = r;
              }
        ;

%%

Polynomial *initialize_polynomial(void)
{
    Polynomial *p = malloc(sizeof *p);
    if (!p) { perror("malloc"); exit(EXIT_FAILURE); }
    memset(p, 0, sizeof *p);
    return p;
}

void print_polynomial(const Polynomial *p)
{
    int first = 1;
    for (int i = MAX_DEGREE; i >= 0; --i)
    {
        int c = p->coeffs[i];
        if (!c) continue;

        if (!first)
            printf(" %c ", c >= 0 ? '+' : '-');
        else if (c < 0)
            putchar('-');

        int a = abs(c);
        if (i == 0)
            printf("%d", a);
        else if (i == 1)
            a == 1 ? printf("Y") : printf("%d*Y", a);
        else
            a == 1 ? printf("Y^%d", i) : printf("%d*Y^%d", a, i);

        first = 0;
    }
    if (first) printf("0");
}

void add_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    for (int i = 0; i <= MAX_DEGREE; ++i)
        result->coeffs[i] = p1->coeffs[i] + p2->coeffs[i];
}

void subtract_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    for (int i = 0; i <= MAX_DEGREE; ++i)
        result->coeffs[i] = p1->coeffs[i] - p2->coeffs[i];
}

void multiply_polynomials(Polynomial *result, const Polynomial *p1, const Polynomial *p2)
{
    for (int i = 0; i <= MAX_DEGREE; ++i) {
        for (int j = 0; j <= MAX_DEGREE; ++j) {
            if (i + j <= MAX_DEGREE) {
                result->coeffs[i + j] += p1->coeffs[i] * p2->coeffs[j];
            }
        }
    }
}

void derivative_polynomial(Polynomial *result, const Polynomial *p)
{
    for (int i = 1; i <= MAX_DEGREE; ++i) {
        if (p->coeffs[i] != 0) {
            result->coeffs[i - 1] = p->coeffs[i] * i;
        }
    }
}

int evaluate_polynomial(const Polynomial *p, int x)
{
    int result = 0;
    int power = 1; 

    for (int i = 0; i <= MAX_DEGREE; ++i) {
        result += p->coeffs[i] * power;
        power *= x; 
    }

    return result;
}

int main(void)
{
    return yyparse();
}