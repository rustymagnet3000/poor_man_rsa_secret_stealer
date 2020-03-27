#import <Foundation/Foundation.h>
#include <sys/ioctl.h>
#define DEFAULT_WIDTH 30
#define KILL_TIMER 5
#define PROGRESS_CHAR '-'

NS_ASSUME_NONNULL_BEGIN

@interface YDPrettyConsole : NSObject

@property BOOL running;

+ (void)single:(NSString *)message;
+ (void)multiple:(NSString *)message,...;
+ (void)banner;

@end

NS_ASSUME_NONNULL_END
