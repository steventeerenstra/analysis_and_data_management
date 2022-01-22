** a very safe way of importing excel data is;
* saving it to a csv file and fully specifying how to read it with a data step statement;
* this requires to name the variables and their format in the dataset;
* see https://sasexamplecode.com/3-ways-to-import-a-csv-file-into-sas-examples/#sas-datastep-infile;
** if you read all in as character variables then you can do a lot of processing;
** e.g. recode missing value such as "NA" or "NaN" into . or .a;
** making character values to numeric or changing decimal sign, e.g. "24,345" to 24.345;

**** EXAMPLE with macros *********************************************;
 
* macro to change decimal sign, make numeric and keep the same name;
%macro char2num(var=,missinglist=(.));
&var._c=&var; *keep the character version;
&var._temp=tranwrd(&var._c,",",".") ; * change decimal , into decimal point .;
if &var._temp in &missinglist then &var._temp=".a";* recode missing;
&var._n=input(&var._temp,16.10);*change to numeric;
drop &var ; * delete the variable to remove the character format; 
rename &var._n=&var;*use the old variable name again;
drop &var._temp;
%mend; 

* repeat for each variable &var in &varlist the macro &acroname(var=);
%macro repeat_macro(varlist=, macroname=);
%local var; %local i;
%do i=1 %to %sysfunc(countw(&varlist));
	%let var=%scan(&varlist,&i);
	%&macroname.(var=&var);
%end;
%mend;

* specific for this dataset;
%macro char2num_specific(var=);
	%char2num(var=&var,missinglist=%str( ("NaN") ) );
%mend; 

******* read and process .csv dataset with semicolon as separator;
data work.b;
    infile "C:\Users\st\Desktop\surfdrive\Actief\21 NIMBUS Sita Vermeulen\data\test\NIMBUS_TR_datafile_Steven_ Sita _ 24-11-2021.csv" 
	delimiter = ";"
	missover 
	dsd
	firstobs=2;
 
	informat Sample $50.;
	informat Patient_ID $50.;
	informat timpepoint $50.;
	informat IL_12p70 $50.;
	informat IL_1RA $50.;
  informat IL_2 $50.;
	
	format Sample $50.;
	format Patient_ID $50.;
	format timpepoint $50.;
	format IL_12p70 $50.;
	format IL_1RA $50.;
  format IL_2 $50.;
	
	input Sample $
	 Patient_ID $
	 timpepoint $
	 IL_12p70 $
	 IL_1RA $
   IL_2 $
   ;
run;


proc print data=b(obs=6);run;
proc contents data=b order=varnum;run;

%let cytokines=IL_12p70 IL_1RA IL_2 ;

data c; set b;
	%repeat_macro(varlist=&cytokines, macroname=char2num_specific); 
run;
