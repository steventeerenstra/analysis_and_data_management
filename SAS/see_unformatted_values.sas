*> change directory (in windows);
x ' cd C:\Users\steer\surfdrive\Actief\19 Santeon mITS SHOUT\03 Kidney (Noel Engels)\analyses'; 

* set libraries;
libname dir '.';
libname data '..\data'; 

*> **read formats ****;
options fmtsearch= (data.formats);;

*  what are unformatted values;
proc freq data=data.decision; 
tables study_phase; 
format _ALL_ ;
run ;
*compare this with formatted values;
proc freq data=data.decision; 
tables study_phase; 
;
run ;
