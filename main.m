#import "YDManager.h"
#import "YDPrettyConsole.h"

int main(void) {
    @autoreleasepool {

        YDManager *mngr = [[YDManager alloc] init];
        if(mngr == NULL)
            [YDManager dirtyExit];
        
        YDFindFactors *findfactors = [[YDFindFactors alloc]initWithPubKey:mngr.keyToAnalyze.foundDictItems];
        if(findfactors == NULL)
            [YDManager dirtyExit];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
              @autoreleasepool {
                  NSError *error = NULL;
                  BOOL result = NO;
                  
                  [findfactors pubKeySummary];
                  [findfactors.progressBar setRunning:YES];
                  [findfactors factorize];
                  [findfactors.progressBar setRunning:NO];
                  [findfactors postFactorize];
                  
                  result = [findfactors totient:&error];
                  if (!result)
                      [mngr timeTaken:&error];

                  result = [findfactors deriveMultiplicativeInverse:&error];
                  if (!result)
                      [mngr timeTaken:&error];
                  
                  [findfactors decryptMessage];
              }
              [mngr timeTaken:NULL];
              dispatch_semaphore_signal(semaphore);
          });

        dispatch_time_t killTimer = dispatch_time(DISPATCH_TIME_NOW, KILLTIMER * NSEC_PER_SEC);
        dispatch_semaphore_wait(semaphore, killTimer);
        
    }
    return 0;
}
