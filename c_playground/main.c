#include "gmp.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, const char * argv[]) {
    long long n = 3 * 5915587277; // Primes: 79 * 83

    int *p_array = (int *)malloc(sizeof(int)*50);      // TO DO: unhandled error
    int array_size = 0;
    int floor_limit = 3;
    long long upper_limit = n/2;
    
    for(int i=floor_limit; i <= upper_limit; i += 2) {
        if (n % i == 0){
            int y=floor_limit;
            do {
                if (i != y && i % y == 0){
                    printf("[+]Found a non-prime: %d\n",i);
                }
                
                y += 2;
                
            }while( y < i );
            
            p_array[array_size] = i;
            array_size++;
        }
    }
    
    for(int i=0; i < array_size; i++)
        printf("[+]Found: %d\n",p_array[i]);
    
    if (array_size == 0)
        printf("[+]Nothing found. Potential prime\n");
    free(p_array);
    p_array = NULL;

    return 0;
}
