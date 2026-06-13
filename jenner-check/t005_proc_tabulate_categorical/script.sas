/* Tabulate one categorical variable (with missing data) by arm, from
   SAS/proc_tabulate_categorical_vars. A single death-cause variable
   dd_cause (3 categories + missing) is expanded into one occurrence
   indicator per cause, then PROC TABULATE reports, per cause and arm:
   mean = fraction, sum = number of subjects with that cause, n =
   number with cause known, nmiss = number with cause unknown. */

* mock source: death cause (1/2/3 + missing) per study arm;
data mort_cause;
   input dd_cause ds_arm;
   datalines;
1 1
2 1
3 1
1 1
. 1
2 2
2 2
3 2
. 2
1 2
;
run;

data mort_cause_tabulate;set mort_cause;
if dd_cause=1 then do; cause=1; occur=1; output;
					   cause=2; occur=0; output;
					   cause=3; occur=0; output;
					   end;
else if dd_cause=2 then do; cause=1; occur=0; output;
					   		cause=2; occur=1; output;
					   		cause=3; occur=0; output;
							end;
else if dd_cause=3 then do; cause=1; occur=0; output;
					   		cause=2; occur=0; output;
					   		cause=3; occur=1; output;
							end;
else if dd_cause=. then do; cause=1; occur=.; output;
					   		cause=2; occur=.; output;
					   		cause=3; occur=.; output;
							end;
run;
proc format;
value causef 1="sepsis related"
                 2="not sepsis related"
				 3="unknown"
				 4="missing"
;
run;

proc tabulate data=mort_cause_tabulate;format cause causef.;
class cause ds_arm;
var occur;
* sum =number of subjects with the specific death cause;
* n_nomiss= number of subjects with death cause known;
* fraction= sum/n_nomiss;
* n_miss= total number of subjects - n_nomiss;
table cause, ds_arm=""*occur=""*(mean="fraction"*f=6.4 sum="occ."*f=2.0 n="n_nonmiss" nmiss="n_miss" );
run;
