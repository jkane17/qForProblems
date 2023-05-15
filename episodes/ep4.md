### [Project Euler - Problem 4](https://projecteuler.net/problem=4)
### [Episode 4](https://www.youtube.com/watch?v=Zjnic9sUrQI&list=PLsQYtymvFUhhft5F6IWzwEZ60dpB6MLMt&index=5)

<br />

# Solution 1

<br />

```q
n:100+til 900                // 3 digit numbers
m:n*/:n                      // Outer product - n x n matrix produced
p:distinct raze m            // Flatten to single list and get unique values
pr:"J"$reverse each string p // Reversed form of each number
i:where p=pr                 // Index of numbers that are palindromes
max p i                      // Index back into the numbers and find the largest

// As one line
max p where p="J"$reverse each string p:distinct raze n*/:n:100+til 900 
```

```q
// Returns only the numbers which are palindromes
palindromes:{x where x="J"$reverse each string x}

s1:{[] max palindromes distinct raze n*/:n:100+til 900} 
s1[] // solution 1
```

<br />

# Solution 2 - General solution

First, we can create a `range` function to generate a list of integers between some bounds.

```q
l:1 // Lower bound
u:9 // Upper bound
s:2 // Step

1+(u-l) div s       // Number of values we need
til 1+(u-l) div s   // Unscaled range
s*til 1+(u-l) div s // Scaled by the step

// List of integers from l to u with step s
// sf - scaling function to allow different range variations
range0:{[l;u;s;sf] sf s*til 1+(u-l) div s}

// Scaled by lower bound
l:4; u:9; s:1; sf:l+
range0[l;u;s;sf]

// List of consecutive integers from x to y inclusive
range:{range0[x;y;1;x+]}

range[4;9]

// Scaled by upper bound (descreasing)
l:4; u:9; s:1; sf:u+neg@
range0[l;u;s;sf]

// Reversed version of range
rrange:{range0[x;y;1;y+neg@]}

rrange[4;9]
```

<br />

```q
// NOTE: the :: at the end is similar to using @ to create a composition function, but :: allows multiple args
s2:max palindromes distinct raze{x*/:x}range:: 
s2[100;999] // solution 2
```

<br />

```q
s2[1;9]           // 1 digit numbers
s2[10;99]         // 2 digit numbers
s2[100;999]       // 3 digit numbers
s2[1000;9999]     // 4 digit numbers
//s2[10000;99999] // 5 digit numbers - Very high time and memory usage 
```

<br />

# Solution 3

The memory issue seen when applying `s2` to $5$ digit numbers is because of the large matrix created when doing the outer product with so many numbers.

```q
prd 2#count 10000+til 99999 // 9,999,800,001 elements
```
<br />

Can use an iterative approach rather than vector approach to avoid this.

```q
x:100 
y:999 
r:range[x;y]

// Check one number at a time 
// e.g. (100*100; 100*101; 100*102; ...) and then reduce this to only the palindromes
palindromes r*r 0 // None found
// Then move on to the second number
palindromes r*r 1 // 10201 11211 12221 13231 ...

// Use each to do this for all
(palindromes r*) each r:range[x;y]

// Raze to get a flat list
raze(palindromes r*) each r:range[x;y]

// Find the max
max raze(palindromes r*)each r:range[x;y]
```

<br />

```q
s3:{max raze(palindromes r*)each r:range[x;y]} 
s3[100;999] // solution 3
```

<br />

# Solution 4

`s3` may solve the memory issue, but it is still very slow.

Can replace `each` with `peach` to use secondary KDB+ threads to execute in parallel.

Set `-s` on the command line to specify how many secondary KDB+ process you wish to start up along with the main process, e.g., to start q with $8$ secondary processes run: `q -s 8`.

If not set, `-s` defaults to $0$ (no secondary process), in which case `peach` will behave exactly like `each`.

Using `peach` produces the same output as `each` but the work is now distributed amongst multiple cores.

The values in *r* are divided up into as many subsets as there are secondary process.

Each secondary process then executes: `(palindromes r*)each subset_of_r`.

The resuts are returned to the main kdb process.

Once all secondary process are finished and have returned the main process combines the results.

```q
(palindromes r*) peach r
```

<br />

```q
s4:{max raze(palindromes r*)peach r:range[x;y]} 
s4[100;999] // solution 4
```

<br />

# Performance test

```q
// All 3 digit numbers
.perf.test[100;] each (
    (`s1;());
    (`s2;100 999);
    (`s3;100 999);
    (`s4;100 999)
 )

// Differnet number of digits 
.perf.test[10;] each `s2`s3`s4 cross (1 9;10 99;100 999;1000 9999)

// Note: Run using secondary threads
.perf.test[1;(`s4;10000 99999)]
```
