%{
#include <stdio.h>
#include <stdlib.h>

#define MAX 10

int yylex(void);
int yyerror(char *s);

typedef struct _line {
    int elems[MAX];
    int no_columns_used;
} line;

typedef struct _matr {
    line *rows[MAX];
    int no_rows_used;
} matr;

matr *mem[26];

matr* add_matrices(matr *a, matr *b);
matr* subtract_matrices(matr *a, matr *b);
matr* multiply_matrices(matr *a, matr *b);
int determinant(matr* m);
matr* create_matrix();
line* create_line();
void print_matrix(matr *m);
void print_line(line *l);
matr* inverse_matrix(matr* m);
matr* power_matrix(matr* m, int power);
matr* identity_matrix(int size);
matr* copy_matrix(matr* src);
void multiply_matrix_by_scalar(matr* m, double scalar);

%}

%union {
    struct _matr *mat;
    struct _line *lin;
    int ival;
}

%token <ival> VAR NUMBER
%type <mat> expr matrix
%type <lin> row

%start input

%%

input:
  | input stmt '\n'
;

stmt:
      VAR '=' matrix ';'      { mem[$1] = $3;}
    | expr ';'                { print_matrix($1); }
    ;


expr:
      expr '+' expr           { $$ = add_matrices($1, $3); }
    | expr '-' expr           { $$ = subtract_matrices($1, $3); }
    | '|' expr '|' { 
        int d = determinant($2);
        matr* m = create_matrix();
        line* l = create_line();
        l->elems[l->no_columns_used++] = d;
        m->rows[m->no_rows_used++] = l;
        $$ = m;
    }
    | expr '*' expr           { $$ = multiply_matrices($1, $3); }
    | 'i' expr                { $$ = inverse_matrix($2); }
    | expr '^' NUMBER         { $$ = power_matrix($1, $3); }
    | VAR                     { $$ = mem[$1]; }
    | '(' expr ')'            { $$ = $2; }
    ;

matrix:
      matrix '\n' row
      {
        $1->rows[$1->no_rows_used++] = $3; 
        $$ = $1;
     }
    | row
      {
        $$ = create_matrix(); 
        $$->rows[$$->no_rows_used++] = $1;
        }
    ;

row:
    row NUMBER {
        $1->elems[$1->no_columns_used++] = $2;
        $$ = $1;
    }
    | NUMBER {
        $$ = create_line();
        $$->elems[$$->no_columns_used++] = $1;
    }
;

%%

