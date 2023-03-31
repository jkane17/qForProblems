### [Project Euler - Problem 5](https://projecteuler.net/problem=5)
### [Episode 5](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-5/m-p/13304#M198)

<br />

# Solution 1 - Brute Force

```q
// Start with numbers 10 - 2520
x:10+10*til 252
// Check if divisible by numbers 2 - 10
0=x mod/: 2+til 9
// Select only the numbers divisible by all 
x where min 0=x mod/: 2+til 9

// Since the list is generated as multiples of 10, there is no need to check the factors of 10
(3+til 8) except 5 10
n where min 0=n mod/: (3+til 8) except 5 10
```

<br />

We can not just generate the multiples of $20$ up to some number because we do not know which number to go up to.

Instead, use the `while` form of the `over` (`/`) accumulator to iterate until a suitable number is found.

```q
n:(3+til 8) except 5 10

// Starting at 10, add 10 and check if the result is divisible by everything in n
// Iteration will stop as soon as a number which is divisible by all n is found
(any mod[;n]@)(10+)/ 10

// Extending to 20
n:(3+til 17) except 4 5 10
(any mod[;n]@)(20+)/ 20

// Making it general
x:20                
n:2+til x-1         
n@:where 0<>x mod n // Remove factors of x
(any mod[;n]@)(x+)/ x
```

<br />

```q
s1:{(any mod[;n where 0<>x mod n:2+til x-1]@)(x+)/ x}
s1 20 // solution 1
```

<br />

# Solution 2

The previous solution is quite slow, but we can improve it using a simple property of factors.

If a number *A* divides *B* evenly that is because the prime factorisation of *A* is contained within the prime factorisation of *B*, e.g.,
$10$ divides $100$ because $10 = 2 * 5$ and $100 = 2 * 2 * 5 * 5$.
 
The **Least Common Multiple (LCM)** of two numbers *A* and *B* is equal to the union of the prime factorisation of both numbers.

When doing the union however, we must maintain the highest order of each factor, e.g., 
$$
    A = 5 \And B = 20 \\
    p_A = pfact[A] = 5 \\
    p_B = pfact[B] = 2, 2, 5 \\
    \space \\
    \text{Normally : } p_A \cup p_B = 2, 5 \\
    \text{Desired : }  p_A \cup p_B = 2, 2, 5
$$

i.e., the union function in q will return only the unique values (it is simply a `distinct` on the join of *A* and *B*) but, we want to keep the two $2$'s from *p<sub>B</sub>* as it is the highest order of $2$.

We can use `pfact` described in [episode 3](ep3.md) to get the prime factorisation of each number.

```q
.math.pfact each 2+til 9
// Group the factors for each number
(group .math.pfact@) each 2+til 9
// Count tells us the power each number should be raised to
(count each group .math.pfact@) each 2+til 9
```

<br />

We need to iterate over each of these dictionaries (groups) to collapse into one.

The keys are the factors and the values are the powers.

So, whilst iterating, if we encounter a factor seen before, we need to compare the current power with the potential new value. If the new value is larger, we replace the old value with it. Otherwise, we do nothing for that key.

Since we must iterate, lets change what we have thus far to use the `scan` (`\`) accumulator.
```q
{count each group .math.pfact y}\[(1#0N)!1#0;2+til 9] // Same as what we had before
```

<br />

The first arg is a dictionary with a single key-value pair which allows a valid comparison (as will be seen next). 
```q
(`a`b`c!1 20 3)>`a`b`c!10 2 30
```

Comparison with an empty list/dict always results in and empty list/dict.
```q
(`a`b`c!1 20 3)>`a`b`c!()
```

<br />


Each iteration will compare the current factors dict with the factors dict for the next number.
```q
x:`2`3!1 1  // current
n:`2`5!2 1  // next

// Identify which keys (factors) need replaced
x<n
// Return the keys of any TRUE values
where x<n
// Index back into n
k!n k:where x<n
// Join to current, overwriting any matching keys
x,k!n k:where x<n
            
// Putting it together
p:{x,k!n k:where x<n:count each group .math.pfact y}/[(1#0N)!1#0;2+til 9] 

// Take the keys to power of the values
value[p]#'key p
// Flatten and take the product of all factors
prd raze value[p]#'key p

// Least common multiple of a list of numbers
lcm:{prd raze value[p]#'key p:{x,k!n k:where x<n:count each group .math.pfact y}/[(1#0N)!1#0;x]}
```

<br />

```q
s2:lcm 2+til -1+
s2 20 // solution 2
```

<br />

# Performance test

```q
.perf.test[10;] each `s1`s2 cross 10 20
```
