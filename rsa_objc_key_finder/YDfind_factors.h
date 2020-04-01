#import <Foundation/Foundation.h>
#include "YDPrettyConsole.h"
#define MAX_FOUND_FACTORS 100
#define CHAR_ARRY_MAX 64

@protocol YDFactorSetupRules <NSObject>
@required
- (BOOL)convertToULL;
- (BOOL)preChecks;
- (void)deriveBinString;

@end

@interface YDFindFactors : NSObject <YDFactorSetupRules>{
    YDPrettyConsole *progressBar;
    unsigned long long n;
    NSMutableArray *foundFactors;
    NSString *binaryString;
    const char *rawInput;
}
- (instancetype)initWithN:(const char*)N;
- (BOOL)postChecks;
@end
