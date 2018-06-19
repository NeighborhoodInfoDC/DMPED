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


data pretables;
	set ipums.acs_2012_16_dc;
	keep largeunit serial hhwt pernum hhtype numprec race hispan age hhincome isadult isschoolage
         issenior isdis
     ;
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


run;




proc freq data = pretables (where=(pernum=1));
	tables race*largeunit;
	weight hhwt;
run;
