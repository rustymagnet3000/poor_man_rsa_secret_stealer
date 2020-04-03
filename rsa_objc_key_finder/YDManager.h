#import <Foundation/Foundation.h>
#import "YDFindFactors.h"
#import "YDPrettyConsole.h"
#define KILLTIMER 600

@protocol YDManagerRules <NSObject>
@required
- (void)setNotification;
@end

@interface YDManager : NSObject  <YDManagerRules>{
    NSDate *startTime;
    NSDate *endTime;
}

- (instancetype) init:(int)argCount;
- (void)setNotification;
- (void)timeTaken;
+ (void)dirtyExit;

@end
