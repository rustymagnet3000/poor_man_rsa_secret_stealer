#import "YDmanager.h"

@implementation YDManager : NSObject

- (instancetype) init: (int)argCount{
    self = [super init];
    if (self) {
        self.startTime = [NSDate now];
        if (argCount != 2){
            [YDPrettyPrint single:@"Usage: keyfinder [n]"];
            return NULL;
        }
    }
    return self;
}

- (void)cleanExit
{
    self.endTime = [NSDate now];
    [YDPrettyPrint multiple:@"Finished in: %ld seconds", lroundf(-[_startTime timeIntervalSinceNow])];
    exit(1);
}

- (void)startRunLoop
{
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSInteger killTime = 120;
    NSDate *startPlusKillTimer = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:killTime
                                                              toDate:_startTime
                                                             options:NSCalendarMatchNextTime];
    [theRL runUntilDate:startPlusKillTimer];
    [YDPrettyPrint single:@"Run-loop started"];
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [YDPrettyPrint single:@"Start: Added observer"];
         [YDNotifications receiveNotification:note];
     }];
}

@end
