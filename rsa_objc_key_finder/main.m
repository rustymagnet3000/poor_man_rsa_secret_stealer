#import "find_factors.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        [[NSNotificationCenter defaultCenter] addObserverForName:@"Factorization" object:nil queue:nil usingBlock:^(NSNotification *note)
        {
            NSLog(@"The action I was waiting for is complete!!!");
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Factorization" object:nil userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver: @"Factorization"];
    }
    return 0;
}

//        NSDate *startTime = [NSDate date];
//
//        YDFindFactors *find_factor = [[YDFindFactors alloc] init];
//        printf("[+]Factorize %d\n", find_factor.n);
//
//        printf("[+]Main thread, put a wait until thread finished\n");
//        for(int i = 1; i <= 10; i++) {
//                usleep(1000000);
//            }
//        printf("[+]time to finish: %f\n", -[startTime timeIntervalSinceNow]);
