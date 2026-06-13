/* Toy example showing how the compare_datasets approach works.
   Adapted from SAS/compare_datasets.sas in this repository.
   If ID is the identifier (implying the other variables are the same)
   then merge by ID; otherwise merge by _all_ (so that only records
   identical in both datasets collapse to one). */

* test data;
data old;
input ID var1 var2;
datalines;
001 1 2
002 1 2
003 1 2
004 1 2
006 1 3
008 1 4
;
run;

data new;
input ID var1 var2;
datalines;
001 1 2
002 1 2
003 1 2
004 1 2
007 2 2
;
run;

proc sort data = old;
by id;
run;
proc sort data = new;
by id;
run;

* merge of all records, only one record if identical in both;
data merged;
merge old(in=in_old) new(in=in_new);
by id;
old=in_old;
new=in_new;
run;

* records present only in old (dropped from new), and only in new (added);
data only_in_old; set merged; if old=1 and new=0; run;
data only_in_new; set merged; if old=0 and new=1; run;

proc print data=merged;   title "Merged: old vs new"; run;
proc print data=only_in_old; title "Records only in OLD"; run;
proc print data=only_in_new; title "Records only in NEW"; run;
