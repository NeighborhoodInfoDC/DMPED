/**************************************************************************
 Program:  LgUnit - Ipums Table 2B.sas
 Library:  IPUMS
 Project:  NeighborhoodInfo DC
 Author:   Yipeng and Rob
 Created:  06/14/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Use ipums data to calculate indicators for Large Units 
			   table 2B. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( IPUMS )
%DCData_lib( DMPED )

%let cvars = allhh largehh isschoolage isadult iskid isstudent
         issenior isdis raceW raceB raceH raceAPI raceO
		 hudincome30 hudincome50 hudincome80 hudincome120 hudincome120plus
		 before1gen before2gen after1gen
		 movedless1 moved2to10 moved10plus
		 bedrooms0 bedrooms1 bedrooms2 bedrooms3 bedrooms4 bedrooms5plus
		 units1 units2to4 units5to9 units10to19 units20plus
		 BuiltBefore1940 Built1940to1959 Built1960to1979 Built1980to1999 Built2000After
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


** Macro for remaining data processing **;
%macro ipums_lgunit (tenure,yrs,largedef);

%let ten = %upcase( &tenure. );
%let yrs = %upcase( &yrs. );
%let largedef = %upcase( &largedef. );

%if &yrs. = ACS %then %do;
	%let indata = Acs_2012_16_dc;
	%let vacdata = acs_2012_16_vacant_dc;
%end;

%if &yrs. = 2000 %then %do;
	%let indata = Ipums_2000_dc;
	%let vacdata = Ipums_2000_vacant_dc;
%end;

data vacdata;
	set ipums.&vacdata. ;

	%if &ten. = OWN %then %do;
		if vacancy in (2) then vac = 1;
			else if valueh > 0 then vac = 1;
		if vac = 1;
	%end;

	%else %if &ten. = RENT %then %do;
		if vacancy in (1) then vac = 1;
			else if rent > 0 then vac = 1;
		if vac = 1;
	%end;
run;

data hhwts;
	set ipums.&indata. (where=(pernum=1 and gq in (1,2)))  
		vacdata ;
	keep serial puma hhwt;

	%if &yrs. = 2000 %then %do;

	if ownershd in (12,13) then ownershp = 1;
	else if ownershd in (21,22) then ownershp = 2;

	%end;


	%if &ten. = OWN %then %do;
		if ownershp = 1;
	%end;

	%else %if &ten. = RENT %then %do;
		if ownershp = 2;
	%end;
run;

proc sort data = hhwts; by serial; run;



data pretables;
	set Ipums.&indata.
		vacdata;

	 /* Flag large units*/

	%if &largedef. = PERSON %then %do;
	if numprec >= 4 then largehh = 1;
		else largehh = 0;
	%end;

	%else %if &largedef. = BEDROOMS %then %do;
	if bedrooms >= 4 then largehh = 1;
		else largehh = 0;
	%end;


	%if &yrs. = 2000 %then %do;
		
	%recode_dvars (raced,race);
	%recode_dvars (hispand,hispan);
	%recode_dvars (related,relate);

	if ownershd in (12,13) then ownershp = 1;
	else if ownershd in (21,22) then ownershp = 2;

	/* Recode builtyr to match builtyr2 from ACS data */

	if builtyr in (1,2) then builtyr2 = 8; /* 1995-1999 */
		else if builtyr in (3) then builtyr2 = 7; /* 1990-1994 */
		else if builtyr in (4) then builtyr2 = 6; /* 1980-1989 */
		else if builtyr in (5) then builtyr2 = 5; /* 1970-1979 */
		else if builtyr in (6) then builtyr2 = 4; /* 1960-1969 */
		else if builtyr in (7) then builtyr2 = 3; /* 1950-1959 */
		else if builtyr in (8) then builtyr2 = 2; /* 1940-1949 */
		else if builtyr in (9) then builtyr2 = 1; /* 1939 or earlier */

	%Dollar_convert(hhincome,hhincome_i,1999,2016);

	/* Re-create hud_inc from 2000 data */

	if (numprec = 1 and hhincome_i <= 16950) or (numprec=2 and hhincome_i <= 19350) or  (numprec=3 and hhincome_i <= 21750)
       or (numprec=4 and hhincome_i <= 24200) or (numprec=5 and hhincome_i <= 26100) or (numprec=6 and hhincome_i <= 28050) 
       or (numprec=7 and hhincome_i <= 30000) or (numprec=8 and hhincome_i <= 31900) then hud_inc=1;                                                                               

	else if (numprec = 1 and hhincome_i <= 28200) or (numprec=2 and hhincome_i <= 32250  ) or  (numprec=3 and hhincome_i <= 36250)
       or (numprec=4 and hhincome_i <= 40300) or (numprec=5 and hhincome_i <= 43500) or (numprec=6 and hhincome_i <= 46750 ) 
       or (numprec=7 and hhincome_i <= 49950) or (numprec=8 and hhincome_i <= 53200) then hud_inc=2;                                                                               
	    
 	else if (numprec = 1 and hhincome_i <= 35150) or (numprec=2 and hhincome_i <= 40150 ) or  (numprec=3 and hhincome_i <= 45200)
       or (numprec=4 and hhincome_i <= 50200) or (numprec=5 and hhincome_i <= 54200) or (numprec=6 and hhincome_i <= 58250) 
       or (numprec=7 and hhincome_i <= 62250) or (numprec=8 and hhincome_i <= 66250) then hud_inc=3;    

 	else if (numprec = 1 and hhincome_i <= 53960) or (numprec=2 and hhincome_i <= 61660 ) or  (numprec=3 and hhincome_i <= 69420)
       or (numprec=4 and hhincome_i <= 77080) or (numprec=5 and hhincome_i <= 83240) or (numprec=6 and hhincome_i <= 89460) 
       or (numprec=7 and hhincome_i <= 95580) or (numprec=8 and hhincome_i <= 101760) then hud_inc=4;    

	else if (numprec = 1 and hhincome_i > 53960) or (numprec=2 and hhincome_i > 61660 ) or  (numprec=3 and hhincome_i > 69420)
       or (numprec=4 and hhincome_i > 77080) or (numprec=5 and hhincome_i > 83240) or (numprec=6 and hhincome_i > 89460) 
       or (numprec=7 and hhincome_i > 95580) or (numprec=8 and hhincome_i > 101760) then hud_inc=5;

	%end;

	%else %if &yrs. = ACS %then %do;

	hhincome_i = hhincome;

	%end;


	%if &ten. = OWN %then %do;
		if ownershp = 1;
	%end;

	%else %if &ten. = RENT %then %do;
		if ownershp = 2;
	%end;

	/* HUD income categories */

	if hud_inc = 1 then hudincome30 =1;
		else hudincome30 =0;

	if hud_inc = 2 then hudincome50 = 1;
		else hudincome50 = 0;

	if hud_inc = 3 then hudincome80 = 1;
		else hudincome80 = 0;

	if hud_inc= 4 then hudincome120= 1;
		else hudincome120=0;

	if hud_inc=5 then hudincome120plus=1;
		else hudincome120plus=0;

	 /*Keep only HHs*/
	if gq in (1,2);

	/* All households */
	allhh = 1;

	/* Householder age */
	if pernum = 1 then hher_age = age;

	/* Household income */
	if pernum = 1 then hh_inc = hhincome_i;

	/* Adult*/
	if age>=18 then isadult = 1;
	    else isadult = 0;

	numadults = isadult;

	/* Student */
	if school = 2 then isstudent = 1;
		else isstudent = 0;

	numstudents = isstudent;

	/*adult but not senior*/
	if 18<=age<65 then nonsenioradult = 1;
        else nonsenioradult = 0;
   
	/*seniors*/
    if age>=65 then issenior = 1;
	    else issenior = 0;

    /*schoolage children*/
    if 6<age<18 then isschoolage = 1;
	    else isschoolage = 0;

	/*all kids */
	if age <18 then iskid = 1;
		else iskid =0;

	if iskid = 1 then kid_age = age;

	numkids = iskid;

	/*Disability*/
	isdis= 0;
    if diffmob = 2 or diffcare = 2 then isdis = 1;

	array vars {*} diffeye diffhear diffphys diffrem;
	array f_vars {*} f_diffeye f_diffhear f_diffphys f_diffrem;

	do i = 1 to 4;
           if vars{i} = 2 then f_vars{i} = 1;
           else f_vars{i} = 0;
    end;

    if sum(f_diffhear, f_diffeye, f_diffphys, F_diffrem)>=2 then isdis = 1;

	/*3 generation household*/

	/* Child or stepchild or foster child or any other relative under 18*/
	if relate in (3,4) then before1gen = 1;
		else if related in (1242) then before1gen = 1;
		else if relate in (10) and age < 18 then before1gen = 1;
		else before1gen = 0;

	/* Grandchild */
	if relate in (9) then before2gen = 1;
		else before2gen = 0;

	/* Parent or stepparent*/
	if relate in (5,6) then after1gen = 1;
		else after1gen = 0;

	/* Race variables */
	if pernum = 1 then do;
		if hispan > 0 then raceH=1;
			else raceH=0;
		if race=1 and hispan=0 then raceW=1;
			else raceW=0;
		if race=2 and hispan=0 then raceB=1;
			else raceB=0;
		if race in (4,5,6) and hispan=0 then raceAPI=1;
			else raceAPI=0;
		if race in (3,7,8,9) and hispan=0 then raceO=1;
			else raceO=0;

	end;

  /* Nonrelatives living together */

     if related = 1115 or related = 1241 or related = 1260 then nonrelative = 1;
	     else nonrelative = 0;

	/* Moved-in */
	%if &yrs. = 2000 %then %do;

	if movedin in (1) then movedless1 = 1;
		else movedless1 = 0;

	if movedin in (2,3,4,5) then moved2to10 = 1;
		else moved2to10 = 0;

	if movedin in (6,7,8) then moved10plus = 1;
		else moved10plus = 0;

	%end;

	%else %if &yrs. = ACS %then %do;

	if movedin in (1) then movedless1 = 1;
		else movedless1 = 0;

	if movedin in (2,3,4) then moved2to10 = 1;
		else moved2to10 = 0;

	if movedin in (5,6,7,8) then moved10plus = 1;
		else moved10plus = 0;

	%end; 

	/* Bedroom size */
	if bedrooms = 1 then bedrooms0 = 1;
		else bedrooms0 = 0;

	if bedrooms = 2 then bedrooms1 = 1;
		else bedrooms1 = 0;

	if bedrooms = 3 then bedrooms2 = 1;
		else bedrooms2 = 0;

	if bedrooms = 4 then bedrooms3 = 1;
		else bedrooms3 = 0;

	if bedrooms = 5 then bedrooms4 = 1;
		else bedrooms4 = 0;

	if bedrooms > 5 then bedrooms5plus = 1;
		else bedrooms5plus = 0;

	/* Units in structure */
	if unitsstr in (3,4) then units1 = 1; 
		else units1 = 0;

	if unitsstr in (5,6) then units2to4 = 1;
		else units2to4 = 0;

	if unitsstr in (7) then units5to9 = 1;
		else units5to9 = 0;

	if unitsstr in (8) then units10to19 = 1;
		else units10to19 = 0;

	if unitsstr in (9,10) then units20plus = 1;
		else units20plus = 0;

	/* Year built */
	if builtyr2 = 1 then BuiltBefore1940 = 1; 
		else BuiltBefore1940 = 0;

	if builtyr2 in (2,3) then Built1940to1959 = 1;
		else Built1940to1959 = 0;

	if builtyr2 in (4,5) then Built1960to1979 = 1;
		else Built1960to1979 = 0;

	if builtyr2 in (6,7) then Built1980to1999 = 1;
		else Built1980to1999 = 0;

	if builtyr2 >= 9 then Built2000After = 1;
		else Built2000After = 0;

