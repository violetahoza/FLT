# FLT (Formal Languages and Translators)

This repository contains a collection of language parsers and interpreters built with Lex and Yacc.

## Prerequisites

- flex (or lex)
- bison (or yacc)
- gcc

## Implementations

### Lisp-like Language (l4)

A simple Lisp-like language interpreter supporting basic list operations.

#### Compilation

```bash
flex l4.l
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
flex matrix.l
yacc -d matrix.y
gcc -o MATRIX lex.yy.c y.tab.c -ly -ll -lm
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
flex postfix.l
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
flex postfix.l  # Uses the same lexer
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
flex tree_haskel.l
yacc -d tree_haskel.y
gcc -o TREE_HASKELL lex.yy.c y.tab.c -ly -ll -lm
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
flex tree_ml.l
yacc -d tree_ml.y  # Implementation needed
gcc -o TREE_ML lex.yy.c y.tab.c -ly -ll -lm
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

