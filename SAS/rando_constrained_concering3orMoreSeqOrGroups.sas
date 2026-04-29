* step 1: first all permutations of all the units that we have to randomize;
*         i.e. like every unit will go to a separate sequence/treatment group;
*         we will built in the restrictions on units later in following steps; 
%let n_units=11;
%let n_perm=%sysfunc(perm(&n_units));
%put number of permutations: &n_perm;

ods exclude all; 
proc plan; 
      factors  allocation=&n_perm ordered
               u= &n_units perm ; *u= unit, so u3=8 means that unit3 goes to sequence/group=8;
  ods output Plan=all_perm;
run;
ods exclude none;

* step 2 is custom-made for each randomisation; 
*        

* condition 1 ("randomize 11 cluster to 10 sequences in a SW") ;
* unit 1 and 2 have to go in the same sequence;
* 	we start from all allocations, see step 1;
*   but select those sequences in which unit 1,2 have subsequent indices;
*   which we will interpret as being in one sequence; 
*   the same for cluster 3, 4; 
* For example u1=4,u2=5 u3=1,u4=2 u5=6 u6=10 u7=8 u8=11 u9=3 u10=9 u11=7 means that cluster 3&4 switch first, then clusters 1, 
*                               then cluster 3, then 7, then 8, then 9 then 1 etc;


* Because we generated permutation, u[i] neq u[j] if i neq j, so we do not have to check this;
* we want that u2=u1+1 and u4=u3+1 to avoid double counting as u1=4, u2=5 is the same as u1=5, u2=4;

data admissible_0; set all_perm;
if u2=u1+1 and u4=u3+1;
run;
 

* for each allocation, we determine the order in clusters switch;
* i.e. for each cluster we count how many other clusters have a sequence/group index that is smaller;
* if there are e.g. 3 clusters before, then the switch moment is 4, therefore the 1+ ;  
data admissible_1; set admissible_0; 
switch_u12=1+ (u2<u1) + (u4<u1) + (u5<u1) + (u6<u1) + (u7<u1) + (u8<u1) + (u9<u1) + (u10 < u1) + (u11< u1);* note that (u2<u1) is false by definition;
switch_u34=1+ (u2<u3) + (u4<u3) + (u5<u3) + (u6<u3) + (u7<u3) + (u8<u3) + (u9<u3) + (u10 < u3) + (u11< u3);* note that (u4<u3) is false by definition; 
%macro repsteps();
%do i=5 %to 11;
	* note that (u2<u&i) counts whether the same sequence/group number of clusters 1 and 2 is below the sequence/group number of &i;
	* idem (u4u&i) for the common sequence/group number of 3,4; 
	* note that (u&i < u&i) is automatically false, so 0, and is not counted;
	switch_u&i=1+ (u2<u&i) + (u4<u&i) +  (u5<u&i) + (u6<u&i) + (u7<u&i) + (u8<u&i) + (u9<u&i) + (u10 < u&i) + (u11< u&i); 
%end;
%mend repsteps();
%repsteps();
run;


* condition 2: cluster 5 switches the 6th 7th 8th or 9th moment; 
* this means that there are least 3 switch moments have to be before cluster 5 switches; 
* note that cluster 1&2 (switching together) have a switch moment before cluster 5 if u2<u5;
	* because u1<u2, in fact u1=u2-1;
* note that cluster 3&4 (switching together) have a switch moment before cluster 5 if u4<u5;
* cluster 6 has a switch moment before cluster 5 if u6 < u5;
data admissible; set admissible_1; 
if switch_u5 ge 6;
run;


libname dir ".";
 
data dir.admissible; set admissible;run;

*number of admissible allocations;
data _NULL_;
if 0 then set dir.admissible nobs=n;
call symput("n_admissible_allocations",n);
run;
%put &n_admissible_allocations;

title "possible allocation given the restraints: &n_admissible_allocations";
title2 "chosen allocation";
data choose0; 
retain chosen_allo;
	if _n_ =1 then do;
	call streaminit(65537);
	chosen_allo=1+floor(&n_admissible_allocations*rand("uniform")); 
	end;
set dir.admissible;
	allo=_n_;
run;

proc print data=choose0 noobs; where allo=chosen_allo;
var u: switch_u:; run;

