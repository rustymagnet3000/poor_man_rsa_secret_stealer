#import "YDManager.h"
#include "gmp.h"

#define N "10403" // (101 * 103)

/*
 
 #define N "10403" // (101 * 103)
 x = (x * x + 1) % number;
 
 This MUST output:
 
 x = 2
 x = 5
 x = 26
 x = 677
 x = 598
 x = 3903
 x = 3418
 x = 156
 x = 3531
 x = 5168
 x = 3724
 x = 978
 x = 9812
 x = 5983
 x = 9970
 
 */

int main(void)
{
    mpz_t exp, n, x, x_increment_1;
    int flag, i = 0;
    
    mpz_inits(n, x_increment_1, NULL);
    mpz_init_set_ui(x, 2);

    flag = mpz_set_str(n, N, 10);
    assert (flag == 0);
    
    do {
        gmp_printf("X = %Zd\n", x);
        mpz_add_ui(x_increment_1,x,1);
        mpz_mul(x,x,x_increment_1);
        mpz_mod( x, x, n );
        
        i++;
    } while (i < 15 );
    
    mpz_clears ( exp, n, x, NULL );

    return 0;

}
