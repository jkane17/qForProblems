\d .util


/ Return parse tree form
ptree:{$[type x;parse x;-11=type f:first x;get[f],1_ x;x]}

/ Create a (row) strided index, with stride size y, until (x - 1)
strdIdx:{til[y]+/:til neg[y-1]+x}
/ Column strided index, with stride size y, until (x - 1)
cStrdIdx:{til[y]+\:til neg[y-1]+x}

/ Add a list of number strings together
addStrs:{
    s:sum 0^("J"$'neg[max count each x]$(),)@/:x; 
    raze string ({(0=first x)_x:(d,0)+0,x-10*d:x div 10}/) s
 } 
