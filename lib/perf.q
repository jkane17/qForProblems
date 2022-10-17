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
    $[10=type expr;[f:expr;args:1_e];[f:first expr;args:1_ expr]];
    `f`args`n`total`average!(f;args;n;t;"n"$t%n)
 }

test:{[n;expr] timeit[n;expr],(1#`mem)!1#memUse expr}

/ Return best and worst time and mem based on some arg specified by arg index (argi)
/ e.g., argi:0 will derive the comparison based on the arg at index 0
compare:{[n;argi;exprs]
    t:test[n;] each exprs;
    r:(1#`t)!enlist t;
    t:update cmp:args[;argi] from t;
    flt:{`cmp xasc ?[x;enlist (=;z;(fby;(enlist;y;z);`cmp));0b;()]}[t];
    r,`bestTime`worstTime`bestMem`worstMem!flt ./: (
        (min;`average);(max;`average);(min;`mem);(max;`mem)
    )
 }

