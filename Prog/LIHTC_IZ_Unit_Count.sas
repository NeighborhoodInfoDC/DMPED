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

data iz_bed;
	set DMPED.IZ_BED_Pipeline_2018;
run;

proc sort data = lihtc;
	by construction_status ward2012;
run;

proc sort data = iz_bed;
	by construction_status ward2012 tenure;
run;


proc tabulate data = iz_bed;
where tenure = "Rental";
class construction_status ward2012 ;
var bedrooms:;
table construction_status all, bedrooms:, ward2012;
run;

proc tabulate data = iz_bed;
where tenure = "Sale";
class construction_status ward2012 ;
var bedrooms:;
table construction_status all, bedrooms:, ward2012;
run;

proc tabulate data = iz_bed;
where tenure = "";
class construction_status ward2012 ;
var bedrooms:;
table construction_status all, bedrooms:, ward2012;
run;

proc tabulate data = lihtc;
class yr_pis ward2012 ;
var n_:;
table yr_pis all, n_:, ward2012;
run;
