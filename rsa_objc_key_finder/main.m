#import "YDfind_factors.h"
#import "YDnotifications.h"

/********************************************************************
*   Works on small, valid large numbers generated by two primes.    *
********************************************************************/

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        NSDate *startTime = [NSDate date];
        
        __unused YDFindFactors *find = [[YDFindFactors alloc] init];

        [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorSearchComplete" object:nil queue:nil usingBlock:^(NSNotification *note)
        {
            [YDNotifications receiveNotification:note];
            printf("[+]time to finish: %f\n", -[startTime timeIntervalSinceNow]);
        }];


    
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];

        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate *startPlusFiveSeconds = [currentCalendar dateByAddingUnit:NSCalendarUnitSecond
                                                               value:5
                                                              toDate:startTime
                                                             options:NSCalendarMatchNextTime];
        [theRL runUntilDate:startPlusFiveSeconds];
    }
    return 0;
}
