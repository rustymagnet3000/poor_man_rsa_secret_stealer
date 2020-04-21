# Find a Private Key
## Challenge
`https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7`

Below was a challenge from the article:
```
Encryption Parameters of a RSA Public key
e: (Exponent)                      65537
𝑁: (Modulus)                      1034776851837418228051242693253376923
𝑝:                                 < unknown Prime Number >
𝑞:                                 < unknown Prime Number >
Length of Modulus:                60 bits
Encrypted secret:                 582984697800119976959378162843817868
```
The code in this repo was built to find a `Private Key` that would reveal a secret message.

## Challenge 1: 60 bit Primes
```
🐝 Started	16:52:38
🐝 Factorize N:1034776851837418228051242693253376923
🐝 Exponent: 65537
🐝 Ciphertext: 582984697800119976959378162843817868
🐝 Length of n:120 bits
******************************
🐝 P:952809000096560291 (60 bits)
🐝 Q:1086027579223696553 (60 bits)
🐝 Finished at loop: 28 k values: 268435456
🐝 PHI:1034776851837418226012406113933120080
🐝 Decryption Key:568411228254986589811047501435713
🐝 Plaintext:345
******************************
🐝 Finished in: 385.018 seconds

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

🐝 Started	06:48:55
🐝 Factorize N:498702132445864856509611776937010471
🐝 Exponent: 65537
🐝 Ciphertext: 96708304500902540927682601709667939
🐝 Bits length of N:119
******************************
🐝 P:640224252335299439 (60 bits)
🐝 Q:778949142627423689 (60 bits)
🐝 Finished at loop: 31 k values: -2147483648       // notice the bug here?
🐝 PHI:498702132445864855090438381974287344
🐝 Decryption Key:385107896622560911412972764596132081
🐝 Plaintext:638
******************************
🐝 Finished in: 3627.512 seconds
```
## Answer 2
```
e: 65537
𝑁: 1034776851837418228051242693253376923
Ciphertext: 582984697800119976959378162843817868
Secret Message:   345
```

## Steps
The first piece of code calculates `factors` of N.  The `factors` must only be `Prime Numbers`.  The found numbers were referred to as `𝑝` and `𝑞` and were to be kept secret.  `𝑁` was not a secret and it was part of the `Public Key`.

After `factorizing` other steps were required:

Step to find Private Key | Expressed as
--|--
`Factorization` | 𝑝,𝑞 primes, 𝑛=𝑝𝑞
`Euler's Totient function (PHI)` |𝑑 relatively prime to 𝜑(𝑛)=(𝑝−1)(𝑞−1)
`Extended Euclidean algorithm (GCD)` | 𝑒 was 𝑒𝑑(mod𝜑(𝑛))=1  or ed =1(mod𝜑(𝑛))
| 𝑥𝑒𝑑(mod𝑛)=𝑥

## Re-Design
I searched for more efficient ways to `Factorize` a large number.  The following article changed my approach:

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html

You could use the `Birthday Paradox` to give you an efficient, *probabilistic* method to achieve the same.  **probabilistic**, huh?  The code could fail.  But it could work the next time you ran the code.

Step forward the `C library` called `GMP` .  I also considered `openSSL` but - after some later trial and error - I realized `gmp` could achieve everything I wanted.

#### Results 6: Pollard Rho
Even with no optimization and memory bugs, Pollard Rho's algorithm unlocked massive improvements:

Status| Number (N) | Primes found | Time taken
--|---|--|--
✅| 8069212743871 | 2840261 * 2841011 |  8069212743871. Instant. Took 5 hours with the `Naive` factoring.
❌| 464583729100140631 | 982451653 * 472882027  | Not found. sucked 300MB before completing 20k cycles!
❌| 1034776....253376923 | < unknown > | Not found. Sucked up a 3MB every second of RAM. Got to 2.7GB used!

#### Results 7: Pollard Rho
Re-using a tidier algorithm, I was able to factorize the challenge `n`.

Status| Number (N) | Primes found | Time taken
--|---|--|--
✅| 4657259 | 443 * 10513 | 0.008 seconds
✅| 505371799 | 16127 * 31337 | 0.008 seconds
✅| 57564127333 | 869273 * 66221 | 0.009 seconds
✅| 8069212743871 | 2840261 * 2841011 |  8069212743871. Took 5 hours with the `Naive` factoring.  
✅| 4728829254758513 | 10000019 * 472882027 | 0.010 seconds
✅| 464583729100140631 | 982451653 * 472882027  | 0.243 seconds
✅| 1034776851837418228051242693253376923 | 1086027579223696553 *	952809000096560291 | 6 minutes 21 seconds
✅| 1642061677267048469007620094567254201801 | 36413321723440003717 * 45095080578985454453   | 42 seconds

