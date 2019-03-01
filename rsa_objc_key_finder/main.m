#import "find_factors.h"
#define n 27
// 33, primes only (3,11)
// 27 is a strong vector as it has one prime and one none prime
// remove 1, 2, even numbers and divide n in half
// check to establish whether odd number divides into N

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int *p_array = (int *) malloc(sizeof(int)*n);
        if(p_array == NULL) {
            printf("malloc of size %d failed!\n", n);
            exit(1);
        }
        int array_size = 0;
        
        int upper_limit = n/2;
        for(int i=3; i <= upper_limit; i += 2) {

            if (n % i == 0){
                upper_limit = n/i;

                for (int y = 3; y <= i; y++) {
                    if (i % y != 0){
                        p_array[array_size] = i;
                        array_size++;
                        break;
                    }
                }
            }
        }

        for(int i=0; i < array_size; i++)
            printf("i=%d\n",p_array[i]);
            
        free(p_array);
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


//[[NSNotificationCenter defaultCenter] addObserverForName:@"Factorization" object:nil queue:nil usingBlock:^(NSNotification *note)
// {
//     NSLog(@"The action I was waiting for is complete!!!");
// }];
//
//[[NSNotificationCenter defaultCenter] postNotificationName:@"Factorization" object:nil userInfo:nil];
//
//[[NSNotificationCenter defaultCenter] removeObserver: @"Factorization"];
