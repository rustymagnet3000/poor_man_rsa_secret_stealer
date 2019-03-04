#import <Foundation/Foundation.h>
#import "YDrun_loop.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDRunLoop : NSObject

@synthesize startTime;

- (void)cleanExit
{
    printf("[+]Finished in: %ld seconds\n\n", lroundf(-[startTime timeIntervalSinceNow]));
 
    
}

- (instancetype)init
{
    self = [super init];
    NSLog(@"[+]Run-loop starting %@", self);
    if (self) {

        self.startTime = [NSDate date];
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
         {
             [YDNotifications receiveNotification:note];
             [self cleanExit];
         }];
        
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate *startPlusFiveSeconds = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                                   value:5
                                                                  toDate:startTime
                                                                 options:NSCalendarMatchNextTime];
        [theRL runUntilDate:startPlusFiveSeconds];
    }
    return self;
}
@end
