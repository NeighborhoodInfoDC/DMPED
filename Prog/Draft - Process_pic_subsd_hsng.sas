/**************************************************************************
 Program:  Process_pic_subsd_hsng.sas
 Library:  DMPED
 Project:  M. Woluchem
 Created:  05/05/14
 Version:  SAS 9.1
 Environment:  Local Windows session (desktop)

 Description:  Attach standard geographies to tract-level Picture of Subsidized Housing Data.
 Modifications:

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";
%DCData_lib( DMPED)

/**StatTransfer imported all character variables with incorrect variable names, which are now replaced according to codebook**/

proc contents data=dmped.Hudpicture2012_606057_mw;
run;

/**Keep only relevant variables and replace names**/

data A (rename=(Code=Geo2010 Subsidized_units_available=total_units  v__Occupied=pct_occupied v__Reported=number_reported                         
	v__Reported0=pct_reported Number_of_people__total=people_total Number_of_people_per_unit=people_per_unit    
	Rent_per_month_=rent_per_month Household_income_per_year=hh_income Household_income_per_year_per_pe=person_income
	v___10_000____14_999=pct_10k_lt15k v___15_000____19_999=pct_15k_lt20k v___1____4_999=pct_lt5k                     
	v___20_000_or_more=pct_ge20k v___5_000____9_999=pct_5k_lt10k v__of_local_median__Household_in=pct_median
	v__very_low_income=pct_lt50_median v__extremely_low_income=pct_lt30_median));
set dmped.Hudpicture2012_606057_mw 


(keep=Program_label Program Name Geo2010 Subsidized_units_available v__Occupied  v__Reported                         
	v__Reported0 Number_of_people__total Number_of_people_per_unit Rent_per_month_  Household_income_per_year Household_income_per_year_per_pe 
	v___10_000____14_999 v___15_000____19_999 v___1____4_999 v___20_000_or_more v___5_000____9_999 v__of_local_median__Household_in 
	v__very_low_income v__extremely_low_income);
run;

/**Recode missing values and add labels**/
/** 
Original: 
	-1 = Not applicable
	-2 = Don't know
	-3 = No geocode
	-4 = Suppressed (where cell entry is less than 11 for variable name "number reported"
	-5 = Non-reporting"

Recode: 
	A = Not applicable
	K = Don't know
	G = No geocode
	S = Suppressed (where cell entry is less than 11 for variable name "number reported"
	R = Non-reporting"
**/
options mprint symbolgen;
data B;
set A;

%macro recodemissing;
%let missvars = pct_occupied number_reported pct_reported people_total people_per_unit rent_per_month hh_income person_income
	pct_10k_lt15k pct_15k_lt20k pct_lt5k pct_ge20k pct_5k_lt10k pct_median pct_lt50_median pct_lt30_median;
	%do i = 1 %to 16;
		%let missvar = %scan(&missvars., &i., " ");
			if &missvar. = -1 then &missvar. = .a;
				else if &missvar. = -2 then &missvar. = .k;
				else if &missvar. = -3 then &missvar. = .g;
				else if &missvar. = -4 then &missvar. = .s;
				else if &missvar. = -5 then &missvar. = .r;
			else &missvar. = &missvar.;
	%end;
%mend;
%recodemissing;

label 	total_units = 		"Subsidized units available"
		pct_occupied = 		"% Occupied"
 		number_reported = 	"# Reported"	
		pct_reported = 		"% Reported"
	 	people_per_unit = 	"Number of people per unit"	
		people_total = 		"Number of people: total"	
		rent_per_month = 	"Rent per month ($$)"	
		hh_income = 		"Household income per year"	
		person_income = 	"Household income per year per person"
		pct_lt5k = 			"% $1 - $4,999"
		pct_5k_lt10k = 		"% $5,000 - $9,999"	
		pct_10k_lt15k = 	"% $10,000 - $14,999"
	 	pct_15k_lt20k =  	"% $15,000 - $19,999"	
		pct_ge20k = 		"% $20,000 or more"	
  		pct_median = 		"% of local median (Household income)"	
		pct_lt50_median = 	"% very low income"	
		pct_lt30_median = 	"% extremely low income";
run;

proc means data=B;
run;

/**Create summary counts of income distribution**/

data dmped.pic_subsd_hsng_2012;
set B;
%macro summarycounts;
%let percents = lt5k 5k_lt10k 10k_lt15k 15k_lt20k ge20k lt50_median lt30_median;

	%do i = 1 %to 7;
			%let percent = %scan(&percents., &i., " ");
				ct_&percent.=(pct_&percent.*number_reported)/100;
	%end;
%mend;
%summarycounts;

label 	ct_lt5k = 			"# $1 - $4,999"
		ct_5k_lt10k = 		"# $5,000 - $9,999"	
		ct_10k_lt15k = 		"# $10,000 - $14,999"
	 	ct_15k_lt20k =  	"# $15,000 - $19,999"	
		ct_ge20k = 			"# $20,000 or more"		
		ct_lt50_median = 	"# very low income"	
		ct_lt30_median = 	"# extremely low income";
run;

proc means data=dmped.pic_subsd_hsng_2012;
run;

/*data dmped.pic_subsd_hsng_2012;*/

%Create_summary_from_tracts( 
  geo=cluster_tr2000, 
  lib=DMPED,
  data_pre=pic_subsd_hsng_2012,
  data_label=%str(Picture of Subsidized Housing summary, DC),
  count_vars=total_units number_reported people_total ct:,
  prop_vars=hh_income person_income,
  calc_vars=,
  calc_vars_labels=,
  tract_yr=2010,
  register=N, 
  restrictions=,
  revisions=,
  mprint=y
);

%Create_summary_from_tracts( 
  geo=city, 
  lib=DMPED,
  data_pre=pic_subsd_hsng_2012,
  data_label=%str(Picture of Subsidized Housing summary, DC),
  count_vars=total_units number_reported people_total ct:,
  prop_vars=hh_income person_income,
  calc_vars=,
  calc_vars_labels=,
  tract_yr=2010,
  register=N, 
  restrictions=,
  revisions=,
  mprint=y
);
