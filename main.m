#import <Foundation/Foundation.h>
#import "YDstart.h"
#import "gmp.h"
#import "progressbar.h"
#import "statusbar.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {

            /******* Naive Trial Division Algorithm *******/
            [YDStart startTime];
            YDStart *start = [[YDStart alloc] initWithRawN:argc rawN:argv[1]];
        
            [start setNotification];
            
            // Add failure check at atoi()
            unsigned long long n = strtoull(argv[1], NULL, 10);
            __unused YDFindFactors *findfacors = [[YDFindFactors alloc] initWithN:n];
            
            [start startRunLoop];
        }
    return 0;
}
