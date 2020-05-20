#import "YDManager.h"
#include "gmp.h"



int main(void) {
    @autoreleasepool {
        
        NSTimeInterval simple = 3627;
        NSLog(@"%@", [YDManager prettyPrintTimeFromSeconds:simple]);
    }
    return 0;
}







    



