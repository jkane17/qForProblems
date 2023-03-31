### [Project Euler - Problem 7](https://projecteuler.net/problem=7)
### [Episode 7](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-7/td-p/13397)

<br />

# Solution 1

```q
// Prime number test
x:997
x<2            // Not prime, return FALSE
x in p:2 3 5 7 // Check the first few primes 
0 in x mod p   // Check the multiples of the first few primes (provides a speed up in most cases)
```

<br />

All primes greater than 3 have the form 

$$
	6k \pm 1
$$

where $k = 1, 2, ...$ 

<br />

```q
// Generate all numbers of the form (6k +/- 1) up to the square root
-1 1+/:(ceiling[sqrt x]>)(6+)\ 6

// Check x is not evenly divisible by any of these numbers
all x mod raze -1 1+/:(ceiling[sqrt x]>)(6+)\ 6

// Check if a number is prime
isPrime:{$[
    x<2; 0b; 
    x in p:2 3 5 7; 1b; 
    0 in x mod p; 0b; 
    all x mod raze -1 1+/:(ceiling[sqrt x]>)(6+)\ 6
 ]}

isPrime each til 20
```

<br />

Starting at $2$, we can use the `while` form of the `over` (`/`) accumulator to generate *n* prime numbers.

```q
// Starting point
1#2     
// Predicate function to check if our list of primes has enough values  
((1+n)>count@) 

// Check to see if the last item in x is prime
// TRUE : Add the next number to the list
// FALSE: Remove it from the list and add the next number 
{$[isPrime l:last x; x,:l+1; x:(-1_x),l+1]}

// Putting it together
n:10
((1+n)>count@){$[isPrime l:last x; x,:l+1; x:(-1_x),l+1]}/1#2

// Always need to get one more number than required so the second last number is correct
// Drop this extra term
-1_((1+n)>count@){$[isPrime l:last x; x,:l+1; x:(-1_x),l+1]}/1#2 

// Generate the first n prime numbers
nprimes1:{-1_((1+x)>count@){$[isPrime l:last x; x,:l+1; x:(-1_x),l+1]}/1#2}
```

<br />

```q
s1:last nprimes1@
s1 10001 // solution 1
```

<br />

# Solution 2

It is not necessary to check every number, only the odd numbers after $2$.

```q
nprimes2:{-1_((1+x)>count@){$[isPrime l:last x; x,:l+2; x:(-1_x),l+2]}/2 3}
```

<br />

```q
s2:last nprimes2@
s2 10001 // solution 2
```

<br />

# Solution 3

Instead of using the *6k* method to check if a number is prime, we can use it to generate our list of primes.

However, not all numbers with the form $6k \pm 1$ are prime, so we need to check them.

```q
// Starting point - (k;primes so far)
x:(1;2 3)
// Predicate function to check if we have reached our desired count
(n>count last@)

// 6k +/- 1
p:-1 1+6*x 0
```

<br />

We can use the primality test described [here](https://community.kx.com/t5/Community-Blogs/Finding-primes-with-q/ba-p/11120).

<br />

```q
// Check if the values are prime
.math.isPrime p
// Select only the prime values
p where .math.isPrime p
// Join on to the list of primes so far
x[1],p where .math.isPrime p

// Increment k
x[0]+:1

// Putting it together
n:10
(n>count last@){(x[0]+:1;x[1],p where .math.isPrime p:-1 1+6*x 0)}/(1;2 3)

// Select the primes list
last(n>count last@){(x[0]+:1;x[1],p where .math.isPrime p:-1 1+6*x 0)}/(1;2 3)

// Because we generate values in pairs, we may exceed the amount required by 1
// Only take the number of values we need
n#last(n>count last@){(x[0]+:1;x[1],p where .math.isPrime p:-1 1+6*x 0)}/(1;2 3)

nprimes3:{x#last(x>count last@){(x[0]+:1;x[1],n where .math.isPrime n:-1 1+6*x 0)}/(1;2 3)} 
```

<br />

```q
s3:last nprimes3@
s3 10001 // solution 3
```

<br />

# Performance test

```q
.perf.test[10;] each `s1`s2`s3 cross 10001
.perf.test[1;] each `s1`s2`s3 cross 100001 // Can take around 2 mins
```
