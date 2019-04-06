#include <assert.h>         // assert
#include <stdio.h>          // printf
#include "gmp.h"            // should be after stdio
#include <stdlib.h>         // malloc
#include <unistd.h>         // usleep
#import "progressbar.h"
#import "statusbar.h"
/* Number of Miller-Rabin tests to run when not proving primality. */
#define MR_REPS 25

int main(int argc, const char * argv[]) {
    
 /*
  Use a large N
  Validate not even,
  
  Search for prime factors of number (Pollard Rho)
  N = 7919261327    7919 * 1000033    19 seconds in old code
  N = 10175656859   100033 * 101723    25 seconds. Failed to find all factors
  */
    
    mpz_t n, re, sq;
    int flag;

    mpz_inits ( n, re, sq, NULL);
    const char *raw = "7919261326";
    flag = mpz_set_str(n,raw, 10);
    assert (flag == 0);
    
    /* n = n + 1 */
    mpz_add_ui(n,n,1);
    fputs("[+] n + 1 = ", stdout);
    mpz_out_str(stdout,10,n);
    putchar('\n');
    
    
    /* Square with alternative gmp_printf */
    mpz_mul(n,n,n); /* n = n * n */
    gmp_printf("[+]\tn^n: %Zd\n", n);
    
    /* Primality test (Miller Rabin)  */
    flag = mpz_probab_prime_p ( n, MR_REPS );
    
    switch (flag) {
        case 0:
            puts("[+] Non-Prime");
            break;
        case 1:
            puts("Prime (probably)");
            break;
        case 2:
            puts("Prime");
            break;
        default:
            puts("Unhandled");
            break;
    }
    
    // Compute k=SQRT(M)

    mpz_sqrtrem(sq, re, n);
    gmp_printf("[+]\tSquare Root : %Zd\n", sq);
    gmp_printf("[+]\tRemainder : %Zd\n", re);
    gmp_printf("[+]\tn: %Zd\n", n);
    
    mpz_clears ( n, sq, re, NULL );
    
    return 0;
}
