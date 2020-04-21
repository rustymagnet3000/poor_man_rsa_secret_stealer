#include "YDManager.h"

@implementation YDManager

- (instancetype)init {
    return [self init:@"pubKeyAndCipherText"];
}

- (instancetype)init:(NSString *)pubKeyfilename{
    self = [super init];
    if (self) {
        self.keyToAnalyze = [[YDPListReader alloc] init];
        
        if(self.keyToAnalyze == NULL){
            [YDPrettyConsole single:@"Can't find Public Key file."];
            return NULL;
        }
        
        startTime = [NSDate date];
        [YDPrettyConsole multiple:@"Started\t%@", [YDManager prettyDate:startTime]];
        [self setNotification];
    }

    return self;
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorizationCompleted" object:NULL queue:NULL usingBlock:^(NSNotification *note)
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
    NSTimeInterval difference = [endTime timeIntervalSinceDate:startTime];
    [YDManager prettyPrintTimeFromSeconds:difference];
}   

+ (NSString *)prettyDate: (NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    return [dateFormat stringFromDate:date];
}

+ (void)prettyPrintTimeFromSeconds: (NSTimeInterval)timeInSecs
{
    NSDateComponentsFormatter *componentFormatter = [[NSDateComponentsFormatter alloc] init];
    componentFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    componentFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropLeading;
    NSString *prettyTimeTaken = [componentFormatter stringFromTimeInterval:timeInSecs];
    [YDPrettyConsole single: prettyTimeTaken];
}

+ (void)dirtyExit
{
    [YDPrettyConsole single:@"Error in setup"];
    exit(EXIT_FAILURE);
}
@end
