

## The Secret Message
echo -n -e '\x41\x42\x43\x44' > secret.plaintext

Verify no character returns..
```
xxd secret.plaintext
00000000: 4142 4344                                ABCD
```
You can also
```
cat secret.plaintext 
ABCD%
```

## Encrypt Secret with Public Key
Easy to hit these errors, with custom Keys.

My `Modulus` caused this:
```
data too small for key size:crypto/rsa/rsa_none.c:23:

data too large for modulus:crypto/rsa/rsa_ossl.c:131:
```

echo -n -e '\x41\x42\x43\x44\x45\x46\x47' > secret.plaintext





## Generate Short RSA Private Key
The normal tools set a minimum version that you cannot override.
```
ssh-keygen -t rsa -b 512 
Invalid RSA key length: minimum is 1024 bits
```
This also fail with:
```
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:100
genpkey: Error setting rsa_keygen_bits:100 parameter:
```
But can you set a custom Private Key?

```
RSAPrivateKey ::= SEQUENCE {
    version           Version,
    modulus           INTEGER,  -- n
    publicExponent    INTEGER,  -- e
    privateExponent   INTEGER,  -- d
    prime1            INTEGER,  -- p
    prime2            INTEGER,  -- q
    exponent1         INTEGER,  -- d mod (p-1)
    exponent2         INTEGER,  -- d mod (q-1)
    coefficient       INTEGER,  -- (inverse of q) mod p
    otherPrimeInfos   OtherPrimeInfos OPTIONAL
}
```


## Custom Keys
openssl asn1parse -genconf custom_key.txt -out key.der 


    0:d=0  hl=2 l=  52 cons: SEQUENCE          
    2:d=1  hl=2 l=   1 prim: INTEGER           :00
    5:d=1  hl=2 l=   7 prim: INTEGER           :0115DC9116DA11
   14:d=1  hl=2 l=   6 prim: INTEGER           :4724659EC8E9
   22:d=1  hl=2 l=   3 prim: INTEGER           :02C695
   27:d=1  hl=2 l=   4 prim: INTEGER           :010AAF2F
   33:d=1  hl=2 l=   4 prim: INTEGER           :010ABABF
   39:d=1  hl=2 l=   3 prim: INTEGER           :02C695
   44:d=1  hl=2 l=   3 prim: INTEGER           :02C695
   49:d=1  hl=2 l=   3 prim: INTEGER           :1898A2


$openssl asn1parse -genconf asn_format_mykey.txt -out key.der
$openssl rsa -inform der -in key.der -outform pem > key.pem
$openssl rsa -inform der -in key.der -outform pem -pubout>pkey.pem


echo 'AAAAAAA'| openssl rsautl -encrypt -pubin -inkey pkey.pem -raw -out message.encrypted
RSA operation error
4514530752:error:0406B06E:rsa routines:RSA_padding_add_none:data too large for key size:crypto/rsa/rsa_none.c:18:


## References
https://math.stackexchange.com/questions/20157/rsa-in-plain-english
https://tools.ietf.org/html/rfc3447#appendix-C                   
https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem
https://superuser.com/questions/1326230/encryption-using-openssl-with-custom-rsa-keys

