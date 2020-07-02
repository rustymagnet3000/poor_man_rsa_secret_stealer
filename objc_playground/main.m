#include "gmp.h"
#include <stdio.h>
#include <assert.h>
#define N "1034776851837418228051242693253376923"
#define MAX_LOOPS 30

/* Memory use remains flat. CPU maxed out. */
/* Algorithm: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm */
/* https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html */


void square_self_add_one_return_mod( mpz_t x, mpz_t n ){
    /* The GMP code equates to: (x*x+1) %n */
    mpz_mul ( x,x,x );
    mpz_add_ui ( x,x,1U );
    mpz_mod ( x, x, n );
}

int main(void)
{
    mpz_t n, gcd, secret_factor, x, y, x_minus_y;
    int flag, k = 2, loop = 1, count;
    
    mpz_inits( n, gcd, x_minus_y, secret_factor, NULL );
    mpz_init_set_ui( x, 2 );
    mpz_init_set_ui( y, 2 );
    
    flag = mpz_set_str( n, N, 10 );
    assert(flag == 0);
    
    int step = 0;
    do {
        count = k;
        gmp_printf("----   loop %4i (k = %d)  ----\n", loop, k);
        do {
            step++;
            /* Tortoise */
            square_self_add_one_return_mod(x, n);
            
            /* Hare */
            square_self_add_one_return_mod(y, n);
            square_self_add_one_return_mod(y,n);
            
            // gmp_printf("%d:\t\t\tx = %Zd\ty = %Zd\n", step, x, y);

            mpz_sub ( x_minus_y, x, y );
            mpz_abs ( x_minus_y, x_minus_y );
            mpz_gcd ( gcd, x_minus_y, n );

            flag = mpz_cmp_ui (gcd, 1);
            if(flag > 0){
                mpz_cdiv_q ( secret_factor, n, gcd );
                gmp_printf("\n\n[*] p:%Zd\t\tq:%Zd\n", gcd, secret_factor);
                break;
            }
        } while (--count && flag == 0);

        k *= 2;
        loop++;
        if(loop >= MAX_LOOPS)
            break;
    } while (flag < 1);

    
    printf("\n[*] Finished k values: %d, loop: %d\n", k, loop);
    
    mpz_clears ( n, gcd, secret_factor, x, y, x_minus_y, NULL );
    return 0;

}
