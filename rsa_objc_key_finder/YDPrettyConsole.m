#include "YDPrettyConsole.h"

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
        return self;
        
    }
    return NULL;
}

- (void) setRunning:(BOOL)r{
    running = r;
    if(running){
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
         
         dispatch_async(dispatchQueue, ^{
             [self UIProgressStart];
         });
    }else{
        [self UIProgressStop];
    }
}
-(BOOL)running{
    return running;
}

- (void) UIProgressStop{
    #pragma mark - complete search banner.
    for (; _curserCounter < width; _curserCounter++){
        putchar(PROGRESS_CHAR);
    }
    putchar('\n');
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressBarFinished" object:NULL userInfo:NULL];
}

- (void) UIProgressStart{
    while (running == YES) {
        if(_curserCounter == width){
            _curserCounter = 0;
            putchar('\n');
        }
        _curserCounter++;
        putchar(PROGRESS_CHAR);
        usleep(750000); // 0.75 second
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
