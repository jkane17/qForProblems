/ https://projecteuler.net/problem=3

\l lib/lib.q


///// Part 1 /////

/ Prime (Integer) factorisation - Expressing an integer as a product of its prime factors

/ Trial division [complexity O(sqrt n)]

N:100 / Number to factorise
p:()  / List to store the prime factors
d:2   / Starting point

/ Is N evenly divisible by d?
0=N mod d / 1b
/ TRUE - d is prime factor so it can be added to the list of prime factors
p,:d / ,2
/ and divide N by d to remove the factor from N
N:N div d / 50

/ Since N was evenly divisible by d, repeat
0=N mod d / 1b
/ TRUE - d is prime factor so, it can be added to the list of prime factors
p,:d / 2 2
/ and divide N by d to remove the factor from N
N:N div d / 25

N:100; p:(); d:2 / Reset

/ Use the 'while' control construct to repeat until N is no longer evenly divisible by d
while[0=N mod d; p,:d; N:N div d]

/ N is no longer evenly divisible by d so, move on to the next number
d+:1 / 3

/ Continue in this fashion until d exceeds the square root of the original N

/ 
    Why the square root?
    A composite (non prime) number will always have a factor less than or equal to its square root
    
    Proof:
    Let C be a composite number such that
        C = n * m 
        i.e, n and m are factors of C
    Also have that
        C = sqrt(C) * sqrt(C)
    Therefore, at least one of n or m must be less than or equal to the square root of C
\ 

N:100; p:(); d:2 / Reset

/ Use ceiling to round up to nearest integer
s:ceiling sqrt N 

/ Use the 'while' control construct to repeat until the square root of the original N is reached
while[s>=d;
    while[0=N mod d; p,:d; N:N div d];
    d+:1
 ]

N:100; p:(); d:2 / Reset

/ Printing out the intermediary value of N shows that it has a value of 1 for many iterations
while[s>=d;
    0N!N;
    while[0=N mod d; p,:d; N:N div d];
    d+:1
 ]

N:100; p:(); d:2 / Reset

/ Add another condition to the outer while loop to avoid 
while[(N>1) and s>=d;
    0N!N;
    while[0=N mod d; p,:d; N:N div d];
    d+:1
 ]

/ p now contains the prime factors of N
/ It may be the case that N>1 by the end of the loop
/ This happens if N becomes a prime factor itself
/ Need to join N to p if this is the case
$[1<N;p,N;p]

/ Putting it altogether in a function
pfact1:{
    if[x<2;:x]; / values less than 2 are simply returned 
    d:2;
    p:();
    s:ceiling sqrt x;
    while[(x>1) and s>=d;
        while[0=x mod d; x:x div d; p,:d];
        d+:1
    ];
    $[1<x;p,x;p]
 }

max pfact1 600851475143 / solution 1

/ 
    Note: 
    q development style usually tries to avoid using the 'while' control construct 
    and instead opt for the over/scan accumulators.
    However, the previous algorithm involes holding state of multiple values (N, d and p)
    and passing this state between iterations.
    This can lead to messy (and even less performant) code, which was the case here
\

/ 
    The previous function can be optimised by noting that only the prime number below the 
    square of N need to be checked.
    This is because any composite factor of N can itself be factorised. 
    For example:
        N = 16
        N = 4 * 4
        N = 2 * 2 * 2 * 2
    There is no point checking because we will have already covered it when we checked 2
\

/ Primes generated using the Sieve of Eratosthenes algorithm described here: 
/ https://community.kx.com/t5/Community-Blogs/Finding-primes-with-q/ba-p/11120
prms:.math.primes ceiling sqrt N:100

