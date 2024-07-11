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

	 value rcost
	  1= "$0 to $899"
	  2= "$900 to $1,499"
	  3= "$1,500 to $1,899"
	  4= "$1,900 to $2,399"
	  5= "$2,400 to $2,799"
	  6= "More than $2,800"
  ;

    value ocost
	  1= "$0 to $1,499"
	  2= "$1,500 to $1,899"
	  3= "$1,899 to $2,499"
	  4= "$2,500 to $3,199"
	  5= "$3,200 to $4,199"
	  6= "More than $4,200"
  ;


  value acost
	  1= "$0 to $899"
	  2= "$900 to $1,499"
	  3= "$1,500 to $1,899"
	  4= "$1,900 to $2,799"
	  5= "$2,800 to $3,599"
	  6= "More than $3,600"
   ;

   value tenure
	1 = 'Rent'
	2 = 'Own'
	; 

RUN;




/*************** NET NEW HOUSING UNITS NEEDED TO ACCOMODATE GROWTH ************/

/*************** HOUSING COST LEVELS ADDITIONAL HOUSEHOLDS COULD AFFORD ************/



/** STEPS -- to be used within a macro that uses low-mid-high projections: 
1) Read in current needs and vacancy datasets;
2) Read in hh growth matrix by hud inc; 

Occupied dataset
3) Using (NOTE - desired var?) mallcostlevel (tenure-combine) housing cast categoreis based on max affordable-desired,
create crosstab (PROC FREQ) of current households - HUD inc vs mallcostlevel; 
4) Using table percentages for each income bracket x mallcostlevel pair,
Apply future number of households for the year (e.g., 2035) broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values;

Vacant 
*5) For vacant units, take allcostlevel and put values into mallcostlevel variable so it can be put into same table as occupied;
*6) For 2025-2040 at 5-year increments, calculate growth rate from Steven's table 1 total units, between 2018-22 
ACS total and the projection year;
*7)  Create table output of vacant units by cost level;
*8) Apply that to vacant unit totals to create projections;

**/

/* Read in data*/

*household projections total by income level;
* Importing "All" tenures; 
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_Households_by_HUD_Income.csv" 
	OUT = all_hh_projections_1
	dbms = dlm
	replace;
	delimiter = ',';
RUN;

* Importing Renters tenures;
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_Renter_Households_by_HUD_Income.csv" 
	OUT = renter_hh_projections_1
	dbms = dlm
	replace;
	delimiter = ','; 
RUN;

* Importing "Owners" tenures;
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_Owner_Households_by_HUD_Income.csv" 
	OUT = owner_hh_projections_1
	dbms = dlm
	replace;
	delimiter = ','; 
RUN;

* MACRO to manipulate these hh projection data frames;
* Change hud_inc to align with baseline needs version;
* separate output for total row as total growth; 
%MACRO hh_proj_tenure(tenure=);
DATA &tenure._hh_projections &tenure._total_growth; 
	SET &tenure._hh_projections_1;
	IF HUD__ = "Total" OR HUD__ =  "All Incomes of Renters" OR HUD__ =  "All Incomes of Owners"
	THEN OUTPUT &tenure._total_growth; 
	ELSE OUTPUT &tenure._hh_projections;
RUN;

DATA &tenure._hh_projections;
	SET &tenure._hh_projections;
	IF HUD__ = "0-29.9" THEN Hud_inc = 1; 
	ELSE IF HUD__ = "30-49.9" THEN	Hud_inc = 2; 
	ELSE IF HUD__ = "50-79.9" THEN 	Hud_inc = 3; 
	ELSE IF HUD__ = "80-119.9" THEN Hud_inc = 4; 
	ELSE IF HUD__ = "120-199.9" THEN Hud_inc = 5; 
	ELSE IF HUD__ = "200+" THEN	Hud_inc = 6; 
	FORMAT hud_inc hud_inc.;
	DROP HUD__; 
