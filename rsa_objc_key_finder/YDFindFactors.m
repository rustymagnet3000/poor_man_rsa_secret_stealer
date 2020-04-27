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
    
    return YES;
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
    [YDPrettyConsole multiple:@"Public Key and Encrypted Message:\n\tn:%@ (%zu bits)\n\tExponent:%@\n\tCiphertext:%@", [self prettyGMPStr:_n], lenPrime, [self prettyGMPStr:_exponent], [self prettyGMPStr:_ciphertext] ];
    [self.progressBar banner];
}

#pragma mark - Summarize and Notify Factorize step
- (void) postFactorize {
    
    size_t lenPrime;
    lenPrime = mpz_sizeinbase(_p, 2);
    [YDPrettyConsole multiple:@"✅ P:%@ (%zu bits)", [self prettyGMPStr:_p], lenPrime];
    lenPrime = mpz_sizeinbase(_q, 2);
    [YDPrettyConsole multiple:@"✅ Q:%@ (%zu bits)", [self prettyGMPStr:_q], lenPrime];
    [YDPrettyConsole multiple:@"✅ Finished at loop: %d k values: %llu", _loopsToFactorize, _kToFactorize ];
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
    
    /* does not accept Hex Ciphertext */
    flag = mpz_set_str(_ciphertext,[_recPubKeyAndCiphertext [@"Ciphertext"] UTF8String], 10);
    if(flag != 0)
        return NO;
        
    return YES;
}

-(BOOL)totient:(NSError **)errorPtr{
    
    mpz_t tempP, tempQ;
    mpz_inits ( tempP, tempQ, NULL);

    /* check for empty p and q */
    int pflag = 0, qflag = 0;
    pflag = mpz_sgn(_p);
    qflag = mpz_sgn(_q);
    if(pflag == 0 || qflag == 0){
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"P or Q equal zero", NULL) };
        if (errorPtr)
            *errorPtr = [NSError errorWithDomain:@"com.youdog.rsaKeyFinder"
                                         code:-8
                                     userInfo:userInfo];
        return NO;
    }
    mpz_sub_ui(tempP,_p,1);
    mpz_sub_ui(tempQ,_q,1);
    
    mpz_mul(_PHI,tempP,tempQ);

    /* check for a 0 value PHI. Indicative of error. */
    pflag = mpz_sgn(_PHI);
    if(pflag == 0){
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Error deriving PHI", NULL) };
        if (errorPtr)
            *errorPtr = [NSError errorWithDomain:@"com.youdog.rsaKeyFinder"
                                         code:-8
                                     userInfo:userInfo];
        return NO;
    }
    [YDPrettyConsole multiple:@"✅ PHI:%@", [self prettyGMPStr:_PHI]];
    mpz_clears ( tempP, tempQ, NULL );
    return YES;
}

-(void)decryptMessage{
    mpz_powm(_plaintext, _ciphertext, _derivedDecryptionKey, _n);
    [YDPrettyConsole multiple:@"✅ Plaintext:%@", [self prettyGMPStr:_plaintext]];
}

-(void)encryptMessage:(NSString *)pt {
    mpz_t   _newCipherText;
    mpz_init( _newCipherText);
    
    int flag = 0;
    flag = mpz_set_str(_plaintext,[pt cStringUsingEncoding:NSASCIIStringEncoding], 10);
    assert (flag == 0);
    
    mpz_powm(_newCipherText, _plaintext, _exponent, _n);
    gmp_printf("[*]\tEncrypted message:%Zd\n", _newCipherText);
    mpz_clears ( _newCipherText, NULL );
}

-(BOOL)deriveMultiplicativeInverse:(NSError **)errorPtr{
    int flag = 0;
    flag = mpz_invert(_derivedDecryptionKey, _exponent, _PHI); // If inverse exists, return value is non-zero
    if(flag == 0){
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Failed getting a Multiplicative Inverse.", NULL) };
        if (errorPtr)
            *errorPtr = [NSError errorWithDomain:@"com.youdog.rsaKeyFinder"
                                         code:-9
                                     userInfo:userInfo];
        return NO;
    }
    [YDPrettyConsole multiple:@"✅ Private Exponent (Decryption Key):%@", [self prettyGMPStr:_derivedDecryptionKey]];
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
