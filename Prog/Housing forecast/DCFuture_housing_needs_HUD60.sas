/**************************************************************************
 Program:  DCFuture_housing_needs.sas
 Library:  DMPED
 Project:  DMPED Housing Forecast
 Author:   AK from L. Hendey
 Created:  07/02/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description: 

USING HUD INC 60% CUTOFF PROJECTIONS/DISTRIBUTIONS: 
  
Project future housing needs at 5-year increments by tenure (2035 plus backup 2020-2035) 
	* use the current distribution of households and the maximum housing costs each household could afford or would desire 
		to pay based on their income and tenure and apply it to the number of households expected to be added in each income x tenure band.	
	* Will do this for a "mid" and a "high" HH projection scenario
	* Assume all households are placed in the housing category appropriate to their income level (no burden)
	* Add additional housing units in each cost category sufficient to maintain the current overall vacancy rates
For alternate gentrification scenario ("Alt")
	*Use HH projections under extreme gentrification to understand housing costs additional households could afford by tenure

Tables: 

Net new Housing units needed to accommodate growth (2020-2035) (including increasing vacant units) (mid, high, alt) 

Housing cost levels new households could afford by tenure in 2035 (mid, high, alt) 


**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( Ipums )

%let date=07172024; 

PROC FORMAT;

  VALUE hud_inc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-60%'
    3 = '61-80%'
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



/** STEPS -- to be used within a macro that uses mid, high, and alt projections: 
1) Read in current needs and vacancy datasets;
2) Read in hh growth matrices by hud inc for each of the three scenarios; 

Occupied dataset
3) By tenure, and using tenure-specific max desired/affordable housing cost variables (mrentlevel for renters, mownlevel for owners)
create crosstab (PROC FREQ) of current households - HUD inc vs cost var; 
4) Using table percentages for each income bracket x cost level pair,
Apply future number of households for the year (e.g., 2035) broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values;

Vacant 
*5) For vacant units, take tenure-specific cost var (rentlevel for units that are "For rent or sale" and ownlevel for those that are "for sale only")
and put values into mrentlevel and mownlevel variables so it can be put into same table as occupied;
*6) For 2025-2040 at 5-year increments, calculate growth rate from Steven's table 1 total units, between 2018-22 
ACS total and the projection year;
*7)  Create table output of vacant units by cost level;
*8) Apply that to vacant unit totals to create projections;

Combined
9) Combine the occupied and vacant tables by tenure
10) Calculate the "net new" units for each 5-year increment for inc X cost intersection

**/

**MACRO FOR MID VERSUS HIGH VERSUS ALT (GENTRIFICATION) LEVEL PROJECTIONS;

%MACRO mid_high_alt(level = );
/* Read in data*/

* Importing Renters tenures;
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_&Level._Renter_Households_by_HUD60_Income.csv" 
	OUT = &Level._renter_hh_proj_1
	dbms = dlm
	replace;
	delimiter = ','; 
RUN;

* Importing "Owners" tenures;
PROC IMPORT DATAFILE = "C:\DCData\Libraries\DMPED\Prog\Housing forecast\Projected_&Level._Owner_Households_by_HUD60_Income.csv" 
	OUT = &Level._owner_hh_proj_1
	dbms = dlm
	replace;
	delimiter = ','; 
RUN;

* MACRO to manipulate these hh projection data frames;
* Change hud_inc to align with baseline needs version;
* separate output for total row as total growth; 
%MACRO hh_proj_tenure(tenure=);
DATA &Level._&tenure._hh_proj &Level._&tenure._total_growth; 
	SET &Level._&tenure._hh_proj_1;
	IF HUD__ = "Total" THEN OUTPUT &Level._&tenure._total_growth; 
	ELSE OUTPUT &Level._&tenure._hh_proj;
RUN;

DATA &Level._&tenure._hh_proj;
	SET &Level._&tenure._hh_proj;
	IF HUD__ = "0-30" THEN Hud_inc = 1; 
	ELSE IF HUD__ = "30.1-60" THEN	Hud_inc = 2; 
	ELSE IF HUD__ = "60.1-80" THEN 	Hud_inc = 3; 
	ELSE IF HUD__ = "80.1-120" THEN Hud_inc = 4; 
	ELSE IF HUD__ = "120.1-200" THEN Hud_inc = 5; 
	ELSE IF HUD__ = ">200" THEN	Hud_inc = 6; 
	FORMAT hud_inc hud_inc.;
	DROP HUD__; 
