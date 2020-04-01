#import "YDfind_factors.h"

@implementation YDFindFactors : NSObject

- (instancetype)initWithN:(const char*)N{
    {
        self = [super init];
        if (self) {
            rawInput = N;
            
            if([self convertToULL] == FALSE){
                return NULL;
            }
            
            if([self preChecks] == FALSE){
                return NULL;
            }
        }
        
        foundFactors = [NSMutableArray array];
        [self deriveBinString];
        [YDPrettyConsole multiple:@"Factorizing %llu", n];
        [YDPrettyConsole multiple:@"Binary %@ (%d bits)", binaryString, [binaryString length]];
        [YDPrettyConsole banner];
        
        progressBar = [[YDPrettyConsole alloc] init];
        #pragma mark - DISPATCH_QUEUE_PRIORITY_BACKGROUND much slower
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(dispatchQueue, ^{
            [self factorize];
        });
        return self;
    }
}

- (void)ullToBinary:(unsigned long long) ullDec buffer:(char *)buf index:(int *)i{

    if (ullDec < 2){
        buf[*i] = ullDec + '0';
        return;
    }

    int temp = ((ullDec / 2  * 10 + ullDec) % 2);
    buf[*i] = temp + '0';
    *i = *i + 1;
    [self ullToBinary:ullDec/2 buffer:buf index:i];

}

- (void)deriveBinString {
    
    int len = 0;
    unsigned long long ullDecimal = n;
    char *binaryStr = calloc(CHAR_ARRY_MAX, sizeof(char));
    char *revbinStr = calloc(CHAR_ARRY_MAX, sizeof(char));
    
    [self ullToBinary:ullDecimal buffer:binaryStr index:&len];
    
    for (int i = 0; binaryStr[i] != '\0'; i++)
        revbinStr[i] = binaryStr[len - i];

    binaryString = [NSString stringWithUTF8String:revbinStr];
    binaryStr = NULL;
    revbinStr = NULL;
    free(binaryStr);
    free(revbinStr);
}



- (BOOL)convertToULL {
    
    char *endptr = NULL;
    
    n = strtoull(rawInput, NULL, 10);

    if (endptr != NULL){
        [YDPrettyConsole single:@"Only enter digits"];
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)preChecks {
    
    if (n >= ULONG_LONG_MAX || n <= 2) {  // catches null values
         [YDPrettyConsole single:@"Outside the supported number range"];
        return FALSE;
    }
    
    if (n % 2 == 0) {
        [YDPrettyConsole single:@"Even numbers are not expected"];
        return FALSE;
    }
    
    return TRUE;
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
            putchar('P');
            NSLog(@"%llu ", i);
            [foundFactors addObject:[NSNumber numberWithUnsignedLongLong:i]];
            progressBar.curser_counter ++;
        }
    }

    [self factorizeCompleted];
}

- (void) factorizeCompleted
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FactorizationCompleted" object:NULL userInfo:NULL];
}

- (BOOL)postChecks {
    [YDPrettyConsole multiple:@"Factors: %@", foundFactors];
    if([foundFactors count] == 2)
        return TRUE;
    return FALSE;
  }


@end
