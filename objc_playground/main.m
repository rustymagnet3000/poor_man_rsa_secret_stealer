#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"
#import "gmp.h"

@protocol YDDeriveDecryptionKey <NSObject>
@required
-(BOOL)totient;
-(BOOL)deriveMultiplicativeInverse;
@end

@interface FooBar : NSObject <YDDeriveDecryptionKey>{
    mpz_t   _exponent,
            _n,
            _p,
            _q,
            _PHI,
            _derivedDecryptionKey,
            _cipherText,
            _plainText;
}

@end

@implementation FooBar

- (instancetype)init{
    self = [super init];
    if (self) {
        int flag = 0;
        mpz_inits ( _exponent, _n, _p, _q, _PHI,_derivedDecryptionKey, _cipherText, _plainText, NULL);
        
        NSString *e = @"65537";
        flag = mpz_set_str(_exponent,[e UTF8String], 10);
        assert (flag == 0);

        NSString *n = @"1034776851837418228051242693253376923";
        flag = mpz_set_str(_n,[n UTF8String], 10);
        assert (flag == 0);

        NSString *p = @"1086027579223696553";
        flag = mpz_set_str(_p,[p UTF8String], 10);
        assert (flag == 0);
        
        NSString *q = @"952809000096560291";
        flag = mpz_set_str(_q,[q UTF8String], 10);
        assert (flag == 0);

        NSString *cipherText = @"582984697800119976959378162843817868";
        flag = mpz_set_str(_cipherText,[cipherText UTF8String], 10);
        assert (flag == 0);
    }
  return self;
}

-(BOOL)totient{
    
    mpz_t tempP, tempQ;
    mpz_inits ( tempP, tempQ, NULL);
    
    mpz_sub_ui(tempP,_p,1);
    mpz_sub_ui(tempQ,_q,1);
    gmp_printf("[+]\tNew p: %Zd: Old p:%Zd\n", tempP, _p);
    gmp_printf("[+]\tNew q: %Zd: Old q:%Zd\n", tempQ, _q);
    
    mpz_mul(_PHI,tempP,tempQ);
    gmp_printf("[+]\tPHI:%Zd\n", _PHI);
    
    mpz_clears ( tempP, tempQ, NULL );
    return YES;
}

-(void)decryptMessage{
    mpz_powm(_plainText, _cipherText, _derivedDecryptionKey, _n);
    gmp_printf("[+]\tplainText:%Zd\n", _plainText);
}



-(BOOL)deriveMultiplicativeInverse{
    
    int flag = 0;
    
    flag = mpz_invert(_derivedDecryptionKey, _exponent, _PHI);
    assert (flag != 0);  // If inverse exists, the return value is non-zero
    gmp_printf("[+]\tdecKey\t%Zd\n", _derivedDecryptionKey);
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
        [foo decryptMessage];
    }
    return 0;
}


    