RUN;

	
*reorder vars;
DATA &tenure._hh_projections; 
	RETAIN Hud_inc _2018_2022 _2025 _2030 _2035 _2040 Total_Increase; 
	SET &tenure._hh_projections;
RUN;

*Manipulating total growth dataset; 
DATA &tenure._total_growth;
	SET &tenure._total_growth; 
	hud_inc = 7;
	DROP HUD__ Total_Increase;
RUN;

%mend;
%hh_proj_tenure(tenure = all);
%hh_proj_tenure(tenure = renter);
%hh_proj_tenure(tenure = owner);

/* NOTE NEED TO CORRECT EXPORT PROCESS IN OTHER SCRIPT SO CAN ACCESS SAS DATASET. CSV doesn't have true values/labels. 

GOING TO PROCEED CODING AS THOUGH THIS HAS ALREADY BEEN CORRECTED*/



*housing needs baseline dataset from current needs script;  
DATA Housing_needs_baseline_2018_22; 
	SET DMPED.dc_2018_22_housing_needs;
RUN;


PROC FREQ DATA = Housing_needs_baseline_2018_22;
	TABLES hud_inc; 
	weight hhwt;
RUN;

/* Import via CSV no longer needed
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Housing_needs_baseline_2018_22.csv" 
	OUT = Housing_needs_baseline_2018_22
	dbms = dlm
	replace;
	delimiter = ',';
RUN;
*/


*housing vacancies dataset from current needs script;
DATA Housing_needs_vacant_2018_22; 
	SET DMPED.dc_2018_22_housing_needs_vac;
RUN;

/* Import via CSV no longer needed
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Housing_needs_vacant_2018_22.csv" 
	OUT = Housing_needs_vacant_2018_22
	dbms = dlm
	replace;
	delimiter = ',';
RUN;
*/

*All housing units (occupied and vacant combined, NOT other_vacant);
DATA all_reg_units;
	SET DMPED.dc_2018_22_all_reg_units;
RUN;



/*** OCCUPIED TOTALS ***/
PROC FREQ DATA = Housing_needs_baseline_2018_22;
	TABLES hud_inc * mallcostlevel/ norow out = hh_inc_cost_matrix OUTPCT;
	WEIGHT hhwt;
RUN;

*Merge HH count projections onto this table;
PROC SORT DATA = hh_inc_cost_matrix; BY hud_inc; RUN;
PROC SORT DATA = all_hh_projections; BY hud_inc; RUN;

DATA proj_hh_inc_cost_matrix;
	MERGE hh_inc_cost_matrix(in=a) all_hh_projections (DROP = total_increase);
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
		proj_year[i] = year[i]* (PCT_ROW/100); 
	END;
	DROP PCT_COL _2025 _2030 _2035 _2040;
RUN; 


/*** VACANT UNITS ***/

*5) For vacant units, take allcostlevel and put values into mallcostlevel variable so it can be put into same table as occupied;
DATA all_reg_units;
	SET all_reg_units;
	IF hud_inc = 7 THEN mallcostlevel = allcostlevel;
RUN;

*Calculate vacancy rates of all regular units;
PROC FREQ DATA = all_reg_units; 
	TABLE hud_inc*mallcostlevel/norow nopercent out = vacancy_rate_cost_matrix;
	WEIGHT hhwt;
RUN;

*Drop occupied units;
DATA vacancy_rate_cost_matrix;
	SET vacancy_rate_cost_matrix;
	WHERE hud_inc = 7;
RUN;

*Calculating household growth rate between 2018-22 and each of the 5-year increments;
DATA all_total_growth; 
	SET all_total_growth;
	_2018_22_to_2025_growth = (_2025 - _2018_2022)/_2018_2022;
	_2018_22_to_2030_growth = (_2030 - _2018_2022)/_2018_2022;
	_2018_22_to_2035_growth = (_2035 - _2018_2022)/_2018_2022;
	_2018_22_to_2040_growth = (_2040 - _2018_2022)/_2018_2022;
RUN;
	
