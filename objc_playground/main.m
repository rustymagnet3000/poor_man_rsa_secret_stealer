#include "gmp.h"
#include <stdio.h>
#include <assert.h>
#define N "10403"
#define MAX_LOOPS 30


void square_self_mod_add_c_mod( mpz_t x, mpz_t n, mpz_t c )
{
    mpz_mul ( x,x, x );
    mpz_mod ( x, x, n );
    mpz_add ( x,x, c );
    mpz_mod ( x, x, n );
}

int main(void)
{
    mpz_t c, gcd, k, i, m, n, q, r, secret_factor, x, x_minus_y, y, ys ;
    gmp_randstate_t state;
    int flag = 0;
    
    mpz_inits( c, gcd, k, i, m, n, q, r, secret_factor, x, x_minus_y, y, ys, NULL );

    mpz_set_ui( gcd, 1 );
    mpz_set_ui( r, 1 );
    mpz_set_ui( q, 1 );
    mpz_set_ui( i, 1 );
    
    flag = mpz_set_str( n, N, 10 );
    assert(flag == 0);
    
    gmp_randinit_default(state);
    mpz_urandomm(y, state, n);
    mpz_urandomm(c, state, n);
    mpz_urandomm(m, state, n);
    
    gmp_printf("y= %Zd\tc = %Zd\tm = %Zd\n", y, c, m);
    gmp_printf("gcd= %Zd\tr = %Zd\tq = %Zd\n", gcd, r, q);
    
    
    int step = 0;
    
    while ( (mpz_cmp_ui (gcd, 1)) == 0 )
    {
        mpz_set( x, y );
        step++;

        /* while i <= 0 */
        while ( mpz_cmp ( i , r ) < 0 || mpz_cmp ( i , r ) == 0 ){
            mpz_add_ui ( i,i,1U );
            square_self_mod_add_c_mod(y, n, c);
        }
        
        mpz_set_ui( k, 0 );
        while ( mpz_cmp ( k , r ) < 0 && mpz_cmp_ui (gcd, 1) == 0 ){
           mpz_set( ys, y );
            
            mpz_gcd ( gcd, x_minus_y, n );
            flag = mpz_cmp_ui (gcd, 1);
            if(flag > 0){
                mpz_cdiv_q (secret_factor, n, gcd);
                gmp_printf("COMPLETE:p = %Zd\tq = %Zd\n", secret_factor,gcd);
                break;
            }
        }

    }
//            /* Tortoise */
//            square_self_add_one_return_mod(x, n);
//
//            /* Hare */
//            square_self_add_one_return_mod(y, n);
//            square_self_add_one_return_mod(y,n);
//
//
//
//            mpz_sub ( x_minus_y, x, y );
//            mpz_abs ( x_minus_y, x_minus_y );


    

    mpz_clears ( x, y, n, gcd, secret_factor, x_minus_y, NULL );
    gmp_randclear ( state );
    return 0;

}
