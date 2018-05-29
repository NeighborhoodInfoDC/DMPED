/**************************************************************************
   Program:  Geocode_iz_data.sas
   Library:  Requests
   Project:  NeighborhoodInfo DC
   Author:   M. Woluchem
   Created:  08/06/14
   Version:  SAS 8.2
   Environment:  SAS1 Server
   
   Description:  Geocodes CIZC data.

   Modifications:
  **************************************************************************/

  %include "L:\SAS\Inc\StdLocal.sas";

  ** Define libraries **;
  %DCData_lib( DMPED )
  %DCData_lib( RealProp ) 



  %DC_geocode(
  data=DMPED.CIZCTrackingMapDatav2,
  out=CIZCTrackingMapDatav2_geo,
  staddr=address,
  listunmatched=y
)


run;

data CIZCTrackingMapDatav2_geomar;
	merge CIZCTrackingMapDatav2_geo DMPED.CIZCTrackingMapDatav2_mar;
	by projid;

	*if projid = 14 then zipcode = 20011
	if projid = 22 then zipcode = 20018
	if projid = 25 then zipcode = 20015
	if projid = 28 then zipcode = 20002
	if projid = 29 then zipcode = 20032
	if projid = 40 then zipcode = 20008
	if projid = 47 then zipcode = 20018
	if projid = 48 then zipcode = 20019
	if projid = 51 then zipcode = 20009
	if projid = 55 then zipcode = 20009
	if projid = 57 then zipcode = 20032;
run;

data mar_data;
	length ssl $17;
	format ssl $17.;
	set dmped.cizctrackingmapdatav2_mar;
run;

proc sort data=dmped.cizctrackingmapdatav2_mar out=mar_data;
	by ssl;
run;

proc sort data=realprop.parcel_geo out=parcel_geo;
	by ssl;
run;

data cizctrackingmapdatav3;
	merge mar_data (in=a)  parcel_geo (in=b);
	by ssl;
	if a=1;
	run;
