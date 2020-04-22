#include "YDPrettyConsole.h"

@implementation YDPrettyConsole

- (instancetype)init{
    self = [super init];
    if (self){
        
        _running = NO;
        
        struct winsize w;
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
        if(w.ws_row > 0) {
            _width = w.ws_col;
        } else {
            _width = DEFAULT_WIDTH;
        }
        return self;
    }
    return NULL;
}

- (void) setRunning:(BOOL)r{
    _running = r;
    if(_running){
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
         
         dispatch_async(dispatchQueue, ^{
             [self UIProgressStart];
         });
    }else{
        [self UIProgressStop];
    }
}
-(BOOL)running{
    return _running;
}

- (void) UIProgressStop{
    for (; _curserCounter < _width; _curserCounter++){
        putchar(PROGRESS_CHAR);
    }
    putchar('\n');
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressBarFinished" object:NULL userInfo:NULL];
}

- (void) UIProgressStart{
    while (_running == YES) {
        if(_curserCounter == _width){
            _curserCounter = 0;
            putchar('\n');
        }
        _curserCounter++;
        putchar(PROGRESS_CHAR);
        fflush(stdout);
        usleep(750000); // 0.75 second
    }
}

- (void)banner{

    for (int i = 0; i < _width; i++)
        putchar(BANNER_CHAR);
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
