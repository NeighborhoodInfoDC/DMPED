/**************************************************************************
 Program:  LgUnit - Ipums Table 2B.sas
 Library:  IPUMS
 Project:  NeighborhoodInfo DC
 Author:   Yipeng
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


data hhwts;
	set ipums.acs_2012_16_dc;
	if pernum = 1;
	if gq in (1,2);
	keep serial hhwt;
run;

proc sort data = hhwts; by serial; run;

%let cvars = allhh largeunit isschoolage isadult iskid
         issenior isdis raceW raceB raceH raceAPI raceO
		 hudincome30 hudincome50 hudincome80 
		 before1gen before2gen after1gen
		 ;

%let mvars = hher_age kid_age isadult iskid;

data pretables;
	set ipums.acs_2012_16_dc;

	 /*only households*/
	if gq in (1,2);

	/* All households */
	allhh = 1;

	/*householder age */
	if pernum = 1 then hher_age = age;

    /*large unit*/
	if numprec >= 4 then largeunit = 1;
		else largeunit = 0;

	/*adult*/
	if age>=18 then isadult = 1;
	    else isadult = 0;

	numadults = isadult;

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

	/* Child or stepchild */
	if relate in (3,4) then before1gen = 1;
		else before1gen = 0;

	/* Grandchild */
	if relate in (9) then before2gen = 1;
		else before2gen = 0;

	/* Parent or stepparent*/
	if relate in (5,6) then after1gen = 1;
		else after1gen = 0;

    /*income category according to HUD definition*/

	if (numprec = 1 and hhincome <= 24650) or (numprec=2 and hhincome <= 28150) or  (numprec=3 and hhincome <= 31540)
       or (numprec=4 and hhincome <= 35150) or (numprec=5 and hhincome <= 38000) or (numprec=6 and hhincome <= 40800) 
       or (numprec=7 and hhincome <= 43600) or (numprec=8 and hhincome <= 46400) then hudincome30=1;                                                                               
	   else hudincome30 = 0;

	if (numprec = 1 and hhincome <= 41050) or (numprec=2 and hhincome <= 46900  ) or  (numprec=3 and hhincome <= 5750)
       or (numprec=4 and hhincome <= 58600) or (numprec=5 and hhincome <= 63300) or (numprec=6 and hhincome <= 68000 ) 
       or (numprec=7 and hhincome <= 72700) or (numprec=8 and hhincome <= 77400) then hudincome50=1;                                                                               
	   else hudincome50 = 0;
	    
 	if (numprec = 1 and hhincome <= 54250) or (numprec=2 and hhincome <= 62000 ) or  (numprec=3 and hhincome <= 69750)
       or (numprec=4 and hhincome <= 77450) or (numprec=5 and hhincome <= 83650) or (numprec=6 and hhincome <= 89850) 
       or (numprec=7 and hhincome <= 96050) or (numprec=8 and hhincome <= 102250) then hudincome80=1;                                                                               
	   else hudincome80 = 0;

   /*income category according to DC Council*/
	if (numprec = 1 and hhincome <= 108600*0.3*0.7) or (numprec=2 and hhincome <= 108600*0.3*0.8) or  (numprec=3 and hhincome <= 108600*0.3*0.9)
       or (numprec=4 and hhincome <= 108600*0.3) or (numprec=5 and hhincome <= 108600*0.3*1.1) or (numprec=6 and hhincome <= 108600*0.3*1.2 ) 
       or (numprec=7 and hhincome <= 108600*0.3*1.3) or (numprec=8 and hhincome <= 108600*0.3*1.4) then dcincome30=1;                                                                               
	   else dcincome30 = 0;

	if (numprec = 1 and hhincome <= 108600*0.5*0.7) or (numprec=2 and hhincome <= 108600*0.5*0.8) or  (numprec=3 and hhincome <= 108600*0.5*0.9)
       or (numprec=4 and hhincome <= 108600*0.5) or (numprec=5 and hhincome <= 108600*0.5*1.1) or (numprec=6 and hhincome <= 108600*0.5*1.2 ) 
       or (numprec=7 and hhincome <= 108600*0.5*1.3) or (numprec=8 and hhincome <= 108600*0.5*1.4) then dcincome50=1;                                                                               
	   else dcincome50 = 0;
	    
	if (numprec = 1 and hhincome <= 108600*0.8*0.7) or (numprec=2 and hhincome <= 108600*0.8*0.8) or  (numprec=3 and hhincome <= 108600*0.8*0.9)
       or (numprec=4 and hhincome <= 108600*0.8) or (numprec=5 and hhincome <= 108600*0.8*1.1) or (numprec=6 and hhincome <= 108600*0.8*1.2 ) 
       or (numprec=7 and hhincome <= 108600*0.8*1.3) or (numprec=8 and hhincome <= 108600*0.8*1.4) then dcincome80=1;                                                                               
	   else dcincome80 = 0;


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

  /*flag for nonrelative living together*/

     if related = 1115 or related = 1241 or related = 1260 then nonrelative = 1;
	     else nonrelative = 0;


	keep &cvars. &mvars. nonrelative numkids numadults
		  serial hhwt pernum hhtype numprec race hispan age hhincome;
  
run;


proc summary data = pretables;
	class serial;
	var &cvars. nonrelative numkids numadults;
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


run;


proc summary data = pretables_collapse;
	class largeunit;
	var allhh raceW raceB raceH raceAPI raceO hudincome30 hudincome50 hudincome80 multigen grouphouse issenior isdis;
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

	pct_issenior = issenior / allhh;
	pct_isdis = isdis / allhh;
	pct_multigen = multigen / allhh;
	pct_grouphouse = grouphouse / allhh;

run;


proc summary data = pretables_collapse;
	class largeunit;
	var &mvars.;
	weight hhwt;
	output out = table2b_m median=;
run;


proc summary data = pretables_collapse;
	class largeunit;
	var numkids numadults;
	weight hhwt;
	output out = table2b_n median=;
run;
