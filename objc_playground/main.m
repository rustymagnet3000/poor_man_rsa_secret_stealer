#include "gmp.h"
#include <stdio.h>
#include <assert.h>
#define N "1642061677267048469007620094567254201801"
#define MAX_LOOPS 30

/* RAM remains flat, unlike past examples */
/* Algorithm: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm */
/* https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html */

int main(void)
{
    mpz_t n, gcd, secretFactor, x, xTemp, xFixed;
        
    int flag, k = 2, loop = 1, count;
    
    mpz_inits( n, gcd, xTemp, secretFactor, NULL );
    mpz_init_set_ui( x, 2 );
    mpz_init_set_ui( xFixed, 2 );
    
    flag = mpz_set_str( n, N, 10 );
    assert(flag == 0);
    
    int step = 0;
    do {
        count = k;
        gmp_printf("----   loop %4i (k = %d, xFixed = %Zd)  ----\n", loop, k, xFixed);
        do {
            step++;
         //   gmp_printf("%d:\t\tx = %Zd n\t\t", step, x);
            mpz_mul ( x,x,x );
            mpz_add_ui ( x,x,1U );
            mpz_mod ( x, x, n );
         //   gmp_printf("\t\t(x*x + 1) mod n= %Zd\n", x);
            
            mpz_sub ( xTemp, x, xFixed );
            mpz_abs ( xTemp, xTemp );
            mpz_gcd ( gcd, xTemp, n );

            flag = mpz_cmp_ui (gcd, 1);
            if(flag > 0){
                mpz_cdiv_q ( secretFactor, n, gcd );
                gmp_printf("\n\n[*] p:%Zd\t\tq:%Zd\n", gcd, secretFactor);
                break;
            }
        } while (--count && flag == 0);

        k *= 2;
        mpz_set(xFixed,x);
        loop++;
        if(loop >= MAX_LOOPS)
            break;
    } while (flag < 1);

    
    printf("\n[*] Finished k values: %d, loop: %d\n", k, loop);
    
    mpz_clears ( n, gcd, secretFactor, x, xTemp, xFixed, NULL );

    return 0;

}