/***** FROM HOUSING_NEEDS_BASELINE ****/
	 if ownershp = 2 or vacancy = 1 then do;
    
    ****** Rental units ******;
    
    Tenure = 1;
    
    if vacancy=1 then do;
	** Impute gross rent for vacant units **;
		%if &yrs. = 2000 %then %do;
				rentgrs = rent*&RATIO_RENTGRS_RENT_2000;
		%end;

		%else %if &yrs. = ACS %then %do;
	     		rentgrs = rent*&RATIO_RENTGRS_RENT_2012_16;
		%END;
	  		Max_income = ( rentgrs * 12 ) / 0.30;
    end;
    else Max_income = ( rentgrs * 12 ) / 0.30;
    
  end;
  else if ownershp = 1 or vacancy = 2 then do;

    ****** Owner units ******;
    
    Tenure = 2;

    **** 
    Calculate max income for first-time homebuyers. 
    Using 3.69% as the effective mortgage rate for DC in 2016, 7.07% for 2000
	  http://www.fhfa.gov/DataTools/Downloads/Documents/Historical-Summary-Tables/Table15_2015_by_State_and_Year.xls
    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
    ******; 
    
    loan = .9 * valueh;
	%if &yrs. = 2000 %then %do;
    month_mortgage= (7.07 / 12) / 100; 
	%end; 
	%else %if &yrs. = ACS %then %do;
    month_mortgage= (3.69 / 12) / 100; 
	%end; 
    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

    ****
    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
    ******;
    
    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

    ** Calculate annual_income necessary to finance house **;
    Max_income = 12 * total_month / .28;

  end;
  
  %if &yrs. = 2000 %then %do;
	%Dollar_convert(Max_income,max_income_i,1999,2016);
  %end;
	%else %if &yrs. = ACS %then %do;
	max_income_i=max_income;
  %end;

  ** Determine maximum HH size based on bedrooms **;
  
  select ( bedrooms );
    when ( 1 )       /** Efficiency **/
      Max_hh_size = 1;
    when ( 2 )       /** 1 bedroom **/
      Max_hh_size = 2;
    when ( 3 )       /** 2 bedroom **/
      Max_hh_size = 3;
    when ( 4 )       /** 3 bedroom **/
      Max_hh_size = 4;
    when ( 5 )       /** 4 bedroom **/
      Max_hh_size = 6;  /*updated this value from 5 from PTs original code*/
    when ( 6, 7, 8, 9, 10, 11, 12, 13, 14 )       /** 5+ bedroom **/
      Max_hh_size = 7;
    otherwise
      do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
 
 if max_income_i in ( 9999999, .n ) then hud_inc_unit = .n;
  else do;

    select ( max_hh_size );
      when ( 1 )
        do;
          if max_income_i <= 22850 then hud_inc_unit = 1;
          else if 22850 < max_income_i <= 38050 then hud_inc_unit = 2;
          else if 38050 < max_income_i <= 49150 then hud_inc_unit = 3;
          else if 49150 < max_income_i <= 91320 then hud_inc_unit = 4;
          else if 91320 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 2 )
        do;
          if max_income_i <= 26100 then hud_inc_unit = 1;
          else if 26100 < max_income_i <= 43450 then hud_inc_unit = 2;
          else if 43450 < max_income_i <= 56150 then hud_inc_unit = 3;
          else if 56150 < max_income_i <= 104280 then hud_inc_unit = 4;
          else if 104280 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 3 )
        do;
          if max_income_i <= 29350 then hud_inc_unit = 1;
          else if 29350 < max_income_i <= 48900 then hud_inc_unit = 2;
          else if 48900 < max_income_i <= 63150 then hud_inc_unit = 3;
          else if 63150 < max_income_i <= 117360 then hud_inc_unit = 4;
          else if 117360 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 4 )
        do;
          if max_income_i <= 32600 then hud_inc_unit = 1;
          else if 32600 < max_income_i <= 54300 then hud_inc_unit = 2;
          else if 54300 < max_income_i <= 70150 then hud_inc_unit = 3;
          else if 70150 < max_income_i <= 130320 then hud_inc_unit = 4;
          else if 130320 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 5 )
        do;
          if max_income_i <= 35250 then hud_inc_unit = 1;
          else if 35250 < max_income_i <= 58650 then hud_inc_unit = 2;
          else if 58650 < max_income_i <= 75800 then hud_inc_unit = 3;
          else if 75800 < max_income_i <= 140760 then hud_inc_unit = 4;
          else if 140760 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 6 )
        do;
          if max_income_i <= 37850 then hud_inc_unit = 1;
          else if 37850 < max_income_i <= 63000 then hud_inc_unit = 2;
          else if 63000 < max_income_i <= 81400 then hud_inc_unit = 3;
          else if 81400 < max_income_i <= 151200 then hud_inc_unit = 4;
          else if 151200 < max_income_i then hud_inc_unit = 5;
        end;
      when ( 7 )
        do;
          if max_income_i <= 40450 then hud_inc_unit = 1;
          else if 40450 < max_income_i <= 67350 then hud_inc_unit = 2;
          else if 67350 < max_income_i <= 87000 then hud_inc_unit = 3;
          else if 87000 < max_income_i <= 161640 then hud_inc_unit = 4;
          else if 161640 < max_income_i then hud_inc_unit = 5;
        end;
      otherwise
        do;
          if max_income_i <= 43050 then hud_inc_unit = 1;
          else if 43050 < max_income_i <= 71700 then hud_inc_unit = 2;
          else if 71700 < max_income_i <= 92600 then hud_inc_unit = 3;
          else if 92600 < max_income_i <= 172080 then hud_inc_unit = 4;
          else if 172080 < max_income_i then hud_inc_unit = 5;
        end;
    end;

  end;

   
  
	max_hh_size2=max_hh_size;
	if bedrooms = 4 then max_hh_size2=5; *three bedroom could hold up to 5; 
	ratio_OccToCap=numprec/max_hh_size2;
	
	if max_hh_size2 ne . then do; 
	if ratio_OccToCap > 1 then underhoused=1; else underhoused=0;
	if ratio_occtocap = 1 then righthoused=1; else righthoused=0;
	if ratio_occtocap < 1 then overhoused=1; else overhoused=0; 
	end; 
	
	 label 
	 Hud_inc_unit = 'HUD income category for unit'
	 ratio_OccToCap='Ratio of Occupants to Capacity'
	 underhoused='Unit has more occupants than its capacity'
	 righthoused='Unit has the right number of occupants for capacity'
	 overhoused='Unit has few occupants than its capacity'
