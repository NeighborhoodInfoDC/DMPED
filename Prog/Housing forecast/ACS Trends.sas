/**************************************************************************
 Program:  ACS Trends.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   Leah Hendey
 Created:  5/13/24
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  #80
  
 Description: Pull tract level ACS to look at changes overtime.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

 data WORK.CROSSWALK    ;
 %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile '\\sas1\dcdata\Libraries\DMPED\Raw\geocorr2018_2413505705.csv' delimiter = ',' MISSOVER DSD lrecl=32767
firstobs=3 ;
informat ucounty $5. tract $7. state $2. puma12 $5.  stab $2. cntyname $23. PUMAname $35.  
		 pop10 best32. afact best32.  AFACT2 best32. ;
format ucounty $5. tract $7. state $2. puma12 $5. stab $2.  cntyname $23.  PUMAname $35.  
		pop10 best12. afact best12. AFACT2 best12. ;
input
	ucounty $
	 tract $
	 state $
	 puma12 $
	 stab $
	cntyname $
	PUMAname $
	   pop10
	 afact
	 AFACT2;
run;
data crosswalk2;

	set crosswalk;

 length Geo2010 $11. tract6 $6.;
  tract6=compress(tract, ".");  
   Geo2010 =ucounty || Tract6;

   label 
    geo2010 = 'Full census tract ID (2010): ssccctttttt'
	puma12 = 'PUMA 12' ; 

 run;

data crosswalk3;
set crosswalk2 acs.acs_2006_10_dc_sum_tr_city (keep=city);
run;

 proc sort data=crosswalk3;
 by geo2010 city;
 run;
%let yearlist=2006_10 2010_14 2011_15 2012_16 2013_17 2014_18 2015_19 2007_11 2008_12 2009_13 ;

%macro pullyear;

	%do y=1 %to 7;

		%let year=%scan(&yearlist.,&y.," ");

	data acs_&Year.;
		set acs_r.acs_&year._dc_sum_tr_tr10 acs_r.acs_&year._dc_sum_tr_city;

		keep geo2010 city 
		numhshlds_&year. numhsgunits_&year. totpop_&year. pophisp_&year.

	popasianpinonhispbridge_&year. popblacknonhispbridge_&year. popwhitenonhispbridge_&year.
	popwithrace_&year. popotherracenonhispbridg_&year.
	popunder5years_&year. popunder18years_&year. pop35_64years_&year. pop18_34years_&year.
	

	numoccupiedhsgunits_&year. numoccupiedhsgunitsb_&year. numoccupiedhsgunitsw_&year. numoccupiedhsgunitsh_&year.
	numowneroccupiedhu_&year. numowneroccupiedhub_&year. numowneroccupiedhuw_&year. numowneroccupiedhuh_&year.;
	run;

	proc sort data=acs_&year.;
	by geo2010 city;
	run;
	%end; 


	%do y=8 %to 10;

		%let year=%scan(&yearlist.,&y.," ");

	data acs_&Year.;
		set acs.acs_&year._sum_tr_tr10 acs.acs_&year._sum_tr_city;

		numhsgunits_&year.=numvacanthsgunits_&year.+ numoccupiedhsgunits_&year.; 

	keep geo2010 city 
		numhshlds_&year. numhsgunits_&year. totpop_&year. pophisp_&year.

	popasianpinonhispbridge_&year. popblacknonhispbridge_&year. popwhitenonhispbridge_&year.
	popwithrace_&year. popotherracenonhispbridg_&year.
	popunder5years_&year. popunder18years_&year. /*pop35_64years_&year. pop18_34years_&year.*/

	numoccupiedhsgunits_&year. numowneroccupiedhsgunits_&year. 
;

	run;

	proc sort data=acs_&year.;
	by geo2010 city;
	run;
	%end;


%mend;

%pullyear;


data pop_hsd_hsg;
merge crosswalk3 acs_2006_10 acs_2007_11 acs_2008_12 acs_2009_13 acs_2010_14 acs_2011_15 acs_2012_16 acs_2013_17 acs_2014_18 acs_2015_19;
by geo2010 city;

keep geo2010 city PUMA12 afact afact2 pop10 totpop: numhshlds: numhsgunits: ;
format geo2010;

run; 

proc export data= pop_hsd_hsg
	outfile="&_dcdata_default_path.\DMPED\Prog\Housing Forecast\Pop_Hshld_Hsg_2006_10_2015_19.csv"
	dbms=csv replace;
	run;

data race;
merge crosswalk3 acs_2006_10  acs_2007_11 acs_2008_12 acs_2009_13 acs_2010_14 acs_2011_15 acs_2012_16 acs_2013_17 acs_2014_18 acs_2015_19;
by geo2010 city;

keep geo2010 city PUMA12 afact afact2 pop10popasian: popblack: popwhite: popother: popwith:;
format geo2010;

run; 

proc export data= race
	outfile="&_dcdata_default_path.\DMPED\Prog\Housing Forecast\Race_2006_10_2015_19.csv"
	dbms=csv replace;
	run;


data age;
merge crosswalk3 acs_2006_10  acs_2007_11 acs_2008_12 acs_2009_13 acs_2010_14 acs_2011_15 acs_2012_16 acs_2013_17 acs_2014_18 acs_2015_19;
by geo2010 city;

keep geo2010 city PUMA12 afact afact2 pop10 totpop: popunder: pop35: pop18:;
format geo2010;

run; 

proc export data= age
	outfile="&_dcdata_default_path.\DMPED\Prog\Housing Forecast\Age_2006_10_2015_19.csv"
	dbms=csv replace;
	run;
data owner;
merge crosswalk3  acs_2006_10  acs_2007_11 acs_2008_12 acs_2009_13 acs_2010_14 acs_2011_15 acs_2012_16 acs_2013_17 acs_2014_18 acs_2015_19;
by geo2010 city;

keep geo2010 city PUMA12 afact afact2 pop10 numoccupied: numowner: ;
format geo2010;

run; 

proc export data= owner
	outfile="&_dcdata_default_path.\DMPED\Prog\Housing Forecast\Owner_2006_10_2015_19.csv"
	dbms=csv replace;
	run;




