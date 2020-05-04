#import "YDManager.h"
#include "gmp.h"

/* When decrypting, check whether it is a String, Hex String or long Decimal */
@implementation FooBar: NSObject

+ (void)guessFormatOfDecryptedType:(NSString *)input{
    NSCharacterSet *hexChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    NSCharacterSet *decimalChars = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSCharacterSet *alphanumericChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    puts("\n[+]NSString says:");
    
    if ([input rangeOfCharacterFromSet:alphanumericChars].location == NSNotFound){
        if ([input rangeOfCharacterFromSet:decimalChars].location == NSNotFound){
            NSLog(@"\t\tGuessed decimal: %@", input);
        }
        else if ([input rangeOfCharacterFromSet:hexChars].location == NSNotFound){
            NSLog(@"\t\tGuessed hex: %@", input);
        }
        else{
            NSLog(@"\t\tGuessed alphanumeric: %@", input);
        }
    }
    else{
        
        const char *chars = [input UTF8String];
        NSMutableString *escapedString = [NSMutableString string];
        while (*chars)
        {
            if (*chars == '\\')
                [escapedString appendString:@"\\\\"];
            else if (*chars == '"')
                [escapedString appendString:@"\\\""];
            else if (*chars < 0x1F || *chars == 0x7F)   // check for special
                [escapedString appendFormat:@"\\x%02X", (int)*chars];
            else
                [escapedString appendFormat:@"%c", *chars];
            ++chars;
        }

        NSLog(@"\t\tEscaped some chars:  %@", escapedString);
    }
    putchar('\n');
}
@end

//const char bytes1[15] = { 0x41, 0x42, 0x43, 0x31, 0x32, 0x33, 0x41, 0x42, 0x43, 0x31, 0x32, 0x33, 0x41, 0x42, 0x43 }; // ABC123
//const char bytes1[6] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00 }; // "Hello"
//const char bytes1[7] = { 0x31, 0x31, 0x31, 0x32, 0x32, 0x32, 0x00 }; // 1112222
const char bytes1[7] = { 0x05, 0x31, 0x32, 0x33, 0x34, 0x05, 0x00 }; // \0x512345
//const char bytes1[8] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0x21, 0x00 }; // "Hello!!"


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

        NSLog(@"can be converted: %hhd", [regurgiatedStr canBeConvertedToEncoding:NSNonLossyASCIIStringEncoding]);
        [FooBar guessFormatOfDecryptedType:regurgiatedStr];
        
        regurg = NULL;
        countp = NULL;
        free(regurg);
        free(countp);
        mpz_clear ( a );
    }
    return 0;
}







    



