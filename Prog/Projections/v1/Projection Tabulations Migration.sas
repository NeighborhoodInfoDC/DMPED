/**************************************************************************
 Program:  Projection Tabulations.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Graham MacDonald
 Created:  1/24/2014
 Version:  SAS 9.2
 
 Description: Tabulate matrix for imputation of certain characteristics
				for the population projections.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Ipums )
%DCData_lib( DMPED )

%include "K:\Metro\PTatian\DCData\Libraries\IPUMS\Prog\hud_inc_all.sas";
%include "K:\Metro\PTatian\DCData\Libraries\IPUMS\Prog\hud_inc_2012.sas";

%macro age_cats();
	
	%let i = -1;
	if age = . then agecat = .;
	%do %until (&i. > 80);
		%let i = %eval(&i. + 5);
		%let j = %eval(&i. - 4);
		else if &j. <= age <= &i. then agecat = "&j. - &i.";
	%end;
	else agecat = "85 and older";

%mend age_cats;

filename asciidat "D:\DCData\Libraries\DMPED\Raw\usa_00057.dat";

data 
  DMPED.ACS_2009_12_US (label="IPUMS ACS sample, 2009-12")
  ;
length agecat $12. race_ethnicity $29.;

/**** COPY INFILE, INPUT, AND LABEL STATEMENTS FROM DOWNLOADED SAS PROGRAM HERE ****/

	infile ASCIIDAT pad missover lrecl=115;

	input
	  RECTYPE     $ 1-1
	  YEAR          2-5
	  DATANUM       6-7
	  SERIAL        8-15
	  NUMPREC       16-17
	  SUBSAMP       18-19
	  HHWT          20-29 .2
	  HHTYPE        30-30
	  STATEICP      31-32
	  STATEFIP      33-34
	  PUMA          35-39
	  PUMARES2MIG   40-44
	  CNTRY         45-47
	  GQ            48-48
	  GQTYPE        49-49
	  GQTYPED       50-52
	  OWNERSHP      53-53
	  OWNERSHPD     54-55
	  RENT          56-59
	  RENTGRS       60-63
	  HHINCOME      64-70
	  PERNUM        71-74
	  PERWT         75-84 .2
	  AGE           85-87
	  SEX           88-88
	  RACE          89-89
	  RACED         90-92
	  YRIMMIG       93-96
	  YRSUSA1       97-98
	  YRSUSA2       99-99
	  HISPAN        100-100
	  HISPAND       101-103
	  RACESING      104-104
	  RACESINGD     105-106
	  MIGRATE1      107-107
	  MIGRATE1D     108-109
	  MIGPLAC1      110-112
	  MIGPUMA1      113-115
	;

	label
	  RECTYPE     = "Record type"
	  YEAR        = "Census year"
	  DATANUM     = "Data set number"
	  SERIAL      = "Household serial number"
	  NUMPREC     = "Number of person records following"
	  SUBSAMP     = "Subsample number"
	  HHWT        = "Household weight"
	  HHTYPE      = "Household Type"
	  STATEICP    = "State (ICPSR code)"
	  STATEFIP    = "State (FIPS code)"
	  PUMA        = "Public Use Microdata Area"
	  PUMARES2MIG = "Public Use Microdata Area matching MIGPUMA"
	  CNTRY       = "Country"
	  GQ          = "Group quarters status"
	  GQTYPE      = "Group quarters type [general version]"
	  GQTYPED     = "Group quarters type [detailed version]"
	  OWNERSHP    = "Ownership of dwelling (tenure) [general version]"
	  OWNERSHPD   = "Ownership of dwelling (tenure) [detailed version]"
	  RENT        = "Monthly contract rent"
	  RENTGRS     = "Monthly gross rent"
	  HHINCOME    = "Total household income"
	  PERNUM      = "Person number in sample unit"
	  PERWT       = "Person weight"
	  AGE         = "Age"
	  SEX         = "Sex"
	  RACE        = "Race [general version]"
	  RACED       = "Race [detailed version]"
	  YRIMMIG     = "Year of immigration"
	  YRSUSA1     = "Years in the United States"
	  YRSUSA2     = "Years in the United States, intervalled"
	  HISPAN      = "Hispanic origin [general version]"
	  HISPAND     = "Hispanic origin [detailed version]"
	  RACESING    = "Race: Single race identification [general version]"
	  RACESINGD   = "Race: Single race identification [detailed version]"
	  MIGRATE1    = "Migration status, 1 year [general version]"
	  MIGRATE1D   = "Migration status, 1 year [detailed version]"
	  MIGPLAC1    = "State or country of residence 1 year ago"
	  MIGPUMA1    = "PUMA of residence 1 year ago"
	;

  ** Create unique PUMA ID **;

  %upuma() 
  
  ** HUD income categories **;
  
  %hud_inc_all()

  /* Create age categories */

  %age_cats();

  /* Adjust HHIncome for Inflation */

  if year = 2009 then hhincome_adj = hhincome * (229.594 / 214.537);
  else if year = 2010 then hhincome_adj = hhincome * (229.594 / 218.056);
  else if year = 2011 then hhincome_adj = hhincome * (229.594 / 224.939);
  else if year = 2012 then hhincome_adj = hhincome;

  /* Classify races - not reported ethnicity assumed to be non-hispanic */

  if hispan ~= 0 and hispan ~= 9 then race_ethnicity = "Hispanic/Latino";
  else if racesing = 1 then race_ethnicity = "White";
  else if racesing = 2 then race_ethnicity = "Black";
  else if racesing = 4 then race_ethnicity = "Asian and/or Pacific Islander";
  else if racesing = 3 or racesing = 5 then race_ethnicity = "Other";

  if GQ in (1,2) then numprec_new = numprec;
  else numprec_new = 0;

  label numprec_new = "Number of person records in the household";

  /* State only migration, ignore inter-PUMA, intra-city migration */

  if migrate1 = 3 and statefip = 11 then do;
		in_geo = upuma;
		mig_in = 1;
  end;
  else if migrate1 = 2 and statefip = 11 then mig_in = 2;
  else if migrate1 = 4 and statefip = 11 then mig_in = 3;
  else mig_in = 0;

  if migrate1 = 3 and migplac1 = 11 then do;
		out_geo = put( migplac1, z2. ) || put( migpuma1, z5. );
		mig_out = 1;
  end;
  else if migrate1 = 2 and migplac1 = 11 then mig_out = 2;
  else mig_out = 0;

  total = 1;

