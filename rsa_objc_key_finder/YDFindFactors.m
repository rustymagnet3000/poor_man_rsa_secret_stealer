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

- (void) pubKeySummary {
    
    [self.progressBar banner];
    [YDPrettyConsole multiple:@"Public Key:\n\tModulus:\t\t%@ (%zu bits)\n\tExponent:\t\t%@", [self prettyGMPStr:_n], _modulusLen, [self prettyGMPStr:_exponent]];
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
    
    _modulusLen = mpz_sizeinbase(_n, 2);
    
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
    size_t aLen;
    aLen = mpz_sizeinbase(_plaintext, 16);

    char *regurg = calloc(aLen, sizeof(char));
    mpz_export ( regurg, NULL, 1, sizeof(char), 0, 0, _plaintext );
    NSString *regurgiatedStr = [[NSString alloc] initWithUTF8String:regurg];
    NSString *prettyPlaintext = [YDPrettyConsole guessFormatOfDecryptedType:regurgiatedStr];
    
    [YDPrettyConsole multiple:@"✅ Plaintext %@ %@", prettyPlaintext, @"(NSString view with escaped chars)"];
    NSMutableString *hex = [NSMutableString string];
    while ( *regurg ) [hex appendFormat:@"%02X" , *regurg++ & 0x00FF];
    [YDPrettyConsole multiple:@"✅ Plaintext %@ %@", hex, @"(Hex view)"];
    
    regurg = NULL;
    free(regurg);
}

-(BOOL)encryptMessage:  (const char *)plaintext
                        ptLength:(size_t)lenPT
                        error:(NSError **)errorPtr {
    
    mpz_t _newCipherText; mpz_init( _newCipherText);
    mpz_t z; mpz_init(z);

    mpz_import (_plaintext, lenPT, 1, sizeof(plaintext[0]), 0, 0, plaintext);

    size_t pLen;
    pLen = mpz_sizeinbase(_plaintext, 2);
    
    if (!(mpz_sgn(_plaintext) > 0 && pLen <= _modulusLen )){
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Failed during encrypt step. Either plaintext didn't convert to Decimal or Modulus was shorter than Plaintext.", NULL) };
        if (errorPtr)
            *errorPtr = [NSError errorWithDomain:@"com.youdog.rsaKeyFinder"
                                         code:-10
                                     userInfo:userInfo];
        return NO;
    }

    gmp_printf("[+]\t_plaintext in Decimal: %Zd (%zu bits)\n", _plaintext, pLen);
    gmp_printf("[+]\t_plaintext in Hex: %Zx \n", _plaintext);
    
    mpz_powm(_newCipherText, _plaintext, _exponent, _n);
    
    /* the result should not be zero or negative */
    assert(mpz_sgn(_newCipherText) > 0);

    gmp_printf("[*]\tEncrypted message:%Zd\n", _newCipherText);
    mpz_clears ( _newCipherText, NULL );
    
    return YES;
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
