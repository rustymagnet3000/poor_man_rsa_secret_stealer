#include "math.h"
#import "find_factors.h"

@implementation YDFindFactors : NSObject

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
            for(int i = 1; i <= 10; i++) {
                usleep(1000000);
                printf("Ready to factorize: %d\n", i);
            }
        });
        return self;
    }

- (NSMutableIndexSet *)getSet
{
    NSRange range;
    NSMutableIndexSet *myset = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    NSLog(@"my set %@", myset);
    return myset;
}

- (BOOL)divideNoRemainder
{
    return FALSE;
}

- (BOOL)factorize
{
    return FALSE;
}

@end
