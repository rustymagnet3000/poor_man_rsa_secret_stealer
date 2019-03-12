# RSA Key Finder
## Challenge
`https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7`

Here is an example:
```
Encryption parameters
e:      65537
N:      1034776851837418228051242693253376923
        123456789012345678901
Cipher:    582984697800119976959378162843817868
We are using  60 bit primes
```
Factors
```
-------
1034776851837418228051242693253376923 = 1086027579223696553 x 952809000096560291
```
## Goal
Take N and establish P and Q, on calculate a background thread.

## Design steps
##### False start
After receiving a positive, large integer (N) the program attempted to:
```
-> verify that N was not even
-> Create an array of all odd numbers, less than N
-> remove 1 and from the array
-> Ensure only prime numbers were left
```
As I was dealing in large, decimal literals (Base 10) I could not use any native C number types.  I used the `gmp` library.  
##### Factors of N
There were multiple ways to achieve this.  My code was primitive so I changed it to the `Pollard Rho Algorithm`.

I purposely added an `observer` to check whether the code to find factors of a large number had been found.  I ran the  find factors on a background thread, to avoid blocking the UI thread.

##### Miller–Rabin primality test
This already had the `primality test` code.  This was a `probabilistic primality test`.  Hence, the code had a watchdog to catch when the code could not determine an answer.
```
/*     printing of result ( reps ) in the form of                    */
/* reps = 2          if n is definitely prime                        */
/* reps = 1          if n is probably prime (without being certain)  */
/* reps = 0          if n is definitly composite. There should be it.*/
```
I also read that `Reasonable values of reps are between 15 and 50.` on `https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm`.

##### Test Vectors
```
Non-Prime Pair: [3,9] = 27
Primes : [3, 11] = 33
Primes : [13, 29] = 377
Primes : [467, 601] = 280667
Primes : [3461, 3319] = 11487059
Primes : [45095080578985454453, 36413321723440003717] = 1642061677267048469007620094567254201801

```
##### GMP References

https://stackoverflow.com/questions/4424374/determining-if-a-number-is-prime

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/gmpTutorial.html

https://gnu.huihoo.org/gmp-3.1.1/html_chapter/gmp_4.html

https://gmplib.org/manual/Binary-GCD.html#Binary-GCD

http://sep.stanford.edu/sep/claudio/Research/Prst_ExpRefl/ShtPSPI/intel/mkl/10.0.3.020/examples/gmp/source/mpz_probab_prime_p_example.c

https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm

##### References

https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm

https://hbfs.wordpress.com/2013/12/10/the-speed-of-gcd/

https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test

https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7

https://en.wikipedia.org/wiki/Pollard%27s_p_%E2%88%92_1_algorithm

https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/

http://abulewis.com/blog/concurrency-in-objective-c-using-grand-central-dispatch-gcd/

https://medium.com/ios-os-x-development/broadcasting-with-nsnotification-center-8bc0ccd2f5c3

https://www.cs.swarthmore.edu/~newhall/unixhelp/C_arrays.html

https://primes.utm.edu/lists/small/small.html

https://github.com/raywenderlich/objective-c-style-guide
