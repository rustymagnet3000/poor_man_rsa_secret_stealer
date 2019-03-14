# Find an RSA Private Key
## Challenge
`https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7`

Here was an example from the article:
```
Encryption parameters
e:              65537
N:              1034776851837418228051242693253376923
Cipher:         582984697800119976959378162843817868
We are using    60 bit primes
```
Now the game was to calculate the factors of N and then derive the Private Key (that could decrypt the ciphertext)
```
------------------------------------------------------------------------------------
1034776851837418228051242693253376923 = 1086027579223696553 x 952809000096560291
------------------------------------------------------------------------------------
```
## Goal
Take N and attempt to find P and Q on a background thread.

## Design steps
#### False start 1
After receiving a positive, large integer (N) the program attempted to follow the same code path as thousand other StackOverflow readers.  This code was called `the Naive Trial Division Algorithm` by academics.

- verify that N was not even
- create an array of all odd numbers
- remove 1, 2 from possible primes
- ensure only prime numbers were left

Status| unsigned long long | Primes
--|---|--
🐝| 3000009  |  3 * 1000003
🐝| 101003333 |  101 * 1000033
🐍| 7919261327 |  7919 * 1000033
🐍| 17746761831 |  3 * 5915587277                              

#### False start 2
Why was I getting a crazy value when I tried to use `7919261327` (almost 8 billion) into an `Unsigned Long Long`?  My code failed.  But I used a Type that could safely store up to `18,446,744,073,709,551,615` (18 billion billion).  That is 20 decimal digits.

The C API I used `atoi()` only returned a `C int` type.   Groan.  In Computer Science speak that is called `unsafe casting`. Fear not, I had just picked the wrong API.  Step forward native C API called `strtol()`.

Status| unsigned long long | Primes | Time taken
--|---|--|--
🐝| 7919261327  |  7919 * 1000033  | 10 seconds
🐍| 17746761831 |  3 * 5915587277  | Failed to find 10 digit prime
🐍 | 24212989121030676023 |  5915587277 * 4093082899  | Too big for C Type
🐍 | 2015994091679141905085000807307 |  3 * 671998030559713968361666935769   | Too big for C Type

#### Problem 1 - size of N
Back to the challenge text:  `we are using 60 bit primes`.  The native `unsigned long` C type gave a ceiling of a positive, ~4 billion decimal value.  In reality, my final code had to deal with _billion billion_ values (which is called a _quintillion_).  Another way to say it:

```
C Type unsigned long  (max 4,294,967,295):
11111111111111111111111111111111  (32 bits)

C Type unsigned long long (max 18446744073709551615)
1111111111111111111111111111111111111111111111111111111111111111 (64 bits)

A 65 bit prime (29497513910652490397):
11001100101011100001110001001111000000001100101011101001010011101 (65 bits)
```
Remember `P * Q = N`.  I could probably get away with `unsigned long long` for P and Q ( 60-65 bits each) but how would I even define N as variable when it was so much bigger than the either of those values ?  

```
N = P * Q
812434587229347807826931000341281416581 = 29497513910652490397 * 27542476619900900873
N = 130 bits
```
Step forward the **gmp** library.  I also considered `openSSL's` inbuilt number functionality but I didn't want to unpick the `openssl` security or networking code.  I expected that decision to bite later as I would probably need a key generation and decrypt function to test my code.

#### Problem 2 - Hard Math problems
On small values, like most code on StackOverflow, my code worked.  Depressingly, my code was less reliable than the `Naive Trial Division Algorithm` on here: https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html.

But when I grew the size of N, my CPU was running at 99% for many minutes without finding an answer.  I think the code would have finished but I wasn't even trying to stress the code at that point.  I needed a more efficient algorithm that avoid my first pattern of `Brute Force`.

#### Other solutions?
So I didn't send my machine into warp speed and melt the CPU, I found better methods to achieve what I wanted. This article really changed my approach.
**https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html**
You could use the `Birthday Paradox` to give you an efficient, *probabilistic* method to achieve the same.  **probabilistic**, huh?  The code could fail.  But it could work the next time you ran the code.  Fun?
#### Factors of N
There were multiple ways to achieve this.  My code was primitive so I changed it to the `Pollard Rho Algorithm`.

I purposely added an `observer` to check whether the code to find factors of a large number had been found.  I ran the  find factors on a background thread, to avoid blocking the UI thread.

#### Miller–Rabin primality test
This already had the `primality test` code.  This was a `probabilistic primality test`.  Hence, the code had a watchdog to catch when the code could not determine an answer.
```
/*     printing of result ( reps ) in the form of                    */
/* reps = 2          if n is definitely prime                        */
/* reps = 1          if n is probably prime (without being certain)  */
/* reps = 0          if n is definitly composite. There should be it.*/
```
I also read that `Reasonable values of reps are between 15 and 50.` on `https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm`.

#### Test Vectors
```
Non-Prime Pair: [3,9] = 27
Primes : [3, 11] = 33
Primes : [13, 29] = 377
Primes : [467, 601] = 280667
Primes : [3461, 3319] = 11487059
Primes : [45095080578985454453, 36413321723440003717] = 1642061677267048469007620094567254201801

```
#### GMP References

https://stackoverflow.com/questions/4424374/determining-if-a-number-is-prime

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/gmpTutorial.html

https://gnu.huihoo.org/gmp-3.1.1/html_chapter/gmp_4.html

https://gmplib.org/manual/Binary-GCD.html#Binary-GCD

http://sep.stanford.edu/sep/claudio/Research/Prst_ExpRefl/ShtPSPI/intel/mkl/10.0.3.020/examples/gmp/source/mpz_probab_prime_p_example.c

https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm

#### C References

https://www.systutorials.com/docs/linux/man/3-strtol/

#### References

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
