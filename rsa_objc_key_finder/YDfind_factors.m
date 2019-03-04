#import "YDfind_factors.h"

@implementation YDFindFactors : NSObject

@synthesize p;
@synthesize q;
@synthesize n;

- (instancetype)init
    {
        self = [super init];
        if (self) {
            self->n = 377;
            self->p = 0; // 13;
            self->q = 0; // 29";
        }
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(dispatchQueue, ^{
            printf("[+]Background queue\n");
            [self factorize];
        });
        return self;
    }

- (BOOL)divideNoRemainder
{
    return FALSE;
}
#pragma mark - void: factorize work horse

- (void)factorize
{
    int *p_array = (int *) malloc(sizeof(int)*n);
    if(p_array == NULL) {
        printf("malloc of size %d failed!\n", n);
        exit(1);
    }
    int array_size = 0;
    int floor_limit = 3;
    int upper_limit = n/2;
    
    
    // Remove evens, 1, 2
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
            
            p_array[array_size] = i;
            array_size++;
        }
    }
    
    for(int i=0; i < array_size; i++)
        printf("[+]Found: %d\n",p_array[i]);
    
    free(p_array);
    p_array = NULL;
    sleep(2);  // Print results
    [self factorize_completed];
}

#pragma mark - BOOL: factorization completed

- (BOOL)factorize_completed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FactorSearchComplete" object:self userInfo:nil];

    return TRUE;
}
@end
