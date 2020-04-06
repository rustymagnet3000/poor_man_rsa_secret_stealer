#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"
#import "gmp.h"

@protocol YDDeriveDecryptionKey <NSObject>
@required
-(BOOL)totient;
-(BOOL)deriveMultiplicativeInverse;
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

-(BOOL)deriveMultiplicativeInverse{
    
    mpz_t phi, e, actualDecKey, derivedDecKey;
    mpz_inits ( phi, e, actualDecKey, derivedDecKey, NULL);
    int flag = 0;
    
    const char *rawPhi = "1034776851837418226012406113933120080";
    const char *correctDecKey =  "568411228254986589811047501435713";
    flag = mpz_set_str(phi,rawPhi, 10);
    assert (flag == 0); // If zero, it succeeded.
    flag = mpz_set_str(actualDecKey,correctDecKey, 10);
    assert (flag == 0); // If zero, it succeeded.
    
    mpz_set_ui(e, [_exponent unsignedLongLongValue]);
    gmp_printf("[+]\tphi ( in gmp ): %Zd: exponent:\t%Zd\n", phi, e);
    
    flag = 0;
    flag = mpz_invert(derivedDecKey, e, phi);
    assert (flag != 0);  // If inverse exists, the return value is non-zero

    gmp_printf("[+]\tdecKey\t%Zd\n", derivedDecKey);

    flag = mpz_cmp(derivedDecKey, actualDecKey);
    if (flag == 0){
        puts("Decryption key passed");
    }
    
    mpz_clears ( phi, e, derivedDecKey, actualDecKey, NULL );
    
    return YES;
}


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        FooBar *foo = [FooBar new];
        if([foo totient] == NO)
            return EXIT_FAILURE;
        if([foo deriveMultiplicativeInverse] == NO)
            return EXIT_FAILURE;

    }
    return 0;
}


    
