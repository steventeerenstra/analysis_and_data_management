***************************************************************************;
**** EXAMPLE **************************************************************;
***************************************************************************;

/** we have a dataset wide with variables date and ward1, ward2, ... .
the variable ward1 contain the count of that ward at the given date.
We want to have a dataset stacked with ward counts 'stacked' on top of each other
so from 
date  ward1 ward2 ...
1      30    50
2      4     60
3       2     5
to
date ward_name  count
1    ward_1     30
2    ward_1      4
3    ward_1     2
1    ward_2     50
2    ward_2     60
3    ward_2      5
****************************************************************
**/


data stacked;set wide;
array a _numeric_;
do over a; 
	if vname(a) ne 'date' then do;
		afd0=cat('afd_',vlabel(a));* naming "afd_1M" etc;
		afd0=lowcase(afd0); *to make uniform lowcase;
  		count=a;
 		output;
	end;
end; 
run;

proc sort data=long1; by afd0 date;run;
