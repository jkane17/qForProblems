
// Intro - This could be its own video

/ Working title - Q for Problems

/
    Hello 
    Who I am
    What these videos are 
        about
        trying to achieve
        aimed at
        etc
    Structure
\


// Problem intro

/ https://projecteuler.net/problem=1

/ Show a screenshot 
/ Read out the problem
/ The answer will be revealed so give it a go yourself first

\l lib/lib.q

// Solution 1

til 1000
/ Below 1000
last til 1000

/ mod (modulus) keyword - returns the remainder of the left argument divided by
/ the right arguement
14 15 mod 3
/ right and left are not same length so need each right (or left)
til[1000] mod 3
til[1000] mod 3 5 / error
til[1000] mod/: 3 5

/ Find the zeros in either list
/ Two choices:
/ Use all
all til[1000] mod/: 3 5 / Converts to a boolean
/ Use min
min til[1000] mod/: 3 5 / Does not convert to a boolean

x:til[1000] mod/: 3 5
/ min faster because it does not convert to a boolean 
/ Look at definitions of all and min
.perf.timeit[1000000;] each ("all x";"min x")
/ not will convert to a boolean, but only need to traverse one list
/ conversion to boolean in all needs to traverse two lists
.perf.timeit[1000000;] each ("not all x";"not min x")

/ Difference is more significant for large data sets
x:til[10000000] mod/: 3 5
.perf.timeit[100;] each ("all x";"min x")

/ Intereseted in the zeros
not all til[1000] mod/: 3 5
where not all til[1000] mod/: 3 5
sum where not all til[1000] mod/: 3 5

s1:{sum where not all til[x] mod/:y}
s1[1000;3 5]

/ General solution in right argument
/ Other solutions will only allow two items in right argument (but could be made to be general)
s1[100;5 8 9]


// Solution 2 - Arithmetic progression

/ https://en.wikipedia.org/wiki/Arithmetic_progression

/ A sequence of numbers where the difference between the consecutive terms is constant

/ 3 6 9 12 15 ...
/ 5 10 15 20 25 ...

/ 
    Arithmetic Series - Sum of the members of a finite arithmetic progression

    3 + 6 + 9 + 12 + 15 + ... + an
    5 + 10 + 15 + 20 + 25 + ... + an

    Sn = n * (a + an) / 2
\

/ Constant time complexity O(1) 
/ rather than generating list and summing which is O(n) time complexity
/ a : first term, an : nth term, n : number of terms
.math.arithSeries:{[a;an;n] .5*n*a+an}

/ Multiplying by decimal form is faster than dividing
/ Multiplication is faster on most modern processors
.perf.timeit[1000000;] each ("10%2";".5*10")

/ To calculate the arithmetic series we require the 3 inputs: a, an, and n

/ a
/ We will start our sequences at 3 and 5 
/ could start at 0, but it would not contribute to the sum anyways

/ an
/ Equation to calculate the n-th term of an arithmetic progression
/ an = a + (n - 1) * d 
/ a : first term, n : number of terms, d : common difference
.math.arithN:{[a;d;n] a+d*n-1}

/ We have a special case because a = d
/ 
    an = a + a * (n - 1)
       = a * (1 + (n - 1))
       = a * n
\

/ n 
1000%3 5 / We do not want to include 1000
999%3 5
/ Round down
floor 999%3 5

a:3 5
n:floor 999%a
an:a*n
.math.arithSeries[a;an;n]

/ Consideration!
/ We are summing two arithmetic progressions with overlapping values
/ 3 6 9 12 15 ...
/ 5 10 15 20 25 ...
/ We would be double counting all the terms which are multiples of both 3 and 15
/ 15 30 45 60 75 ...
/ We just need to calculate the arithmetic series of this and subtract from the sum
/ of the 3 and 5 arithmetic series to cancel out the double counting

/ Restriction on the solutions to these problems:
/ input can only be what we are given, we must calculate everything else

/ Join first term of common multiples sequence
a,prd a

a:3 5
a,:prd a
n:floor 999%a
an:a*n
.math.arithSeries[a;an;n]

/ We need to sum the first two arithmetic series and subtract the last
sum 1 1 -1*.math.arithSeries[a;an;n]

s2:{sum 1 1 -1*.math.arithSeries[y;;n] y*n:floor x%y,:prd y}
s2[999;3 5]


// Solution 3

/ Similarly to what we did in for n-th term equation, 
/ we can simplify the arithmetic series equation to improve our solution

/ 
    an = a * n

    Sn = 0.5 * n * (a + an)
       = 0.5 * n * (a + a * n)
       = 0.5 * n * (a * (1 + n)) 
       = 0.5 * n * a * (1 + n)
\

s3:{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}
s3[999;3 5]


// Solution 4

/ and use abs and neg instead of 1 1 -1*
a,neg prd a
/ 0.5 * n * a * (1 + n)
/ If a is negative then it will produce the negative form of the result
/ since we are multiplying by a negative 
/ we could not do this if 'a' was being added to something

s4:{sum .5*n*y*1+n:floor x%abs y,:neg prd y}
s4[999;3 5]


// Code Golf - s1 is the shortest
{sum where not all til[x]mod/:y}
{sum 1 1 -1*{.5*y*x+z}[y;n] y*n:floor x%y,:prd y} / replaced function name with lambda for fairness
{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}
{sum .5*n*y*1+n:floor x%abs y,:neg prd y}


// Performance

x:(
    (`s1;1000;3 5);
    (`s2;999;3 5);
    (`s3;999;3 5);
    (`s4;999;3 5)
 )

/ s4 is the fastest
.perf.timeit[100000] each x

/ s3 and s4 use least memory
.perf.memUse each x

/ s1 memory usage grows 
.perf.memUse each (
    (`s1;1000000;3 5);
    (`s2;99999;3 5);
    (`s3;99999;3 5);
    (`s4;99999;3 5)
 )

