#import <XCTest/XCTest.h>
#import "YDManager.h"
#include "gmp.h"
#define MAX_ARRAYS 5
#define MAX_STR_LEN 10

@interface GenerateCiphertexts : XCTestCase
@end

@implementation GenerateCiphertexts

const char byteArrays[MAX_ARRAYS][MAX_STR_LEN] = {
        { 0x41, 0x42, 0x43, 0x31, 0x32, 0x33 },// ABC123
        { 0x48, 0x65, 0x6C, 0x6C, 0x6F }, // "Hello"
        { 0x68, 0x45, 0x4C, 0x4C, 0x4F }, // "hELLO"
        { 0x31, 0x31, 0x31, 0x32, 0x32, 0x32 }, // 1112222
        { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0x21 } // "Hello!!"
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
    
     const size_t elementsInByteArray = sizeof( byteArrays ) / sizeof( *byteArrays );
     printf("[+]Elements in array: %lu\n", elementsInByteArray);
     printf("[+]sizeof byte arrays: %lu\n", sizeof( byteArrays ));
     
     char *startAddress = (char *)byteArrays;
     char *endAddress = (char *)byteArrays + sizeof( byteArrays );
     size_t sizeElements = sizeof(byteArrays[0]);
     
     printf("\n\n[+]Start address of byte arrays: %p\n", startAddress );
     printf("[+]End address of byte arrays: %p\n", endAddress);
     printf("[+]Each element is: %lu\n", sizeElements);

     while (startAddress < endAddress) {
         printf("%p\t\t\t\t= %s\n", startAddress, startAddress);
         [findfactors encryptMessage:startAddress ptLength:sizeElements error:NULL];
         startAddress = startAddress + sizeElements;
     }
}

@end
