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
run;

  data IZ_units_06_2018;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\IZ_units_06_2018.csv" dsd stopover lrecl=2000 firstobs=2;
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
	merge prescat (in=in1) ph_unitsize (keep = nlihc_id units: link pubhous) lihtc_subsidy (keep = nlihc_id lihtc);
	by nlihc_id;
  if in1;
run;

proc sort data = pres_large_unit_a;
	by contract_number;
run;

data pres_large_unit;
	merge pres_large_unit_a (in=in1) sec8_2018 (keep = contract_number sec8 br:);
	by contract_number;
  if in1;
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

options orientation=landscape;

ods rtf file="&_dcdata_default_path\DMPED\Prog\Large_unit_subsidy_count.rtf" style=Styles.Rtf_arial_9pt;
ods listing close;

proc tabulate data = pres_large_unit missing format=comma10.0;
where pubhous = 1 and unitstot ^= . and status = "A";
class ward2012;
var units:;
table n='Projects' (units:)*sum=' ', all='DC' ward2012 = "Public Housing with Bed Count";
run;

proc tabulate data = pres_large_unit missing format=comma10.0;
where pubhous = 1 and unitstot = . and status = "A";
class ward2012;
var Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min;
table n='Projects' (Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min)*sum=' ', all='DC' ward2012 = "Public Housing w/o Bed Count";
run;

proc tabulate data = pres_large_unit missing format=comma10.0;
where Sec8 = 1 and status = "A";
class ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count ;
table 
  n='Projects' (br0_count br1_count br2_count br3_count br4_count br5plus_count)*sum=' ', 
  all='DC' ward2012 = 'Multifamily and Section 8';
run ;


proc format;
  value bedrooms3p
    0-2 = '0-2 bedrooms'
    3-high = '3+ bedrooms';
  value $blankns
    ' ' = 'Not specified';
run;

proc tabulate data = iz missing format=comma10.0;
class bedrooms construction_status ward2012 ami tenure /preloadfmt;
table 
  (all='DC' ward2012= ' ')*(all='Total IZ units' tenure), 
  (all='Total' construction_status=' '), 
  N='IZ Units by AMI and Bedroom Size' * (all='Total' ami=' ')*bedrooms=' ' 
  / printmiss;
format bedrooms bedrooms3p. tenure ami $blankns.;
run;

proc tabulate data = lihtc missing format=comma10.0;
where nonprog ^= 1 and not( missing( ward2012 ) );
class ward2012 ;
var n_:;
table n='Projects' (n_:)*sum=' ', (all='DC' ward2012='Units in LIHTC Projects');
run;


proc tabulate data = pres_large_unit missing format=comma10.0;
where pubhous = . and sec8 = . and lihtc = .;
class ward2012;
var Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min;
table 
  n='Projects' (Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min)*sum=' ', 
  all='DC' ward2012 = 'Other Housing Units in Assisted Projects';
run;

ods listing;
ods rtf close;
