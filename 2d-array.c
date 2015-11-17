#include <stdio.h>

int main()
{
   int (*ptr)[2];
   int arr[2][2]={{17,9},{3,2}};
   ptr = arr;
   printf("%d\n", (*ptr)[0]);
   printf("%d\n", (*ptr)[1]);
   printf("%d\n", (*ptr+1)[1]);
   printf("%d\n", (*ptr+1)[2]);
   return 0;
}
