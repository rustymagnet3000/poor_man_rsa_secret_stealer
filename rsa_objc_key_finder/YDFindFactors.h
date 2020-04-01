#import <Foundation/Foundation.h>
#include "YDPrettyConsole.h"
#define MAX_FOUND_FACTORS 100
#define CHAR_ARRY_MAX 64

@protocol YDFactorSetupRules <NSObject>
@required
-(BOOL)preChecks;
-(instancetype)initWithN:(const char*)N;
@end

@interface YDFindFactors : NSObject <YDFactorSetupRules>{
    unsigned long long n;
    unsigned long long e;
    NSMutableArray *foundFactors;
    NSString *binaryString;
    const char *rawInput;
}
@property YDPrettyConsole *progressBar;

- (instancetype)initWithN:(const char*)N;
- (void)factorize;
- (BOOL)postChecks;
@end
