#import "YDnotifications.h"

@implementation YDNotifications : NSObject

#pragma mark - receiveNotification: print object details

+(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        [YDPrettyPrint multiple:@"Notification received. Need to add exit.%p",[notification object]];
//        [YDManager cleanExit];
    }
}

@end
