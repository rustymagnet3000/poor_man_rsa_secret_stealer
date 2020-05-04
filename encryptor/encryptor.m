#import "YDManager.h"
#include "gmp.h"
#import <XCTest/XCTest.h>

@interface encryptor : XCTestCase

@end

@implementation encryptor

YDManager *mngr;
YDFindFactors *findfactors;

- (void)setUp {
    self.continueAfterFailure = NO;

    mngr = [[YDManager alloc] init];
    XCTAssertNotNil(mngr, @"Check Public Key plist available");

    findfactors = [[YDFindFactors alloc]initWithPubKey:mngr.keyToAnalyze.foundDictItems];
    XCTAssertNotNil(findfactors, @"can't parse Public Key");
}

- (void)testGenerateCiphertext {
    NSLog(@"✅ test started");
    const char byteArray[] = {0x05, 0x31, 0x32, 0x33, 0x34, 0x35, 0x00 };
    const char *bytes = byteArray;
    [findfactors pubKeySummary];
    [findfactors encryptMessage:bytes ptLength:sizeof(byteArray) error:NULL];
}

@end
