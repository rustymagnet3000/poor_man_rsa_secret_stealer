#import "YDManager.h"
#include "gmp.h"

int main(void) {
    @autoreleasepool {

        YDManager *mngr = [[YDManager alloc] init];
        if(mngr == NULL)
            [YDManager dirtyExit];

        YDFindFactors *findfactors = [[YDFindFactors alloc]initWithPubKey:mngr.keyToAnalyze.foundDictItems];
        if(findfactors == NULL)
            [YDManager dirtyExit];

        unsigned char byteArray[] = {0x05, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37 };
        
        [findfactors pubKeySummary];
        [findfactors encryptMessage:&byteArray ptLength:sizeof(byteArray)];

 
        
    }
    return 0;
}








