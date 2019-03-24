#import "YDstart.h"

@implementation YDStart : NSObject

static NSDate *_startTime;

- (instancetype) initWithRawN: (int)argCount rawN: (const char *)n_as_char{
    self = [super init];
    if (self) {
        _startTime = [NSDate date];
        
        if (argCount != 2){
            printf ("Usage: keyfinder [n] \n");
            return nil;
        }
        
        char *endptr;
        unsigned long long n = strtoull(n_as_char, &endptr, 10);
        
        if (strlen(endptr) > 0){
            fprintf(stderr, "Only enter digits\n");
            exit(EXIT_FAILURE);
        }
        
        if (n >= ULONG_LONG_MAX || n <= 2) {  // also catches null values
            fprintf(stderr, "Outside the supported number range\n");
            exit(EXIT_FAILURE);
        }
        
        if (n % 2 == 0) {
            fprintf(stderr, "Even numbers are not expected\n");
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
    printf("[+]Finished in: %ld seconds\n\n", lroundf(-[_startTime timeIntervalSinceNow]));
    
    exit(1);
}

- (void)startRunLoop
{
    printf("[+]Start: Run-loop starting\n");
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *startPlusTwoMinutes = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:36000
                                                              toDate:_startTime
                                                             options:NSCalendarMatchNextTime];
    [theRL runUntilDate:startPlusTwoMinutes];
    
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         printf ("[+]Start: observer set\n");
         [YDNotifications receiveNotification:note];
     }];
}

@end
