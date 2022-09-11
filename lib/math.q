\d .math


///// Number Sequences /////

/ https://en.wikipedia.org/wiki/Arithmetic_progression
/ (n)-th term of an arithmetic progression
/ a : first term, common (d)ifference
arithN:{[a;d;n] a+d*n-1}
/ Sum of the first n members of an arithmetic progression
/ a : first term, an : n-th term
arithSeries:{[a;an;n] .5*n*a+an}

