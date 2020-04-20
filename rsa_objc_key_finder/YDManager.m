#include "YDManager.h"

@implementation YDManager

- (BOOL)preCheck: (int)args {

    if (args != 2){
        [YDPrettyConsole multiple:@"Usage: <n> <e> of RSA Public Key. \nYou entered %d argument(s)", args];
        return FALSE;
    }
    
    return TRUE;
}

- (instancetype) init: (int)argCount{
    self = [super init];
    if (self) {
        if([self preCheck: argCount] == FALSE){
            return NULL;
        }
        startTime = [NSDate date];
        [YDPrettyConsole multiple:@"Started\t%@", [YDManager prettyDate:startTime]];
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

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorizationCompleted" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self receiveNotification:note];
     }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ProgressBarFinished" object:NULL queue:NULL usingBlock:^(NSNotification *prettyConsole)
     {
         [self receiveNotification:prettyConsole];
     }];
}


-(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorizationCompleted"])
    {
        endTime = [NSDate date];
    }
}

- (void)timeTaken
{
    [YDPrettyConsole multiple:@"Finished in: %.2f seconds", [endTime timeIntervalSinceDate:startTime]];
}

+ (void)dirtyExit
{
    [YDPrettyConsole single:@"Error in setup"];
    exit(EXIT_FAILURE);
}
@end
