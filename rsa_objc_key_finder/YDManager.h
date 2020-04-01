#import <Foundation/Foundation.h>
#import "YDFindFactors.h"
#import "YDPrettyConsole.h"
#define KILLTIMER 10

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
- (void)cleanExit;
+ (void)dirtyExit;

@end
