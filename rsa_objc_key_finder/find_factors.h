#import <Foundation/Foundation.h>
#ifndef Header_h
#define Header_h

@interface YDFindFactors : NSObject{
    UInt n;
    UInt p;
    UInt q;
}

-(BOOL)divideNoRemainder;
-(BOOL) factorize;
@property(readonly) int n;

@end

#endif /* Header_h */
