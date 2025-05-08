#ifndef LIST_H
#define LIST_H

typedef struct List {
    int value;
    struct List* next;
} List;

List* cons(int value, List* list);
int car(List* list);
List* cdr(List* list);
List* append(List* l1, List* l2);
void print_list(List* list);

#endif