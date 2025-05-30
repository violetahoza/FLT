# FLT (Formal Languages and Translators)

This repository contains a collection of language parsers and interpreters built with Lex and Yacc.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Implementations](#implementations)
  - [Lisp-like Language (l4)](#lisp-like-language-l4)
  - [Matrix Calculator](#matrix-calculator)
  - [Infix to Postfix Converter](#infix-to-postfix-converter)
  - [Infix to Prefix Converter](#infix-to-prefix-converter)
  - [Binary Tree Interpreter (Haskell-style)](#binary-tree-interpreter-haskell-style)
  - [Binary Tree Interpreter (ML-style)](#binary-tree-interpreter-ml-style)
  - [Polynomials Interpreter](#polynomials-interpreter)
  - [Simple Expression Parser](#simple-expression-parser)
  - [List Operations Parser](#list-operations-parser)
  - [Binary Search Trees in Haskell](#binary-search-trees-in-haskell)

## Prerequisites

- lex (or flex)
- yacc (or bison)
- gcc

## Implementations

### Lisp-like Language (l4)

A simple Lisp-like language interpreter supporting basic list operations.

#### Compilation

```bash
lex l4.l
yacc -d l4.y
gcc -o LISP lex.yy.c y.tab.c -ly -ll
```

#### Usage

```bash
./LISP
```

#### Example Commands

```lisp
'(1 2 3)
(CAR '(1 2 3))        # Returns first element
(CDR '(1 2 3))        # Returns rest of the list
(CONS 1 '(2 3))       # Adds element to list
(APPEND '(1 2) '(3 4)) # Combines lists
```

### Matrix Calculator

A parser for matrix operations with support for various matrix calculations.

#### Compilation

```bash
lex matrix.l
yacc -d matrix.y
gcc -o MATRIX lex.yy.c y.tab.c -ly -ll
```

#### Usage

```bash
./MATRIX
```

#### Example Operations

```
# Define matrices
A = 1 2 3
    4 5 6
    7 8 9;
    
B = 1 0 0
    0 1 0
    0 0 1;
    
# Operations
A + B;     # Addition
A - B;     # Subtraction
A * B;     # Multiplication
|A|;       # Determinant
iA;        # Inverse
A^2;       # Power
```

### Infix to Postfix Converter

Converts mathematical expressions from infix to postfix (Reverse Polish) notation.

#### Compilation

```bash
lex postfix.l
yacc -d postfix.y
gcc -o POSTFIX lex.yy.c y.tab.c -ly -ll
```

#### Usage

```bash
./POSTFIX
```

#### Examples

```
a + b * c       # Converts to: a b c * +
(a + b) * (c - d) # Converts to: a b + c d - *
```

### Infix to Prefix Converter

Converts mathematical expressions from infix to prefix (Polish) notation.

#### Compilation

```bash
lex postfix.l  # Uses the same lexer
yacc -d prefix.y
gcc -o PREFIX lex.yy.c y.tab.c -ly -ll
```

#### Usage

```bash
./PREFIX
```

#### Examples

```
a + b * c       # Converts to: + a * b c
(a + b) * (c - d) # Converts to: * + a b - c d
```

### Binary Tree Interpreter (Haskell-style)

Binary tree operations using Haskell-like syntax.

#### Compilation

```bash
lex tree_haskel.l
yacc -d tree_haskel.y
gcc -o TREE_HASKELL lex.yy.c y.tab.c -ly -ll 
```

#### Usage

```bash
./TREE_HASKELL
```

#### Examples

```
# Create a node
Node Lf 10 Lf

# Insert a value
insert 5 (Node Lf 10 Lf)

# Find a value
find 5 (Node Lf 10 (Node Lf 12 Lf))

# Count nodes
count (Node (Node Lf 5 Lf) 10 (Node Lf 15 Lf))

# Check if balanced
balanced (Node (Node Lf 5 Lf) 10 (Node Lf 15 Lf))

# Delete a node
delete 10 (Node (Node Lf 5 Lf) 10 (Node Lf 15 Lf))
```

### Binary Tree Interpreter (ML-style)

Binary tree operations using ML-like syntax with comma-separated parameters.

#### Compilation

```bash
lex tree_ml.l
yacc -d tree_ml.y  
gcc -o TREE_ML lex.yy.c y.tab.c -ly -ll 
```

#### Usage

```bash
./TREE_ML
```

#### Examples

```
# Create a node
Node(Lf, 10, Lf)

# Insert a value
insert(5, Node(Lf, 10, Lf))
```

### Polynomials Interpreter

A lexico-syntactic analyzer that executes operations (addition, subtraction, multiplication, derivation) on polynomials with a single variable. 

#### Compilation

```bash
lex polynomials.l
yacc -d polynomials.y 
gcc -o polynomials lex.yy.c y.tab.c -ly -ll -lm
```

#### Usage

```bash
./polynomials
```

#### Examples

```
# Multiplication
(2 Y ^ 3 + 3 Y ^ 2 – Y + 5) * (Y ^ 2 – 4)
> 2 Y ^ 5 + 3 Y ^ 4 – 9 Y ^ 3 – 7 Y ^ 2 + 4 Y ^ 1 – 20 
# Derivation
(2 Y ^ 3 + 3 Y ^ 2 – Y + 5)’Y
> 6 Y ^ 2 + 6 Y ^ 1 – 1 
# Compute the value of a polynomial in a point
value [2 * Y ^ 3 + 3 * Y ^ 2 – Y + 5, 0, 2]
> 31
# Addition / subtraction on polynomials with 2 variables
(3 * X ^ 1 + 2 * X ^ 2 * Y ^ 3) + (3 * X ^ 2 * Y ^ 3 + 2 * Y ^ 3) 
> 2 * Y ^ 3 + 3 * X + 5 * X ^ 2 * Y ^ 3
```

### Simple Expression Parser

A recursive descent parser for simple arithmetic expressions supporting addition and subtraction operations.

#### Usage

```bash
lex addsub.l
gcc -o ADDSUB addsub.c lex.yy.c -ll
./ADDSUB
```

### List Operations Parser

A recursive descent parser for list operations in Haskell.

#### Usage

```bash
lex lists.l
gcc -o LISTS lists.c lex.yy.c -ll
./LISTS
```

#### Examples

```
# Create lists
[1, 2, 3, 4, 5]

# Concatenate lists
[1, 2] ++ [3, 4]        # Result: [1, 2, 3, 4]

# Take first n elements
take [1, 2, 3, 4, 5] 3  # Result: [1, 2, 3]

# Drop first n elements
drop [1, 2, 3, 4, 5] 2  # Result: [3, 4, 5]

# CONS operation (add to front)
1 : [2, 3, 4]           # Result: [1, 2, 3, 4]
```

### Binary Search Trees in Haskell

A recursive descent parser implementation for binary search trees, demonstrating parsing without Yacc.

#### Usage

```bash
lex trees.l
gcc -o TREES trees.c lex.yy.c -ll
./TREES
```

#### Examples

```
# Create a leaf node
Node Lf 10 Lf

# Insert values into a tree
insert 5 (Node Lf 10 Lf)

# Count nodes in a tree
count (Node (Node Lf 5 Lf) 10 (Node Lf 15 Lf))

# Complex tree operations
insert 15 (insert 5 (Node Lf 10 Lf))
```
