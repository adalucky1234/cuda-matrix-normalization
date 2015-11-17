#include <stdio.h>

void func(int *ptr){
    printf("%d\n", (ptr+0)[0]);
    printf("%d\n", (ptr+0)[1]);
    printf("%d\n", (ptr+1)[1]);
    printf("%d\n", (ptr+1)[2]);
}

int main()
{
   int (*ptr)[2];
   int arr[2][2]={{17,9},{3,2}};
   ptr = arr;
   func(*ptr);
   arr = ptr;
   return 0;
}
