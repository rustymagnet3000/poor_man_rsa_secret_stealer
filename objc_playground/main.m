#import "YDManager.h"
#include "gmp.h"

#define N "1199977" // (827 * 1451)
#define MAX_LOOPS 50

/* Assumes 1<a<n, and k=LCM[1,2,3,4...K], some K */
/* When running. RAM remains flat, unlike past examples */
/* but it does max out my CPU!  */
/* Algorithm based on: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm */

int main(void)
{
    mpz_t exp, n, gcd, secretFactor, x, xTemp, xFixed;
        
    int flag, k = 2, loop = 1, count;
    
    mpz_inits(n, gcd, xTemp, xFixed, secretFactor, NULL);
    mpz_init_set_ui(x, 2);

    flag = mpz_set_str(n, N, 10);
    assert (flag == 0);
    
    do {
        count = k;
        gmp_printf("\n----   loop %4i (k = %d, n = %Zd)  ----\n", loop, k, n);
        do {
            gmp_printf("Be = %Zd\t", exp);
            mpz_add_ui(exp,x,1);
            gmp_printf("Af = %Zd\n", exp);
            mpz_powm(x, x, exp, n);

            mpz_sub(xTemp,x, xFixed);
            mpz_gcd(gcd, xTemp, n);
            
            mpz_abs (xTemp, xTemp);
            
   //         gmp_printf("[%d]\tgcd:%Zd \t\t( %Zd )\n", k - count + 1, gcd, xTemp);

            flag = mpz_cmp_ui (gcd, 1);
            if(flag > 0){
                mpz_cdiv_q (secretFactor, n, gcd);
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
    
    /* free all gmp structs  */
    mpz_clears ( exp, n, gcd, secretFactor, x, xTemp, xFixed, NULL );

    return 0;

}
