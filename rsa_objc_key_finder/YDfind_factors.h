#import <Foundation/Foundation.h>
#include "YDPrettyConsole.h"
#define MAX_FOUND_FACTORS 100

@protocol YDFactorSetupRules <NSObject>
@required
- (BOOL)convertToULL;
- (BOOL)preChecks;
@end


@interface YDFindFactors : NSObject <YDFactorSetupRules>{
    unsigned long long n;
    char *binaryRepresentation;
    const char *rawInput;
}
- (instancetype)initWithN:(const char*)N;

@end
