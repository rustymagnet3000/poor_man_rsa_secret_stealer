#include "YDPrettyConsole.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@implementation YDPrettyConsole

static int width;
int curser_counter;

- (instancetype)init{
        self = [super init];
        if (self) {
            [self setNotification];
            self.running = TRUE;
            dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
             
             dispatch_async(dispatchQueue, ^{
                 [self UIProgressStart];
             });
        }
    return self;
}

- (void) UIProgressStart{

    while (self.running == TRUE) {
        if(curser_counter == width){
            curser_counter = 0;
            putchar('\n');
        }
        curser_counter++;
        putchar(PROGRESS_CHAR);
        usleep(750000); // 0.75 second
    }
    #pragma mark - complete search banner.
    for (; curser_counter < width; curser_counter++){
        putchar(PROGRESS_CHAR);
    }
    putchar('\n');
}

- (void)setNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FactorizationCompleted" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self receiveNotification:note];
     }];
}

- (void)receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"FactorizationCompleted"])
    {
        [self setRunning:FALSE];
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
        putchar('*');
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
