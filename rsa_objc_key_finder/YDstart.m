#import "YDstart.h"

@implementation YDStart : NSObject
- (instancetype) initWithRawN: (int)argCount rawN: (const char *)n{
    self = [super init];
    if (self) {
        
        if (argCount != 2){
            printf ("Usage: keyfinder [n] \n");
            return nil;
        }
        
        // Check for Primeness
    }
    return self;
}

@end
