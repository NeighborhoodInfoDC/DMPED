/**************************************************************************
 Program:  LIHTC_IZ_Unit_Count.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  7/17/2018
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Count LIHTC and IZ Bedrooms
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( HUD )
%DCData_lib( DMPED )
%DCData_lib( MAR )

data lihtc;
	set HUD.lihtc_2016_dc /*(rename =(_notes_ = notes))*/;
	if proj_add = "TWINING TER" then proj_add = "2505 N St. SE";
run;

  data 
    IZ_units_06_2018_dc;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\IZ_Units_&month._&year..csv" dsd stopover lrecl=2000 firstobs=2;
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
run ;

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
  data = IZ_units_06_2018_dc,
  staddr = proj_address,
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

proc tabulate data = Sec8_2018geo ;
class ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count ;
table ward2012, br0_count br1_count br2_count br3_count br4_count br5plus_count;
run ;

proc tabulate data = iz;
where bedrooms = 0 or bedrooms = 1 or bedrooms = 2;
class construction_status ward2012 ami tenure;
*var bedrooms;
table tenure, N, ward2012*ami*construction_status;
run;


proc tabulate data = iz;
where bedrooms >= 3;
class construction_status ward2012 ami tenure;
*var bedrooms;
table tenure, N, ward2012*ami*construction_status;
run;


proc tabulate data = lihtc;
where nonprog ^= 1;
class ward2012 ;
var n_:;
table n_:, ward2012;
run;
