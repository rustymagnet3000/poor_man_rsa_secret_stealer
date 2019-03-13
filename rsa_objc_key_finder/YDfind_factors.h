#import <Foundation/Foundation.h>

@interface YDFindFactors : NSObject{
    unsigned long long n;
    unsigned long long p;
    unsigned long long q;
}

- (instancetype)initWithN: (unsigned long long)N;

@property unsigned long long n;
@property unsigned long long p;
@property unsigned long long q;

@end
