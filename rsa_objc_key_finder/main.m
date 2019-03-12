#import "YDfind_factors.h"
#import "YDrun_loop.h"
#import "YDstart.h"
#import "gmp.h"
#import "progressbar.h"
#import "statusbar.h"


int main(int argc, const char *argv[]) {
    
    @autoreleasepool {

        YDStart *start = [[YDStart alloc] initWithRawN:argc rawN:argv[1]];
        
        mpz_t n, p, q;
        int flag;
        int reps = 15;

        mpz_init ( n );
        mpz_init ( p );
        mpz_init ( q );
        
        flag = mpz_set_str(n,argv[1], 10);
        assert (flag == 0);

        reps = mpz_probab_prime_p ( n, reps );
        
        mpz_nextprime(p, n);

        gmp_printf("[+] n = %Zd\n", n);
        gmp_printf("[+] Next Prime = %Zd\n", p);
        printf("[+] mpz_probab_prime = %d]\t[2=definite,1=probably]\n", reps);
        
        mpz_clear ( n );
        mpz_clear ( p );
    }
    return 0;
}
