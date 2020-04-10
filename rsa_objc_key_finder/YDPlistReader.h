#ifndef YDPlistReader_h
#define YDPlistReader_h
#define ARGS_EXPECTED_IN_FILE 3

@interface YDPListReader : NSObject{
    NSString *_name;
    NSString *_file;
}

@property NSDictionary *foundDictItems;
- (instancetype)initWithPlistName:(NSString *)name;

@end

#endif /* YDPlistReader_h */
