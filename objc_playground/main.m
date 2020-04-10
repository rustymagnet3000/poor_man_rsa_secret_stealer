#import <Foundation/Foundation.h>
#import "YDPrettyConsole.h"
#import "YDPlistReader.h"
#import "gmp.h"

@protocol YDReverseRSAProtocol <NSObject>
@required
-(BOOL)parseRecievedPubKey;
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
}
- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict;

@end

@implementation YDReverseRSAIngrediants

- (BOOL)parseRecievedPubKey{

    int flag = 0;
    
    flag = mpz_set_str(_exponent,[_recPubKeyAndCiphertext [@"Exponent"] UTF8String], 10);
    assert(flag == 0);
        
    flag = mpz_set_str(_n,[_recPubKeyAndCiphertext [@"Modulus"] UTF8String], 10);
    assert(flag == 0);
        
    flag = mpz_set_str(_ciphertext,[_recPubKeyAndCiphertext [@"Ciphertext"] UTF8String], 10);
    assert(flag == 0);
        
    return YES;
}

- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict{
    self = [super init];
    if (self) {
        int flag = 0;
        mpz_inits ( _exponent, _n, _p, _q, _PHI,_derivedDecryptionKey, _ciphertext, _plaintext, NULL);
        
        _recPubKeyAndCiphertext = pubKeyDict;
        
        if([self parseRecievedPubKey] == NO)
            return NULL;

        NSString *p = @"1086027579223696553";
        flag = mpz_set_str(_p,[p UTF8String], 10);
        assert (flag == 0);
        
        NSString *q = @"952809000096560291";
        flag = mpz_set_str(_q,[q UTF8String], 10);
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
        if([reverse totient] == NO)
            return EXIT_FAILURE;
        if([reverse deriveMultiplicativeInverse] == NO)
            return EXIT_FAILURE;
  //      [reverse decryptMessage];
  //      [reverse encryptMessage];
    }
    return 0;
}


    
