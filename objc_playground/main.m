#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"
#import "YDPlistReader.h"
#import "gmp.h"
#define MAX_LOOPS 50


@protocol YDReverseRSAProtocol <NSObject>
@required
-(BOOL)parseRecievedPubKey;
-(BOOL)factorize;
-(BOOL)totient;
-(BOOL)deriveMultiplicativeInverse;
@end

@interface YDReverseRSAIngrediants : NSObject <YDReverseRSAProtocol> {
    NSDictionary *_recPubKeyAndCiphertext;
    mpz_t   _exponent,
            _n,
            _p,
            _q,
            _PHI,
            _derivedDecryptionKey,
            _ciphertext,
            _plaintext;
    int _loopsToFactorize;
    int _kToFactorize;
}
- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict;

@end

@implementation YDReverseRSAIngrediants

#pragma mark - Pollard Rho
- (BOOL) factorize
{
    mpz_t exp, gcd, secretFactor, x, xTemp, xFixed;
    int flag = 0, count;
    _kToFactorize = 2;
    _loopsToFactorize = 1;
    
    mpz_inits(exp, gcd, xTemp, xFixed, secretFactor, NULL);
    mpz_init_set_ui(x, 2);

     do {
         count = _kToFactorize;

         do {
             mpz_add_ui(exp,x,1);
             mpz_powm(x, x, exp, _n);

             mpz_sub(xTemp,x, xFixed);
             mpz_gcd(gcd, xTemp, _n);

             flag = mpz_cmp_ui (gcd, 1);
             if(flag > 0){
                 mpz_cdiv_q (secretFactor, _n, gcd);
                                  mpz_set(xFixed,x);
                 mpz_set(_p, secretFactor);
                 mpz_set(_q, gcd);
                 break;
             }
         } while (--count && flag == 0);

         _kToFactorize *= 2;
         mpz_set(xFixed,x);
         _loopsToFactorize++;
     } while (flag < 1 || _loopsToFactorize >= MAX_LOOPS);

     mpz_clears ( exp, gcd, secretFactor, x, xTemp, xFixed, NULL );
     return _loopsToFactorize <= MAX_LOOPS ? YES : NO;
}

#pragma mark - Summarize and Notify Factorize step
- (void) postFactorize {
    gmp_printf("[*] n:%Zd\n[*] p:%Zd\n[*] q:%Zd\n", _n, _p, _q);
    printf("[*] Finished k values: %d, loop: %d\n", _kToFactorize, _loopsToFactorize);
}

- (BOOL)parseRecievedPubKey{

    int flag = 0;
    
    flag = mpz_set_str(_exponent,[_recPubKeyAndCiphertext [@"Exponent"] UTF8String], 10);
    if(flag == -1)
        return NO;
        
    flag = mpz_set_str(_n,[_recPubKeyAndCiphertext [@"Modulus"] UTF8String], 10);
    if(flag == -1)
        return NO;
        
    flag = mpz_set_str(_ciphertext,[_recPubKeyAndCiphertext [@"Ciphertext"] UTF8String], 10);
    if(flag == -1)
        return NO;
        
    return YES;
}

- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict{
    self = [super init];
    if (self) {

        mpz_inits ( _exponent, _n, _p, _q, _PHI,_derivedDecryptionKey, _ciphertext, _plaintext, NULL);
        
        _recPubKeyAndCiphertext = pubKeyDict;
        
        if([self parseRecievedPubKey] == NO)
            return NULL;
    }
  return self;
}

-(BOOL)totient{
    
    mpz_t tempP, tempQ;
    mpz_inits ( tempP, tempQ, NULL);
    
    mpz_sub_ui(tempP,_p,1);
    mpz_sub_ui(tempQ,_q,1);

    mpz_mul(_PHI,tempP,tempQ);
    gmp_printf("[+]\tPHI:%Zd\n", _PHI);
    
    mpz_clears ( tempP, tempQ, NULL );
    return YES;
}

-(void)decryptMessage{
    mpz_powm(_plaintext, _ciphertext, _derivedDecryptionKey, _n);
    gmp_printf("[+]\tplainText:%Zd\n", _plaintext);
}

-(void)encryptMessage{
    mpz_t   _newCipherText;
    mpz_inits ( _newCipherText, NULL);
    
    mpz_powm(_newCipherText, _plaintext, _exponent, _n);
    gmp_printf("[+]\tencrypted message:%Zd\n", _newCipherText);
    mpz_clears ( _newCipherText, NULL );
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

        YDPListReader *pubKeyAndCipherText = [[YDPListReader alloc] init];
        if(pubKeyAndCipherText == NULL)
            NSLog(@"🍭Can't find Plist file");

        
        YDReverseRSAIngrediants *reverse = [[YDReverseRSAIngrediants alloc]initWithPubKey:pubKeyAndCipherText.foundDictItems];

        if(reverse == NULL)
            return EXIT_FAILURE;
        if([reverse factorize] == NO)
            return EXIT_FAILURE;
        [reverse postFactorize];
        if([reverse totient] == NO)
            return EXIT_FAILURE;
//        if([reverse deriveMultiplicativeInverse] == NO)
//            return EXIT_FAILURE;
  //      [reverse decryptMessage];
  //      [reverse encryptMessage];
    }
    return 0;
}


    
