\d .math


///// General /////

isodd:mod[;2]
/ Filter out even numbers
odds:{x where isodd x}
/ Filter out odd numbers
evens:{x where 0=isodd x}

/ Digits of a number
digits:10 vs
/ Last digit
ldigit:last digits::
/ ith digit
ithd:{[i;n] digits[n] i}

/ Return the quotient and remainder of x div y
divmod:{d,x-y*d:x div y}
/ Continuously divide x by y until not evenly divisible
divs:{(0=mod[;y]@) div[;y]\ x}

/ Greatest common divisor of two numbers (Euclidean algorithm)
gcd:{first last({y,x mod y}.)/x,y}

/ Least common multiple of a list of numbers
lcm:{prd raze value[p]#'key p:{x,k!n k:where x<n:count each group pfact y}/[(1#0N)!1#0;x]}

/ Returns only the numbers which are palindromes
palindromes:{x where x="J"$reverse each string x}

/ Pythagorean Triplet where a + b + c = x
pyTriplet:{
    m:.math.range . (floor;ceiling)@'1 -1+sqrt[x]%2,sqrt 2;
    n:neg[m]+x div 2*m;       
    a:2*m*n;                   
    b:(-). mn2:"j"$(m;n) xexp 2; 
    c:sum mn2; 
    i:where x=sum v:0|(a;b;c);
    flip v[;i]
 }

/ All Pythagorean Triplets below x 
pyTriplets:{(i+1)!n i:where 0<count each n:pyTriplet each 1+til x}


///// Number Sequences /////

/ https://en.wikipedia.org/wiki/Arithmetic_progression
/ n-th term of an arithmetic progression
/ a : first term, d : common difference
arithN:{[a;d;n] a+d*n-1}
/ Sum of the first n members of an arithmetic progression
/ a : first term, an : n-th term
arithSeries:{[a;an;n] .5*n*a+an}

/ Sum of the first x positive integers
nsum:{"j"$.5*x*x+1}
/ Sum of the squares of the first x positive integers
n2sum:{div[x*(1+2*x)*x+1;6]} 

/ First n+2 Fibonacci numbers
fib:{x,sum -2#x}/[;0 1]
/ Fibonacci numbers below some maximum
fibm:-1_fib {x>last y}@

/ List of integers from l to u with step s
/ sf - scaling function to allow different range variations
range0:{[l;u;s;sf] sf s*til 1+(u-l) div s}
/ List of consecutive integers from x to y inclusive
range:{range0[x;y;1;x+]}
/ Reversed version of range
rrange:{range0[x;y;1;y+neg@]}

/ n random numbers between (l)ower and (u)pper bounds (upper bound not inclusive for integers)
randNs:{[n;l;u] l+n?u-l}
/ Random number between (l)ower and (u)pper bounds (upper bound not inclusive for integers)
randN:{[l;u] first randNs[1;l;u]}


///// Primes /////

/ Arthur's prime generator - Best for primes X < 10^4
primesA:{$[x<3;1#2;r,1 _ where not max x#'not til each r:.z.s ceiling sqrt x]}
/ Improvement - Best for primes 10^4 <= X < 10^5
primesB:{$[x<3; 1#2; r,1_ where not {y or x#not til z}[x]/[x#0b;] r:.z.s ceiling sqrt x]}

/ Primes - Sieve of Eratosthenes
util.isPrime0:{(x<>1) and not 0 in x mod 1 _ 1+til floor sqrt x}
util.sieve:{n:1+y?1b; (x,n; @[y;1_-[;1]n*til 1+count[y] div n;:;0b])}.
util.es:{[s;N] {x,1+where y} . ({any z#y}[;;floor sqrt N].) s/(2; 0b,1_N#10b)}
isPrime:{@[;where x in 2 3 5 7;:;1b] @'[;x] ({0b};util.isPrime0)0 1 0 1 0 0 0 1 0 1 ldigit x}
/ Primes up to X - Best for primes X > 10^5
primes:util.es util.sieve

nprimes:{x#last(x>count last@){(x[0]+:1;x[1],n where isPrime n:-1 1+6*x 0)}/(1;2 3)} 

/ Prime factorisation using trial division
pfact:{
    if[x<2;:x];
    p:{while[0=x[0] mod y; x[0]:x[0] div y; x,:y];x}/[1#x;primes ceiling sqrt x];
    $[1<p 0;p;1_p]
 }

/ Pollard's Rho algorithm - Fast for a large composite number with small prime factors
/ x - Starting value (usually 2)
/ f - Polynomial (function) to generate a pseudorandom sequence (usually f(x) = (c + x^2) mod n)
/ n - The number we want to factorise
pollardsRho0:{[x;f;n] y:x; g:1; while[g=1;x:f x;y:f f y;g:gcd[abs x-y;n]]; g}
/ Pollard's Rho algorithm with the commonly used f(x)
/ c - An integer value (usually 1)
pollardsRho:{[x;c;n] pollardsRho0[x;;n] (mod[;n] c+prd 2#)}
/ Pollard's Rho algorithm with the commonly used f(x) and, random x and c
pollardsRho1:{(x=){pollardsRho0[randN[2;x];;x] (mod[;x] randN[1;x]+prd 2#)}/ x}

rhoFact0:{[x;c;n] ({z[where ip],p,r[i] div p i:where r<>p:pollardsRho[x;y] each r:z where not ip:isPrime z}[x;c]/) 1#n}
/ Prime factorisation using Pollard's rho algorithm
rhoFact:{[x;c;n] if[n<2;:n]; $[all i:isPrime r:rhoFact0[x;c;n]; r; r[where i],raze pfact each r where not i]}
/ Prime factorisation using Pollard's rho algorithm where x and c are continuously chosen at random until 
/ x can be factorise. Note that some numbers cannot be factorised and so generate an infinite loop
rhoFact1:{if[x<2;:x]; ({x[where ip],p,r[i] div p i:where r<>p:pollardsRho1 each r:x where not ip:isPrime x}/) 1#x}


