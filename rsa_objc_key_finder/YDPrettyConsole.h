#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDPrettyConsole : NSObject

@property BOOL running;

+ (void)single:(NSString *)message;
+ (void)multiple:(NSString *)message,...;

@end

NS_ASSUME_NONNULL_END
