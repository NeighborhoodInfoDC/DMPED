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


data test;
	set ipums.acs_2012_16_dc;
	keep largeunit serial hhwt pernum hhtype numprec race hispan;
	if numprec >= 4 then largeunit = 1;
		else largeunit = 0;
run;

proc freq data = test (where=(pernum=1));
	tables race*largeunit;
	weight hhwt;
run;
