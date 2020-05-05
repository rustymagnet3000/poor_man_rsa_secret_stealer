#import <XCTest/XCTest.h>
#import "YDManager.h"
#include "gmp.h"
#define MAX_ARRAYS 5

@interface GenerateCiphertexts : XCTestCase
@end

@implementation GenerateCiphertexts

/*
    The Array of Byte Arrays was constant.
    It was declared as immutable (const).
    Efficient in terms of space.
    NULL terminators required at the end of each string literal.
    But the NULL termination is not encrypted.
*/

/* REMEMBER -> length of input has to be less than Modulus length   */
const char *byteArrays[MAX_ARRAYS] = {
    (char []) { 0x41, 0x42, 0x43, 0x31, 0x32, 0x33, 0x00  },// ABC123
    (char []) { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00 }, // Hello\x0
    (char []) { 0x31, 0x31, 0x31, 0x32, 0x32, 0x32, 0x00 }, // 1112222
    // (char []) { 0x44, 0x45, 0x41, 0x44, 0x46, 0x41, 0x43, 0x45, 0x00 }, //[!] "DEADFACE" invalid. Too long for 59-bit modulus
    (char []) { 0x42, 0x45, 0x45, 0x46, 0x00 }, // "BEEF"
    (char []) { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0x21, 0x00 } // "Hello!!"
};

YDManager *mngr;
YDFindFactors *findfactors;

- (void)setUp {
    self.continueAfterFailure = NO;
    NSLog(@"✅ test setUp");
    mngr = [[YDManager alloc] init];
    XCTAssertNotNil(mngr, @"❌ Check Public Key plist available");

    findfactors = [[YDFindFactors alloc]initWithPubKey:mngr.keyToAnalyze.foundDictItems];
    XCTAssertNotNil(findfactors, @"❌ can't parse Public Key");
    [findfactors pubKeySummary];
}

- (void)testGenerateCiphertext {
    NSLog(@"✅ test started");
    size_t totalBytes = 0;
    NSError *error = NULL;
    
    for (int i = 0; i < MAX_ARRAYS; ++i){
        printf("\n[+]\t%s (strlen %lu) \t\t(address %p)\n", byteArrays[i], strlen(byteArrays[i]), byteArrays[i] );
        totalBytes = totalBytes + strlen(byteArrays[i]);
        [findfactors encryptMessage:byteArrays[i] ptLength:strlen(byteArrays[i]) error:&error];
        XCTAssertNil(error, "❌ hit encrypt error");
    }
                                  
     printf("[+] Bytes used: %lu\n", totalBytes);


}

@end


/*
 ✅ test setUp
 Started       13:50:37
 Kill timer    2 days, 0 hours, 0 minutes, 0 seconds
 ------------------------------
 Public Key:
     Modulus:        464583729100140631 (59 bits)
     Exponent:        65537
 ------------------------------
 ✅ test started

 [+]    ABC123 (strlen 6)         (address 0x1031ed940)
 [+]    _plaintext in Decimal: 71752850944563 (47 bits)
 [+]    _plaintext in Hex: 414243313233
 [*]    Encrypted message:182885092137362914

 [+]    Hello (strlen 5)         (address 0x1031ed947)
 [+]    _plaintext in Decimal: 310939249775 (39 bits)
 [+]    _plaintext in Hex: 48656c6c6f
 [*]    Encrypted message:312515172274248771

 [+]    111222 (strlen 6)         (address 0x1031ed94d)
 [+]    _plaintext in Decimal: 54087348531762 (46 bits)
 [+]    _plaintext in Hex: 313131323232
 [*]    Encrypted message:181829619463323891

 [+]    DEADFACCE (strlen 9)         (address 0x1031ed954)

 [+]    Hello!! (strlen 7)         (address 0x1031ed95e)
 [+]    _plaintext in Decimal: 20377714673262881 (55 bits)
 [+]    _plaintext in Hex: 48656c6c6f2121
 [*]    Encrypted message:464519888449598487
 [+] Bytes used: 33
 */
