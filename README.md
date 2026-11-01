# A poor man's secret stealer for RSA

#### Results 8: Speed, speed, bug
I created a branch to check if I could speed up my `factorization` code.  I was hoping to factorize `128 bit Primes`.  At the moment, I could run my computer for 4 days without an answer to a `128 bit Prime`.

My `GMP` code appeared to work.  Double checking the code - which I should have done with a `Unit Test` - it was not following the code sample that was available here: [Pollard Rho wikipedia](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm).

My original code raised x to an exponent.  This was based on the instructions [here][c83cb04d].  
```
mpz_add_ui(exp,x,1);
mpz_powm(x, x, exp, n);
mpz_sub(xTemp, x, xFixed);
mpz_gcd(gcd, xTemp, n);
```

  [c83cb04d]: https://www.youtube.com/watch?v=fFJMoIj71nQ&list=PLf3LTJuIxYkTdahPywj7RcTU0OAyRph8H&index=5&t=0s "example_video"
But if you look at the example code, it was supposed to do this [ and not raise to a power ].
```
x = (x * x + 1) % number;
factor = gcd(abs(x - x_fixed), number);
```
Double checking what should happen, the original method I used was wrong.  I went back to check the original papers. The summary to confirm the truth was [richard_brent_article][b67750ba].
Re-writing this code in `GMP`:
```
mpz_mul ( x,x,x );
mpz_add_ui ( x,x,1U );
mpz_mod ( x, x, n );
mpz_sub ( xTemp, x, xFixed );
mpz_abs ( xTemp, xTemp );
mpz_gcd ( gcd, xTemp, n );
```
That change sped up small factorization attempts.  But it also killed my code, when it previously worked.

  [b67750ba]: https://maths-people.anu.edu.au/~brent/pd/rpb051i.pdf "example_video"

Status| Number (N) | Time taken
--|---|--
❌| 1642061677267048469007620094567254201801  | Did not complete. 42 seconds with old code, to find the primes.


