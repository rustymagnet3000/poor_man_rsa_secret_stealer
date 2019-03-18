#include "gmp.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <errno.h>

int main(int argc, const char * argv[]) {
    
    /******************* Naive Trial Division Algorithm *******************/
    unsigned long long n;
    char *endptr;
    const char *str;
    
    str = argv[1];
    errno = 0;    /* To distinguish success/failure after call */
    n = strtoull(argv[1], &endptr, 10);

    if ((errno == ERANGE && (n == LONG_MAX || n == LONG_MIN))
        || (errno != 0 && n == 0)) {
        perror("strtol");
        exit(EXIT_FAILURE);
    }
    
    if (endptr == str) {
        fprintf(stderr, "No digits were found\n");
        exit(EXIT_FAILURE);
    }
    
    
    if (n % 2 == 0)
        exit(2);
    
    /* If we got here, strtol() successfully parsed a number */
    printf("[+]String value = %s\n[+]Int value = %llu\n", argv[1], n);
    
    int floor_limit = 3;
    unsigned long long i = floor_limit;
    unsigned long long upper_limit = n/2;
    
    OUTERLOOP: for(; i <= upper_limit; i += 2) {
        if (n % i == 0){

            unsigned long long y=floor_limit;
            do {
                if (i != floor_limit && i % y == 0){
                    i += 2;
                    goto OUTERLOOP; // Found a non-prime factor
                }
                
                y += 2;
                
            }while( y < i );
            printf ("[+]%llu is a prime factor \n", i);
        }
    }
    
    return 0;
}
