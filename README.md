# RSA Key Finder

##### Challenge
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
code to get factors:
Factors
```
-------
1,034,776,851,837,418,228,051,242,693,253,376,923 = 1,086,027,579,223,696,553 x 952,809,000,096,560,291
```
##### Goal
After receiving a positive, large integer (N) the program attempts to:
```
-> verify that N is not EVEN number
-> get all primes as a Set (?) which are less than N
-> remove 1 from the Set
-> Divide N by each set item looking for 0 quotient / 0 modulo
-> if result found, add both the Set[i] value and N/set[i] value to answer
```
##### Watchdog
```
An observer to check whether the app has finished or gone beyond a reasonable time.
```
##### Test Vectors
```
Non-Prime Pair: [3,9] = 27
Primes : [3, 11] = 33
Primes : [13, 29] = 377
Primes : [467, 601] = 280667
Primes : [3461, 3319] = 11487059
Primes : [45095080578985454453, 36413321723440003717] = 1642061677267048469007620094567254201801

```
##### References
https://www.cs.colorado.edu/~srirams/courses/csci2824-spr14/gmpTutorial.html

https://medium.com/asecuritysite-when-bob-met-alice/cracking-rsa-a-challenge-generator-2b64c4edb3e7

https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/

http://abulewis.com/blog/concurrency-in-objective-c-using-grand-central-dispatch-gcd/

https://medium.com/ios-os-x-development/broadcasting-with-nsnotification-center-8bc0ccd2f5c3

https://www.cs.swarthmore.edu/~newhall/unixhelp/C_arrays.html

https://primes.utm.edu/lists/small/small.html
