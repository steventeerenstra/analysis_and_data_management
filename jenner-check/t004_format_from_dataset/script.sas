/* Build a numeric format FROM a dataset, with an "other" catch-all,
   from EXAMPLE 3 in SAS/formats_working_with_formats.sas.
   A continuous month counter <cmonth> maps to a "year/month" label;
   values not enumerated map to the label 'other' via the cntlin HLO
   row (hlo='o' marks the OTHER bucket). */

data format_tbl;
do cmonth=1 to 100;
month=mod(cmonth-1,12)+1; * the month in a year as number;
year=2019+floor((cmonth-1)/12);
description=catx("/",year,month);
output;
end;
run;

data work.outfmt(keep=start label fmtname hlo);
set work.Format_Tbl(rename=(cmonth=start description=label)) end=last;
fmtname='outfmt';type='n';
output;
if last then do;start=' ';hlo='o';label='other';output;end;
run;

proc format library=work cntlin=work.outfmt;
run;

/* apply the format: in-range values get year/month, out-of-range -> 'other' */
data demo;
   input cmonth;
   datalines;
1
12
13
100
101
500
;
run;

proc print data=demo;
   format cmonth outfmt.;
   title "cmonth through outfmt. (101 and 500 fall to 'other')";
run;
