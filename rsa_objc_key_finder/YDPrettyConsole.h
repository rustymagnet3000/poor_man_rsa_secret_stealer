#import <Foundation/Foundation.h>
#include <sys/ioctl.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDPrettyConsole : NSObject

@property BOOL running;

+ (void)single:(NSString *)message;
+ (void)multiple:(NSString *)message,...;
+ (void)banner;

@end

NS_ASSUME_NONNULL_END
