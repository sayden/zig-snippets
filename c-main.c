// gcc -o c-main main.c -L. -lmylib
#include <stdio.h>
 
// declare the function, ideally the library has a .h file for this
int double_me(int);
 
int main(void)                 
{
    int i;
    for (i = 1; i <= 10; i++) {
        // call our library function
        printf("%d doubled is %d\n", i, double_me(i));
    }
    return 0;
}