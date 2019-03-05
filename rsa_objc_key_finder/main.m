#import "YDfind_factors.h"
#import "YDrun_loop.h"
#import "gmp.h"

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        printf ("[+]N passed to program: %s \n", argv[1]);
        
        if (argc <= 1){
            printf ("Usage: %s <number> \n", argv[0]);
            return 2;
        }

        mpz_t n;
        int flag;
        int reps = 15;

        mpz_init ( n );

        flag = mpz_set_str(n,argv[1], 10);
        assert (flag == 0);

        reps = mpz_probab_prime_p ( n, reps );

        switch (reps) {
            case 0:
                puts("Non-Prime");
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

        mpz_clear ( n );
        
    }
    return 0;
}
