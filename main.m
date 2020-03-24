#import <Foundation/Foundation.h>
#import "YDmanager.h"
#import "gmp.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {

            /******* Naive Trial Division Algorithm *******/
            
            YDManager *start = [[YDManager alloc] init:argc];
            [start setNotification];

            unsigned long long n = strtoull(argv[1], NULL, 10);
            if (n % 2 == 0)
                exit(2);
        
            __unused YDFindFactors *findfacors = [[YDFindFactors alloc] initWithN:n];
            [start startRunLoop];

            [YDPrettyPrint single:@"Run-loop killed"];
        }
    return 0;
}
