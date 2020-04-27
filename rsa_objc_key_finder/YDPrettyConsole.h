#import <Foundation/Foundation.h>
#include <sys/ioctl.h>
#define DEFAULT_WIDTH 30
#define PROGRESS_CHAR '-'
#define BANNER_CHAR '-'

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

NS_ASSUME_NONNULL_BEGIN

@interface YDPrettyConsole : NSObject{
    BOOL _running;
    int _curserCounter;
    int _width;
}

@property BOOL running;

+ (void)single:(NSString *)message;
+ (void)multiple:(NSString *)message,...;
- (void)banner;

@end
NS_ASSUME_NONNULL_END
