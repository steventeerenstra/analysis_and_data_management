/* Long-to-wide reshape with PROC TRANSPOSE, from SAS/transpose_long2wide.
   'by' determines the rows, 'id' the columns of the transposed dataset:
   the same 'by' values become one row, distinct 'id' values are spread
   across the columns. The COPY statement carries var1/var2 along, but it
   copies them only into the first transposed record, so the trailing
   'empty' records (blank _name_) are dropped afterwards.

   Mock _long: per-patient repeated measurements (measurement 1..3) of a
   value, plus two patient-level attributes (var1, var2) to carry along. */

data _long;
   input pat_id measurement value var1 var2;
   datalines;
1 1 10  100 5
1 2 12  100 5
1 3 15  100 5
2 1 20  200 7
2 2 22  200 7
2 3 19  200 7
3 1  8  300 9
3 2  9  300 9
3 3 11  300 9
;
run;

* 'by' determines the rows, 'id' the columns in the resulting transposed dataset;
proc sort data=_long; by pat_id measurement; run;
proc transpose data=_long out=_wide;
    *variables that you want to copy along;
    copy var1 var2;
by pat_id; id measurement;
var value; *the measurement value of pat_id at the given measurement;
run;

* the copy statement copies the copy variables into the first record only;
* so we remove the 'empty' records;
data _wide; set _wide;
if _name_ ne "";
run;

proc print data=_wide;
   title "Long-to-wide: one row per patient, measurements as columns";
run;
