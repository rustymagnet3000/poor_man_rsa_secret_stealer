#import <Foundation/Foundation.h>
#import "YDManager.h"
#import "YDPrettyConsole.h"
#import "gmp.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {

        YDManager *manager = [[YDManager alloc] init:argc];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        if(manager != NULL){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  @autoreleasepool {
                      YDFindFactors *findfactors = [[YDFindFactors alloc] initWithN:argv[1]];
                      [findfactors factorize];
                      [findfactors.progressBar setRunning:FALSE];
                      [findfactors.progressBar UIProgressStop];
                      [findfactors postChecks];
                  }
                  dispatch_semaphore_signal(semaphore);
              });

            dispatch_time_t killTimer = dispatch_time(DISPATCH_TIME_NOW, KILLTIMER * NSEC_PER_SEC);
            dispatch_semaphore_wait(semaphore, killTimer);
        }
        else {
            [YDManager dirtyExit];
        }
    }
    return 0;
}
