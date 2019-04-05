#include "gmp.h"            // primes
#include <stdio.h>          // printf
#include <stdlib.h>         // malloc
#include <unistd.h>         // usleep
#import "progressbar.h"
#import "statusbar.h"
#define YD_SLEEP 100000

int main(int argc, const char * argv[]) {
    
 /*
  Use a large N
  Validate not even,
  Validated not prime (Miller Rabin)
  Search for prime factors of number (Pollard Rho)
  N = 7919261327    7919 * 1000033    19 seconds in old code
  N = 10175656859   100033 * 101723    25 seconds. Failed to find all factors
  */
    
    mpz_t m, n, p, k;
    int i,j;
    
    // Get the number to play with
    if(argc < 2) {
        printf("No argument provided, using built in number\n");
        mpz_init_set_str(m, "6005662386412099", 10);
    } else {
        mpz_init_set_str(m, argv[1], 10);
    }
    
    // Output the number we are working on
    printf("        m: ");
    mpz_out_str(stdout, 10, m);
    printf("\n");
    
    // Check for 2|m
    if(mpz_divisible_ui_p(m, 2)) {
        printf("FOUND p|m: 2\n");
        exit(1);
    }
    
    // Compute k=SQRT(M)
    mpz_init(k);
    mpz_sqrt(k, m);
    gmp_printf("  SQRT(m): %Zd\n", k);
    
    // 2|SQRT(M) => p=SQRT(M)+5, else p=SQRT(M)+4
    mpz_init(p);
    if(mpz_divisible_ui_p(k, 2)) {
        mpz_add_ui(p, k, 5);
    } else {
        mpz_add_ui(p, k, 4);
    }
    
    // Move DOWN from SQRT(m) by two looking for something that | m
    mpz_init(n);
    for(i=0,j=0;1 || i<10000000;i++) {
        // Subtract 2, and test for |.
        mpz_sub_ui(p, p, 2);
        if(mpz_divisible_p(m, p)) {
            gmp_printf("FOUND p|m: %Zd\n", p);
            if(mpz_cmp_ui(p, 1) == 0)
                printf("m was prime!\n");
            exit(1);
        }
        // Print status every 100K tests
        j++;
        if(j>100000) {
            j=0;
            mpz_sub(n, k, p);
            gmp_printf("  CHECKED: %Zd\n", n);
        }
    }
    
    // If we got here, then we didn't find the value..
    printf("No Factors Found\n");
    exit(0);

    return 0;
}
