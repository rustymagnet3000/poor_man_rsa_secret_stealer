#import "YDstart.h"

@implementation YDStart : NSObject

static NSDate *_startTime;

- (instancetype) initWithRawN: (int)argCount rawN: (const char *)n_as_char{
    self = [super init];
    if (self) {
        _startTime = [NSDate date];
        
        if (argCount != 2){
            [YDPrettyPrint single:@"Usage: keyfinder [n]"];
            return nil;
        }
        
        char *endptr;
        unsigned long long n = strtoull(n_as_char, &endptr, 10);
        
        if (strlen(endptr) > 0){
            [YDPrettyPrint single:@"Only enter digits"];
            exit(EXIT_FAILURE);
        }
        
        if (n >= ULONG_LONG_MAX || n <= 2) {  // also catches null values
             [YDPrettyPrint single:@"Outside the supported number range"];
            exit(EXIT_FAILURE);
        }
        
        if (n % 2 == 0) {
            [YDPrettyPrint single:@"Even numbers are not expected"];
            exit(EXIT_FAILURE);
        }
    }
    return self;
}

+ (NSDate *)startTime {
    return _startTime;
}

+ (void)cleanExit
{
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
