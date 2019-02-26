#import <Foundation/Foundation.h>
#ifndef Header_h
#define Header_h

@interface YDFindFactors : NSObject{
    UInt n;
    UInt p;
    UInt q;
}
-(BOOL) factorize;
@property int n;
@property int p;
@property int q;
@end

#endif /* Header_h */
