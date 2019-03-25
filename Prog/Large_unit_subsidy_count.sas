/**************************************************************************
 Program:  Large_unit_subsidy_count.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  7/17/2018
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Count Units by Bedroom Size
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( HUD )
%DCData_lib( DMPED )
%DCData_lib( MAR )
%DCData_lib( PRESCAT )

data lihtc;
	set HUD.lihtc_2016_dc /*(rename =(_notes_ = notes))*/;
	if proj_add = "TWINING TER" then proj_add = "2505 N St. SE";
	units_w_brsize = sum( n_0br, n_1br, n_2br, n_3br, n_4br, 0 );
run;

  data IZ_units_06_2018;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\IZ_Units_06-18-2018.csv" dsd stopover lrecl=2000 firstobs=2;
input
	Project :$80.
	Construction_Status :$40.
	Project_Address :$80.
	IZ_Unit_Num :$10.
	Tenure :$10.
	Bedrooms :1.
	AMI :$10.
	Estimated_Availability_Date :$12.
	drop_ : 2.
	Unit_Total :3.;

run;

data Sec8_2018 ;
set HUD.Sec8mf_2018_06_dc ;
sec8 = 1;
units_w_brsize = sum( br0_count, br1_count, br2_count, br3_count, br4_count, br5plus_count, 0 );
run ;

  data 
    PH_Unitsize;
 infile "L:\Libraries\DMPED\Raw\Public Housing List w Unit Size.csv" dsd stopover lrecl=2000 firstobs=2;
input
                   program : $40.
                   nlihc_id : $8.
                   proj_name : $80.
				   proj_addr: $80.
                   units0b : 4.
                   units1b : 4.
                   units2b : 4.
                   units3b : 4.
                   units4b : 4.
                   units5b: 4.
                   units6b : 4.
                   unitstot : 4.
                   link : $80.;

pubhous = 1;

units_w_brsize = sum( units0b, units1b, units2b, units3b, units4b, units5b, units6b, 0 );

run;

data prescat;
	set prescat.project;
  where status = 'A';
run;


data lihtc_subsidy;
	set prescat.subsidy;
	if Subsidy_Active = 0 then delete;
	if portfolio ^= "LIHTC" then delete;
	LIHTC = 1;
run;

proc sort data =prescat;
	by nlihc_id;
run;
proc sort data = ph_unitsize;
	by nlihc_id;
run;
proc sort data = lihtc_subsidy nodupkey;
	by nlihc_id;
run;

data pres_large_unit_a;
	merge 
	prescat (in=in1) 
	PresCat.subsidy (where=(program='PUBHSNG' and subsidy_active) keep=nlihc_id program subsidy_active) 
	ph_unitsize (keep = nlihc_id units: link pubhous in=inphusz) 
	lihtc_subsidy (keep = nlihc_id lihtc);
	by nlihc_id;
  if in1;
  if program ~= 'PUBHSNG' then pubhous = 0;
  if inphusz and not pubhous then put nlihc_id= proj_name= (units:)(=);
run;

proc sort data = pres_large_unit_a;
	by contract_number;
run;

data pres_large_unit;
	merge pres_large_unit_a (in=in1) sec8_2018 (keep = contract_number sec8 br: assisted_units_count units_w_brsize);
	by contract_number;
  if in1;
  
  if pubhous = 1 and unitstot = . and status = "A" then unitstot = max( Proj_Units_Tot, Proj_Units_Assist_Max );
run;

 %DC_mar_geocode(
  data = IZ_units_06_2018,
  staddr = project_address,
  zip=,
  out = iz,
  geo_match = Y,
  streetalt_file=,
  debug = N,
  mprint = Y
);

 %DC_mar_geocode(
  data = lihtc,
  staddr = proj_add,
  zip=,
  out = lihtc,
  geo_match = Y,
  streetalt_file=,
  debug = N,
  mprint = Y
);

options orientation=landscape missing='-';

ods rtf file="&_dcdata_default_path\DMPED\Prog\Large_unit_subsidy_count.rtf" style=Styles.Rtf_arial_9pt;
ods listing close;

title2 '** Public housing **';