RUN;

	
*reorder vars;
DATA &Level._&tenure._hh_proj; 
	RETAIN Hud_inc _2020 _2025 _2030 _2035 _2040; 
	SET &Level._&tenure._hh_proj;
RUN;

*Manipulating total growth dataset; 
DATA &Level._&tenure._total_growth;
	SET &Level._&tenure._total_growth; 
	hud_inc = 7;
	DROP HUD__;
RUN;


%mend hh_proj_tenure;

*%hh_proj_tenure(tenure = all);
%hh_proj_tenure(tenure = renter);
%hh_proj_tenure(tenure = owner);


*Importing housing needs baseline dataset from current needs script;  
DATA Housing_needs_baseline_2018_22; 
	SET DMPED.dc_2018_22_housing_needs_60;
RUN;

*Importing housing vacancies dataset from current needs script;
DATA Housing_needs_vacant_2018_22; 
	SET DMPED.dc_2018_22_housing_needs_vac_60;
RUN;




/*** OCCUPIED TOTALS ***/
* BY tenure and tenure-specific cost levels; 

*Starting macro as function of tenure;
%MACRO future_cost_by_tenure(tenure_name = , tenure_var = , cost = );
PROC FREQ DATA = Housing_needs_baseline_2018_22;
	WHERE tenure = &tenure_var. ; 
	TABLES hud_inc * &cost./ nocol nopercent out = &level._&tenure_name._hh_inc_cost OUTPCT;
	WEIGHT hhwt;
RUN;

*Merge HH count projections onto this table;
PROC SORT DATA = &level._&tenure_name._hh_inc_cost; BY hud_inc; RUN;
PROC SORT DATA = &level._&tenure_name._hh_proj; BY hud_inc; RUN;

DATA &level._proj_&tenure_name._hh_inc_cost;
	MERGE &level._&tenure_name._hh_inc_cost(in=a) &level._&tenure_name._hh_proj;
	BY hud_inc; 
	IF a = 1; 
RUN;


/* Calculate the units needed for the year in each level: 
 Using table percentages for each income bracket x cost level pair,
Apply future number of households for the year 2035 broken out by hud income level 
to calculate anticipated number of HHs matrix for that year's values

*/	

* Array across years;
DATA &level._proj_&tenure_name._hh_inc_cost; 
	SET &level._proj_&tenure_name._hh_inc_cost; 
	ARRAY year(4) _2025 _2030 _2035 _2040; *existing vars;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; *new vars;
	DO i = 1 to 4;
		proj_year[i] = year[i]* (PCT_ROW/100); 
	END;
	DROP PCT_COL _2025 _2030 _2035 _2040;
RUN; 

PROC EXPORT DATA = &level._proj_&tenure_name._hh_inc_cost
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\hud60_&Level._Fut_&tenure_name._units_by_cost_&date..csv"
   dbms=csv
   replace;
   run;
%mend;
%future_cost_by_tenure(tenure_name = renter, tenure_var = 1, cost = mrentlevel);
%future_cost_by_tenure(tenure_name = owner, tenure_var = 2, cost = mownlevel);


/*** VACANT UNITS ***/

*Split out by rent/own cost;
* Vacancy_r has values of "for rent or sale" or "for sale only." The first has rentgrs, the second has owner costs.;

*5) For vacant units, take cost level and put values into corresponding mrentlevel or mownlevel variable so it can be put into same table as occupied;
DATA Housing_needs_vacant_2018_22;
	SET Housing_needs_vacant_2018_22;
	mrentlevel = rentlevel;
	mownlevel = ownlevel;
RUN;

*Calculate vacancy rates of all regular units;
*By vacancy rent vs own; 
%MACRO vacancy_by_tenure(tenure_name = , tenure_var = , tenure_grow_name = ,  cost = );
PROC FREQ DATA = Housing_needs_vacant_2018_22;
	WHERE vacancy_r = &tenure_var.;
	TABLE hud_inc*&cost./norow nocol nopercent out = &tenure_name._vacant_cost;
	WEIGHT hhwt;
RUN;

