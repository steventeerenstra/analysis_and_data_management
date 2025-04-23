

* &n_tot: total number of units to randomize;
* &n_intv: total number of units randomized to intervention;
* so &n_intv=&n_tot/2 for 1:1 randomization;;
%let n_tot=14;
%let n_intv=7;
* calculate the number of combinations;
* (choose &n_intv that gets intervention out of &n_tot a subset; 
%let n_allcomb=%sysfunc(comb(&n_tot,&n_intv));
%put &n_allcomb;

* Step 0: indentify the variables to achieve balance on;
* here only numerical variables are considered, e.g.e continuous or counts or binary (yes=1, no=0);
* if more or other type of variables needed then this has to be adapted;
* the naming is as in the data file with the characteristics of the clusters;
* clusters have to be numbered in the variable "cluster" from 1 onwards;
%let var1=unihosp;
%let var2=belgium;

* Step 1: make all possible allocation schemes, but only show which units get intervention;
title 'All Combinations of (&n_tot Choose &n_intv) Integers';
ods exclude all;* to get faster calculation;
ods results off;
proc plan;
   factors allocation=&n_allcomb ordered
           Treat= &n_intv of &n_tot comb ;
   ods output Plan=Combinations;
run;
ods exclude none;
ods results on;

* step 2: show for each unit what the treatment (intervention or control) is;
* trt_unit{i}=0 for ctl, =1 for intervention for unit i;
data a; set Combinations;
array trt_unit{&n_tot}; 
array treat{&n_intv} treat1-treat&n_intv;
do i=1 to &n_tot; 
trt_unit{i}=0; * in principle each subject = 0 (ctl arm)..;   
	do j=1 to &n_intv; trt_unit{ treat{j} } =1; * except when indicated by treat1-treat&intv;
	end;
end;
drop i j; 
run;
/*
proc print data=a;run;
*/

/* 
*step 3: restrict if necessary to the admissible allocation schemes;
* (restricted randomisation);
* here: cluster 18, 19, 20 must have the same randomisation allocation;
data a1; set a; if trt_unit18=trt_unit19 and trt_unit19=trt_unit20; run;
data a; set a1;run; * rename this dataset a;
*/

*number of admissible allocations;
data _NULL_;
if 0 then set a nobs=n;
call symput("n_admissible_allocations",n);
run;


* step 4: couple the allocation/randomisation scheme to the characteristics from the to-be-randomized units;
* the dataset of characteristics has as variables: cluster, characteristic 1, characteristic 2, etc;
* (other information may be present in that dataset but is not used).
*> read units characteristics;
libname data ".\data characteristics";
data b; set data.characteristics;run;
*> replicate the unit characteristics for each of the allocation/randomization scheme in dataset a;
*> so we get a long dataset (clusters repeated across each of allocation); 
proc sql;
create table c as
select
*
from a,b;
quit;
proc sort data=c; by allocation;run;

/* check
proc print data=c;run; 
*/

*> add to each unit (record) the treatment assigned by the allocation scheme;
data d; set c; 
array trt_unit{&n_tot} trt_unit1-trt_unit&n_tot;
treatment=trt_unit{cluster}; 
run;
/* check
proc print data=d;run; 
*/

* Step 5: calculate imbalance;
* step 5a: summarize the characteristics by allocation scheme;
*          this is custom made action according to the characteristics (here man, vrouw);  
proc means data=d noprint; by allocation;
class treatment;
var &var1 &var2; 
output out=e mean= sum= /autoname;
run; 

data e; set e; where _type_=1; drop _type_;run;
proc print data=e;run;

*step 5b: calculating the absolute difference for each characteristic by allocation scheme;
* here using the range option as there only 2 records per allocation (treatment=0 or =1);
proc means data=e noprint;by allocation; 
var &var1._sum &var2._sum;
output out=f range=  /autoname;
run;

*step 5c: calculate total imbalance as the sum of the absolute differnces over the characteristics;
* across the characteristics;
data g; 
set f(drop=_type_ _freq_ 
rename=(&var1._sum_range=imbalance_&var1 &var2._sum_range=imbalance_&var2)
);
imbalance=sum(of imbalance:);
run;

* step 6: randomly choose one of the allocation schemes from the schemes with smallest imbalance;
* step 6a: sort from small to large imbalance;
proc sort data=g;by imbalance;run;

* step 6b: custom step: read what is the range of the smallest (e.g.10%) of imbalances; 
*          for instance: those with rank=1, 2, 3, ... 4356 have the lowest 10% imbalances;
*                        so records with number > 4356 are not in the 10% lowest imbalances; 
proc freq data=g; table imbalance;run;

* step 6c: identify set allocations schemes with smallest imbalance (e.g. smallest 10%);
* determined by rank_upper;
* and choose 1 scheme randomly of those; 
data choose0;
****first *** determine set with smallest imbalance and choose one of them;
retain rank_upper chosen_rank;
if _n_=1 then do;
call streaminit(37); * set the random number sequence;
rank_upper=1000;*all the allocations with the lowest imbalance=1; * upper rank of the allocations with smallest imbalance; 
* random number out of 1, 2, 3, ..., rank_upper;
chosen_rank=1 + floor( (rank_upper)*rand("uniform") );
end;
****before *** adding this information to the set of all allocation schemes;
set g;
if _n_=chosen_rank then chosen_allocation=1; else chosen_allocation=0;
run;

* clean up;
* custom made: name of the imbalance variables;
data choose1; set choose0(keep=allocation chosen_allocation imbalance:);run;

*** step 7: merge to full information of the allocations;
proc sort data=choose1; by allocation;run;
proc sort data=d; by allocation;run;

data final0; merge choose1 d; by allocation;run; 
* clean up;
data final1; set final0; 
keep allocation chosen_allocation cluster abbreviation treatment imbalance: &var1 &var2;
run;

data final; set final1; if chosen_allocation=1;run;


/** for each variable in the imbalance measure, calculate the imbalance;
proc means data=final ; class treatment; var unihosp belgium ; output out=x1 sum=  /autoname; run;
data x1; set x(where=(treatment ne .) drop=_type_ _freq_ belgium_sum unihosp_mean belgium_mean);run;
proc transpose data=x1; id treatment;by unihosp_sum; run;
*/


** custom made file naming etc ***;
ods pdf style=statistical file="hithard_randomization_250423.pdf" compress=9;
title "chosen allocation out of &n_admissible_allocations admissible allocations";
proc print data=final(drop=chosen_allocation allocation imbalance: &var1 &var2 ) noobs label;run;

title "imbalance in the chosen allocation"; *note that format and sum is used;
proc print data=final(keep=allocation imbalance: obs=1) noobs;run;
ods startpage=off;
data final_table; set final;
balance_variable=vname(&var1); value=&var1;output;
balance_variable=vname(&var2);value=&var2;output;
run;
proc tabulate data=final_table f=3.0; 
class treatment balance_variable; var value;
table balance_variable="to balance on:   ",treatment*value=" "*sum=' ';
run;
proc sort data=final; by treatment;
proc print data=final(drop=chosen_allocation allocation imbalance: cluster ) noobs label;by treatment;run;

ods startpage=on;
title "distribution of imbalance across all allocations";
proc freq data=g; table imbalance;run;
title "imbalance of each allocation (treat1, treat2, etc are the units with the intervention)";
data info; set final0;by allocation;
if first.allocation;
keep allocation chosen_allocation treat: imbalance;
drop treatment;
run;
proc sort data=info; by imbalance;
proc print data=info noobs label;run;
ods pdf close;


