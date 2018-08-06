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
proc sort data = lihtc_subsidy;
	by nlihc_id;
run;

data pres_large_unit;
	merge prescat ph_unitsize (keep = nlihc_id units: link pubhous) lihtc_subsidy (keep = nlihc_id lihtc);
	by nlihc_id;
run;

proc sort data = pres_large_unit;
	by contract_number;
run;

data pres_large_unit;
	merge pres_large_unit sec8_2018 (keep = contract_number sec8 br:);
	by contract_number;
run;

 %DC_mar_geocode(
  data = Sec8_2018,
  staddr = address_line1_text,
  zip= zip_code,
  out = Sec8_2018geo,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

 %DC_mar_geocode(
  data = IZ_units_06_2018,
  staddr = project_address,
  zip=,
  out = iz,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

 %DC_mar_geocode(
  data = lihtc,
  staddr = proj_add,
  zip=,
  out = lihtc,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

proc sort data = lihtc;
	by ward2012;
run;

proc sort data = iz;
	by construction_status ward2012 tenure ami;
run;

proc sort data = Sec8_2018geo;
by ward2012;
run;

proc tabulate data = pres_large_unit;
where pubhous = 1 and unitstot ^= . and status = "A";
class ward2012;
var units:;
table units:, ward2012 = "Public Housing with Bed Count";
run;

proc tabulate data = pres_large_unit;
where pubhous = 1 and unitstot = . and status = "A";
class ward2012;
var Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min;
table Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min, ward2012 = "Public Housing w/o Bed Count";
run;

proc tabulate data = pres_large_unit ;
where Sec8 = 1 and status = "A";
class ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count ;
table br0_count br1_count br2_count br3_count br4_count br5plus_count, ward2012 = 'Multifamily and Section 8';
run ;


proc tabulate data = iz;
where bedrooms = 0 or bedrooms = 1 or bedrooms = 2;
class construction_status ward2012 ami tenure;
table tenure, N, ward2012*= 'IZ Units 0-2 Bedrooms'ami*construction_status ;
run;

proc tabulate data = iz;
where bedrooms >= 3;
class construction_status ward2012 ami tenure;
table tenure, N, ward2012= 'IZ Units 3+ Bedrooms'*ami*construction_status ;
run;


proc tabulate data = lihtc;
where nonprog ^= 1;
class ward2012 ;
var n_:;
table n_:, ward2012 = 'LIHTC Units';
run;


proc tabulate data = pres_large_unit;
where pubhous = . and sec8 = . and lihtc = .;
class ward2012;
var Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min;
table Proj_Units_Tot Proj_Units_Assist_Max Proj_Units_Assist_Min, ward2012 = 'Other Housing Units';
run;
