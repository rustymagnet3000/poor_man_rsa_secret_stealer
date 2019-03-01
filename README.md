# RSA Key Finder
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
I might see if I can add an observer on the minute of system time.
```
##### Test Vectors
```
Primes : [3, 11] = 33
Primes : [13, 29] = 377
```
##### References

https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/

http://abulewis.com/blog/concurrency-in-objective-c-using-grand-central-dispatch-gcd/

https://medium.com/ios-os-x-development/broadcasting-with-nsnotification-center-8bc0ccd2f5c3

https://www.cs.swarthmore.edu/~newhall/unixhelp/C_arrays.html
