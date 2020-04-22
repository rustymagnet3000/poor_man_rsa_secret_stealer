#import "YDFindFactors.h"

@implementation YDFindFactors : NSObject

- (BOOL)preChecks {
      
    /* stop if even number found */
    int flag = 0;
    flag = mpz_odd_p(_n);
    if(flag == 0)
        return NO;
  
    /* check for empty value */
    flag = mpz_sgn(_n);
    if(flag == 0)
        return NO;
    
    return TRUE;
}

- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict{
    self = [super init];
    if (self) {

        mpz_inits ( _exponent, _n, _p, _q, _PHI,_derivedDecryptionKey, _ciphertext, _plaintext, NULL);
               
        _recPubKeyAndCiphertext = pubKeyDict;
        
        if([self parseRecievedPubKey] == NO)
            return NULL;
        
        if([self preChecks] == NO)
            return NULL;
        
        _progressBar = [[YDPrettyConsole alloc] init];
    }
  return self;
}

#pragma mark - Pollard Rho
- (BOOL) factorize
{
    mpz_t exp, gcd, secretFactor, x, xTemp, xFixed;
    int flag = 0;
    unsigned long long count;
    _kToFactorize = 2;
    _loopsToFactorize = 1;
    
    mpz_inits(exp, gcd, xTemp, xFixed, secretFactor, NULL);
    mpz_init_set_ui(x, 2);

     do {
         if (_kToFactorize >= ULONG_LONG_MAX) {
               [YDPrettyConsole single:@"Outside supported number range"];
              return FALSE;
          }
         
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

#pragma mark - Beautify Factorize step
- (void) preFactorize {

    size_t lenPrime;
    lenPrime = mpz_sizeinbase(_n, 2);
    [self.progressBar banner];
    [YDPrettyConsole multiple:@"n:%@ (%zu bits)", [self prettyGMPStr:_n], lenPrime];
    [YDPrettyConsole multiple:@"Exponent:%@", [self prettyGMPStr:_exponent]];
    [YDPrettyConsole multiple:@"Ciphertext:%@", [self prettyGMPStr:_ciphertext]];
    [self.progressBar banner];
}

#pragma mark - Summarize and Notify Factorize step
- (void) postFactorize {
    
    size_t lenPrime;
    lenPrime = mpz_sizeinbase(_p, 2);
    [YDPrettyConsole multiple:@"P:%@ (%zu bits)", [self prettyGMPStr:_p], lenPrime];
    lenPrime = mpz_sizeinbase(_q, 2);
    [YDPrettyConsole multiple:@"Q:%@ (%zu bits)", [self prettyGMPStr:_q], lenPrime];
    [YDPrettyConsole multiple:@"Finished at loop: %d k values: %llu", _loopsToFactorize, _kToFactorize ];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FactorizationCompleted" object:NULL userInfo:NULL];
    [self.progressBar banner];
}

- (BOOL)parseRecievedPubKey{

    int flag = 0;
    
    flag = mpz_set_str(_exponent,[_recPubKeyAndCiphertext [@"Exponent"] UTF8String], 10);
    if(flag != 0)
        return NO;
        
    flag = mpz_set_str(_n,[_recPubKeyAndCiphertext [@"Modulus"] UTF8String], 10);
    if(flag != 0)
        return NO;
    
    flag = mpz_set_str(_ciphertext,[_recPubKeyAndCiphertext [@"Ciphertext"] UTF8String], 10);
    if(flag != 0)
        return NO;
        
    return YES;
}

-(BOOL)totient{
    
    mpz_t tempP, tempQ;
    mpz_inits ( tempP, tempQ, NULL);
    
    mpz_sub_ui(tempP,_p,1);
    mpz_sub_ui(tempQ,_q,1);

    mpz_mul(_PHI,tempP,tempQ);
    [YDPrettyConsole multiple:@"PHI:%@", [self prettyGMPStr:_PHI]];
    mpz_clears ( tempP, tempQ, NULL );
    return YES;
}

-(BOOL)decryptMessage{
    mpz_powm(_plaintext, _ciphertext, _derivedDecryptionKey, _n);
    [YDPrettyConsole multiple:@"Plaintext:%@", [self prettyGMPStr:_plaintext]];
    return YES;
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
    if(flag != 0)
        return NO;
    [YDPrettyConsole multiple:@"Decryption Key:%@", [self prettyGMPStr:_derivedDecryptionKey]];
    return YES;
}

- (NSString *)prettyGMPStr:(mpz_t)gmpStr {
   
    NSZone *dz = NSDefaultMallocZone();
    char *buf;
    NSString *res;

    buf = NSZoneMalloc(dz, mpz_sizeinbase(gmpStr, 10)+2);
    mpz_get_str(buf, 10, gmpStr);
    res = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
    NSZoneFree(dz, buf);
    return res;
}


@end
