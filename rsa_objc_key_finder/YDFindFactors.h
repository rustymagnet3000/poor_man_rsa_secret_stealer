#import <Foundation/Foundation.h>
#import "gmp.h"
#include "YDPrettyConsole.h"

#define MAX_LOOPS 50
#define MAX_FOUND_FACTORS 100
#define CHAR_ARRY_MAX 64

@protocol YDReverseRSAProtocol <NSObject>
@required
-(BOOL)parseRecievedPubKey;
-(BOOL)preChecks;
-(BOOL)factorize;
-(BOOL)totient;
-(BOOL)deriveMultiplicativeInverse;
@end

@interface YDFindFactors : NSObject <YDReverseRSAProtocol>{
    NSDictionary *_recPubKeyAndCiphertext;
    NSString *binaryString;
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

@property YDPrettyConsole *progressBar;

- (instancetype)initWithPubKey:(NSDictionary *)pubKeyDict;
- (BOOL)factorize;
- (void)postFactorize;
- (void)totient;
- (BOOL)deriveMultiplicativeInverse;
@end

