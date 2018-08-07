/**************************************************************************
 Program:  LgUnit - IPUMS ward weights.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  08/07/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create weights to summarize IPUMS data by wards.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( IPUMS )
%DCData_lib( ACS )

** Read Block-PUMA crosswalk **;

filename geocorr "&_dcdata_r_path\DMPED\Raw\ipums\geocorr14_PUMA2012.csv";

data geocorr14_PUMA2012;

  infile geocorr dsd stopover firstobs=3;

  length
    county $5
    tract $7
    block $4
    state $2
    puma12 $5
    stab $2
    cntyname $80
    PUMAname $80
    hus10 8
    afact 8;

  input
    county
    tract
    block
    state
    puma12
    stab
    cntyname
    PUMAname
    hus10
    afact
  ;

  length GeoBlk2010 $15;
  
  GeoBlk2010 = trim( county ) || trim( compress( tract, "." ) ) || block;
  
  length GeoBg2010 $12;
  
  GeoBg2010 = GeoBlk2010;
  
  drop stab cntyname PUMAname; 
  
  %Block10_to_ward12()
  
run;

filename geocorr clear;


%File_info( data=geocorr14_PUMA2012 )


** ACS SF data on housing units by bedroom size **;

proc transpose data=Acs.Acs_sf_2012_16_dc_bg10 out=ACS_tr;
  by geobg2010;
  var B25041e2-B25041e7;
run;

%File_info( data=ACS_tr )


proc sql noprint;
  create table A as
  select ACS_tr.*, ACS_sf.geobg2010, ACS_sf.B25041e1 from 
    ACS_tr left join 
    Acs.Acs_sf_2012_16_dc_bg10 as ACS_sf
  on Acs_tr.geobg2010 = Acs_sf.geobg2010
  order by Acs_tr.geobg2010;
quit;

proc print data=A (obs=50);
run;
