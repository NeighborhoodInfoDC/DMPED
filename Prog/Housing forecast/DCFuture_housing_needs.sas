/**************************************************************************
 Program:  DCFuture_housing_needs.sas
 Library:  DMPED
 Project:  DMPED Housing Forecast
 Author:   AK from L. Hendey
 Created:  07/02/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  
For future 5-year increments (2035 plus backup 2020-2035)
	* use the current distribution of households and the maximum housing costs each household could afford or would desire 
		to pay based on their income and apply it to the number of households expected to be added in each income band.	
	* Assume all households are placed in the housing category appropriate to their income level (no burden)
	* Add additional housing units in each cost category sufficient to maintain the current overall vacancy rates


Tables: 

Net new Housing units needed to accommodate growth (2020-2035) (including increasing vacant units) (low-mid-high) 

Housing Cost levels additional households could afford in 2035  (owner is firstime homebuyer costs) (low-mid-high) 

Housing cost levels new households could afford by tenure in 2035 (low-mid-high) 


**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( Ipums )

%let date=07022024Alt; 

PROC FORMAT;

  VALUE hud_inc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-50%'
    3 = '51-80%'
    4 = '81-120%'
    5 = '120-200%'
    6 = 'More than 200%'
	7 = 'Vacant'
	;
RUN;
/****** NEW HOUSING UNITS NEEDED TO ACCOMODATE GROWTH *******/

/** STEPS: 
1) Read in current needs and vacancy datasets;
2) Read in hh growth matrix by hud inc; 

Occupied
3) Using (NOTE - desired var?) mallcostlevel (tenure-combine) housing cast categoreis based on max affordable-desired,
create crosstab (PROC FREQ) of current households - HUD inc vs mallcostlevel; 
4) Using table percentages for each income bracket x mallcostlevel pair,
Apply future number of households for the year (e.g., 2035) broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values;

Vacant
Goal: Add additional housing units in each cost category sufficient to 
maintain the current overall housing vacancy rates.

**/

/* Read in data*/

*household projections total by income level; 
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_Households_by_HUD_Income.csv" 
	OUT = hh_projections_1
	dbms = dlm
	replace;
	delimiter = ',';
RUN;

* Change hud_inc to align with baseline needs version;
* drop total row; 
DATA hh_projections; 
	SET hh_projections_1;
	IF HUD__ = "Total" THEN DELETE; 
	ELSE IF HUD__ = "0-29.9" THEN Hud_inc = 1; 
	ELSE IF HUD__ = "30-49.9" THEN	Hud_inc = 2; 
	ELSE IF HUD__ = "50-79.9" THEN 	Hud_inc = 3; 
	ELSE IF HUD__ = "80-119.9" THEN Hud_inc = 4; 
	ELSE IF HUD__ = "120-199.9" THEN Hud_inc = 5; 
	ELSE IF HUD__ = "200+" THEN	Hud_inc = 6; 
	FORMAT hud_inc hud_inc.;
	DROP HUD__; 
RUN;
*reorder vars;
DATA hh_projections; 
	RETAIN Hud_inc _2018_2022 _2025 _2030 _2035 _2040 Total_Increase; 
	SET hh_projections;
RUN;


/* NOTE NEED TO CORRECT EXPORT PROCESS IN OTHER SCRIPT SO CAN ACCESS SAS DATASET. CSV doesn't have true values/labels. 

GOING TO PROCEED CODING AS THOUGH THIS HAS ALREADY BEEN CORRECTED*/



*housing needs baseline dataset from current needs script;  
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Housing_needs_baseline_2018_22.csv" 
	OUT = Housing_needs_baseline_2018_22
	dbms = dlm
	replace;
	delimiter = ',';
RUN;

*housing vacancies dataset from current needs script;
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Housing_needs_vacant_2018_22.csv" 
	OUT = Housing_needs_vacant_2018_22
	dbms = dlm
	replace;
	delimiter = ',';
RUN;

*other vacancies dataset from current needs script;
* NOTE : Do we need this?;
/*PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\other_vacant_2018_22.csv" 
	OUT = other_vacant_2018_22
	dbms = dlm
	replace;
	delimiter = ',';
RUN;*/


/*** OCCUPIED TOTALS ***/
PROC FREQ DATA = Housing_needs_baseline_2018_22;
	TABLES hud_inc * mallcostlevel/ norow nocol out = hh_inc_cost_matrix;
	WEIGHT hhwt;
RUN;

*Merge HH count projections onto this table;
PROC SORT DATA = hh_inc_cost_matrix; BY = hud_inc; RUN;
PROC SORT DATA = hh_projections; BY = hud_inc; RUN;

/*NOTE: will want to start macro for each year here*/
DATA proj_hh_inc_cost_matrix;
	MERGE hh_inc_cost_matrix(in=a) hh_projections (DROP = total_increase);
	BY hud_inc; 
	IF a = 1; 
RUN;

/* Calculate the units needed for the year in each level: 
 Using table percentages for each income bracket x mallcostlevel pair,
Apply future number of households for the year (e.g., 2035) broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values

*/	

* Array across years;
DATA proj_hh_inc_cost_matrix; 
	SET proj_hh_inc_cost_matrix; 
	ARRAY year(4) _2025 _2030 _2035 _2040; *existing vars;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; *new vars;
	DO i = 1 to 4;
		proj_year[i] = year[i]* PERCENT; 
	END;
RUN; 


/*** VACANT UNITS ***/

*5) Create table output of vacant units by cost level;
* NOTE - do we need vacancy by cost level? Would it be matched to desired cost level from occupied matrix?;

PROC FREQ DATA = Housing_needs_vacant_2018_22; 
	TABLE allcostlevel/ out = vacant_cost_matrix;
	WEIGHT hhwt;
RUN;

