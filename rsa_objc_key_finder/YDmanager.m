#import "YDmanager.h"
#define KILLTIMER 10

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
       
        startTime = [NSDate date];
        [YDPrettyConsole multiple:@"Started\t%@", [YDManager prettyDate:startTime]];
        [YDPrettyConsole multiple:@"Kill Timer\t%d", KILLTIMER];
        if([self preCheck: argCount] == FALSE){
            return NULL;
        }
        [self setNotification];
    }

    return self;
}


+ (NSString *)prettyDate: (NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss:mm"];
    return [dateFormat stringFromDate:date];
}

- (void)cleanExit
{
    endTime = [NSDate date];
    [YDPrettyConsole multiple:@"Finished in: %.2f seconds", [endTime timeIntervalSinceDate:startTime]];
    exit(EXIT_SUCCESS);
}

- (void)dirtyExit
{
    endTime = [NSDate date];
    [YDPrettyConsole multiple:@"Kill timer fired: %.1f seconds", [endTime timeIntervalSinceDate:startTime]];
}

- (void)startRunLoop
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];

    NSDate *startPlusKillTimer = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:KILLTIMER
                                                              toDate:startTime
                                                             options:NSCalendarMatchNextTime];
    [runLoop runUntilDate:startPlusKillTimer];
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorizationCompleted" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self receiveNotification:note];
     }];
}

-(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorizationCompleted"])
    {
        [self cleanExit];
    }
}

@end
