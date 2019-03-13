#include "gmp.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, const char * argv[]) {
    
    /******************* Naive Trial Division Algorithm *******************/
    
    unsigned long long n;

    n = atoi(argv[1]);
    printf("String value = %s, Int value = %llu\n", argv[1], n);
    
    int floor_limit = 3;
    unsigned long long upper_limit = n/2;
    
    for(int i=floor_limit; i <= upper_limit; i += 2) {
        if (n % i == 0){
            // check for primes
            int y=floor_limit;
            do {
                if (i != y && i % y == 0){
                    printf("[+]Found a non-prime: %d\n",i);
                }
                
                y += 2;
                
            }while( y < i );
            printf ("%d is a factor \n", i);
        }
    }
    
    return 0;
}
