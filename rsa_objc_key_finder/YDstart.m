#import "YDstart.h"

@implementation YDStart : NSObject

@synthesize startTime;

- (instancetype) initWithRawN: (int)argCount rawN: (const char *)n_as_char{
    self = [super init];
    if (self) {
        
        self.startTime = [NSDate date];
        
        if (argCount != 2){
            printf ("Usage: keyfinder [n] \n");
            return nil;
        }

    }
    return self;
}

- (void)cleanExit
{
    printf("[+]Finished in: %ld seconds\n\n", lroundf(-[startTime timeIntervalSinceNow]));
    exit(1);
}

- (void)startRunLoop
{
    printf("[+]Run-loop starting");
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *startPlusFiveSeconds = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:5
                                                              toDate:self.startTime
                                                             options:NSCalendarMatchNextTime];
    NSLog(@"Run Loop on thread: %@", [NSThread currentThread]);
    [theRL runUntilDate:startPlusFiveSeconds];
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         printf ("[+]Start: set notification Observer: FactorSearchComplete\n");
         [YDNotifications receiveNotification:note];
     }];
}

@end
