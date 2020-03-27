#import <Foundation/Foundation.h>
#import "YDfind_factors.h"
#import "YDPrettyConsole.h"
#define KILLTIMER 600

@protocol YDManagerRules <NSObject>
@required
- (void)startRunLoop;
- (void)setNotification;
@end

@interface YDManager : NSObject  <YDManagerRules>{
    NSDate *startTime;
    NSDate *endTime;
}

- (instancetype) init:(int)argCount;
- (void)startRunLoop;
- (void)exitAfterRunLoop;
- (void)setNotification;
+ (void)dirtyExit;

@end
