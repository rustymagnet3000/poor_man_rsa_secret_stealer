#import <Foundation/Foundation.h>
#import "YDmanager.h"
#import "YDPrettyConsole.h"
#import "gmp.h"

/******* Naive Trial Division Algorithm *******/

int main(int argc, const char *argv[]) {
    @autoreleasepool {

        YDManager *manager = [[YDManager alloc] init:argc];

        if(manager != NULL){
            __unused YDFindFactors *findfactors = [[YDFindFactors alloc] initWithN:argv[1]];
            [manager startRunLoop];
            [manager exitAfterRunLoop];
        }else {
            [YDManager dirtyExit];
        }
    }
    return 0;
}
