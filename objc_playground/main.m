#import "YDManager.h"
#include "gmp.h"

/* When decrypting, check whether it is a String, Hex String or long Decimal */

@implementation FooBar: NSObject

+ (void) guessFormatOfDecryptedType: (NSString *)input{
    NSCharacterSet *hexChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    NSCharacterSet *decimalChars = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSCharacterSet *alphanumericChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    puts("\n[+]NSString says:");
    
    if ([input rangeOfCharacterFromSet:alphanumericChars].location == NSNotFound){
        if ([input rangeOfCharacterFromSet:decimalChars].location == NSNotFound){
            NSLog(@"\t\tGuessed decimal: %d", (int) input);
        }
        else if ([input rangeOfCharacterFromSet:hexChars].location == NSNotFound){
            NSLog(@"\t\tGuessed hex: %@", input);
        }
        else{
            NSLog(@"\t\tGuessed alphanumeric: %@", input);
        }
    }
    else{
        NSLog(@"\t\t Not just alphanumeric chars.  Default NSLog: %@", input);
    }
    putchar('\n');
}
@end

const char bytes1[15] = { 0x41, 0x42, 0x43, 0x31, 0x32, 0x33, 0x41, 0x42, 0x43, 0x31, 0x32, 0x33, 0x41, 0x42, 0x43 }; // ABC123
const char bytes2[6] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00 }; // "Hello"
const char bytes3[7] = { 0x31, 0x31, 0x31, 0x32, 0x32, 0x32, 0x00 }; // 1112222
const char bytes4[8] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0x21, 0x00 }; // "Hello!!"


int main(void) {
    @autoreleasepool {
        
        mpz_t a; mpz_init( a );
        
        mpz_import ( a, sizeof(bytes1), 1, sizeof(bytes1[0]), 0, 0, bytes1 );

        size_t aLen;
        aLen = mpz_sizeinbase(a, 16);
        gmp_printf("[+]GMP says:\n\t\tBytes:%Zx (hex bytes)\n\t\tBytes:%Zd (%zu bits)", a, a, aLen );

        char *regurg = calloc(aLen, sizeof(char));
        size_t *countp = NULL;
        mpz_export ( regurg, countp, 1, sizeof(char), 0, 0, a );
        
        if(countp)
            printf("[+] countp:(%p)\n", countp);

        NSString *regurgiatedStr = [[NSString alloc] initWithUTF8String:regurg];

        [FooBar guessFormatOfDecryptedType:regurgiatedStr];
        
        regurg = NULL;
        countp = NULL;
        free(regurg);
        free(countp);
        mpz_clear ( a );
    }
    return 0;
}







    



