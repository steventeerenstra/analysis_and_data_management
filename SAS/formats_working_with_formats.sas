***********************************************************************;
***** EXAMPLE 1: making the formats while reading an SPSS database ****;
***********************************************************************;
libname dir ".";

* import .sav file and save to sas file;
PROC IMPORT OUT= dir.effampart 
            DATAFILE= "C:\Users\st\surfdrive\Actief\22 SW EFFAMPART (Paul Rood)\analyse final\data\20230112 EFFAMPART final dataset_ST.sav" 
            DBMS=SPSS REPLACE;
RUN;



* save the accompanying formats;
* see https://communities.sas.com/t5/General-SAS-Programming/Saving-work-formats-to-a-permanent-location/td-p/321848;
proc catalog catalog = work.formats;
  copy out = dir.formats;
  run;
quit;



/*** code to read in the sas7bdat and the formats is as follows***;
********* READ 	DATA *******;
options pagesize=60;
libname data ".\data"; * or use ..\data as relative path;
* get formats;
options fmtsearch= (data.formats);
* show variables in dataset;
proc contents data=data.effampart;run;
**/

********************************************************************************;
***** EXAMPLE 2: reading dates from file and making a format out of it *********;
********************************************************************************;
/*** macro to make date formats to lookup period nummer from datasets of the form;
datum       period_c  period hypen text;
5-10-2020	Periode 1 - Introductie
6-10-2020	Periode 1 - Start
2-11-2020	Periode 1 - Stop
*/ 
%macro mk_format(ds=);
data &ds; set &ds; drop period_c hypen;
if index(text,"Intro") then do; text="Start";intro=1;end;
else intro=0;
run;

data _test0; set &ds; by period;retain start_n;
* put the first date of a period into variable start as a character;
* and the last date of a period into variable end as a character;
* make both numeric versions (to print a check) and character versions (to make the format);
if first.period then do; start_n=datum; end; 
if last.period then do; end_n=datum; 
	start=put(start_n,8.);end=put(end_n,8.);; * 8. is character of 8 places;
    output; end; 
run;

data _test1; set _test0 end=last_record;
output; *output all records;
*add a last record for the long term period measurements;
if last_record then do; 
	start_n=end+1; end_n=.; start=put(start_n,8.);end="High";period=5;
	output;end;
run;


* format name is derived from the dataset variable label;
data _test2; set _test1;
fmtname="&ds";label=put(period,2.);
keep start end label fmtname;
run;

proc format cntlin=_test2;run;

* make a format to derive the introduction dates;
data _intro_0; set &ds; 
if intro=1;
start_n=datum; format start_n ddmmyy10.;
fmtname="&ds._intro";label="1";start=put(start_n,8.);
run;
title6 "check format: &ds._intro";
proc print data=_intro_0 noobs;var start start_n label;run;

data _intro; set _intro_0; keep start label fmtname;run;
proc format cntlin=_intro;run;

*clean up;
title6 " ";
proc delete data= _intro_0 _intro _test0-_test2;run;
%mend mk_format;

%let ds=afd_1M_onc;
data &ds;
input datum ddmmyy10. period_c $ period hypen $ text $30.;
datalines;
17-5-2021   Periode 1 - Introductie
13-6-2021   Periode 1 - Stop
14-6-2021	Periode 2 - Start
17-7-2021	Periode 2 - Stop
18-7-2021	Periode 3 - Start
29-9-2021	Periode 3 - Stop
30-9-2021	Periode 4 - Start
15-11-2021	Periode 4 - Stop
;
run;
%mk_format(ds=&ds);


**************************************************************************************;
**** EXAMPLE .....;
**************************************************************************************;
