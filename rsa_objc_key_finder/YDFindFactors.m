#import "YDFindFactors.h"

@implementation YDFindFactors : NSObject

- (BOOL)preChecks {
    
// check for nulls
// check for evens
  
//    if (_n % 2 == 0) {
//        [YDPrettyConsole single:@"Even numbers are not expected"];
//        return FALSE;
//    }
    
    return TRUE;
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

- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict{
    self = [super init];
    if (self) {

        mpz_inits ( _exponent, _n, _p, _q, _PHI,_derivedDecryptionKey, _ciphertext, _plaintext, NULL);
        
//        if([self preChecks] == FALSE){
//            return NULL;
//        }
        
        _recPubKeyAndCiphertext = pubKeyDict;
        
        if([self parseRecievedPubKey] == NO)
            return NULL;
        
        
        [YDPrettyConsole multiple:@"Factorize:%@", [self prettyGMPStr:_n]];
        //  [self deriveBinString];
        // [YDPrettyConsole multiple:@"Binary %@ (%d bits)", binaryString, [binaryString length]];
        [YDPrettyConsole banner];
        _progressBar = [[YDPrettyConsole alloc] init];
    }
  return self;
}

- (void)ullToBinary:(unsigned long long) ullDec buffer:(char *)buf index:(int *)i{

    if (ullDec < 2){
        buf[*i] = ullDec + '0';
        return;
    }

    int temp = ((ullDec / 2  * 10 + ullDec) % 2);
    buf[*i] = temp + '0';
    *i = *i + 1;
    [self ullToBinary:ullDec/2 buffer:buf index:i];

}

- (void)deriveBinString {
    
    int len = 0;
    unsigned long long ullDecimal = _n;
    char *binaryStr = calloc(CHAR_ARRY_MAX, sizeof(char));
    char *revbinStr = calloc(CHAR_ARRY_MAX, sizeof(char));
    
    [self ullToBinary:ullDecimal buffer:binaryStr index:&len];
    
    for (int i = 0; binaryStr[i] != '\0'; i++)
        revbinStr[i] = binaryStr[len - i];

    binaryString = [NSString stringWithUTF8String:revbinStr];
    binaryStr = NULL;
    revbinStr = NULL;
    free(binaryStr);
    free(revbinStr);
}

- (BOOL)divideNoRemainder
{
    return FALSE;
}

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
    [YDPrettyConsole multiple:@"P:%@", [self prettyGMPStr:_p]];
    [YDPrettyConsole multiple:@"Q:%@", [self prettyGMPStr:_q]];
    [YDPrettyConsole multiple:@"Finished at loop: %d k values: %d", _loopsToFactorize, _kToFactorize ];
  //  [[NSNotificationCenter defaultCenter] postNotificationName:@"FactorizationCompleted" object:NULL userInfo:NULL];
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

-(void)totient{
    
    mpz_t tempP, tempQ;
    mpz_inits ( tempP, tempQ, NULL);
    
    mpz_sub_ui(tempP,_p,1);
    mpz_sub_ui(tempQ,_q,1);

    mpz_mul(_PHI,tempP,tempQ);
    gmp_printf("[+]\tPHI:%Zd\n", _PHI);
    
    mpz_clears ( tempP, tempQ, NULL );
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