### Euler's totient function
Number (N) | Primes
--|--
7919261327 |  7919 * 1000033

As we know the above numbers were prime, this step is simple.
```
ϕ(𝑛)=(𝑝−1)(𝑞−1)
ϕ(𝑛)=(7919−1)(1000033−1)
ϕ(𝑛)=(7918)(1000032)
ϕ(𝑛)=7918253376
```
### Greatest Common Denominator (GCD) / Modular multiplicative inverse
So you need `e [ Exponent ]` for this step.  Remember `e` is a Public value readable inside the Public Key.

Use the `Extended Euclidean Algorithm` to compute a `modular multiplicative inverse`.

```
Inverse of  65537  mod  7918253376
```


This is where my knowledge is thin. Apparently you can't just calculate `φ(n)`. You need to do `𝜑(𝑛)=(𝑝−1)(𝑞−1)`.
```
gcd(e, φ(n)) = 1
e = Exponent. Pre-selected, and public information.
gcd(65537, 7918253376) = 1
```




 these steps, the app had derived the Private Key.  The Private Key could decrypt the `ciphertext` (above) into `plaintext`.

### Context

The challenge used tiny numbers compared to real-world `RSA` implementations.  This challenge used `60 bit Primes`.  Where standards organizations (`NIST` et al ) disallowed anything less than `2048 bit number (Modulus) and 1,024 bit prime numbers`.  How hard is `factoring` for a computer?  A great video on this [topic](https://www.youtube.com/watch?v=tq8dTl74bL0).

This project was purely for academic interest and would not work against a real RSA implementation.  


## Goal 1: Read and factorize N
My first goal was to take a long, user entered number (`N`).  Eventually my code would handle the challenge `N` value of ` 1034776851837418228051242693253376923`.

Sounds easy?   Defintely not; this is a [`Time Complex`](https://en.wikipedia.org/wiki/Time_complexity) problem.



## Design steps
#### Assumptions about the number N

 - [x] Not a negative
 - [x] Not even [as this implies a non-prime input `(100 = 5 * 20)`
 - [x] Not a prime number
 - [x] A "good" `N` was made of two `Primes`.

#### Brainstorm
My original idea was to write super simple code that enforced:

- N was not even
- Only `odd` numbers
- Only numbers less than less than ` N / 2 `
- Any found odd number was a prime
- divide N / found odd number was a zero remainder
- discount 1 and 2


My code was the same as thousands of other `StackOverflow` readers.  This was cynically (and probably fairly) labelled the **the Naive Trial Division Algorithm** by people who understood the _Math Theory_ behind the problem.
#### Result 1
```
✅ [3, 11] = 33       // find both prime factors but not 1 or 2
✅ [3, 13] = 39       // same as previous
🔸 [3,9] = 27         // wrong. My code should have removed 9
🔸 [5, 20] = 100      // wrong. My code should have rejected n = 100
```

#### Original code setup
I wrote a mix of C and Objective-C code.  I preferred `Objective-C` as existing Apple `Classes` helped my basic requirements:

- Know when my code completed [ `NSNotificationCenter` ]
- kill my app if it took too long [ `Run-Loop set to 20 mins ` ]
- Keep the U.I. refreshing [ `background threading` ]


I set a `kill timer` to 20 minutes.  This was my `fail-safe` for `N` values that were too large.  I ran the find factors code on a background thread, to avoid blocking the UI thread. I added an `Observer` to check whether the code to find factors of a large number finished.

On my first attempts to code this solution, I did not use third party libraries.  That was a mistake.

#### Results 2: Bugs everywhere 🐜 🐜 🐜
Status| Number (N) | Primes
--|---|--
✅| 3000009  |  3 * 1000003
✅| 101003333 |  101 * 1000033
🐜| 7919261327 |  7919 * 1000033
🐜| 17746761831 |  3 * 5915587277                              

A crazy value was returned shown when I tried to find the factors of `7919261327`.  Why?  Almost 8 billion.  I had the common sense to check the [limits of C Types](https://docs.microsoft.com/en-us/cpp/cpp/data-type-ranges?view=vs-2017).

I had the common sense to pick the `Unsigned Long Long`.  Any variable of that type could store a positive value up to `18,446,744,073,709,551,615`. That is 18 billion billion.  20 characters.

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
✅| 505371799 | 16127 * 31337 | 1 second
✅| 7919261327 | 7919 * 1000033  | 19 seconds
🐜| 10175656859 | 100033 * 101723 | This was a mistake! 100033 was not a Prime.
✅| 17746761831 | 3 * 5915587277  | 72 seconds
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
#### Result 4: Hitting the limits
I set my kill timer to 10 hours, while I slept.  My crude calculation was accurate enough.

Status| Number (N) | Primes | Time taken
--|---|--|--
🐝| 8069212743871 |  2840261 * 2841011 | 5 hours.
  |   |   |  

#### Results 6: Choosing P and Q
I assumed when 𝑝 and 𝑞 were prime, 𝑁 would have only two factors.  I wanted to verify this and test something I missed on the `Key Generation for RSA`.

> p and q should be chosen at random, and should be similar in magnitude but differ in length by a few digits to make factoring harder.

Primes here: https://primes.utm.edu/lists/small/100000.txt

Status| Number (N) | Primes found | Time taken
--|---|--|--
✅| 505371799 | 16127 * 31337 | 1 second
✅| 57564127333 | 869273 * 66221| 140 seconds
✅| 33726446021 | 341233 * 98837| 82 seconds
✅| 25125434821 | 1180873 * 21277| 62 seconds

Things looked up.

When I started this project, I didn't know this.  I picked `Primes` that were "close together".  That led me to write this code:

```
unsigned long long upper_limit = n / 2;
```  

This caused bugs with some numbers where you had widely different primes `10185829159 = 11 * 925984469`.  I could fix it.
```
unsigned long long upper_limit = n;
```  
But that hurt performance. See the following difference:

Status| Number (N) | Bits | Primes found | Time taken

✅| 112740085193 | 37 |  86771 * 1299283 | 522 seconds.
✅| 112740085193 | 37 |  86771 * 1299283 | 264 seconds.

## Summary
#### Failings of the Naive Trial Division Algorithm
In summary, on small values my initial code worked well.  Most code from `StackOverflow` was the same.  When you grew the size of `n` the `Factorization` sent your machine into warp speed and a problem that could not be solved in reasonable time.  

That said, the `Naive Trial Division Algorithm` does work if the `Public Key's Modulus (n)` is "short".  By short, my proof is `35-39 bit` numbers were solved in minutes by my code:
 For example,
```
🐝 Factorizing 85828944079
🐝 Binary 1001111111011110011011100000011001111 (37 bits)
-PP---------------------------
🐝 Factors: (
    71971,
    1192549
)
🐝 Finished in: 196.60 seconds
```
It took 5 hours to search all odd numbers when the loop's upper limit was set to 4 trillions (43 bits).  But a number that was over `100 trillion (47 bits)` I estimated **3 days** to finish.  

#### Computing Power
This code could never work against a real world RSA implementation.  The `Naive Trial Division Algorithm` had no chance of dealing with a `60 bit primes`.    Crudely illustrated as follows:
```
My computer could do 4 trillion in 5 hours
18 quintillion \ 4 trillion == 4.5 million
4.5 million * 5 hours = 2,500 years
```
**2,500 years**  to exhaust a single `60 bit` prime?




#### Miller–Rabin primality test
This already had the `primality test` code.  This was a `probabilistic primality test`.  Hence, the code had a watchdog to catch when the code could not determine an answer.
```
/*     printing of result ( reps ) in the form of                    */
/* reps = 2          if n is definitely prime                        */
/* reps = 1          if n is probably prime (without being certain)  */
/* reps = 0          if n is definitly composite. There should be it.*/
```
I also read that `Reasonable values of reps are between 15 and 50.` on `https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm`.

#### GMP References

https://stackoverflow.com/questions/4424374/determining-if-a-number-is-prime

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/gmpTutorial.html

https://gnu.huihoo.org/gmp-3.1.1/html_chapter/gmp_4.html

https://gmplib.org/manual/Binary-GCD.html#Binary-GCD

http://sep.stanford.edu/sep/claudio/Research/Prst_ExpRefl/ShtPSPI/intel/mkl/10.0.3.020/examples/gmp/source/mpz_probab_prime_p_example.c

https://machinecognitis.github.io/Math.Gmp.Native/html/52ce0428-7c09-f2b9-f517-d3d02521f365.htm

https://frenchfries.net/paul/factoring/source.html

http://www.martani.net/2011/12/factoring-integers-part-1-pollards-rho.html

#### C References
https://en.cppreference.com/w/c/types/limits

https://www.systutorials.com/docs/linux/man/3-strtol/

#### Key Length References

https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar1.pdf

#### References
https://www.cryptool.org/en/cto-highlights/rsa-step-by-step

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
