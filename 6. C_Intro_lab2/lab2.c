#include <stdio.h>  
#include <math.h>  

int main()  
{  
    int a = 256;

    printf("%d\n", a);

    while(a > 1) {
      a = sqrt(a);
      printf("%d\n", a);
    } 

    return 0;
}  

