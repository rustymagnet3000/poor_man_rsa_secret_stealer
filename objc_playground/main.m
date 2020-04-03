#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"

// 25125434821     1180873 * 21277     62 seconds

@interface FooBar: NSObject{
    NSMutableArray *_foundFactors;
    unsigned long long _PHI;
    NSNumber *_p;
    NSNumber *_q;
}
- (unsigned long long)getPHI;
@end

@implementation FooBar

- (unsigned long long)getPHI{
    return _PHI;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _PHI = 5;
        _p = [NSNumber numberWithUnsignedLongLong:21277];
        _q = [NSNumber numberWithUnsignedLongLong:1180873];
        _foundFactors = [NSMutableArray arrayWithObjects:_p, _q, nil];
    }
  return self;
}

-(BOOL)totientPreCheck{
    
    NSUInteger factorCount = [_foundFactors count];
    if (factorCount != 2){
        return NO;
    }

    _PHI = ([_p unsignedLongLongValue] - 1) * ([_q unsignedLongLongValue] - 1);
    
    return YES;
}


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        FooBar *foo = [FooBar new];
        if([foo totientPreCheck] == NO)
            return EXIT_FAILURE;
        
        [YDPrettyConsole multiple:@"PHI:%llu", [foo getPHI]];
        
    }
    return 0;
}
