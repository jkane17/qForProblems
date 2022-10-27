### [Project Euler - Problem 2](https://projecteuler.net/problem=2)
### [Episode 2](https://community.kx.com/t5/kdb-and-q/Q-For-Problems-Episode-2/m-p/13148#M165)
<br>

# Solution 1

### Fibonacci sequence
Starting with 0 and 1, each term is found by adding the previous two terms. For example,
```
0 1 1 2 3 5 8 13 21 34 55 89 ...
```
<br>

```q
// Only want to sum the last 2 terms each time
x:0 1
show x,:sum -2#x // 0 1 1
show x,:sum -2#x // 0 1 1 2
show x,:sum -2#x // 0 1 1 2 3

// Put into a function 
f:{x,sum -2#x}

f 0 1     // 0 1 1
f f 0 1   // 0 1 1 2
f f f 0 1 // 0 1 1 2 3

// Can do this repeatedly using the 'do' control construct
x:0 1
do[10;x:f x]; x

// However, this is not good q practice
// Can instead make use of the over (/) accumulator 
10 f/ 0 1  // infix notation
f/[10;0 1] // bracket notation

// Use scan (\) to see the intermediary results
10 f\ 0 1
```
<br>


Using the bracket notation, we can create a projection which is ready to accept a single argument.
```q
// First n + 2 Fibonacci numbers
fib:{x,sum -2#x}/[;0 1]

// First 10 + 2 Fibonacci numbers
fib 10 
```
<br>

We require the Fibonacci numbers whose value do not exceed 4 million. 

The over and scan accumulators are overloaded so, their behaviour changes based on the arguments.

Providing a predicate function (function which returns a TRUE or FALSE value) instead of an integer will make over a 'while' accumulator instead of a 'do' accumulator.
```q
fibm:fib {x>last y}@ 
```
<br>

**NOTE**: The `@` creates a composition function which knows it must still receive an argument before it is executed. Otherwise, fib would try to execute with an arguement of the lambda `{x>last y}`.
<br>
<br>

The predicate function takes two arguments:
  - x : The max Fibonacci number (e.g. 50 as below).
  - y : The current list of Fibonacci numbers (output of fib at each iteration).

It compares the last item of the Fibonacci sequence thus far with the max.

The iteration will continue until the first FALSE value is produced by the predicate function.

```q
fibm 50 // 0 1 1 2 3 5 8 13 21 34 55
```

We only want the terms below the argument so, we need to drop the last term.

```q
// Fibonacci numbers below some maximum
fibm:-1_fib {x>last y}@

fibm 50 // 0 1 1 2 3 5 8 13 21 34
```
<br>


Apply the modulus with a second argument of 2 to check whether a number is even or odd.

An odd number will have a remainder of 1 and an even number will have a remainder of 0.

We can treat the 1 and 0 values as TRUE and FALSE values for checking if a number is odd.
```q
isodd:mod[;2]

x:1 2 3 4 5
isodd x // 1 0 1 0 1

// Check where the value is zero to check if a number is even
0=isodd x
// Get indices of even values
where 0=isodd x
// Index into the orginal list 
x where 0=isodd x

// Filter to return only even numbers
evens:{x where 0=isodd x}
```
<br>

```q
// Fibonacci numbers below 4 million
fibm 4000000
// Only the even values
evens fibm 4000000
// Sum the result
sum evens fibm 4000000
```
<br>

```q
s:sum evens fibm@
s 4000000 // solution

\ts:10000 s 4000000

// Full form
sf:{sum n where 0=mod[;2] n:-1_{x>last y}[x]{x,sum -2#x}/ 0 1} 
sf 4000000
```
