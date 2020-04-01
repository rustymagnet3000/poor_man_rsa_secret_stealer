18446744073709551615
1034776851837418228051242693253376923


## The Secret Message
```
echo -n -e '\x41\x42\x43\x44' > secret.plaintext
```
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
➜  create_keypair git:(foundfactors) ✗ openssl rsautl -encrypt -pubin -inkey pkey.pem -raw -in secret.plaintext -out secret.encrypted
RSA operation error
4347848128:error:04068084:rsa routines:rsa_ossl_public_encrypt:





## Generate Short RSA Private Key
We are trying to create a file that completes this Struct:

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
Then create the key:
```
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

```
Convert to PEM format:
```
$openssl rsa -inform der -in key.der -outform pem > key.pem
```
Extract the Public Key:
```
$openssl rsa -inform der -in key.der -outform pem -pubout>pkey.pem
```
Print the Public Key:
```
openssl rsa -inform PEM -pubin -in pkey.pem -text -noout 
RSA Public-Key: (49 bit)
Modulus: 305512047893009 (0x115dc9116da11)
Exponent: 78221649299689 (0x4724659ec8e9)
```


## Why not use the normal commands?
The normal tools set a minimum version that you cannot override.
```
ssh-keygen -t rsa -b 512 
Invalid RSA key length: minimum is 1024 bits

openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:100
genpkey: Error setting rsa_keygen_bits:100 parameter:
```






## References
https://math.stackexchange.com/questions/20157/rsa-in-plain-english
https://tools.ietf.org/html/rfc3447#appendix-C                   
https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem
https://superuser.com/questions/1326230/encryption-using-openssl-with-custom-rsa-keys

