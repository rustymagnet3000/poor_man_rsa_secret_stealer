#import "YDfind_factors.h"
#import "YDrun_loop.h"
#import "gmp.h"
#import "progressbar.h"
#import "statusbar.h"

#define YD_SLEEP 100000

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {

        progressbar *fast = progressbar_new("Fast",20);
        for(int i=0; i < 20; i++) {
            usleep(YD_SLEEP);
            progressbar_inc(fast);
        }
        progressbar_finish(fast);
        
        if (argc <= 1){
            printf ("Usage: %s <number> \n", argv[0]);
            return 2;
        }

        printf ("[+]N: %s \n", argv[1]);
        

        mpz_t n;
        int flag;
        int reps = 15;

        mpz_init ( n );
        
        flag = mpz_set_str(n,argv[1], 10);
        assert (flag == 0);

        reps = mpz_probab_prime_p ( n, reps );
        
        // void mpz_gcd (mpz_ptr, mpz_srcptr, mpz_srcptr);
        
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
