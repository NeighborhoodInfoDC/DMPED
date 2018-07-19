/**************************************************************************
 Program:  Sec8 with bedroom and ward
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   W. Oliver
 Created:  7/19/2018
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

data Sec8_2018 ;
set HUD.Sec8mf_2018_06_dc ;
/*city_summary (in = a ) ;
if a ward2012 = "0" ;*/
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
proc sort data = Sec8_2018geo;
by ward2012;
run;

proc summary data = Sec8_2018geo ;
by ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count ;
output out = Sec8_ward ;
run ;

proc tabulate data = Sec8_2018geo ;
class ward2012 ;
var br0_count br1_count br2_count br3_count br4_count br5plus_count ;
table ward2012 ;
run ;
