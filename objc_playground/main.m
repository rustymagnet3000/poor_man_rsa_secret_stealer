#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"
#import "gmp.h"

@protocol YDDeriveDecryptionKey <NSObject>
@required
-(BOOL)totient;
-(BOOL)deriveMultiInverse;
@end

@interface FooBar : NSObject <YDDeriveDecryptionKey>{
    NSMutableArray *_foundFactors;
    unsigned long long _PHI;
    NSNumber *_exponent;
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
        _exponent = [NSNumber numberWithUnsignedLongLong:65537];
        _PHI = 5;
        _p = [NSNumber numberWithUnsignedLongLong:21277];
        _q = [NSNumber numberWithUnsignedLongLong:1180873];
        _foundFactors = [NSMutableArray arrayWithObjects:_p, _q, nil];
    }
  return self;
}

-(BOOL)totient{
    
    NSUInteger factorCount = [_foundFactors count];
    if (factorCount != 2){
        return NO;
    }
    _PHI = ([_p unsignedLongLongValue] - 1) * ([_q unsignedLongLongValue] - 1);
    return YES;
}

-(BOOL)deriveMultiInverse{
    
    NSUInteger factorCount = [_foundFactors count];
    if (factorCount != 2){
        return NO;
    }
    // Inverse of  65537  mod  1034776851837418226012406113933120080
    _PHI = ([_p unsignedLongLongValue] - 1) * ([_q unsignedLongLongValue] - 1);

    mpz_t phi, e, decKey;
    
    mpz_inits ( phi, e, decKey, NULL);

    mpz_set_ui(phi, _PHI);
    mpz_set_ui(e, [_exponent unsignedLongLongValue]);
    gmp_printf("[+]\tphi ( in gmp ): %Zd: exponent:\t%Zd\n", phi, e);
    
    int flag = 0;
    flag = mpz_invert(decKey, e, phi);
    assert (flag != 0);  // If inverse exists, the return value is non-zero
    
    gmp_printf("[+]\tdecKey\t%Zd\n", decKey);
    
    mpz_clears ( phi, e, decKey, NULL );
    
    return YES;
}


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        FooBar *foo = [FooBar new];
        if([foo totient] == NO)
            return EXIT_FAILURE;
        if([foo deriveMultiInverse] == NO)
            return EXIT_FAILURE;


    }
    return 0;
}


    
