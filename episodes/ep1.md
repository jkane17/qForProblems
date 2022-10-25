### [Project Euler - Problem 1](https://projecteuler.net/problem=1)
### [Episode 1](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-1/m-p/13090#M150)
<br>

# Solution 1

```q
/ Integers from 0 - 999
q) til 1000

/ mod (modulus) keyword - returns the remainder of the left argument divided by the right arguement
q) til[1000] mod 3

/ Add each-right (/:) iterator to apply to both 3 and 5
q) til[1000] mod/: 3 5

```
<br>

Need to find the zeros in either list. There are two choices:
```q
/ 1. Use all - Converts to a boolean
q) all til[1000] mod/: 3 5

/ 2. Use min - Does not convert to a boolean
q) min til[1000] mod/: 3 5

/ min is faster because it does not convert to a boolean (look at their definitions) 
q) x:til[1000] mod/: 3 5
q) \ts:100000 all x
q) \ts:100000 min x
```
<br>

Intereseted in the numbers whose modulus with 3 or 5 is zero.
```q
/ Use the 'not' keyword to flip the zeros to TRUE (1b) and non-zeros to FALSE (0b)
q) not min til[1000] mod/: 3 5  

/ Can use the 'where' keyword to find the indices of the TRUE (1b) values
q) where not min til[1000] mod/: 3 5

/ Just sum the indices as these correspond to the same values in those positions
q) sum where not min til[1000] mod/: 3 5
```

```q
s1:{sum where not all til[x] mod/:y}

s1[1000;3 5] / solution 1
```
<br>

# Solution 2

### [Arithmetic Progression](https://en.wikipedia.org/wiki/Arithmetic_progression)

A sequence of numbers where the difference between the consecutive terms is constant.

```
3 6 9 12 15 ...   / Contant difference of 3
5 10 15 20 25 ... / Contant difference of 5
```
<br>

### [Arithmetic Series](https://en.wikipedia.org/wiki/Arithmetic_progression#Sum)

The sum of the members of a finite arithmetic progression.

```
3 + 6 + 9 + 12 + 15 + ... + an
5 + 10 + 15 + 20 + 25 + ... + an
```
where a<sub>n</sub> is the last term.
<br>
<br>

$$ S_n = n * (a + a_n) / 2 $$

where <br>
- n  -->  Number of terms in the sequence
- a  -->  First term in the sequence
- an -->  n-th (final) term in the sequence
<br>

```q
q) arithSeries:{[a;an;n] .5*n*a+an}
```

NOTE: Multiplying by decimal form is faster than dividing on most modern processors
```q
\ts:1000000 10%2
\ts:1000000 .5*10
```
<br>

Three inputs are required: 

1. **a**
   - Will start the sequences at 3 and 5 (allows us to take advantage of a special case detailed below).
   - Could start at 0, but it would not contribute to the sum anyways.

2. **a<sub>n</sub>**
    - Equation to calculate the n-th term of an arithmetic progression.
    - $a_n = a + d * (n - 1)$ <br>
      where d is the common difference (3 and 5 in our case).
    - `arithN:{[a;d;n] a+d*n-1}`
    - Special case because a = d
      ```
      an = a + a * (n - 1)
         = a * (1 + (n - 1))
         = a * n
      ```

3. **n** 
    - Simply divide our max term by 3 and 5 to find the number of terms.
    - ```q
      q) 999%3 5
      / Round down as n must be an integer
      q) floor 999%3 5
      ```
<br>

```q
q) a:3 5
q) n:floor 999%a
q) an:a*n
q) arithSeries[a;an;n]
```
<br>

### Consideration!
  - Summing two arithmetic progressions with overlapping values.
  - Therefore, we are double counting all the terms which are multiples of both 3 and 5, i.e., `15 30 45 60 75 ...`.
  - To cancel out the double counting, we can subtract the arithmetic series of `15 30 45 60 75 ...` from the sum of the 3 and 5 arithmetic series'.
<br>

```q
/ Join first term of common multiples sequence
q) a,prd a

q) a:3 5
q) a,:prd a
q) n:floor 999%a
q) an:a*n
q) arithSeries[a;an;n]

/ Sum the first two arithmetic series and subtract the last
q) sum 1 1 -1*arithSeries[a;an;n]
```

```q
q) s2:{sum 1 1 -1*arithSeries[y;;n] y*n:floor x%y,:prd y}
q) s2[999;3 5] / solution 2
```
<br>

# Solution 3

Can simplify the arithmetic series equation (due to the special case described previously) to improve our solution.

$$\eqalign{
a_n &= a * n \\
S_n &= 0.5 * n * (a + a_n) \\
        &= 0.5 * n * (a + a * n) \\
        &= 0.5 * n * (a * (1 + n)) \\
        &= 0.5 * n * a * (1 + n)
}$$

```q
q) s3:{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}
q) s3[999;3 5]
```
<br>

# Solution 4

Use `abs` (absolute) and `neg` (negative) keywords instead of `1 1 -1*`.

```q
q) s4:{sum .5*n*y*1+n:floor x%abs y,:neg prd y}
q) s4[999;3 5]
```
<br>

# Performance test

Arithmetic Series solutions (s2, s3, and s4) have constant time and space complexity (O(1)).

Compared with solution 1 (s1) which has time and space complexity which increases proportionaly with n (O(n)).

```q
q) .perf.test[100000;] each (
    (`s1;1000;3 5);
    (`s2;999;3 5);
    (`s3;999;3 5);
    (`s4;999;3 5)
 )

/ s1 time and memory usage grows with increasing n
q) .perf.test[10000;] each (
    (`s1;100000;3 5);
    (`s2;99999;3 5);
    (`s3;99999;3 5);
    (`s4;99999;3 5)
 )
 ```
