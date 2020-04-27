#import "YDManager.h"

int main(void) {
    @autoreleasepool {

        YDManager *mngr = [[YDManager alloc] init];
        if(mngr == NULL)
            [YDManager dirtyExit];
        
        YDFindFactors *findfactors = [[YDFindFactors alloc]initWithPubKey:mngr.keyToAnalyze.foundDictItems];
        if(findfactors == NULL)
            [YDManager dirtyExit];

        [findfactors preFactorize];
        [findfactors encryptMessage:@"123"];
        
    }
    return 0;
}
