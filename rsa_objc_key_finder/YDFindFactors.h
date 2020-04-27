#import <Foundation/Foundation.h>
#import "gmp.h"
#include "YDPrettyConsole.h"

#define MAX_LOOPS 80

@protocol YDReverseRSAProtocol <NSObject>
@required
-(BOOL)parseRecievedPubKey;
-(BOOL)preChecks;
-(BOOL)factorize;
-(BOOL)totient:(NSError **)errorPtr;
-(BOOL)deriveMultiplicativeInverse:(NSError **)errorPtr;
@end

@interface YDFindFactors : NSObject <YDReverseRSAProtocol>{
    NSDictionary *_recPubKeyAndCiphertext;
    mpz_t   _exponent,
            _n,
            _p,
            _q,
            _PHI,
            _derivedDecryptionKey,
            _ciphertext,
            _plaintext;
    int     _loopsToFactorize;
    unsigned long long     _kToFactorize;
}

@property YDPrettyConsole *progressBar;
-(instancetype)initWithPubKey:(NSDictionary *)pubKeyDict;
-(void)pubKeySummary;
-(BOOL)factorize;
-(void)postFactorize;
-(BOOL)totient:(NSError **)errorPtr;
-(BOOL)deriveMultiplicativeInverse:(NSError **)errorPtr;
-(void)decryptMessage;
-(void)encryptMessage:(NSString *)pt;
@end

