#import <Foundation/Foundation.h>
#include "YDPrettyPrint.h"


@protocol YDFactorSetupRules <NSObject>
@required
- (BOOL)convertToULL;
- (BOOL)preChecks;
@end


@interface YDFindFactors : NSObject <YDFactorSetupRules>

@property (readwrite) unsigned long long n;
@property (readwrite) unsigned long long p;
@property (readwrite) unsigned long long q;
@property (readwrite) char *binaryRepresentation;
@property (readwrite) const char *rawInput;

- (instancetype)initWithN:(const char*)N;

@end
