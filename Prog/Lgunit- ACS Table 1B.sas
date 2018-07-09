/************************************************************************** 
Program:  LargeUnits_Affordability.sas 
Library:  
Project:  NeighborhoodInfo DC 
Author:   Yipeng Su 
Created:  6/20/18
Version:  SAS 9.4 
Environment:  Windows with SAS/Connect  
Description: Create calculate percent affordability of large rental units and then calculate concentration by tract
Modifications: 
**************************************************************************/ 

%include "L:\SAS\Inc\StdLocal.sas";

%DCData_lib( ACS );
%DCData_lib( Police );

%let _years = 2012_16;

data calculate_pct;
     set ACS.acs_2012_16_dc_sum_tr_tr10;
	 keep geo2010 numrenterhsgunits_&_years. numownocchu3plusbd_&_years. numrentocchu3bd_&_years.
          numrtohu3b500to749_&_years. numrtohu3b750to999_&_years.  numrtohu3bunder500_&_years. numrtohu3b1500plus_&_years.
          pct3baffordable1000 pct3baffordable1500;
          pct3baffordable1500= (numrentocchu3bd_&_years.-numrtohu3b1500plus_&_years.)/numrentocchu3bd_&_years.
          pct3baffordable1000= sum(numrtohu3b500to749_&_years.,numrtohu3b750to999_&_years., numrtohu3bunder500_&_years.)/numrentocchu3bd_&_years.;
     if   pct3baffordable1000 >=0.5 then aff1000median=1;
	      else aff1000median=0;
	 if  pct3baffordable1000 >=0.75 then  aff1000threequarter=1;
	      else aff1000threequarter=0;
     if   pct3baffordable1500 >=0.5 then aff1500median=1;
	      else aff1500median=0;
	 if  pct3baffordable1500 >=0.75 then  aff1500threequarter=1;
	      else aff1500threequarter=0;

run;


data ACScharacteristics;
     set ACS.acs_2012_16_dc_sum_tr_tr10;
	 keep geo2010 popaloneh_&_years.  popblacknonhispbridge_&_years.  popalonew_&_years.  mpopwithrace_&_years. 
          pop25andoverwcollege_&_years. popunemployed_&_years. totpop_&_years. 
	      medfamincm_&_years. ;

     



run;

data crimedata;
     set Police.Crimes_sum_tr10;
	 keep geo2010 crimes_pt1_property_2016 crimes_pt1_violent_2016;
run;

data neighborhood;
	merge ACScharacteristics crimedata;
	by geo2010;
run;

data affordabletracts;
     merge neighborhood calculate_pct;
	 by geo2010;
run;
