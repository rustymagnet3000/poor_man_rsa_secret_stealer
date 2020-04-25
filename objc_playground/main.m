#include <stdio.h>
#include <assert.h>
#include "gmp.h"
#define MR_REPS 25  /* Number of Miller-Rabin tests */

int main()
{
    mpz_t x, n, n_x_n;
    int flag;

    // init values. NULL required as it is a variadic function.
    mpz_inits ( x, n, n_x_n, NULL);
    
    // 414243444546     ABCDEF
    const char *raw = "414243444546";
    
    // int mpz_set_str (mpz_t rop, const char *str, int base)
    flag = mpz_set_str(n,raw, 10);
    assert (flag == 0);

    // Length in Bits
    size_t lenPrime;
    lenPrime = mpz_sizeinbase(n, 2);

    /* GMP's printf  */
    gmp_printf("[+]\tn: %Zd (%zu bits)\n", n, lenPrime);
    
    /* Addition */
    mpz_add_ui(x,n,1);
    fputs("[+] n + 1 = ", stdout);
    mpz_out_str(stdout,10,x);
    putchar('\n');
    
    /* Multiply  */
    mpz_mul(n_x_n,n,n); /* n = n * n */
    gmp_printf("[+]\tn * n = %Zd\n", n_x_n);
    
    /* Primality test (Miller Rabin)  */
    flag = mpz_probab_prime_p ( n, MR_REPS );
    
    switch (flag) {
        case 0:
            gmp_printf("[+]\t%Zd not a Prime\n", n);
            break;
        case 1:
            puts("[+] Prime (probably)");
            break;
        case 2:
            puts("[+] Prime");
            break;
        default:
            puts("[+] Unhandled");
            break;
    }
    
    mpz_clears ( x, n, n_x_n, NULL );
    return 0;
}