*Calculating household growth rate between 2018-22 and each of the 5-year increments;
DATA &level._&tenure_grow_name._total_growth; 
	SET &level._&tenure_grow_name._total_growth;
	_2018_22_to_2025_growth = (_2025 - _2020)/_2020;
	_2018_22_to_2030_growth = (_2030 - _2020)/_2020;
	_2018_22_to_2035_growth = (_2035 - _2020)/_2020;
	_2018_22_to_2040_growth = (_2040 - _2020)/_2020;
RUN;
	
*Merge growth rates onto vacancy by cost matrix;
PROC SORT DATA = &tenure_name._vacant_cost; BY hud_inc; RUN;
PROC SORT DATA = &level._&tenure_grow_name._total_growth; BY hud_inc; RUN;

DATA &level._proj_&tenure_name._vacant_cost; 
	MERGE &tenure_name._vacant_cost &level._&tenure_grow_name._total_growth (DROP = _2020 _2025 _2030 _2035 _2040) ; 
	BY hud_inc;
RUN;

*Calculate vacant unit counts for year projections;
DATA &level._proj_&tenure_name._vacant_cost; 
	SET &level._proj_&tenure_name._vacant_cost; 
	ARRAY growth(4) _2018_22_to_2025_growth _2018_22_to_2030_growth _2018_22_to_2035_growth _2018_22_to_2040_growth; *existing vars;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040;
	DO i = 1 to 4;
		proj_year[i] = COUNT + growth[i]*COUNT; 
	END;
	DROP _2018_22_to_2025_growth _2018_22_to_2030_growth _2018_22_to_2035_growth _2018_22_to_2040_growth;
RUN;	

%mend;
%vacancy_by_tenure(tenure_name = rent_sale, tenure_var = 1, tenure_grow_name = renter, cost = mrentlevel);
%vacancy_by_tenure(tenure_name = sale_only, tenure_var = 2,  tenure_grow_name = owner, cost = mownlevel);


/* COMBINING OCCUPIED AND VACANT INTO ONE TABLE*/
*BY TENURE and VACANCY TYPE;

*Rental occupied and rent/sale vacant;
DATA &level._proj_rent_by_cost_inc ; 
	SET &level._proj_renter_hh_inc_cost  &level._proj_rent_sale_vacant_cost; 
	KEEP hud_inc mrentlevel COUNT PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; 
RUN;

*Exporting table; 
PROC EXPORT DATA = &level._proj_rent_by_cost_inc
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\hud60_&level._Fut_all_rent_units_by_cost_&date..csv"
   dbms=csv
   replace;
   run; 

*Owner occupied and for-sale only vacant;
DATA &level._proj_own_by_cost_inc ; 
	SET &level._proj_owner_hh_inc_cost  &level._proj_sale_only_vacant_cost; 
	KEEP hud_inc mownlevel COUNT PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040;
RUN;

*Exporting table; 
PROC EXPORT DATA = &level._proj_own_by_cost_inc
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\hud60_&level._Fut_all_owner_sale_units_by_cost_&date..csv"
   dbms=csv
   replace;
   run; 


* NET NEW UNITS ;
%MACRO net_new_by_tenure(tenure_name = );

DATA &level._new_proj_&tenure_name._by_cost_inc ; 
	SET &level._proj_&tenure_name._by_cost_inc;
	ARRAY proj_year(4) PROJ_2025 PROJ_2030 PROJ_2035 PROJ_2040; *existing vars;
	ARRAY net_new(4) NET_NEW_2025 NET_NEW_2030 NET_NEW_2035 NET_NEW_2040;
	DO i = 1 to 4;
		net_new[i] = proj_year[i] - COUNT; 
	END;
RUN;

* Creating summary table for net new housing needed (totals);
PROC EXPORT DATA =  &level._new_proj_&tenure_name._by_cost_inc
	outfile="C:\DCData\Libraries\DMPED\Prog\Housing Forecast\hud60_&level._Fut_net_new_&tenure_name._units_by_cost_&date..csv"
   dbms=csv
   replace;
   run;
%mend net_new_by_tenure; 
%net_new_by_tenure(tenure_name = rent);
%net_new_by_tenure(tenure_name = own);

%mend mid_high_alt;
%mid_high_alt(level = mid);
%mid_high_alt(level = high);
%mid_high_alt(level = alt);
