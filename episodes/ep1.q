/ https://projecteuler.net/problem=1

\l lib/lib.q


// Solution 1

/ Integers from 0 - 999
til 1000

/ mod (modulus) keyword - returns the remainder of the left argument divided by the right arguement
til[1000] mod 3
/ Add each-right (/:) iterator to apply to both 3 and 5
til[1000] mod/: 3 5

/ Find the zeros in either list
/ Two choices:
/ 1. Use all - Converts to a boolean
all til[1000] mod/: 3 5
/ 2. Use min - Does not convert to a boolean
min til[1000] mod/: 3 5

x:til[1000] mod/: 3 5
/ min is faster because it does not convert to a boolean (look at their definitions) 
\ts:100000 all x
\ts:100000 min x

/ Intereseted in the numbers whose modulus with 3 or 5 is zero
/ Use the 'not' keyword to flip the zeros to TRUE (1b) and non-zeros to FALSE (0b)
not min til[1000] mod/: 3 5  
/ Can use the 'where' keyword to find the indices of the TRUE (1b) values
where not min til[1000] mod/: 3 5
/ Just sum the indices as these correspond to the same values in those positions
sum where not min til[1000] mod/: 3 5

s1:{sum where not all til[x] mod/:y}
s1[1000;3 5]


// Solution 2 - Arithmetic progression

/ https://en.wikipedia.org/wiki/Arithmetic_progression

/ Arithmetic progression: A sequence of numbers where the difference between the consecutive terms is constant
/ e.g.
/ 3 6 9 12 15 ... 
/ 5 10 15 20 25 ...

/ 
    Arithmetic Series - Sum of the members of a finite arithmetic progression

    3 + 6 + 9 + 12 + 15 + ... + an
    5 + 10 + 15 + 20 + 25 + ... + an

    Sn = n * (a + an) / 2

    where 
        n  -->  Number of terms in the sequence
        a  -->  First term in the sequence
        an -->  n-th (final) term in the sequence
\

arithSeries:{[a;an;n] .5*n*a+an}

/ NOTE: Multiplying by decimal form is faster than dividing on most modern processors
\ts:1000000 10%2
\ts:1000000 .5*10

/ To calculate the arithmetic series we require the 3 inputs: 

/ 1. a
/ We will start our sequences at 3 and 5 (will allow us to take advantage of a special case detailed below)
/ could start at 0, but it would not contribute to the sum anyways

/ 2. an
/ Equation to calculate the n-th term of an arithmetic progression
/ an = a + (n - 1) * d 
/ where d is the common difference (3 and 5 in our case)
arithN:{[a;d;n] a+d*n-1}

/ We have a special case because a = d
/ 
    an = a + a * (n - 1)
       = a * (1 + (n - 1))
       = a * n
\

/ 3. n 
/ Simply divide our max term by 3 and 5 to find the number of terms 
999%3 5
/ Round down as n must be an integer
floor 999%3 5

a:3 5
n:floor 999%a
an:a*n
arithSeries[a;an;n]

/ 
    Consideration!
    We are summing two arithmetic progressions with overlapping values
    3 6 9 12 15 ...
    5 10 15 20 25 ...
    We would be double counting all the terms which are multiples of both 3 and 5 
    i.e., 15 30 45 60 75 ...
    We just need to calculate the arithmetic series of this and subtract it from the sum of the 3 and 5 arithmetic series to cancel out the double counting
\

/ Join first term of common multiples sequence
a,prd a

a:3 5
a,:prd a
n:floor 999%a
an:a*n
arithSeries[a;an;n]

/ Need to sum the first two arithmetic series and subtract the last
sum 1 1 -1*arithSeries[a;an;n]

s2:{sum 1 1 -1*arithSeries[y;;n] y*n:floor x%y,:prd y}
s2[999;3 5]


// Solution 3

/ Can simplify the arithmetic series equation (due to the special case described previously) to improve our solution

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

/ Use 'abs' (absolute) and 'neg' (negative) keywords instead of 1 1 -1*

s4:{sum .5*n*y*1+n:floor x%abs y,:neg prd y}
s4[999;3 5]


// Performance test

/ Arithmetic Series solutions (s2, s3, and s4) have constant time and space complexity (O(1))
/ Compared with solution 1 (s1) which has time and space complexity which increases proportionaly with n (O(n))
.perf.test[100000;] each (
    (`s1;1000;3 5);
    (`s2;999;3 5);
    (`s3;999;3 5);
    (`s4;999;3 5)
 )

/ s1 time and memory usage grows with increasing n
.perf.test[10000;] each (
    (`s1;100000;3 5);
    (`s2;99999;3 5);
    (`s3;99999;3 5);
    (`s4;99999;3 5)
 )

