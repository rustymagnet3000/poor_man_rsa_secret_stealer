#import "YDnotifications.h"

@implementation YDNotifications : NSObject

#pragma mark - receiveNotification: print object details

+(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        [YDPrettyPrint multiple:@"Notification received. Exiting.%p",[notification object]];
        [YDStart cleanExit];
    }
}

@end
