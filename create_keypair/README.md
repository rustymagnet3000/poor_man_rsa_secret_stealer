## Generate Short RSA Private Key
We are trying to create a file that completes the following `Struct`.
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
Adding the custom key:
```
asn1=SEQUENCE:rsa_key

[rsa_key]
version=INTEGER:0
modulus=INTEGER:464583729100140631
pubExp=INTEGER:65537
privExp=INTEGER:445365782275853969
p=INTEGER:982451653
q=INTEGER:2841011
e1=INTEGER:982451652
e2=INTEGER:2841010
coeff=INTEGER:464583727644806952
```
Then create the key:
```
openssl asn1parse -genconf custom_key.txt -out key.der
```
Convert to PEM format:
```
openssl rsa -inform der -in key.der -outform pem > key.pem
```
Extract the Public Key:
```
openssl rsa -inform der -in key.der -outform pem -pubout>pkey.pem
```

## Encrypt message with Public Key
The `public key's Modulus length` dictates the maximum length of the message you hope to keep confidential.  Bigger primes ( `p * q = n` ) equate to a bigger maximum length of the secret message.

Let's try with this Public Key:
```
openssl rsa -inform PEM -pubin -in pkey.pem -text -noout
--------------------------------------------------------
RSA Public-Key: (59 bit)
Modulus: 464583729100140631 (0x6728870ad70b057)
Exponent: 65537 (0x10001)

```
#### Create message to keep confidential
A Modulus of `59 bits` leaves us with `7 Bytes`.  You actually have `8 Bytes` as `59 bit / 8 bits = 7 bytes`.  But there is a remainder.  The remainder is enough for a small byte.  This is important.  The first byte can be anything between `0x00` - `0x06`.  Did you notice the Modulus' first byte was not `0x67`?
```
echo -n -e '\x05\x34\x33\x34\x34\x33\x34\x33' > secret.plaintext
// WORKS as x05 < x06 (modulus' first byte)

echo -n -e '\x07\x34\x33\x34\x34\x33\x34\x33' > secret.plaintext
// FAILS -> data too large for modulus
```
The failed message, was caused by the first byte (x07) being greater than the modulus' first byte (x06).

#### RSA with no Padding
Why did that step matter? If you understood that step, you will be able to to avoid these errors:

- data too small for key size
- data too large for key size
- data too large for modulus

When you pass `-raw` flag to `OpenSSL's rsautl` tool you have selected `use no padding`.  **The user is responsible** for making sure the message and the modulus length match.

`No padding` would never be used in a real application as the output would be `deterministic`.

#### Verify your Bytes
```
echo -n -e '\x05\x31\x32\x33\x34\x35\x36\x37' > secret.plaintext
// changed leading byte to 05 instead of NULL. 1234567.

hexdump secret.plaintext
0000000 05 31 32 33 34 35 36 37

xxd -b secret.plaintext
00000000: 00000101 00110001 00110010 00110011 00110100 00110101  .12345
00000006: 00110110 00110111                                      67

stat -f "%z bytes" secret.plaintext
8 bytes
```
#### Encrypt data
```
openssl rsautl -encrypt -raw -pubin -inkey pkey.pem -in secret.plaintext -out secret.encrypted

-encrypt = Public Key used to Encrypt
-raw = No padding

hexdump secret.encrypted
0000000 05 a9 09 d5 f6 84 fa 3e

xxd -ps secret.encrypted
05a909d5f684fa3e

// get the Decimal version
>>> print int("0x5b34443cce8fe1a",16)
410747049012166170

// be sure it reverses back to Hex
>>> print int("0x531323334353637",16)
374135439549085239
```

### Appendix - Why not use standard Key Generation commands?
The normal tools set a minimum version that you cannot override.
```
ssh-keygen -t rsa -b 512
Invalid RSA key length: minimum is 1024 bits

openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:100
genpkey: Error setting rsa_keygen_bits:100 parameter:
```
### References

https://gist.github.com/aishraj/4010562  (advanced use of GMP)

https://math.stackexchange.com/questions/20157/rsa-in-plain-english

https://tools.ietf.org/html/rfc3447#appendix-C                   

https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem

https://superuser.com/questions/1326230/encryption-using-openssl-with-custom-rsa-keys