;

  
run;


proc summary data = pretables;
	class serial;
	var &cvars. nonrelative numkids numadults numstudents;
	output out= pretables_s sum=;
run;


proc sort data = pretables_s; by serial; run;


proc summary data = pretables;
	class serial;
	var &mvars.;
	output out= pretables_m median=;
run;

proc sort data = pretables_m; by serial; run;


data pretables_collapse;
	merge pretables_s  pretables_m hhwts;
	by serial;
	if serial ^= .;

	%macro onezero();
		%let varlist = &cvars.;
			%let i = 1;
				%do %until (%scan(&varlist,&i,' ')=);
					%let var=%scan(&varlist,&i,' ');
			if &var. >= 1 then &var. = 1;
		%let i=%eval(&i + 1);
				%end;
			%let i = 1;
				%do %until (%scan(&varlist,&i,' ')=);
					%let var=%scan(&varlist,&i,' ');
		%let i=%eval(&i + 1);
				%end;
	%mend onezero;
	%onezero;

	/* Flag 3+ generation households */
	numgens = sum(of before1gen before2gen after1gen);
	if numgens >=2 then multigen = 1;
		else multigen = 0;

	/* Flag "group houses" */
	if nonrelative >= 3 then grouphouse = 1;
		else grouphouse = 0;

	/* Flag "student house" */
	if grouphouse = 1 and numstudents >= 2 then studenthouse = 1;
		else studenthouse = 0;


