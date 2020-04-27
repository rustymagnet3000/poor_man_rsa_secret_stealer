## Encrypt message with Public Key
The `public key's Modulus length` dictates the maximum length of the message you hope to keep confidential.  Bigger primes ( `p * q = n` ) equate to a bigger maximum length of the secret message.

Let's try with this Public Key:
```
openssl rsa -inform PEM -pubin -in pkey.pem -text -noout
RSA Public-Key: (36 bit)
Modulus: 57564127333 (0xd6716e065)
Exponent: 65537 (0x10001)
```
Now the encrypted message:
```
echo -n -e '\x0\x33\x33\x33\x33' > secret.plaintext

xxd -b secret.plaintext
00000000: 00000000 00110011 00110011 00110011 00110011           .3333

openssl rsautl -encrypt -raw -pubin -inkey pkey.pem -in secret.plaintext -out secret.encrypted

xxd -b secret.encrypted
00000000: 00001001 01100101 00000011 11111101 11100010           .e...

xxd -ps secret.encrypted
096503fde2

// My app only took Decimal inputs ( not hex strings )
>>> print int("096503fde2", 16)
40349466082
```
## Understand the options
```
openssl help rsautl

-raw
Use no padding
```
You could also verify what you did with a hex print:
```
openssl rsautl -encrypt -pubin -inkey pkey.pem -raw -in secret.plaintext -hexdump
```
### START AGAIN

My code gets:  12232475972

## Troubleshoot Encrypt step
It was easy to hit errors, when generating custom Keys.

- data too small for key size
- data too large for key size
- data too large for modulus

```
xxd secret.plaintext
00000000: 0041 4243 4445 46                        .ABCDEF
```

Ok, we know the Key we generated was `RSA Public-Key: (36 bit)`.  That means we need to ensure the data is less than the modulus.

How big is the data?  Well, `ABCDEF` is actually:
```
n: 414243444546 (39 bits)
```
Ok, let's just shrink the plaintext?
```
echo -n -e '\x41\x42\x43\x44\x45' > secret.plaintext

cat secret.plaintext
ABCD%                      

stat -f "%z bytes" secret.plaintext
5 bytes

openssl rsautl -encrypt -pubin -inkey pkey.pem -raw -in secret.plaintext -out secret.encrypted
```

## Generate Short RSA Private Key
We are trying to create a file that completes this Struct.  I added comments to help the reader.

```
RSAPrivateKey ::= SEQUENCE {
    version           Version,
    modulus           INTEGER,  -- n                    ( in Public Key )
    publicExponent    INTEGER,  -- e                    ( in Public Key )
    privateExponent   INTEGER,  -- d                    ( Private. The decryption key )
    prime1            INTEGER,  -- p                    ( Private. p * q = n )
    prime2            INTEGER,  -- q                    ( Private. p * q = n )
    exponent1         INTEGER,  -- d mod (p-1)          ( Private )
    exponent2         INTEGER,  -- d mod (q-1)          ( Private )
    coefficient       INTEGER,  -- (inverse of q) mod p (Private. PHI)
    otherPrimeInfos   OtherPrimeInfos OPTIONAL
}
```
Specify the custom key:
```
asn1=SEQUENCE:rsa_key

[rsa_key]
version=INTEGER:0
modulus=INTEGER:57564127333
pubExp=INTEGER:65537
privExp=INTEGER:47169898753
p=INTEGER:869273
q=INTEGER:66221
e1=INTEGER:869272
e2=INTEGER:66220
coeff=INTEGER:57563191840
```


Then create the key:
```
openssl asn1parse -genconf custom_key.txt -out key.der
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
