#import <Foundation/Foundation.h>
#include <sys/ioctl.h>
#define DEFAULT_WIDTH 30
#define KILL_TIMER 5
#define PROGRESS_CHAR '-'

NS_ASSUME_NONNULL_BEGIN

@interface YDPrettyConsole : NSObject

@property (nonatomic) BOOL running;
@property int curser_counter;

+ (void)single:(NSString *)message;
+ (void)multiple:(NSString *)message,...;
+ (void)banner;
- (void)UIProgressStop;
@end

NS_ASSUME_NONNULL_END
