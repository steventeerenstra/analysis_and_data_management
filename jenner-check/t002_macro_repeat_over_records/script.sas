/* %read_data_from_periods from SAS/%repeat_over_records_dataset.
   Walks a dataset one record at a time: it opens the dataset with the
   SAS function interface (OPEN/ATTRN nlobs) to count records, then for
   each record subsets that single observation, lifts its values into
   macro variables via CALL SYMPUTX (no leading/trailing blanks), and
   runs an action per record. Here the action simply %PUTs the values. */

* example dataset to repeat for each record;
data periods;
year=2025;
input period_start $ period_stop $;*character variables as the 0 in 0430 etc needs to be kept;
datalines;
0101 0430
0501 0531
;
run;

%macro read_data_from_periods(ds_periods=);
%local i n_periods dsid ds_close;

* count number of periods;
%let dsid = %sysfunc(open(&ds_periods));
%let n_periods = %sysfunc(attrn(&dsid, nlobs));
%let ds_close = %sysfunc(close(&dsid));

%put NOTE: number of periods = &n_periods;

* repeat for each record in the dataset;
%do i=1 %to &n_periods;
data _null_;
	set &ds_periods(firstobs=&i obs=&i); *subset the &i record only;
	call symputx('year', year); *use symputx to get no leading/trailing spaces;
	call symputx('period_start',period_start);
	call symputx('period_stop',period_stop);
run;

* perform an action for the macro variables (here: output the values);
%put RECORD &i: &year &period_start &period_stop;

%end;

%mend read_data_from_periods;

%read_data_from_periods(ds_periods=periods);

proc print data=periods;
   title "Periods dataset iterated record by record";
run;
