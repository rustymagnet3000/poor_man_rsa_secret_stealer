#import "find_factors.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(dispatchQueue, ^{
            printf("Factorize code\n");
            YDFindFactors *factors = [[YDFindFactors alloc] init];
           
            for(int i = 1; i <= 10; i++) {
                usleep(1000000);
                printf("Ready to factorize: %d", i);
            }
        });

        dispatch_async(dispatchQueue, ^{
            for(int i = 1; i <= 10; i++) {
                usleep(1000000);
            }
            printf("Kill the app, due to watchdog here\n");
        });
        printf("Main thread not blocked by background operations\n");
    }
    return 0;
}
