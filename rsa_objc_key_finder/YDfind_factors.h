#import <Foundation/Foundation.h>
#import "progressbar.h"
#import "statusbar.h"
#include "YDPrettyPrint.h"

@interface YDFindFactors : NSObject{
    unsigned long long n;
    unsigned long long p;
    unsigned long long q;
}

- (instancetype)initWithN: (unsigned long long)N;

@property (readonly) unsigned long long n;
@property (readonly) unsigned long long p;
@property (readonly) unsigned long long q;

@end