*Merge growth rates onto vacancy by cost matrix;
DATA proj_vacancy_cost_matrix; 
	MERGE vacancy_rate_cost_matrix all_total_growth (DROP = _2018_2022 _2025 _2030 _2035 _2040) ; 
	BY hud_inc;
RUN;

*Calculate vacant unit counts for year projections;
DATA proj_vacancy_cost_matrix; 
	SET proj_vacancy_cost_matrix; 
	ARRAY growth(4) _2018_22_to_2025_growth _2018_22_to_2030_growth _2018_22_to_2035_growth _2018_22_to_2040_growth; *existing vars;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040;
	DO i = 1 to 4;
		proj_year[i] = COUNT + growth[i]*COUNT; 
	END;
	DROP _2018_22_to_2025_growth _2018_22_to_2030_growth _2018_22_to_2035_growth _2018_22_to_2040_growth;
RUN;	

/* COMBINING OCCUPIED AND VACANT INTO ONE TABLE*/

DATA all_proj_units_by_cost_inc ; 
	SET proj_hh_inc_cost_matrix  proj_vacancy_cost_matrix; 
	KEEP hud_inc mallcostlevel COUNT PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; 
RUN;

*Exporting table; 
PROC EXPORT DATA = all_proj_units_by_cost_inc
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\Future_all_units_by_cost_&date..csv"
   dbms=csv
   replace;
   run; 

/* NET NEW UNITS */

DATA net_new_proj_units_by_cost_inc ; 
	SET all_proj_units_by_cost_inc;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; *existing vars;
	ARRAY net_new(4) NET_NEW_2025 NET_NEW_2030 NET_NEW_2035 NET_NEW_2040;
	DO i = 1 to 4;
		net_new[i] = proj_year[i] - COUNT; 
	END;
RUN;

/* Creating summary table for net new housing needed (totals)*/
PROC EXPORT DATA = net_new_proj_units_by_cost_inc 
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\Future_net_new_all_units_by_cost_&date..csv"
   dbms=csv
   replace;
   run;


/*************** BY TENURE: HOUSING COST LEVELS ADDITIONAL HOUSEHOLDS COULD AFFORD ************/

*Using occupied data;

*Starting macro as function of tenure;
%MACRO future_cost_by_tenure(tenure_name = , tenure_var = , cost = );
PROC FREQ DATA = Housing_needs_baseline_2018_22;
	WHERE tenure = &tenure_var. ; 
	TABLES hud_inc * &cost./ nocol nopercent out = &tenure_name._hh_inc_cost_matrix OUTPCT;
	WEIGHT hhwt;
RUN;

*Merge HH count projections onto this table;
PROC SORT DATA = &tenure_name._hh_inc_cost_matrix; BY hud_inc; RUN;
PROC SORT DATA = &tenure_name._hh_projections; BY hud_inc; RUN;

DATA proj_&tenure_name._hh_inc_cost_matrix;
	MERGE &tenure_name._hh_inc_cost_matrix(in=a) &tenure_name._hh_projections (DROP = total_increase);
	BY hud_inc; 
	IF a = 1; 
RUN;

/* Calculate the units needed for the year in each level: 
 Using table percentages for each income bracket x mallcostlevel pair,
Apply future number of households for the year 2035 broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values

*/	

* Just 2035;
DATA proj_&tenure_name._hh_inc_cost_matrix; 
	SET proj_&tenure_name._hh_inc_cost_matrix; 
	PROJ_2035 = _2035 * (PCT_ROW/100);
	DROP PCT_COL _2018_2022 _2025 _2035 _2030 _2040;
RUN;

PROC EXPORT DATA = proj_&tenure_name._hh_inc_cost_matrix
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\Future_&tenure_name._units_by_cost_&date..csv"
   dbms=csv
   replace;
   run;
%mend;
%future_cost_by_tenure(tenure_name = renter, tenure_var = 1, cost = mrentlevel);
%future_cost_by_tenure(tenure_name = owner, tenure_var = 2, cost = mownlevel);


