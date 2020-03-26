#include "YDPrettyConsole.h"
#define DEFAULT_WIDTH 30

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDPrettyConsole

static int width;

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

+ (void)banner{

    if(width == 0) {
        struct winsize w;
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
        if(w.ws_row > 0) {
            width = w.ws_col;
        } else {
            width = DEFAULT_WIDTH;
        }
    }
    for (int i = 0; i < width; i++)
        putchar('-');
    putchar('\n');
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

+ (void)error:(NSString *)message,...{
    va_list args;
    va_start(args,message);
    NSString *concatStr= [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"🐝 %@", concatStr);
    va_end(args);
    exit(99);
}

@end
