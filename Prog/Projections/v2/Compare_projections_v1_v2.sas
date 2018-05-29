/**************************************************************************
 Program:  Compare_projections_v1_v2.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/18/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compare v1 and v2 projection summary files.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

proc compare base=DMPED.Projections_v1 compare=DMPED.Projections_v2 maxprint=(40,32000);
  id year age Geo2010 a15 race female lowinc hhsize hhacat;
  var p prob;
run;


