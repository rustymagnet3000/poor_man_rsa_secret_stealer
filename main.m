#import <Foundation/Foundation.h>
#import "YDManager.h"
#import "YDPrettyConsole.h"
#import "YDPlistReader.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {

        YDManager *manager = [[YDManager alloc] init:argc];
        if(manager == NULL)
            [YDManager dirtyExit];
        
        YDPListReader *pubKeyAndCipherText = [[YDPListReader alloc] init];
        if(pubKeyAndCipherText == NULL)
            NSLog(@"🍭Can't find Plist file");
        
        YDFindFactors *findfactors = [[YDFindFactors alloc]initWithPubKey:pubKeyAndCipherText.foundDictItems];
        if(findfactors == NULL)
            return EXIT_FAILURE;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
              @autoreleasepool {
                  [findfactors.progressBar setRunning:YES];
                  [findfactors factorize];
                  [findfactors postFactorize];
                  [findfactors totient];
                  [findfactors.progressBar setRunning:NO];
                  [manager timeTaken];
              }
              dispatch_semaphore_signal(semaphore);
          });

        dispatch_time_t killTimer = dispatch_time(DISPATCH_TIME_NOW, KILLTIMER * NSEC_PER_SEC);
        dispatch_semaphore_wait(semaphore, killTimer);
        
    }
    return 0;
}