/ Can now use the over (/) accumulator instead of the outer while loop
/ To maintain the list of factors found so far, the first argument to the accumulator
/ (which is passed in on each iteration) is a list whose first element is the current value of N
/ and all other elements are the factors found so far
{
    while[0=x[0] mod y; 
        x[0]:x[0] div y; / Remove factor from N
        x,:y             / Add new factor to end of the list
    ]; 
    x                    / Return the current state
 }/[1#N;prms] 

/ Printing out the intermediary values, using scan (\), shows that the iterations could be stopped when N equals 1
{while[0=x[0] mod y; x[0]:x[0] div y; x,:y]; x}\[1#N;prms] 

/ Could use the 'while' form of the over accumulator to add the condition
/ but we need to maintain state and incremement an index value.
/ It is clearer to use the 'while' control construct
ct:count prms
i:0 / Index to prms
p:()
while[(i<ct) and x>1; / Check we do not exceed the max index or prms and that x>1
    d:prms i; / The next prime factor to check
    while[0=x mod d; x:x div d; p,:d];
    i+:1 / Move on to the next prime factor
 ]

pfact2:{
    if[x<2;:x];
    prms:.math.primes ceiling sqrt x;
    ct:count prms;
    i:0;
    p:();
    while[(i<ct) and x>1;
        while[0=x mod d:prms i; x:x div d; p,:d];
        i+:1
    ];
    $[1<x;p,x;p]
 }

max pfact2 600851475143 / solution 2


/ Performance can depend on the input but, in general, pfact2 should be better for larger numbers
.perf.test[100;] each ((`pfact1;600851475143);(`pfact2;600851475143)) / Number from problem (small factors)
.perf.test[10;] each ((`pfact1;435517289103);(`pfact2;435517289103))  / Number with large factor
.perf.test[1;] each ((`pfact1;593144405383);(`pfact2;593144405383))   / Large prime number


///// Part 2 /////

/ Pollard's Rho algorithm [complexity possibly O(n^1/4)]
/ Fast for a large composite number with small prime factors
/ x - Starting value (usually 2)
/ f - Polynomial (function) to generate a pseudorandom sequence (usually f(x) = (1 + x^2) mod n)
/ n - The number we want to factorise
pollardsRho0:{[x;f;n]
    y:x; g:1; / Starting points
    while[g=1;
        x:f x;  
        y:f f y;
        g:gcd[abs x-y;n]
    ];
    g
 }

/ Pollard's Rho algorithm with the commonly used f(x)
/ c - An integer value (usually 1)
pollardsRho:{[x;c;n] pollardsRho0[x;;n] (mod[;n] c+prd 2#)}

/ 
    Greatest common divisor of two numbers (Euclidean algorithm)

                 a,               if b = 0
    gcd(a,b) = { 
                 gcd(b,a mod b),  otherwise.
\

a:15; b:10
/ Example: gcd[15;10] = gcd[10;5] = gcd[5;0] = 5
show n:b,a mod b / 10 5
a:n 0; b:n 1
/ b not equal to zero -> CONTINUE
show n:b,a mod b / 5 0
a:n 0; b:n 1
/ b equal to zero -> RETURN a
a / 5

/ Can use the while form of the over (/) accumulator to repeatedly apply the logic until b becomes zero
{last[x],(mod). x} 15 10                 / Function to get the values of the next iteration
(0<last@)                                / Predicate function to check if b is zero
(0<last@){last[x],(mod). x}\ 15 10       / Putting it together (use scan (\) to see intermediary results)
first (0<last@){last[x],(mod). x}/ 15 10 / Select a

gcd:{first(0<last@){last[x],(mod). x}/x,y}

/ gcd of a list of numbers
(gcd/) 12 18 42 60


/ Pollard's Rho algorithm only returns one factor
/ Need to remove the factor from N and repeat
N:600851475143
p:pollardsRho[0;2] N / Retrieve the first factor
/ Can extract another factor by dividing by this factor (since factors come in pairs)
show p:p,N div p / 71 8462696833
/ Repeat for each factor until they can not longer be factorise
/ The algorithm will return N if it cannot be factorise
p1:pollardsRho[0;2] each p
p2:p1 i:where b:p<>p1 / Filter out numbers that can not be factored
p1,p[i] div p2

/ Combining into a function
f:{p,x[i] div p i:where x<>p:pollardsRho[0;2] each x}
/ Will only work on a list so use 1# to create a one element list
N:1#600851475143 
f N       / 71 8462696833
f f N     / 71 839 10086647
f f f N   / 71 839 6857 1471
f f f f N / 71 839 6857 1471 - Repeated!

/ Can use the converge form of the over (/) accumulator to repeat until the same result is repeated
(f/) 1#N

/ Also want to make the x and c arguments for pollardsRho function configurable
f:{[x;c;n] ({p,z[i] div p i:where z<>p:pollardsRho[x;y] each z}[x;c]/) 1#n}
f[0;2;N] 

/ Finally, add special handling for values less than 2
rhoFact1:{[x;c;n] 
    if[n<2;:n]; 
    ({p,z[i] div p i:where z<>p:pollardsRho[x;y] each z}[x;c]/) 1#n
 }

max rhoFact1[0;2] 600851475143 / solution 3

/ The algorithm can perform badly for prime number inputs
/ rhoFact1 continues running the pollardsRho algorithm over the factors list so far (some of which will be prime numbers)
/ Can improve performance by filtering out those which we know to be prime

/ iSPrime function is described here: 
/ https://community.kx.com/t5/Community-Blogs/Finding-primes-with-q/ba-p/11120

N:71 8462696833
ip:.math.isPrime N
r:N where not ip            / Filter out prime numbers
p:pollardsRho[0;2] each r   / Only apply to the non primes
p,:r[i] div p i:where r<>p  / Join new factors
p,:N where ip               / Join the primes back

rhoFact2:{[x;c;n] 
    if[n<2;:n]; 
    ({
        z[where ip],p,r[i] div p i:where r<>p:pollardsRho[x;y] each r:z where not ip:.math.isPrime z
    }[x;c]/) 1#n
 }

max rhoFact2[0;2] 600851475143 / solution 4

/ The main problem with Pollard's Rho algorithm is that x and c must be chosen appropriately 
/ depending on the number you are trying to factorise
/ The following example shows that when x=0 and c=2, 100 cannot be completely factorised
rhoFact2[0;2] 100 / 5 5 4

/ Using trial an error I was able to find that x=0 and c=2 were good choices for 600851475143
/ But it may not alays be easy to find appropriate values
/ The solution can be generalised to use trial division to factorise any number which were unable to 
/ be factorised by Pollard's Rho algorithm
rhoFact3:{[x;c;n] 
    if[n<2;:n]; 
    $[all i:.math.isPrime r:rhoFact2[x;c;n];      / Identify if any numbers are still not completely factorised
        r;                                        / Return if all are factorised
        r[where i],raze pfact2 each r where not i / Else, use trial divison on the unfactorised numbers 
    ]
 }

rhoFact3[0;2] 100 

max rhoFact3[0;2] 600851475143 / solution 5


/ Another method is to choose x and c randomly

/ Use ? (roll) operator to generate random numbers
5?10     / 5 random integers between 0 and 10 (10 not inclusive)
2+5?10-2 / 5 random integers between 2 and 10 (10 not inclusive)

/ n random numbers between (l)ower and (u)pper bounds (upper bound not inclusive for integers)
randNs:{[n;l;u] l+n?u-l}
/ Random number between (l)ower and (u)pper bounds (upper bound not inclusive for integers)
randN:{[l;u] first randNs[1;l;u]} / Use 'first' keyword so an atom is returned instead of a one item list

/ Using the 'while' form of the over (/) accumulator, continuously apply pollardsRho0, with random x and c values
/ until a result not equal to n is produced (pollardsRho0 returns n if it could not be factorised)
pollardsRho1:{[n] (n=){[n] pollardsRho0[randN[2;n];;n] (mod[;n] randN[1;n]+prd 2#)}/ n}

/ Modifying rhoFact2 to no longer take the x and c args and use pollardsRho1
rhoFact4:{
    if[x<2;:x]; 
    ({
        x[where ip],p,r[i] div p i:where r<>p:pollardsRho1 each r:x where not ip:.math.isPrime x
    }/) 1#x
 }

max rhoFact4 600851475143 / solution 6


/ Performance test
n:100; x:600851475143 / Number from problem (small factors)
n:10;  x:435517289103 / Number with large factor
n:1;   x:593144405383 / Large prime number

.perf.test[n;] each (
    (`pfact1;x);
    (`pfact2;x);
    (`rhoFact1;0;2;x);
    (`rhoFact2;0;2;x);
    (`rhoFact3;0;2;x);
    (`rhoFact4;x)
 )
