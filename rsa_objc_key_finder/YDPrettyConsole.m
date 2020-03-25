#include "YDPrettyConsole.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDPrettyConsole

- (instancetype)init{
        self = [super init];
        if (self) {
             dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
             
             dispatch_async(dispatchQueue, ^{
                 self.running = TRUE;
                 [self UIProgressStart];
             });
        }
    return self;
}

- (void) UIProgressStart{
    putchar('>');
    while (self.running == TRUE) {
        putchar('_');
        sleep(1);
    }
}

+ (void)single:(NSString *)message{
    NSLog(@"🐝 %@", message);
}

+ (void)multiple:(NSString *)message,...{
    va_list args;
    va_start(args,message);
    NSString *concatStr= [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"🐝 %@", concatStr);
    va_end(args);
}

@end
