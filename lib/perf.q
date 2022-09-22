\d .perf


/ Time and space of a function application or string evaluation
ts:{.Q.ts . e[0],enlist 1_ e:.util.ptree x}

/ Memory usage of a function application or string evaluation
memUse:.[;0 1] ts::

/ Time stats of n function applications or string evaluations
timeit:{[n;expr] 
    e:.util.ptree expr;
    s:.z.N; 
    do[n;eval e]; 
    t:.z.N-s;
    `f`n`total`average!(expr;n;t;"n"$t%n)
 }

test:{[n;expr] timeit[n;expr],(1#`mem)!1#memUse expr}
