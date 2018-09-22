/**************************************************************************
 Program:  Additional Runs for Assessment.sas
 Library:  DMPED
 Project:  Large Units
 Author:   L.Hendey
 Created:  9/22/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Use ipums data to calculate indicators for Large Units 
			   to respond to questions from Yari. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( IPUMS )
%DCData_lib( DMPED )

libname ipums2 "&_dcdata_r_path.\DMPED\Raw\ipums";

%let cvars = allhh largehh renter isschoolage isadult iskid isstudent
         issenior isdis raceW raceB raceH raceAPI raceO
		 hudincome30 hudincome50 hudincome80 hudincome120 hudincome120plus
		 dcincome30 dcincome50 dcincome80 dcincome120 dcincome120plus
		 hud_inc_unit30 hud_inc_unit50 hud_inc_unit80 hud_inc_unit120 hud_inc_unit120plus
		 not_burdened cost_burdened severe_burdened
		 before1gen before2gen after1gen
		 movedless1 moved2to10 moved10plus
		 bedrooms0 bedrooms1 bedrooms2 bedrooms3 bedrooms4 bedrooms5plus
		 units1 units2to4 units5to9 units10to19 units20plus
		 BuiltBefore1940 Built1940to1959 Built1960to1979 Built1980to1999 Built2000After
		 overcrowded overcrowdedbr overhousedbr
		 ;

%let mvars = hher_age hh_inc kid_age isadult iskid;

%macro recode_dvars (var1,var2);
	if &var1. < 100 then &var2. = 0;
	else if 100 <= &var1. < 200 then &var2. = 1;
	else if 200 <= &var1. < 300 then &var2. = 2;
	else if 300 <= &var1. < 400 then &var2. = 3;
	else if 400 <= &var1. < 500 then &var2. = 4;
	else if 500 <= &var1. < 600 then &var2. = 5;
	else if 600 <= &var1. < 700 then &var2. = 6;
	else if 700 <= &var1. < 800 then &var2. = 7;
	else if 800 <= &var1. < 900 then &var2. = 8;
	else if 900 <= &var1. < 1000 then &var2. = 9;
	else if 1000 <= &var1. < 1100 then &var2. = 10;
	else if 1100 <= &var1. < 1200 then &var2. = 11;
	else if 1200 <= &var1. < 1300 then &var2. = 12;
	else if 1300 <= &var1. < 1400 then &var2. = 13;
	else if 1400 <= &var1. < 1500 then &var2. = 14;
	else if 1500 <= &var1. < 1600 then &var2. = 15;
%mend recode_dvars;


** Calculate average ratio of gross rent to contract rent for occupied units **;
data Ratio;

  set Ipums.Acs_2012_16_dc 
    (keep=rent rentgrs pernum gq ownershpd
     where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )));
     
  Ratio_rentgrs_rent_2012_16 = rentgrs / rent;
  
run;

proc summary data=Ratio;
  var Ratio_rentgrs_rent_2012_16 rentgrs rent;
  output out = Ratio_rentgrs_2012_16 mean = ;
run;

proc sql noprint;
	select Ratio_rentgrs_rent_2012_16
	into :Ratio_rentgrs_rent_2012_16 separated by " "
	from Ratio_rentgrs_2012_16;
quit;

%put &Ratio_rentgrs_rent_2012_16;

data Ratio2000;

  set Ipums.Ipums_2000_dc 
    (keep=rent rentgrs pernum gq ownershd
     where=(pernum=1 and gq in (1,2) and ownershd in ( 22 )));
     
  Ratio_rentgrs_rent_2000 = rentgrs / rent;
  
run;

proc summary data=Ratio2000;
  var Ratio_rentgrs_rent_2000 rentgrs rent;
  output out = Ratio_rentgrs_2000 mean = ;
run;

proc sql noprint;
	select Ratio_rentgrs_rent_2000
	into :Ratio_rentgrs_rent_2000 separated by " "
	from Ratio_rentgrs_2000;
quit;

%put &Ratio_rentgrs_rent_2000;


** Add extra vars needed for 2000 data **;
proc sort data = ipums.Ipums_2000_dc out = Ipums_2000_dc; by serial pernum; run;
proc sort data = ipums2.Ipums_2000_dc_extra out = Ipums_2000_dc_extra; by serial pernum; run;

data Ipums_2000_dc_new;
	merge Ipums_2000_dc 
		  Ipums_2000_dc_extra (keep = serial pernum diffmob diffcare owncost);
	by serial pernum;
run;


%ipums_lgunit (all,ACS,person);

/*Yari Questions in Part 2*/
	data foryari;
		set pretables_collapse;

	incomeY=.;
	if hh_inc ne . then do;
	if hh_inc < 20000 then incomeY=1;
	if 20000 <= hh_inc < 30000 then incomeY=2;
	if 30000 <= hh_inc < 40000 then incomeY=3; 
	if 40000 <= hh_inc < 60000 then incomeY=4;
	if hh_inc >= 60000 then incomeY=5; 
	end; 

	run; 
	proc freq data=foryari;
	where largehh=1 and renter = 1;
	tables incomeY;
	weight whhwt;
	run; 

/* Yari questions in Part 4*/
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables cost_burdened*dcincome30;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables cost_burdened*dcincome50;
	weight whhwt;
	run;
	proc sort data=pretables_collapse;
	by ward2012;
	proc freq data=pretables_collapse;
	by ward2012;
	where largehh=1 and renter = 1 ;
	tables cost_burdened*dcincome30;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	by ward2012;
	where largehh=1 and renter = 1 ;
	tables cost_burdened*dcincome50;
	weight whhwt;
	run;

	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables severe_burdened*dcincome30;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables severe_burdened*dcincome50;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables overcrowded*dcincome30;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables overcrowded*dcincome50;
	weight whhwt;
	run;
	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables overcrowded*dcincome80;
	weight whhwt;
	run;

	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables overcrowded*dcincome120;
	weight whhwt;
	run;

	proc freq data=pretables_collapse;
	where largehh=1 and renter = 1;
	tables overcrowded*dcincome120plus;
	weight whhwt;
	run;

