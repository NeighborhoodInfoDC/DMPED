/**************************************************************************
 Program:  LgUnit - Export ACS Tract Data for Maps.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  7/6/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Export CSV of 2012-16 ACS data for large units maps. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

%let geo_suffix = _tr10;
%let geo = geo2010;


data ACS_2012_16_map; 
	set acs.acs_2012_16_dc_sum_tr&geo_suffix.;

	numhsgunits_2012_16 = sum(of numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3plusbd_2012_16);

	keep &geo. numhsgunits_2012_16 numrenteroccupiedhu_2012_16 all3brplusrentunits numrnt3br_under1000 numrnt3br_under1500 pctrnt3br_under1000 pctrnt3br_under1500 pct3brrent;

	all3brplusrentunits = sum(of numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16
							numrtohu3b1000to1499_2012_16 numrtohu3b1500plus_2012_16);

	numrnt3br_under1000 = sum(of numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16);
	numrnt3br_under1500 = sum(of numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16 numrtohu3b1000to1499_2012_16);

	pctrnt3br_under1000 = numrnt3br_under1000 / all3brplusrentunits;
	pctrnt3br_under1500 = numrnt3br_under1500 / all3brplusrentunits;

	pct3brrent = numrentocchu3plusbd_2012_16 / numrenteroccupiedhu_2012_16;

	label all3brplusrentunits = "All 3br+ rental units"
		  numrnt3br_under1000 = "Number of 3br+ rental units under $1,000"
		  numrnt3br_under1500 = "Number of 3br+ rental units under $1,500"
		  pctrnt3br_under1000 = "Percent of 3br+ rental units under $1,000"
		  pctrnt3br_under1500 = "Percent of 3br+ rental units under $1,500"
		  pct3brrent = "Percent of all rental units that are 3br+"
		  ;

run;


proc export data = ACS_2012_16_map
	outfile = "&_dcdata_default_path.\DMPED\Prog\ACS_2012_16_map.csv"
	dbms = csv replace;
run;

proc univariate data=acs_2012_16_map;
id geo2010;
var numrenteroccupiedhu_2012_16 all3brplusrentunits pct3brrent;
run; 

/* End of program */
