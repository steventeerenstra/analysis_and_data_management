
**** EXAMPLE 1 ******************;
*** sometimes an SPSS date is with or without the time part (i.e. hours, minutes, seconds);
*** we can check for a dates in format like 21-9-2021 as follows; 
data long0; set long0; 
	if vformat(f1)="DATE9." then date=f1; * otherwise adapt format if needed;
	else date =datepart(f1);  *if the date format is a datetime format: change it to date9 format;
run;
