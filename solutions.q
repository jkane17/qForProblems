\l lib/lib.q


// Problem 1 - https://projecteuler.net/problem=1

{sum where not all til[x] mod/:y}[1000;3 5]
{sum 1 1 -1*.math.arithSeries[y;;n] y*n:floor x%y,:prd y}[999;3 5]
{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}[999;3 5]
{sum .5*n*y*1+n:floor x%abs y,:neg prd y}[999;3 5]


// Problem 2 - https://projecteuler.net/problem=2

sum .math.evens .math.fibm 4000000

/ Every 3rd number is even (credit SJT)
sum {x where count[x]#100b} .math.fibm 4000000

/ Goldern Ratio (credit cillianreilly)
phi:0.5*1+sqrt 5
fibn:{reciprocal[sqrt 5]*(-/)xexp[;y]x,1-x}[phi;]
sum -1_{4000000>last x}{x,fibn 3*count x}/0f 


// Problem 3 - https://projecteuler.net/problem=3

max .math.pfact 600851475143
max .math.rhoFact[0;2] 600851475143


// Problem 4 - https://projecteuler.net/problem=4

max .math.palindromes distinct raze n*/:n:.math.range[100;999]
max raze(.math.palindromes r*)peach r:.math.range[100;999] / parallel algorithm
/ Very efficient (credit alivigston)
{
    / Create all palindromes in reverse order
    digits:reverse string til 10;
    palindromes:{[x;y;z]raze x,/:'y,\:/:x}[digits]/[;til x-1];
    pals:"J"$palindromes 2#/:digits;

    / Create all x digit numbers
    nums:reverse r[1]+til(-/)r:`long$10 xexp 0 -1+\:x;
    
    / Recursively check each palindrome, early exit if found
    {[pals;nums]
        p:first pals;
        b:and[first[nums]>n]not mod[;1]n:p%nums mod[p;nums]?0;
        $[b;p;.z.s[1_pals;nums]]
    }[pals;nums]
 } 3


// Problem 5 - https://projecteuler.net/problem=5

{(any mod[;n where 0<>x mod n:2+til x-1]@)(x+)/ x} 20
.math.lcm 2+til 19
/ Using gcd (credit cillianreilly)
{{7h$(x*y)%.math.gcd[x;y]}/[reverse 1+til x]} 20


// Problem 6 - https://projecteuler.net/problem=6

{(s*s:sum n)-sum n*n:1+til x} 100
{(prd 2#.math.nsum x)-.math.n2sum x} 100 


// Problem 7 - https://projecteuler.net/problem=7

last {-1_((1+x)>count@){$[isPrime l:last x; x,:l+2; x:(-1_x),l+2]}/2 3} 10001 
last {x#last(x>count last@){(x[0]+:1;x[1],n where .math.isPrime n:-1 1+6*x 0)}/(1;2 3)} 10001


// Problem 8 - https://projecteuler.net/problem=8

N:raze read0 `$":input/p8.txt" 
{max prd ("J"$/:x) cStrdIdx[count x;y]}[N;13]


// Problem 9 - https://projecteuler.net/problem=9

prd first .math.pyTriplet 1000


// Problem 10 - https://leetcode.com/problems/two-sum/

{[t;n] (99=type@){[t;n;m] $[count[m]=count n; "j"$(); null m t-x:n i:1+last m; m,(1#x)!1#i; m[t-x],i]}[t;n]/(1#n)!1#0}[9;2 7 11 15]
/ (Credit jbetz34)
{i where x=yi+yi@yi bin x-yi:y i:iasc y}[9;2 7 11 15]


// Problem 11 - https://projecteuler.net/problem=11

N:("J"$" " vs) each read0 `$"input/p11.txt"
{[n;x]
    c:1+r:count n;
    i:.util.cStrdIdx[r*c;x];
    rn:raze n,\:0;
    ds:c*til x;
    d:neg c*x-1;

    max prd (,'/)(
        rn i;                            // Horizontal
        raze[flip[n],\:0] i;             // Vertical
        rn ds+d _/:i;                    // Right diagonal 
        raze[0,/:n](ds+x-2*til x)+d _/:i // Left diagonal
    )
 }[N;4]


// Problem 12 - https://projecteuler.net/problem=12

{last(x>count .math.factor last@){(1+x 0;x[1]+x 0)}/(1;0)} 500
{.math.triNum first (x>last@){(n;.math.nTriFactors n:1+x 0)}/(1;0)} 500


// Problem 13 - https://projecteuler.net/problem=13

10#.math.addStrs read0 `$"input/p13.txt"


// Problem 14 - https://projecteuler.net/problem=14
{
    k:ceiling x%2;
    start:`n`c!(k+til 1+k;(k+1)#0);

    r:({
        cont:1<>x`n;
        isodd:1=x[`n] mod 2;
        x[`c]+:cont+cont and isodd;
        x[`n]:?[cont;?[isodd;1+3*x`n;x`n] div 2;1];
        x
    }/) start;
    
    k+r[`c]?max r`c
 } 999999

