### [Project Euler - Problem 6](https://projecteuler.net/problem=6)
### [Episode 6](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-6/td-p/13351)

<br />

# Solution 1

```q
show n:1+til 10 // Numbers 1 - 10
n*n             // Squares
sum n*n         // Sum of squares
s*s:sum n       // Square of sum
```

<br />

```q    
s1:{(s*s:sum n)-sum n*n:1+til x} 
s1 100 // solution 1
```

<br />

Performance is ok for $100$, but it quicky degrades if we increase the input.
```q
.perf.test[10000;] each `s1 cross 100 1000 10000 100000
```

<br />

# Solution 2

It is possible to obtain a constant time solution using some arithmetic.

$$
    1 + 2 + 3 + ...
$$

This is an arithmetic progression with $a = d = 1$ (see [episode 1](ep1.md) notes for details on arithmetic progressions). Therefore, the sum of first *n* natural numbers is

$$    
    S_n = n * ( n + 1 ) / 2
$$

<br />

```q
// Sum of the first x positive integers
nsum:{"j"$.5*x*x+1}

// Works on multiple values
nsum 10 100 
```

<br />

The sum of the first *n* squares can also be expressed in terms of *n*.

Let *k* be some positive integer value such that 

$$
    1 <= k <= n
$$

Starting with 

$$
    (k - 1)^3
$$

<br />

$$
    ( k - 1 )^3 = ( k - 1 )( k^2 - 2k + 1 )
$$

$$
    => ( k - 1 )^3 = k^3 - 3k^2 + 3k - 1
$$

$$
    => k^3 - ( k - 1 )^3 = 3k^2 - 3k + 1
$$

<br />

Take the sum from $k = 1$ to *n*:

$$
    \sum_{k=1}^n ( k^3 - ( k - 1 )^3 ) = \sum_{k=1}^n 3k^2 - \sum_{k=1}^n 3k + \sum_{k=1}^n 1
$$

<br />

Left hand side (LHS): 

$$
    LHS = \sum_{k=1}^n ( k^3 - ( k - 1 )^3 ) 
$$

This is know as a **telescoping series** and can be rewritten.
 
Letting 

$$
    t[k] = k^3 \text{ and } u[k] = t[k] - t[k - 1],
$$

<br />

$$
\begin{align*}
    LHS &= u[1] + u[2] + ... + u[n] \\
        &= ( t[1] - t[0] ) + ( t[2] - t[1] ) + ( t[3] - t[2] ) + ... + ( t[n - 1] - t[n - 2] ) + ( t[n] - t[n - 1] ) \\
        &= t[0] + t[n] \text{ (All other terms cancel) } \\
        &= 0^3 + n^3 \\
        &= n^3
\end{align*}
$$

<br />
                
Right hand side (RHS): 

$$
    RHS = \sum_{k=1}^n 3k^2 - \sum_{k=1}^n 3k + \sum_{k=1}^n 1
$$

<br />

$$
\begin{align*}
    RHS &= 3 * \sum_{k=1}^n k^2 - 3 * \sum_{k=1}^n k + n \\
        &= 3 * \sum_{k=1}^n k^2 - 3 * S_n + n \\
        &= 3 * \sum_{k=1}^n k^2 - ( 3n * ( n + 1 ) / 2 ) + n 
\end{align*}
$$

<br />

Combining the LHS and RHS:

$$
    n^3 = 3 * \sum_{k=1}^n k^2 - ( 3n * ( n + 1 ) / 2 ) + n
$$

$$
    => 3 * \sum_{k=1}^n k^2 = n^3 + ( 3n * ( n + 1 ) / 2 ) - n
$$

$$
\begin{align*}
    => \sum_{k=1}^n k^2 &= ( n^3 / 3 ) + ( n * ( n + 1 ) / 2 ) - ( n / 3 ) \\
                        &= ( n^3 / 3 ) + ( n^2 / 2 ) + ( n / 2 ) - ( n / 3 ) \\
                        &= ( 2n^3 + 3n^2 + n ) / 6 \\
                        &= n * ( 2n^2 + 3n + 1 ) / 6 \\
                        &= n * ( 2n + 1 )( n + 1 ) / 6
\end{align*}
$$

<br />

Therefore, the sum of the first *n* squares is given by

$$
    S_{n^2} = n * ( 2n + 1 )( n + 1 ) / 6
$$

<br />

```q
// Sum of the squares of the first x positive integers
n2sum:{div[x*(1+2*x)*x+1;6]} 

// Works on multiple values
n2sum 10 100 
```

<br />

```q
s2:{(prd 2#nsum x)-n2sum x} 
s2 100 // solution 2
```

<br />

# Performance test

```q
// s2 has constant time and space complexity
.perf.test[10000;] each `s1`s2 cross 100 1000 10000 100000
```
