#import <Foundation/Foundation.h>
#import "YDfind_factors.h"
#import "YDPrettyPrint.h"

@protocol YDManagerRules <NSObject>
@required
- (void) startRunLoop;
@end

@interface YDManager : NSObject  <YDManagerRules>

@property (nonatomic, strong, readwrite) NSDate *startTime;
@property (nonatomic, strong, readwrite) NSDate *endTime;

- (instancetype) init:(int)argCount;
- (void)startRunLoop;
- (void)setNotification;
- (void)cleanExit;

@end
