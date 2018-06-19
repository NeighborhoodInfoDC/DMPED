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


data pretables;
	set ipums.acs_2012_16_dc;
	keep largeunit serial hhwt pernum hhtype numprec race hispan age hhincome isadult isschoolage
         issenior isdis
     ;

	 /*only households*/
	if gq in (1,2);

    /*large unit*/
	if numprec >= 4 then largeunit = 1;
		else largeunit = 0;

	/*adult*/
	if age>=18 then isadult = 1;
	    else isadult = 0;
   
	/*seniors*/
    if age>65 then issenior = 1;
	    else issenior = 0;

    /*schoolage children*/
    if 6<age<18 then isschoolage = 1;
	    else isschoolage = 0;

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


    /*income category according to HUD definition*/

	if (numprec = 1 and hhincome <= 24650) or (numprec=2 and hhincome <= 28150) or  (numprec=3 and hhincome <= 31540)
       or (numprec=4 and hhincome <= 35,150) or (numprec=5 and hhincome <= 38,000) or (numprec=6 and hhincome <= 40,800) 
       or (numprec=7 and hhincome <= 43,600) or (numprec=8 and hhincome <= 46,400) then hudincome30=1;                                                                               
	   else hudincome30 = 0;

	if (numprec = 1 and hhincome <= 41,050) or (numprec=2 and hhincome <= 46,900  ) or  (numprec=3 and hhincome <= 52,750)
       or (numprec=4 and hhincome <= 58,600) or (numprec=5 and hhincome <= 63,300) or (numprec=6 and hhincome <= 68,000 ) 
       or (numprec=7 and hhincome <= 72,700) or (numprec=8 and hhincome <= 77,400) then hudincome50=1;                                                                               
	   else hudincome50 = 0;
	    
 	if (numprec = 1 and hhincome <= 54,250) or (numprec=2 and hhincome <= 62,000 ) or  (numprec=3 and hhincome <= 69,750)
       or (numprec=4 and hhincome <= 77,450) or (numprec=5 and hhincome <= 83,650) or (numprec=6 and hhincome <= 89,850) 
       or (numprec=7 and hhincome <= 96,050) or (numprec=8 and hhincome <= 102,250) then hudincome80=1;                                                                               
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
   
run;


proc summary data = pretables;
	class serial;
	var isschoolage largeunit isadult isschoolage
         issenior isdis ;
	output out= pretables_collapse sum=;
run;


proc sort data = pretables_collapse; by serial; run;

data pretables_collapse_w;
	merge pretables_collapse hhwts;
	by serial;
run;

proc freq data = pretables_collapse_w;
	tables isschoolage;
	weight hhwt;
run;

proc freq data = pretables (where=(pernum=1));
	tables race*largeunit;
	weight hhwt;
run;