proc tabulate data = pres_large_unit missing format=comma10.0;
where pubhous = 1 and status = "A";
class ward2012;
var units:;
table 
  n='Projects' (unitstot units_w_brsize units0b units1b units2b units3b units4b units5b units6b)*sum=' ', 
  all='DC' ward2012 = " ";
label
  units0b = '\~ No bedrooms'
  units1b = '\~ 1 bedroom'
  units2b = '\~ 2 bedrooms'
  units3b = '\~ 3 bedrooms'
  units4b = '\~ 4 bedrooms'
  units5b = '\~ 5 bedrooms'
  units6b = '\~ 6+ bedrooms'
  unitstot = 'Total units'
  units_w_brsize = 'Units w/bedroom size';
run;

title2 '** Multifamily Section 8 **';

proc tabulate data = pres_large_unit missing format=comma10.0;
where Sec8 = 1 and status = "A";
class ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count assisted_units_count units_w_brsize;
table 
  n='Projects' (assisted_units_count units_w_brsize br0_count br1_count br2_count br3_count br4_count br5plus_count)*sum=' ', 
  all='DC' ward2012 = ' ';
label
  br0_count = '\~ No bedrooms'
  br1_count = '\~ 1 bedroom'
  br2_count = '\~ 2 bedrooms' 
  br3_count = '\~ 3 bedrooms' 
  br4_count = '\~ 4 bedrooms' 
  br5plus_count = '\~ 5+ bedrooms'
  assisted_units_count = 'Total assisted units'
  units_w_brsize = 'Units w/bedroom size';
run ;

title2 '** Inclusionary Zoning **';

proc format;
  value bedrooms3p
    0-2 = '0-2 BR'
    3-high = '3+ BR';
  value $blankns
    ' ' = 'Not specified';
  value yr_pis
    .c = 'Unknown'
    1990-1999 = '1990-1999'
    2000-2009 = '2000-2009'
    2010-2016 = '2010-2016';
  value $construction_status
    '1. Planning' = 'In planning'
    '2. Under Construction' = 'Under construction'
    '3. Construction Complete/Lottery Pending',
    '4. Construction Complete/Lottery Held',
    '5. Subsequent Lottery Pending' = 'Construction completed';
run;

proc tabulate data = iz missing format=comma10.0;
class bedrooms construction_status ward2012 ami tenure /preloadfmt;
table 
  (all='Total IZ units' tenure), 
  (all='Total' construction_status=' '), 
  N=' ' * (all='Total' ami=' ')*bedrooms=' ' 
  / printmiss condense;
table 
  (all='Total IZ units' tenure), 
  (all='Total' Ward2012=' '), 
  N=' ' * (all='Total' ami=' ')*bedrooms=' ' 
  / printmiss;
format bedrooms bedrooms3p. construction_status $construction_status. tenure ami $blankns.;
run;

title2 '** LIHTC **';

proc tabulate data = lihtc missing format=comma10.0;
where nonprog ^= 1 and not( missing( ward2012 ) );
class ward2012 yr_pis /preloadfmt;
var n_: li_unitr units_w_brsize;
table n='Projects' (n_unitsr li_unitr units_w_brsize n_0br n_1br n_2br n_3br n_4br)*sum=' ', (all='DC' ward2012=' ') / printmiss;
table n='Projects' (n_unitsr li_unitr units_w_brsize n_0br n_1br n_2br n_3br n_4br)*sum=' ', (all='DC' yr_pis='Year Placed in Service');
format yr_pis yr_pis.;
label
  n_unitsr = 'Total units'
  li_unitr = 'Low-income units'
  units_w_brsize = 'Units w/bedroom size'
  n_0br = '\~ No bedrooms' 
  n_1br = '\~ 1 bedroom' 
  n_2br = '\~ 2 bedrooms' 
  n_3br = '\~ 3 bedrooms' 
  n_4br = '\~ 4+ bedrooms';
run;

title2 '** Other subsidies **';

proc tabulate data = pres_large_unit missing format=comma10.0;
where pubhous = . and sec8 = . and lihtc = .;
class ward2012;
var Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min;
table 
  n='Projects' (Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min)*sum=' ', 
  all='DC' ward2012 = ' ';
run;

ods listing;
ods rtf close;

title2;
