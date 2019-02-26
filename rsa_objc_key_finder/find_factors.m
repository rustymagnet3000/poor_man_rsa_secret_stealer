#import "find_factors.h"
// Test vector: [13, 29] = 377

@implementation YDFindFactors : NSObject

- (instancetype)init
    {
        self = [super init];
        if (self) {
            self->n = 377;
            self->p = 0; // 13;
            self->q = 0; // 29";
        }
        
        return self;
    }
- (BOOL)factorize
    {
        return FALSE;
    }

@end
