#include "gmp.h"            // primes
#include <stdio.h>          // printf
#include <stdlib.h>         // malloc
#include <unistd.h>         // usleep
#import "progressbar.h"
#import "statusbar.h"
#define YD_SLEEP 100000

int main(int argc, const char * argv[]) {
    
    /* TO DO: solve mixing an unsigned long VS an ULL value in the progress bar) */
    unsigned long long upper_limit = 100;
    progressbar *fast = progressbar_new("[+]Find factor",upper_limit);
    for(int i=0; i < upper_limit; i++) {
        usleep(YD_SLEEP);
        progressbar_inc(fast);
    }
    progressbar_finish(fast);

    return 0;
}
