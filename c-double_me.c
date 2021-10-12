#include <stdio.h>

int double_me(int a);

int main(int argc, char **argv) {
    int result = double_me(8);
    printf("%d\n", result);
    return 0;
}