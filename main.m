#import <Foundation/Foundation.h>
#import "YDManager.h"
#import "YDPrettyConsole.h"
#import "gmp.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {

        YDManager *manager = [[YDManager alloc] init:argc];
        if(manager == NULL)
            [YDManager dirtyExit];
        
        YDFindFactors *findfactors = [[YDFindFactors alloc] initWithN:argv[1]];
        if(findfactors == NULL)
            [YDManager dirtyExit];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
              @autoreleasepool {
                  [findfactors.progressBar setRunning:YES];
                  [findfactors factorize];
                  [findfactors.progressBar setRunning:NO];
                  [findfactors postChecks];
                  [manager timeTaken];
              }
              dispatch_semaphore_signal(semaphore);
          });

        dispatch_time_t killTimer = dispatch_time(DISPATCH_TIME_NOW, KILLTIMER * NSEC_PER_SEC);
        dispatch_semaphore_wait(semaphore, killTimer);
        
    }
    return 0;
}
