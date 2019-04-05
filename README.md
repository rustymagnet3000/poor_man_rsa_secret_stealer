# Find an RSA Private Key
## Challenge
`https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7`

Below was a challenge from the article:
```
Encryption parameters
e:              65537
N:              1034776851837418228051242693253376923
Cipher:         582984697800119976959378162843817868
We are using    60 bit primes
```
The first game was to calculate the factors of N.  After that, and more hops, you would derive the Private Key.  With that key you would decrypt the ciphertext into plaintext.  Revealing a secret message! 🕵🏼‍.

## Goal
My first goal was to take a user entered `N` and attempt to find `P` and `Q` without blowing up my computer.  This was harder than I imagined but each roadblock was a fun lesson.

Even as I moved through this project, I still used tiny numbers compared to real-world RSA implementations.  This project was purely for academic / personal use and would not work against a real RSA implementation [unless somebody went against recommendations on RSA Key Lengths that were published here: __INSERTLINK__.
```
------------------------------------------------------------------------------------
1034776851837418228051242693253376923 = 1086027579223696553 x 952809000096560291
------------------------------------------------------------------------------------
```
## Design steps
#### Attempt 1: the Naive Trial Division Algorithm
After receiving a positive, large `N`, my app attempted to follow the same code path as a thousand other StackOverflow readers.  This was cynically (and probably fairly) labelled the `the Naive Trial Division Algorithm` by people who understood the _Math Theory_ behind the problem.  I did not have this understanding.  I hit every bump on the journey 🤕.

#### The number N
Assumptions about the `N` number:
 - [x] Not a negative
 - [x] Not even [as this implies there was a non-prime input `(100 = 5 * 20)`
 - [x] Not a prime number

#### Brainstorm
My idea was to write super simple code.

- verify that N was not even
- check every odd number less than < ( N / 2 )
- remove 1, 2 from possible primes
- check whether I could divide N / odd number and get a zero remainder
- checked whether any found odd number was a prime

#### Results 1
```
✅ [3, 11] = 33       // find both prime factors but not 1 or 2
✅ [3, 13] = 39       // same as previous
🔸 [3,9] = 27         // wrong. My code should have removed 9
🔸 [5, 20] = 100      // wrong. My code should have rejected n = 100
```

#### Code setup
I wrote a mix of C and Objective-C code.  xCode was the IDE.  That allowed me to apply existing Apple `Classes` [ like `run-loop` and `background threading` ] to kill my app and keep the U.I. refreshing.  My kill timer was set to 20 minutes.  This was my fail-safe to `N` values that were too large.  I ran the find factors on a background thread, to avoid blocking the UI thread. I added an `Observer` to check whether the code to find factors of a large number had been found.

I could have written everything in C but it would take longer and I found my C code soon became spaghetti without `Objects` to keep things structured.

At the beginning, I did not use third party libraries to tell me if a number was prime.

#### Results 2: Bugs everywhere 🐜 🐜 🐜
Status| Number (N) | Primes
--|---|--
🐝| 3000009  |  3 * 1000003
🐝| 101003333 |  101 * 1000033
🐍| 7919261327 |  7919 * 1000033
🐍| 17746761831 |  3 * 5915587277                              

A crazy value was returned shown when I tried to find the factors of `7919261327`.  Why?  Almost 8 billion.  I had the common sense to check the limits of C Types (good reference: https://docs.microsoft.com/en-us/cpp/cpp/data-type-ranges?view=vs-2017).

I picked the `Unsigned Long Long`.  Any variable of that type could store up to `18,446,744,073,709,551,615`.  Big.  That is 18 billion billion.  20 decimal digits.

Well, I made several errors with the same root cause.  I had used `int` and `unsigned long long` C Types interchangeably.  For your amusement, my bugs were the following:

```
BUG 1: int val = atoi(str);
// return type was `int`

BUG 2: for(int i = floor_limit; i <= upper_limit; i += 2)
// `i` was set to `int` when it was going to increment beyond the max integer

BUG 3: printf ("[+]%d is a factor \n", i);
// I told `printf` the input was an `int` when I sent it huge `unsigned long long` values
// this was one of those compiler warnings you just skipped over...
```
#### Results 3: harder bugs 🐜
I purged my code of `int` types.  I sped up my search loop by removing stupid code.

Status| Number (N) | Primes found | Time taken
--|---|--|--
🐝| 505371799 | 16127 * 31337 | 1 second
🐝| 7919261327 | 7919 * 1000033  | 19 seconds
🐜| 10175656859 | 100033 * 101723 | 25 seconds. Failed to find all factors
🐝| 17746761831 | 3 * 5915587277  | 72 seconds
🐜| 8069212743871 |  2840261 * 2841011 (7) | Found factors but timed out.
🐜| 100001880003211 | 10000019 * 10000169 (8) | Found factors but timed out.

Why was `8069212743871` not able to finish ?

In 20 minutes, my computer running was able to check `N` values of up to ~220 billion.  Give or take a billion.  This was a long way off the (8 trillion / 2) I asked for it to check.  Let say the crude calculation was:

```
(8 trillion / 2) == upper_limit (4 trill)
4 trill / 220 bill == 18.1
20 minutes * 18.1 = 362 minutes
362 = 6 hours
```

#### Brute Force is slow
I set my kill timer to 10 hours, while I slept.  My crude calculation was accurate enough.

Status| Number (N) | Primes | Time taken
--|---|--|--
🐝| 8069212743871 |  2840261 * 2841011 (7) | 5 hours.

How long to calculate `100001880003211` which is just over 100 trillion?
```
100 trill / 2 == upper_limit
upper_limit / 4 trill == 12.5
12.5 * 6 hours == 75 hours.
```
Using my crude calculation again, with 2 x Primes of 8-digits, my `N` value would take over **3 days** to exhaust all possible `N` values.

## Summary
#### Failings of the Naive Trial Division Algorithm
In summary, on small values, like most code on StackOverflow, my code worked.  But when I grew the size of N == 2 primes of 8 or more digits, my CPU would have to run at 99% for many days, weeks, millennia !

The `Naive Trial Division Algorithm` had no chance of dealing with a `60 bit primes`.  It took 5 hours to search all odd numbers when the loop's upper limit was set to 4 trillions  __INSERT BIT LENGTH OF 8069212743871__   My crude numbers illustrate this:
```
My computer could do 4 trillion in 5 hours
18 quintillion \ 4 trillion == 4.5 million
4.5 million * 5 hours = 2,500 years
```
**2,500 years** just to exhaust a single prime.

Back to the challenge text:  `we are using 60 bit primes`.  The native `unsigned long` C type gave a ceiling of a positive, ~4 billion decimal value.  Another way to say it:
```
C Type unsigned long  (max 4294967295):
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
## Redesign
So I didn't send my machine into warp speed and melt the CPU, I searched for better methods to achieve what I wanted. The following article changed my entire approach:

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html

You could use the `Birthday Paradox` to give you an efficient, *probabilistic* method to achieve the same.  **probabilistic**, huh?  The code could fail.  But it could work the next time you ran the code.  Fun?

Step forward the **gmp** library.  I also considered `openSSL's` in-built Big Number functionality but I didn't want to unpick the `openssl` security or networking code.  I expected that decision would bite later [ as I would need a RSA key generation and an RSA decrypt function to test my code ].




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
