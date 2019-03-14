#ifndef YDstart_h
#define YDstart_h

#import <Foundation/Foundation.h>
#import "YDnotifications.h"
#import "YDfind_factors.h"

@interface YDStart : NSObject

@property (class, nonatomic, strong, readonly) NSDate *startTime;

- (instancetype) initWithRawN:(int)argCount rawN: (const char *)n;
- (void)startRunLoop;
- (void)setNotification;
+ (void)cleanExit;

@end

#endif /* YDstart_h */
