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
#### False start
After receiving a positive, large integer (N) the program attempted to follow the same code path as thousand other StackOverflow readers:
```
-> verify that N was not even
-> Create an array of all odd numbers
-> remove 1, 2 from possible primes
-> Ensure only prime numbers were left

🐝 n = 3 * 1000003;                1, 7 digit prime
🐝 n = 101 * 1000033;              3, 7 digit prime
🐝 n = 7919 * 1000033;             4, 7 digit prime
🐝 99932297657 = 99929 * 1000033;  circa 5 seconds to complete
🐍 n = 3 * 5915587277;       10 digit prime

```
#### Problem 1 - size of N
Back to the challenge text:  `we are using 60 bit primes`.  The native `unsigned long` C type gave a ceiling of a positive, ~4 billion decimal value.  In reality, my final code had to deal with _billion billion_ values (which is called a _quintillion_).  Another way to say it:

```
C Type unsigned long  (max 4,294,967,295):
11111111111111111111111111111111  (32 bits)

C Type unsigned long long (max 18,446,744,073,709,551,615)
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
On small values, like most code on StackOverflow, my code worked.  But when I grew the size of N, my CPU was running at 99% for many minutes without finding an answer.  I think the code would have finished but I wasn't even trying to stress the code at that point.  I needed a more efficient algorithm that avoid my first pattern of `Brute Force`.

#### Other solutions?
So I didn't send my machine into warp speed and melt its processor, there were better ways to achieve a result without the `brute force` method I naively started with.

It was this article that really changed my approach.
**https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html**
You could use the `Birthday Paradox` to give you an efficient, *probabilistic* method to achieve the same.  **probabilistic**, huh?  The code could fail as it was starting to leverage random numbers.  But it could work the next time you ran the code.  I thought this was such a groovy concept.
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
