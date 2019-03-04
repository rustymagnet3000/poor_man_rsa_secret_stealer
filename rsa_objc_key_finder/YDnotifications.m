#import "YDnotifications.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDNotifications : NSObject

#pragma mark - receiveNotification: print object details

+(void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorSearchComplete"])
    {
        printf("[+]factors found. Code completed\n");
        NSLog(@"[+] N, P, Q: %@", notification.object);
    }
}

@end
