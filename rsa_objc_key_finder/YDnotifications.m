#import "YDnotifications.h"

@implementation YDNotifications : NSObject

#pragma mark - receiveNotification: print object details

+(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        printf("[+]Notification received. Exiting.%p\n", [notification object]);
        [YDStart cleanExit];
    }
}

@end
