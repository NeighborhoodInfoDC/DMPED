/**************************************************************************
 Program:  Read_dmped2.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read dmped2.csv file from Graham's PC.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

filename fimport "L:\Libraries\DMPED\Raw\Projections\v1\dmped2.csv" lrecl=256;

proc import out=Projections_v1
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;

run;

data DMPED.Projections_v1;

  set Projections_v1;
  
  format _all_ ;
  informat _all_ ;
  
  length Geo2010 $ 11;
  
  Geo2010 = put( '11001' || put( tract, z6. ), $geo10v. );

  format Geo2010 $geo10a.;
  
run;

proc sort data=DMPED.Projections_v1;
  by year age Geo2010 a15 race female lowinc hhsize hhacat;

%File_info( data=DMPED.Projections_v1, freqvars=year race female hhsize hhacat lowinc Geo2010 )

run;
