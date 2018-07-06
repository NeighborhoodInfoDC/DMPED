/**************************************************************************
 Program:  LgUnit - Export ACS Tract Data for Maps.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  7/6/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Use NCDB and ACS data to populte table 1A for the large
			   units study.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( NCDB )
%DCData_lib( ACS )

%let geo_suffix = _tr10;
%let geo = geo2010;


data xACS_2012_16; 
	set acs.acs_2012_16_dc_sum_tr&geo_suffix.;

	numhsgunits_2012_16 = sum(of numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3plusbd_2012_16);

	keep &geo. 

	num3br_under1000 num3br_under1500 pct3br_under1000 pct3br_under1500 pct3brrent_2012_16;

	numrnt3br_under1000 = sum(of numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16);
	numrnt3br_under1500 = numrenteroccupiedhu_2012_16 - numrtohu3b1500plus_2012_16;

	pctrnt3br_under1000 = num3br_under1000 / numrentocchu3plusbd_2006_10;
	pctrnt3br_under1500 = num3br_under1500 / numrentocchu3plusbd_2006_10;

	pct3brrent_2012_16 = numrentocchu3plusbd_2012_16 / numrenteroccupiedhu_2012_16;

	label pct3brall_2012_16 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_2012_16 = "Pct. of Rental Units with 3+ bedrooms" 
		  pct3brown_2012_16 = "Pct. of Owner Units with 3+ bedrooms" 
	;

run;
