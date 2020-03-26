#import "YDmanager.h"

@implementation YDManager : NSObject


- (BOOL)preCheck: (int)args {

    if (args != 2){
        [YDPrettyConsole multiple:@"Usage: enter N value. You entered %d argument(s)", args];
        return FALSE;
    }
    
    return TRUE;
}

- (instancetype) init: (int)argCount{
    self = [super init];
    if (self) {
       
        [YDPrettyConsole banner];
        startTime = [NSDate date];
        [YDPrettyConsole multiple:@"Started %@", [YDManager prettyDate:startTime]];

        if([self preCheck: argCount] == FALSE){
            return NULL;
        }

        progressBar = [[YDPrettyConsole alloc] init];
        [self setNotification];
    }

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
    endTime = [NSDate date];
    [YDPrettyConsole multiple:@"Finished in: %ld seconds", lroundf(-[startTime timeIntervalSinceNow])];
    exit(1);
}

- (void)startRunLoop
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSInteger killTime = 120;
    NSDate *startPlusKillTimer = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:killTime
                                                              toDate:startTime
                                                             options:NSCalendarMatchNextTime];
    [runLoop runUntilDate:startPlusKillTimer];
    
    [YDPrettyConsole single:@"Run-loop started"];
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self receiveNotification:note];
     }];
}

-(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        [progressBar setRunning:FALSE];
        [self cleanExit];
    }
}

@end
