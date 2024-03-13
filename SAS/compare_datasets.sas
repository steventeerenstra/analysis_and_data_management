/*  Toy example how it works
*test data;
* if ID is the identifyer iplying the other variables are the same: then use by ID;
* otherwise use by _all_ (to merge on all variable values being equal;
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
* merge of all record, only one record if identical in both;
data merged;
merge old(in=in_old) b(in=in_new);
by id;
old=in_old; 
new=in_new;
run;

proc print;run;
 end Toy example*/


%let folder=C:\Users\st\...; * folder where dataset is;
%let keep_vars=%str(studysubjectid entity meetperiode interventie type_entity Drug1_prescription_date); * variables to check;
* large original database, in this case SPSS;
PROC IMPORT OUT= WORK.OLD 
            DATAFILE= "&folder\original.sav" 
            DBMS=SPSS REPLACE;

RUN;

* database matched to the user analytics;
PROC IMPORT OUT= WORK.new 
            DATAFILE= "&folder\updated.sav" 
            DBMS=SPSS REPLACE;

RUN;

***;
proc sort data = old;
by StudySubjectID;
run;
proc sort data = new;
by StudySubjectID;
run;

proc contents data=old;run;

* below is only needed as SPSS has a numeric format with too wide width;
* indication_2_other has f40 and maximally f32 is allowed;
* see https://communities.sas.com/t5/SAS-Programming/Error-Width-specified-for-format-F-is-invalid/m-p/652468#M195885; 
data old; set old;format indication_2_other f32.;run;
data new; set new;format indication_2_other f32.;run;


* merge of all records, only one record if identical in both;
data merged;
merge old(in=in_old keep=&keep_vars) 
      new(in=in_new keep=&keep_vars);
by StudySubjectID;
old=in_old; 
new=in_new;
run;

proc sort data=merged;by drug1_prescription_date;run;

data not_in_new; set merged;if old=1 and new=0;run;

*records that are not in new;
ods rtf style=minimal file="non_in_new.doc";
proc print data=not_in_new;run;
ods rtf close;

