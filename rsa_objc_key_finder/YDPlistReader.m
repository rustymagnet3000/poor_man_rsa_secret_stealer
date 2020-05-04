#import <Foundation/Foundation.h>
#import "YDPlistReader.h"

@implementation YDPListReader

- (instancetype)init {
    self = [self initWithPlistName:@"pubKeyAndCipherText"];
    return self;
}

- (BOOL)fileChecks {
   // MARK: The NSBundle pointer is defined as below to ensure Unit Tests work
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    _file = [bundle pathForResource:_name ofType:@"plist"];
    
    if (bundle == NULL || _file == NULL) {
        return NO;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:_file]){
        return YES;
    }
    return NO;
}

- (BOOL)checkPlistContents {

    _foundDictItems = [NSDictionary dictionaryWithContentsOfFile:_file];
    if (_foundDictItems == NULL || [_foundDictItems count] != ARGS_EXPECTED_IN_FILE){
        NSLog(@"Not able to read plist file or unexpected values");
        return NO;
    }
    return YES;
}

- (instancetype)initWithPlistName:(NSString *)name {
    self = [super init];

    if (self) {
        _name = name;
        
        if(![self fileChecks])
            return NULL;

        if(![self checkPlistContents])
            return NULL;
    }
    return self;
}
@end
