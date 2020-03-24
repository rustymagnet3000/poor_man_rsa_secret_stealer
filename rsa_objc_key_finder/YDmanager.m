#import "YDmanager.h"

@implementation YDManager : NSObject

- (instancetype) init: (int)argCount{
    self = [super init];
    if (self) {
        self.startTime = [NSDate date];
        if (argCount != 2){
            [YDPrettyPrint single:@"Usage: keyfinder [n]"];
            return NULL;
        }
    }
    [YDPrettyPrint multiple:@"Started %@", [YDManager prettyDate:self.startTime]];
    return self;
}

+ (NSString *)prettyDate: (NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    return [dateFormat stringFromDate:date];
}

- (void)cleanExit
{
    self.endTime = [NSDate date];
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
         [self receiveNotification:note];
     }];
}

-(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        [YDPrettyPrint multiple:@"Notification received %p",[notification object]];
        [self cleanExit];
    }
}

@end