#### Results 9: The Tortoise and The Hare
I could see other [sample code](https://asecuritysite.com/encryption/pollard) for Pollard's Rho Algorithm had two numbers - the Tortoise and the Hare - who started at the same point and should eventually met.  

But this was even worse:

Status| Number (N) | Time taken
--|---|--
❌| 1034776851837418228051242693253376923 | 9 minutes, 37 seconds compared to 6 minutes with previous code.
❌| 1157170973102575683016736411062049761643292045397 | Did not finished.

#### Results 10: Learn from other people
Other [C code](https://github.com/grouville/factrace) and [Javascript code](https://github.com/henrikfredriksson/pollard-rho) looked like my own.

Then I found [code](https://github.com/dbrazel/integer-factorization) that looked markedly different as it introduced a redundancy check Richard Brent's [method](https://maths-people.anu.edu.au/~brent/pd/rpb051i.pdf).  This one looked interesting.  It was still slower than my original code but I wanted to try it.


```


<!-- TOC -->

- [A poor man's secret stealer for RSA](#a-poor-mans-secret-stealer-for-rsa)
	- [Challenge](#challenge)
	- [Setup](#setup)
	- [Background](#background)
	- [History of repo](#history-of-repo)
	- [Challenge](#challenge-1)
	- [Structure of code](#structure-of-code)
	- [Goal 1: Read and factorize N](#goal-1-read-and-factorize-n)
	- [Design steps](#design-steps)
		- [Assumptions about the number N](#assumptions-about-the-number-n)
		- [Brainstorm](#brainstorm)
		- [Result 1](#result-1)
		- [Original code setup](#original-code-setup)
		- [Results 2: Bugs everywhere 🐜 🐜 🐜](#results-2-bugs-everywhere---)
		- [Results 3: harder bugs 🐜](#results-3-harder-bugs-)
		- [Result 4: Hitting the limits](#result-4-hitting-the-limits)
		- [Results 6: Choosing P and Q](#results-6-choosing-p-and-q)
	- [Summary](#summary)
		- [Failings of the Naive Trial Division Algorithm](#failings-of-the-naive-trial-division-algorithm)
		- [Computing Power](#computing-power)
	- [Re-Design](#re-design)
		- [Results 6: Pollard Rho](#results-6-pollard-rho)
		- [Results 7: Pollard Rho](#results-7-pollard-rho)
		- [Euler's totient function](#eulers-totient-function)
		- [Greatest Common Denominator (GCD) / Modular multiplicative inverse](#greatest-common-denominator-gcd--modular-multiplicative-inverse)
			- [Miller–Rabin primality test](#millerrabin-primality-test)
	- [Answers](#answers)
		- [Challenge 1A: 60 bit Primes](#challenge-1a-60-bit-primes)
		- [Challenge 1B: 60 bit Primes](#challenge-1b-60-bit-primes)
		- [Challenge 1C: 60 bit Primes](#challenge-1c-60-bit-primes)
		- [Challenge 2: 80 bit Primes](#challenge-2-80-bit-primes)
		- [Challenge 3: 128 bit Primes](#challenge-3-128-bit-primes)
		- [GMP References](#gmp-references)
		- [C References](#c-references)
		- [Key Length References](#key-length-references)
		- [References](#references)

<!-- /TOC -->

### Challenge

  > Can you derive a Private Key from it's corresponding [ short ] Public Key, with RSA?

"__Yes, with caveats"__."  The major caveat being RSA is based on the assumption that factoring "large" integers is ___computationally intractable___.  This assumption may die in future with Quantum computers.  See reference to [Shor's algorithm](https://en.wikipedia.org/wiki/Shor%27s_algorithm).

### Setup
`git clone` the repo.  Open XCode and the `Project File`.  Run the program. This will reveal the Secret Message.  

A pre-filled example is already in the project. See below. This is a `60-bit Public Key` and encrypted message.  In just over `6 minutes` - on an old `macOS` machine - you derive the `Private Key` and decrypt the Secret Message.

```
<plist version="1.0">
<dict>
	<key>Ciphertext</key>
	<string>582984697800119976959378162843817868</string>
	<key>Exponent</key>
	<string>65537</string>
	<key>Modulus</key>
	<string>1034776851837418228051242693253376923</string>
</dict>
</plist>
```
When you are ready to try it with your own values, populate the project's `plist` file and re-run the app.  

### Background
The code in this repository builds into a `macOS` command line application.

The application takes a short `Public Key` ( `< 200 bits` ) and a Secret Message.  The Secret Message was generated by encrypting a short piece of `plaintext` with an `RSA Public Key`.  Then, the program attempts to derive the two `Prime Numbers` that were factors of the `Modulus`.  

These primes can be extremely long.  This step can take seconds, minutes, days or forever.  

Keep the `Primes` that combine to make the `Modulus` less than `< 200 bits`. Then you won't have to wait days for an answer.  

What length of numbers can I use?  The following example will reveal the `Private Key` in < 10 minutes.

```
-----------------------------------------------------------------------------
🐝 Modulus:1034776851837418228051242693253376923 (120 bits)
🐝 P:952809000096560291 (60 bits)
🐝 Q:1086027579223696553 (60 bits)
-----------------------------------------------------------------------------
```

If the program can successfully derive these `Primes` ( referred to as `P` and `Q` ) it will continue.  It eventually derives the `Private Key`.  The `Private Key` is the piece of the puzzle required to decrypt the Secret Message.

### History of repo
The program was written to answer the questions from **Prof Bill Buchanan OBE**.

`https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7`

Below was a challenge from the article:
```
Encryption Parameters of a RSA Public key
e: (Exponent)                     65537
𝑁: (Modulus)                     1034776851837418228051242693253376923
𝑝:                                 < unknown Prime Number >
𝑞:                                 < unknown Prime Number >
Length of Modulus:                60 bits
Encrypted secret:                 582984697800119976959378162843817868
```

This repo would never work against a real RSA implementation [ unless the person who implemented the keys used crazily short keys ].  But there are cash prizes available for people who can factorize larger numbers: https://en.wikipedia.org/wiki/RSA_Factoring_Challenge.

The challenge used tiny numbers compared to real-world `RSA` implementations.  This challenge used `60 - 120 bit Primes`.  Where standards organizations (`NIST` et al ) disallowed anything less than `2048 bit number (Modulus) and 1,024 bit prime numbers`.  

> The cost of `Factorizing` limits the program.  This is how `RSA` resists against engineers who attempt to brute force a `Private Key` from it's counterpart `Public Key`.

How hard is `factoring` for a computer?  A great video on this [topic](https://www.youtube.com/watch?v=tq8dTl74bL0).

That isn't to say somebody hasn't attempted the same thing on a large scale with lots of hardware and optimized code.  Even `2048 bit` Public Keys will be end-of-life within [ten years](https://en.wikipedia.org/wiki/Key_size):

> RSA claimed that 1024-bit keys were likely to become crackable some time between 2006 and 2010 and that 2048-bit keys are sufficient until 2030.[15] NIST recommends 2048-bit keys for RSA.

## Structure of code
The first piece of code calculates `factors` of N.  The `factors` must only be `Prime Numbers`.  The found numbers were referred to as `𝑝` and `𝑞` and were to be kept secret.  `𝑁` was not a secret and it was part of the `Public Key`.

After `factorizing` other steps were required:

Step to find Private Key | Expressed as
--|--
`Factorization` | 𝑝,𝑞 primes, 𝑛=𝑝𝑞
`Euler's Totient function (PHI)` |𝑑 relatively prime to 𝜑(𝑛)=(𝑝−1)(𝑞−1)
`Extended Euclidean algorithm (GCD)` | 𝑒 was 𝑒𝑑(mod𝜑(𝑛))=1  or ed =1(mod𝜑(𝑛))

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

## Re-Design
I searched for more efficient ways to `Factorize` a large number.  The following article changed my approach:

https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/pollardsRho.html

You could use the `Birthday Paradox` to give you an efficient, *probabilistic* method to achieve the same.  **probabilistic**, huh?  The code could fail.  But it could work the next time you ran the code.

Step forward the `C library` called `GMP` .  I also considered `openSSL` but - after some later trial and error - I realized `gmp` could achieve everything I wanted.

#### Results 6: Pollard's Rho Algorithm
Even with no optimization and memory bugs, Pollard's Rho Algorithm unlocked massive improvements:

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

```
ϕ(𝑛)=(𝑝−1)(𝑞−1)
ϕ(𝑛)=(7919−1)(1000033−1)
ϕ(𝑛)=(7918)(1000032)
ϕ(𝑛)=7918253376
```
### Greatest Common Denominator (GCD) / Modular multiplicative inverse
So you need ` Exponent ` for this step.  

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


## Answers
#### Challenge 1A: 60 bit Primes
```
🐝 Started	15:53:25
🐝 n:1034776851837418228051242693253376923 (120 bits)
🐝 Exponent:65537
🐝 Ciphertext:582984697800119976959378162843817868
-----------------------------------------------------------------------------
🐝 P:952809000096560291 (60 bits)
🐝 Q:1086027579223696553 (60 bits)
🐝 Finished at loop: 28 k values: 268435456
🐝 PHI:1034776851837418226012406113933120080
🐝 Decryption Key:568411228254986589811047501435713
-----------------------------------------------------------------------------
🐝 Plaintext:345
🐝 6 minutes, 16 seconds
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
```
#### Challenge 1B: 60 bit Primes
```
🐝 Started	06:48:55
🐝 n:       498702132445864856509611776937010471 (119 bits)
🐝 Exponent: 65537
🐝 Ciphertext: 96708304500902540927682601709667939
-----------------------------------------------------------------------------
🐝 P:640224252335299439 (60 bits)
🐝 Q:778949142627423689 (60 bits)
🐝 Finished at loop: 31 k values: -2147483648       // notice the bug here?
🐝 PHI:498702132445864855090438381974287344
🐝 Decryption Key:385107896622560911412972764596132081
-----------------------------------------------------------------------------
🐝 Plaintext:638
🐝 1 hour, 0 minutes, 27 seconds
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
```
#### Challenge 1C: 60 bit Primes
```
🐝 Started   	20:44:11
🐝 Kill timer	12 hours, 0 minutes, 0 seconds
---------------------------------------------------------------------------
🐝 n:911844725340031776516886332975892441 (120 bits)
🐝 Exponent:65537
🐝 Ciphertext:801127314512167104045686292190207406
---------------------------------------------------------------------------
🐝 P:878638229491672919 (60 bits)
🐝 Q:1037793137987599439 (60 bits)
🐝 Finished at loop: 34 k values: 17179869184
---------------------------------------------------------------------------
🐝 PHI:911844725340031774600454965496620084
🐝 Decryption Key:778860122981058618953550948525799101
🐝 Plaintext:1497
🐝 10 hours, 47 minutes, 37 seconds
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
```
#### Challenge 2: 80 bit Primes
```
🐝 Started	    18:18:11
🐝 Kill timer   8 hours, 0 minutes, 0 seconds
🐝 n:1157170973102575683016736411062049761643292045397 (160 bits)
🐝 Exponent:65537
🐝 Ciphertext:398616441584847118291875619819339172891325623639
-----------------------------------------------------------------------------
🐝 P:1133129089862698274158927 (80 bits)
🐝 Q:1021217250051175170083611 (80 bits)
🐝 Finished at loop: 32 k values: 0
🐝 PHI:1157170973102575683016734256715709847769847802860
🐝 Decryption Key:383045716015186488050491065584183124609290602793
-----------------------------------------------------------------------------
🐝 Plaintext:427
🐝 4 hours, 40 minutes, 12 seconds
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
```
#### Challenge 3: 128 bit Primes
```
🐝 Started   	07:50:38
🐝 Kill timer	24 hours, 0 minutes, 0 seconds
-----------------------------------------------------------------------------
🐝 n:49141939931137261116843775362783398673931258031923895283286320973486872970729 (255 bits)
🐝 Exponent:65537
🐝 Ciphertext:14199123787046830048066972290052136769415356824981695836360604590953658335413
🐝 < NOT SOLVED, WITHIN TWO DAYS >
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
```

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