run;

/* Get age of household head */

data households;
	set DMPED.ACS_2009_12;
	where relate = 1;
	agecat_hhead = agecat;
	keep relate agecat_hhead agecat serial year;
run;

proc sort data = DMPED.ACS_2009_12_US; by year SERIAL; run;

proc sort data = households (keep = agecat_hhead serial year) out = households_out; by year SERIAL; run;

/* People in group quarters with no household head are given their own age as age of household head */

data to_analyze;
	merge DMPED.ACS_2009_12_US households_out;
	by year SERIAL;
	if agecat_hhead = '' then agecat_hhead = agecat;
run;

/* Calculate Totals */

proc tabulate data=to_analyze (where = (year = 2011 and statefip = 11)) format=comma10.0 noseps missing out=Totals_2011;
	class agecat;
	class sex;
	class race_ethnicity;
	class upuma;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' ' * (all = ' ' upuma = ' ')
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2011";
run;

proc tabulate data=to_analyze (where = (year = 2012 and statefip = 11)) format=comma10.0 noseps missing out=Totals_2012;
	class agecat;
	class sex;
	class race_ethnicity;
	class upuma;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' ' * (all = ' ' upuma = ' ')
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2012";
run;

/* Calculate in and out migration */

/* Out migration */

proc tabulate data=to_analyze (where = (mig_out = 1 and year = 2012)) format=comma10.0 noseps missing out=Out_Migration_DC_Other;
	class agecat;
	class sex;
	class race_ethnicity;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' '
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2012";
run;

data Out_Migration_DC_Other; length upuma $7.; set Out_Migration_DC_Other; upuma = ''; run;

/* In Migration */

proc tabulate data=to_analyze (where = (mig_in = 2 and year = 2012)) format=comma10.0 noseps missing out=In_Migration_DC_DC;
	class agecat;
	class sex;
	class race_ethnicity;
	class upuma;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' ' * (all = ' ' upuma = ' ')
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2012";
run;

proc tabulate data=to_analyze (where = (mig_in = 1 and year = 2012)) format=comma10.0 noseps missing out=In_Migration_DC_Other;
	class agecat;
	class sex;
	class race_ethnicity;
	class upuma;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' ' * (all = ' ' upuma = ' ')
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2012";
run;

proc tabulate data=to_analyze (where = (mig_in = 3 and year = 2012)) format=comma10.0 noseps missing out=In_Migration_DC_Int;
	class agecat;
	class sex;
	class race_ethnicity;
	class upuma;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' ' * (all = ' ' upuma = ' ')
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2012";
run;

proc sort data = Totals_2011 (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = total_2011)); by agecat sex race_ethnicity upuma; run;
proc sort data = Totals_2012 (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = total_2012)); by agecat sex race_ethnicity upuma; run;
proc sort data = Out_Migration_DC_Other (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = out_State)); by agecat sex race_ethnicity upuma; run;
proc sort data = In_Migration_DC_DC (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = in_DC)); by agecat sex race_ethnicity upuma; run;
proc sort data = In_Migration_DC_Other (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = in_State)); by agecat sex race_ethnicity upuma; run;
proc sort data = In_Migration_DC_Int (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = in_Int)); by agecat sex race_ethnicity upuma; run;

data DMPED.DC_Migration;
	merge Totals_2011 Totals_2012 In_Migration_DC_DC In_Migration_DC_Other In_Migration_DC_Int Out_Migration_DC_Other;
	by agecat sex race_ethnicity upuma;
run;

proc export data = DMPED.DC_Migration outfile = "D:\DCData\Libraries\DMPED\Data\DC_Migration.csv" dbms = csv replace; run;

proc means data = DMPED.DC_Migration nway missing noprint sum;
	var total_2011 total_2012 in_DC in_State in_Int out_State;
	class upuma;
	output out = DMPED.Migration_PUMA (drop = _TYPE_ _FREQ_) sum=;
run;

proc export data = DMPED.Migration_PUMA outfile = "D:\DCData\Libraries\DMPED\Data\Migration_PUMA.csv" dbms = csv replace; run;

proc means data = DMPED.DC_Migration nway missing noprint sum;
	var total_2011 total_2012 in_DC in_State in_Int out_State;
	class agecat;
	output out = DMPED.Migration_Age (drop = _TYPE_ _FREQ_) sum=;
run;

proc export data = DMPED.Migration_Age outfile = "D:\DCData\Libraries\DMPED\Data\Migration_Age.csv" dbms = csv replace; run;

proc means data = DMPED.DC_Migration nway missing noprint sum;
	var total_2011 total_2012 in_DC in_State in_Int out_State;
	class race_ethnicity;
	output out = DMPED.Migration_Race (drop = _TYPE_ _FREQ_) sum=;
run;

proc export data = DMPED.Migration_Race outfile = "D:\DCData\Libraries\DMPED\Data\Migration_Race.csv" dbms = csv replace; run;