run;


/* Add vacancy data */
data pretables_withvac;
	set pretables_collapse 
		vacdata ;
	if vacancy ^= . then vacant = 1;
		else vacant = 0;

	allhh_withvac = 1;



run;


proc summary data = pretables_withvac;
	class puma largehh;
	var &cvars. multigen grouphouse studenthouse vacant allhh_withvac;
	weight hhwt;
	output out = table2b_pre sum=;
run;

data table2b_pcts;
	set table2b_pre;

	pct_raceW = raceW / allhh;
	pct_raceB = raceB / allhh;
	pct_raceH = raceH / allhh;
	pct_raceAPI = raceAPI / allhh;
	pct_raceO = raceO / allhh;

	pct_hudincome30 = hudincome30 / allhh;
	pct_hudincome50 = hudincome50 / allhh;
	pct_hudincome80 = hudincome80 / allhh;
	pct_hudincome120= hudincome120 / allhh;
	pct_hudincome120plus= hudincome120plus / allhh;

	pct_issenior = issenior / allhh; 
	pct_isdis = isdis / allhh;
	pct_multigen = multigen / allhh;
	pct_grouphouse = grouphouse / allhh;
	pct_studenthouse = studenthouse / allhh;

	pct_movedless1 = movedless1 / allhh;
	pct_moved2to10 = moved2to10 / allhh;
	pct_moved10plus = moved10plus / allhh;

	pct_bedrooms0 = bedrooms0 / allhh; 
	pct_bedrooms1 = bedrooms1 / allhh; 
	pct_bedrooms2 = bedrooms2 / allhh; 
	pct_bedrooms3 = bedrooms3 / allhh; 
	pct_bedrooms4 = bedrooms4 / allhh; 
	pct_bedrooms5plus = bedrooms5plus / allhh; 

	pct_units1 = units1 / allhh; 
	pct_units2to4 = units2to4 / allhh;
	pct_units5to9 = units5to9 / allhh;
	pct_units10to19 = units10to19 / allhh;
	pct_units20plus = units20plus / allhh;

	pct_BuiltBefore1940 = BuiltBefore1940 / allhh;
	pct_Built1940to1959 = Built1940to1959 / allhh;
	pct_Built1960to1979 = Built1960to1979 / allhh;
	pct_Built1980to1999 = Built1980to1999 / allhh;
	pct_Built2000After = Built2000After / allhh;

	pct_vacant = vacant / allhh_withvac;

