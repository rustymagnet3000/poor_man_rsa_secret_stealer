#import "YDmanager.h"
#define KILLTIMER 5

@implementation YDManager : NSObject

NSTimer *killTimer;

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
        
        [YDPrettyConsole banner];
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
    [dateFormat setDateFormat:@"HH:mm:ss:mm"];
    return [dateFormat stringFromDate:date];
}

- (void)cleanExit
{
    endTime = [NSDate date];
    [YDPrettyConsole multiple:@"Finished in: %.1f seconds", [endTime timeIntervalSinceDate:startTime]];
}

- (void)dirtyExit
{
    endTime = [NSDate date];
    [YDPrettyConsole multiple:@"Kill timer fired: %.1f seconds", [endTime timeIntervalSinceDate:startTime]];
    [killTimer invalidate];
}

- (void)startRunLoop
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:KILLTIMER
                                                      target:self
                                                    selector:@selector(dirtyExit)
                                                    userInfo:nil
                                                     repeats:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
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
