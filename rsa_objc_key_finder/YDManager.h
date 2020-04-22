#import <Foundation/Foundation.h>
#import "YDFindFactors.h"
#import "YDPlistReader.h"
#import "YDPrettyConsole.h"
#define KILLTIMER 3600 * 8
#define TWOMINUTES 120

@protocol YDManagerRules <NSObject>
@required
- (void)setNotification;
@end

@interface YDManager : NSObject  <YDManagerRules>{
    NSDate *startTime;
    NSDate *endTime;
}

@property YDPListReader *keyToAnalyze;

- (instancetype)init:(NSString *)pubKeyfilename;
- (void)setNotification;
- (void)timeTaken;
+ (void)dirtyExit;

@end
