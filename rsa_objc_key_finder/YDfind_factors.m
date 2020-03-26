#import "YDfind_factors.h"

@implementation YDFindFactors : NSObject

@synthesize p;
@synthesize q;
@synthesize n;
unsigned long long foundFactors[MAX_FOUND_FACTORS];

- (BOOL)convertToULL {
    
    char *endptr = NULL;
    
    n = strtoull(self.rawInput, NULL, 10);

    if (endptr != NULL){
        [YDPrettyConsole single:@"Only enter digits"];
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)preChecks {
    
    if (n >= ULONG_LONG_MAX || n <= 2) {  // also catches null values
         [YDPrettyConsole single:@"Outside the supported number range"];
        return FALSE;
    }
    
    if (n % 2 == 0) {
        [YDPrettyConsole single:@"Even numbers are not expected"];
        return FALSE;
    }
    
    return TRUE;
}

- (instancetype)initWithN:(const char*)N{
    {
        self = [super init];
        if (self) {
            self.rawInput = N;
            
            if([self convertToULL] == FALSE){
                return NULL;
            }
            
            if([self preChecks] == FALSE){
                return NULL;
            }
        }
        
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(dispatchQueue, ^{
            [YDPrettyConsole multiple:@"Searching factors of: %llu",self.n];
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
    unsigned long long i = floor_limit;
    unsigned long long upper_limit = n/2;
    
    OUTERLOOP: for(; i <= upper_limit; i += 2) {
        
        if (n % i == 0){
            
            unsigned long long y=floor_limit;
            do {
                if (i != floor_limit && i % y == 0){
                    i += 2;
                    goto OUTERLOOP; // Found a non-prime factor
                }
                
                y += 2;
                
            }while( y < i );
            foundFactors
            [YDPrettyConsole multiple:@"Prime factor: %llu",i];
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
