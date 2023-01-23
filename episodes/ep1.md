### [Project Euler - Problem 1](https://projecteuler.net/problem=1)
### [Episode 1](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-1/m-p/13090#M150)

<br />

# Solution 1

```q
// Integers from 0 - 999
til 1000

// mod (modulus) keyword - returns the remainder of the left argument divided by the right arguement
til[1000] mod 3

// Add each-right (/:) iterator to apply to both 3 and 5
til[1000] mod/: 3 5

```
<br />

Need to find the zeros in either list. There are two choices:
```q
// 1. Use all - Converts to a boolean
all til[1000] mod/: 3 5

// 2. Use min - Does not convert to a boolean
min til[1000] mod/: 3 5

// min is faster because it does not convert to a boolean (look at their definitions) 
x:til[1000] mod/: 3 5
\ts:100000 all x
\ts:100000 min x
```
<br />

Intereseted in the numbers whose modulus with 3 or 5 is zero.
```q
// Use the 'not' keyword to flip the zeros to TRUE (1b) and non-zeros to FALSE (0b)
not min til[1000] mod/: 3 5  

// Can use the 'where' keyword to find the indices of the TRUE (1b) values
where not min til[1000] mod/: 3 5

// Just sum the indices as these correspond to the same values in those positions
sum where not min til[1000] mod/: 3 5
```

<br />

```q
s1:{sum where not all til[x] mod/:y}

s1[1000;3 5] // solution 1
```

<br />

# Solution 2

### [Arithmetic Progression](https://en.wikipedia.org/wiki/Arithmetic_progression)

A sequence of numbers where the difference between the consecutive terms is constant.

```
3 6 9 12 15 ...   // Constant difference of 3
5 10 15 20 25 ... // Constant difference of 5
```

<br />

### [Arithmetic Series](https://en.wikipedia.org/wiki/Arithmetic_progression#Sum)

The sum of the members of a finite arithmetic progression.

```
3 + 6 + 9 + 12 + 15 + ... + an
5 + 10 + 15 + 20 + 25 + ... + an
```

where <var>a<sub>n</sub></var> is the last term.

<br />

$$
S_n = n * (a + a_n) / 2
$$

where 
- <var>n</var>  -->  Number of terms in the sequence
- <var>a</var>  -->  First term in the sequence
- <var>a<sub>n</sub></var> -->  n-th (final) term in the sequence

<br/>

```q
arithSeries:{[a;an;n] .5*n*a+an}
```

NOTE: Multiplying by decimal form is faster than dividing on most modern processors.

```q
\ts:1000000 10%2
\ts:1000000 .5*10
```

<br />

Three inputs are required: 

1. <var>a</var>
   - Will start the sequences at 3 and 5 (allows us to take advantage of a special case detailed below).
   - Could start at 0, but it would not contribute to the sum anyways.

2. <var>a<sub>n</sub></var>
    - Equation to calculate the n-th term of an arithmetic progression.
    - $a_n = a + d * (n - 1)$ <br />
      where d is the common difference (3 and 5 in our case).
    - `arithN:{[a;d;n] a+d*n-1}`
    - Special case because $a = d$
      $$
      \begin{align*}
        a_n &= a + a * (n - 1) \\
          &= a * (1 + (n - 1)) \\
          &= a * n
      \end{align*}
      $$

1. <var>n</var> 
    - Simply divide our max term by *3* and *5* to find the number of terms.
    - ```q
      999%3 5
      // Round down as n must be an integer
      floor 999%3 5
      ```

<br />

```q
a:3 5
n:floor 999%a
an:a*n
arithSeries[a;an;n]
```
<br>

### Consideration!
  - Summing two arithmetic progressions with overlapping values.
  - Therefore, we are double counting all the terms which are multiples of both *3* and *5*, i.e., `15 30 45 60 75 ...`.
  - To cancel out the double counting, we can subtract the arithmetic series of `15 30 45 60 75 ...` from the sum of the *3* and *5* arithmetic series'.
  
<br />

```q
// Join first term of common multiples sequence
a,prd a

a:3 5
a,:prd a
n:floor 999%a
an:a*n
arithSeries[a;an;n]

// Sum the first two arithmetic series and subtract the last
sum 1 1 -1*arithSeries[a;an;n]
```

```q
s2:{sum 1 1 -1*arithSeries[y;;n] y*n:floor x%y,:prd y}
s2[999;3 5] // solution 2
```
<br>

# Solution 3

Can simplify the arithmetic series equation (due to the special case described previously) to improve our solution.

$$
\begin{align*}
  a_n &= a * n \\
  S_n &= 0.5 * n * (a + a_n) \\
        &= 0.5 * n * (a + a * n) \\
        &= 0.5 * n * (a * (1 + n)) \\
        &= 0.5 * n * a * (1 + n)
\end{align*}
$$

```q
s3:{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}
s3[999;3 5] // solution 3
```

<br />

# Solution 4

Use `abs` (absolute) and `neg` (negative) keywords instead of `1 1 -1*`.

```q
s4:{sum .5*n*y*1+n:floor x%abs y,:neg prd y}
s4[999;3 5]
```

<br />

# Performance test

Arithmetic Series solutions (s2, s3, and s4) have constant time and space complexity ( <var>O(1)</var> ).

Compared with [solution 1](#solution-1) (s1) which has time and space complexity which increases proportionaly with n ( <var>O(n)</var> ).

```q
.perf.test[100000;] each (
    (`s1;1000;3 5);
    (`s2;999;3 5);
    (`s3;999;3 5);
    (`s4;999;3 5)
 )

// s1 time and memory usage grows with increasing n
.perf.test[10000;] each (
    (`s1;100000;3 5);
    (`s2;99999;3 5);
    (`s3;99999;3 5);
    (`s4;99999;3 5)
 )
 ```
