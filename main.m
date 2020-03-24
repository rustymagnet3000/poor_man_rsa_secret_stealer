#import <Foundation/Foundation.h>
#import "YDmanager.h"
#import "gmp.h"

/******* Naive Trial Division Algorithm *******/

int main(int argc, const char *argv[]) {
    @autoreleasepool {

            YDManager *start = [[YDManager alloc] init:argc];
            [start setNotification];

            __unused YDFindFactors *findfacors = [[YDFindFactors alloc] initWithN:argv[1]];
            [start startRunLoop];

            [YDPrettyPrint single:@"Run-loop killed"];
        }
    return 0;
}