line* create_line() {
    line* l = (line*)malloc(sizeof(line));
    if (l == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    l->no_columns_used = 0;
    return l;
}

void print_matrix(matr* m) {
    if (m == NULL) {
        printf("NULL matrix\n");
        return;
    }
    
    for (int i = 0; i < m->no_rows_used; i++) {
        print_line(m->rows[i]);
        printf("\n");
    }
}

void print_line(line* l) {
    for (int i = 0; i < l->no_columns_used; i++) {
        printf("%d ", l->elems[i]);
    }
}

matr* identity_matrix(int size) {
    matr* result = create_matrix();

    for (int i = 0; i < size; i++) {
        line* l = create_line();
        for (int j = 0; j < size; j++) {
            l->elems[l->no_columns_used++] = (i == j) ? 1 : 0;
        }
        result->rows[result->no_rows_used++] = l;
    }

    return result;
}

matr* copy_matrix(matr* src) {
    matr* result = create_matrix();

    for (int i = 0; i < src->no_rows_used; i++) {
        line* l = create_line();
        for (int j = 0; j < src->rows[i]->no_columns_used; j++) {
            l->elems[l->no_columns_used++] = src->rows[i]->elems[j];
        }
        result->rows[result->no_rows_used++] = l;
    }

    return result;
}

void multiply_matrix_by_scalar(matr* m, double scalar) {
    for (int i = 0; i < m->no_rows_used; i++) {
        for (int j = 0; j < m->rows[i]->no_columns_used; j++) {
            m->rows[i]->elems[j] *= scalar;
        }
    }
}

matr* get_cofactor(matr* m, int p, int q, int n) {
    matr* temp = create_matrix();
    int i = 0, j = 0;

    for (int row = 0; row < n; row++) {
        if (row == p)
            continue;

        line* l = create_line();
        j = 0;

        for (int col = 0; col < n; col++) {
            if (col != q) {
                l->elems[l->no_columns_used++] = m->rows[row]->elems[col];
                j++;
            }
        }

        temp->rows[temp->no_rows_used++] = l;
        i++;
    }

    return temp;
}

matr* adjoint(matr* m) {
    int n = m->no_rows_used;
    matr* adj = create_matrix();

    if (n == 1) {
        line* l = create_line();
        l->elems[l->no_columns_used++] = 1;
        adj->rows[adj->no_rows_used++] = l;
        return adj;
    }

    int sign = 1;

    for (int i = 0; i < n; i++) {
        line* l = create_line();
        for (int j = 0; j < n; j++) {
            matr* temp = get_cofactor(m, i, j, n);

            sign = ((i + j) % 2 == 0) ? 1 : -1;

            int det_cof = determinant(temp);

            l->elems[l->no_columns_used++] = sign * det_cof;

        }
        adj->rows[adj->no_rows_used++] = l;
    }

    return adj;
}

matr* inverse_matrix(matr* m) {
    if (m->no_rows_used != m->rows[0]->no_columns_used) {
        fprintf(stderr, "Error: Matrix must be square for inversion\n");
        return NULL;
    }

    int det = determinant(m);

    if (det == 0) {
        fprintf(stderr, "Error: Matrix is singular, cannot find inverse\n");
        return NULL;
    }

    matr* adj = adjoint(m);

    for (int i = 0; i < adj->no_rows_used; i++) {
        for (int j = 0; j < adj->rows[i]->no_columns_used; j++) {
            adj->rows[i]->elems[j] /= det;
        }
    }

    return adj;
}

matr* power_matrix(matr* m, int power) {
    if (m->no_rows_used != m->rows[0]->no_columns_used) {
        fprintf(stderr, "Error: Matrix must be square for power operation\n");
        return NULL;
    }

    int n = m->no_rows_used;

    if (power == 0) {
        return identity_matrix(n);
    }

    if (power < 0) {
        matr* inv = inverse_matrix(m);
        if (!inv) return NULL;

        matr* result = power_matrix(inv, -power);
        return result;
    }

    matr* result = identity_matrix(n);
    matr* base = copy_matrix(m);

    while (power > 0) {
        if (power % 2 == 1) {
            matr* temp = multiply_matrices(result, base);
            result = temp;
        }

        power = power / 2;
        if (power > 0) {
            matr* temp = multiply_matrices(base, base);
            base = temp;
        }
    }

    return result;
}

matr* create_matrix() {
    matr* m = (matr*)malloc(sizeof(matr));
    if (m == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    m->no_rows_used = 0;
    return m;
}

matr* add_matrices(matr* a, matr* b) {
    if (a == NULL || b == NULL) {
        fprintf(stderr, "Cannot add NULL matrices\n");
        return NULL;
    }
    
    if (a->no_rows_used != b->no_rows_used) {
        fprintf(stderr, "Matrices have different number of rows\n");
        return NULL;
    }
    
    for (int i = 0; i < a->no_rows_used; i++) {
        if (a->rows[i]->no_columns_used != b->rows[i]->no_columns_used) {
            fprintf(stderr, "Matrices have incompatible dimensions\n");
            return NULL;
        }
    }
    
    matr* result = create_matrix();
    
    for (int i = 0; i < a->no_rows_used; i++) {
        line* l = create_line();
        for (int j = 0; j < a->rows[i]->no_columns_used; j++) {
            l->elems[l->no_columns_used++] = a->rows[i]->elems[j] + b->rows[i]->elems[j];
        }
        result->rows[result->no_rows_used++] = l;
    }
    
    return result;
}

matr* subtract_matrices(matr* a, matr* b) {
    if (a == NULL || b == NULL) {
        fprintf(stderr, "Cannot subtract NULL matrices\n");
        return NULL;
    }
    
    if (a->no_rows_used != b->no_rows_used) {
        fprintf(stderr, "Matrices have different number of rows\n");
        return NULL;
    }
    
    for (int i = 0; i < a->no_rows_used; i++) {
        if (a->rows[i]->no_columns_used != b->rows[i]->no_columns_used) {
            fprintf(stderr, "Matrices have incompatible dimensions\n");
            return NULL;
        }
    }
    
    matr* result = create_matrix();
    
    for (int i = 0; i < a->no_rows_used; i++) {
        line* l = create_line();
        for (int j = 0; j < a->rows[i]->no_columns_used; j++) {
            l->elems[l->no_columns_used++] = a->rows[i]->elems[j] - b->rows[i]->elems[j];
        }
        result->rows[result->no_rows_used++] = l;
    }
    
    return result;
}

matr* multiply_matrices(matr* a, matr* b) {
    if (a == NULL || b == NULL) {
        fprintf(stderr, "Cannot multiply NULL matrices\n");
        return NULL;
    }
    
    // Check if matrices can be multiplied
    if (a->no_rows_used == 0 || b->no_rows_used == 0) {
        fprintf(stderr, "Cannot multiply empty matrices\n");
        return NULL;
    }
    
    int a_cols = a->rows[0]->no_columns_used;
    
    for (int i = 1; i < a->no_rows_used; i++) {
        if (a->rows[i]->no_columns_used != a_cols) {
            fprintf(stderr, "First matrix has inconsistent number of columns\n");
            return NULL;
        }
    }
    
    int b_cols = b->rows[0]->no_columns_used;
    for (int i = 1; i < b->no_rows_used; i++) {
        if (b->rows[i]->no_columns_used != b_cols) {
            fprintf(stderr, "Second matrix has inconsistent number of columns\n");
            return NULL;
        }
    }
    
    if (a_cols != b->no_rows_used) {
        fprintf(stderr, "Cannot multiply matrices: incompatible dimensions\n");
        return NULL;
    }
    
    matr* result = create_matrix();
    
    for (int i = 0; i < a->no_rows_used; i++) {
        line* l = create_line();
        for (int j = 0; j < b_cols; j++) {
            int sum = 0;
            for (int k = 0; k < a_cols; k++) {
                sum += a->rows[i]->elems[k] * b->rows[k]->elems[j];
            }
            l->elems[l->no_columns_used++] = sum;
        }
        result->rows[result->no_rows_used++] = l;
    }
    
    return result;
}

int determinant(matr* m) {
    if (m == NULL) {
        fprintf(stderr, "Cannot calculate determinant of NULL matrix\n");
        return 0;
    }
    
    if (m->no_rows_used == 0) {
        fprintf(stderr, "Cannot calculate determinant of empty matrix\n");
        return 0;
    }
    
    int n = m->no_rows_used;
    for (int i = 0; i < n; i++) {
        if (m->rows[i]->no_columns_used != n) {
            fprintf(stderr, "Cannot calculate determinant of non-square matrix\n");
            return 0;
        }
    }
    
    if (n == 1) {
        return m->rows[0]->elems[0];
    }
    
    if (n == 2) {
        return m->rows[0]->elems[0] * m->rows[1]->elems[1] - 
               m->rows[0]->elems[1] * m->rows[1]->elems[0];
    }
    
    if (n == 3) {
        int a = m->rows[0]->elems[0];
        int b = m->rows[0]->elems[1];
        int c = m->rows[0]->elems[2];
        int d = m->rows[1]->elems[0];
        int e = m->rows[1]->elems[1];
        int f = m->rows[1]->elems[2];
        int g = m->rows[2]->elems[0];
        int h = m->rows[2]->elems[1];
        int i = m->rows[2]->elems[2];
        
        return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    }
    
    // For larger matrices, use cofactor expansion
    int det = 0;
    int sign = 1;
    for (int j = 0; j < n; j++) {
        matr* cofactor = get_cofactor(m, 0, j, n);
        det += sign * m->rows[0]->elems[j] * determinant(cofactor);
        sign = -sign;
    }
    
    return det;
}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}

int main() {
    yyparse();
    return 0;
}