run;


proc summary data = pretables_collapse;
	class puma largehh;
	var &mvars.;
	weight hhwt;
	output out = table2b_m median=;
run;


proc summary data = pretables_collapse;
	class puma largehh;
	var numkids numadults;
	weight hhwt;
	output out = table2b_n median=;
run;


data table2b_all;
	merge table2b_pcts table2b_m table2b_n;
	if _type_ in (1,3);
	if puma = . then puma = 100;
run;


/* Transpose data to fit final Table shell */

proc transpose data = table2b_all out = table2b_csv_all;

	var 
	/* HH count */
	allhh

	/* Race */
	pct_raceW pct_raceB pct_raceAPI pct_raceO pct_raceH

	/* Age */
	hher_age

	/* Income */
	hh_inc pct_hudincome30 pct_hudincome50 pct_hudincome80 pct_hudincome120 pct_hudincome120plus

	/* HH Structure */
	pct_issenior pct_isdis pct_multigen pct_grouphouse pct_studenthouse numadults numkids 

	/* Migration */
	pct_movedless1 pct_moved2to10 pct_moved10plus

	/* Bedrooms */
	pct_bedrooms0 pct_bedrooms1 pct_bedrooms2 pct_bedrooms3 pct_bedrooms4 pct_bedrooms5plus

	/* Units in structure */
	pct_units1 pct_units2to4 pct_units5to9 pct_units10to19 pct_units20plus

	/* Year built */
	pct_BuiltBefore1940 pct_Built1940to1959 pct_Built1960to1979 pct_Built1980to1999 pct_Built2000After

	;

	id largehh puma;

run;


proc export data = table2b_csv_all
	outfile = "&_dcdata_default_path.\DMPED\Prog\table2b_csv_&yrs._&tenure._&largedef..csv"
	dbms = csv replace;
run;


%mend ipums_lgunit;


%ipums_lgunit (all,2000,person);


%macro output_lg (define);
	%ipums_lgunit (all,2000,&define.);
	%ipums_lgunit (own,2000,&define.);
	%ipums_lgunit (rent,2000,&define.);

	%ipums_lgunit (all,ACS,&define.);
	%ipums_lgunit (own,ACS,&define.);
	%ipums_lgunit (rent,ACS,&define.);

%mend output_lg;
%output_lg (person);
%output_lg (bedrooms);
