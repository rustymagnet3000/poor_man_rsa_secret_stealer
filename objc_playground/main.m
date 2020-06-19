#import "YDManager.h"
#include "gmp.h"

#define N "10403" // (101 * 103)

int main(void)
{
    mpz_t exp, n, x;

    int flag;
    
    mpz_inits(n, NULL);
    mpz_init_set_ui(x, 2);

    flag = mpz_set_str(n, N, 10);
    assert (flag == 0);
    
    int i = 0;
    do {
        // x = (x * x + 1) % number;
        gmp_printf("X = %Zd\n", x);
        mpz_add_ui(exp,x,1);
        mpz_powm(x, x, exp, n);
        i++;
    } while (i < 15 );
    
    mpz_clears ( exp, n, x, NULL );

    return 0;

}
