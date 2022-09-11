\l lib/lib.q


// Problem 1

/ https://projecteuler.net/problem=1

{sum where not all til[x] mod/:y}[1000;3 5]
{sum 1 1 -1*.math.arithSeries[y;;n] y*n:floor x%y,:prd y}[999;3 5]
{sum 1 1 -1*.5*n*y*1+n:floor x%y,:prd y}[999;3 5]
{sum .5*n*y*1+n:floor x%abs y,:neg prd y}[999;3 5]

