#import "YDfind_factors.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDFindFactors : NSObject

@synthesize p;
@synthesize q;
@synthesize n;

- (instancetype)initWithN: (unsigned long long)N{
    {
        self = [super init];
        if (self) {
            self->n = N;
            self->p = 0;
            self->q = 0;
        }
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(dispatchQueue, ^{
            printf("[+]Searching for factors of: %llu\n",self.n);
            [self factorize];
        });
        return self;
    }
}


- (BOOL)divideNoRemainder
{
    return FALSE;
}
#pragma mark - void: factorize work horse

- (void)factorize
{
    int floor_limit = 3;
    unsigned long long upper_limit = n/2;
    
    for(int i=floor_limit; i <= upper_limit; i += 2) {
        if (n % i == 0){
            // check for primes
            int y=floor_limit;
            do {
                if (i != y && i % y == 0){
                    printf("[+]Found a non-prime: %d\n",i);
                }
                
                y += 2;
                
            }while( y < i );
            printf ("[+]%d is a factor \n", i);
        }
    }
    [self factorize_completed];
}

#pragma mark - BOOL: factorization completed

- (BOOL)factorize_completed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FactorSearchComplete" object:self userInfo:nil];

    return TRUE;
}
@end
