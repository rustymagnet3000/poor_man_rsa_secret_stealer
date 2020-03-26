#import <Foundation/Foundation.h>
#import "YDmanager.h"
#import "YDPrettyConsole.h"
#import "gmp.h"

/******* Naive Trial Division Algorithm *******/

int main(int argc, const char *argv[]) {
    @autoreleasepool {

        YDManager *start = [[YDManager alloc] init:argc];

        if(start != NULL){
            __unused YDFindFactors *findfactors = [[YDFindFactors alloc] initWithN:argv[1]];
            [start startRunLoop];
        }
        [start dirtyExit];
    }
    return 0;
}
