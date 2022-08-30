#include <stdio.h>

void hello() {
    puts("Message from C: hello");
}

int greater(int a, int b) {
    if (a > b)
        return a;
    else
        return b;
}