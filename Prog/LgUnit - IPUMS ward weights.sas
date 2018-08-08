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
  
  ** Numeric puma **;
  
  puma = input( substr( puma12, 3, 3 ), 3. );

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
  select geocorr.*, bg.*, hus10 * ( col1 / B25041e1 ) as wt from
  geocorr14_PUMA2012 as geocorr
  full join  
  (
    select ACS_tr.*, ACS_sf.geobg2010, ACS_sf.B25041e1 from 
      ACS_tr left join 
      Acs.Acs_sf_2012_16_dc_bg10 as ACS_sf
    on Acs_tr.geobg2010 = Acs_sf.geobg2010
  ) as bg
  on geocorr.GeoBg2010 = bg.GeoBg2010 
  order by geocorr.GeoBlk2010, bg._name_;
quit;

proc print data=A (obs=50);
 by GeoBlk2010;
 id GeoBlk2010;
 sumby GeoBlk2010;
 sum wt;
 var _label_ puma ward2012 hus10 col1 B25041e1 wt;
run;

proc summary data=A nway;
  class _label_ puma ward2012;
  var wt;
  output out=A_ward (drop=_type_ _freq_ rename=(_label_=BrSize)) sum=;
run;

proc print data=A_ward (obs=50);
run;

proc summary data=A nway;
  class _label_ puma;
  var wt;
  output out=A_puma (drop=_type_ _freq_ rename=(_label_=BrSize)) sum=wt_puma;
run;

data Puma12_ward2012_weights;

  merge
    A_ward
    A_puma;
  by BrSize puma;
 
  adjwt = wt / wt_puma;
  
run;

%File_info( data=Puma12_ward2012_weights, printobs=0 )

proc print data=Puma12_ward2012_weights (obs=50);
  by BrSize puma;
  id BrSize puma;
  sumby puma;
  sum adjwt;
run;



** Test weights **;

data ACS_micro;

  set Ipums.Acs_2012_16_dc (keep=serial puma bedrooms gq pernum perwt hhwt);
  
  where gq not in ( 3, 4 );
  
  retain total 1;
  
run;

proc format;
  value bedrooms_to_brsize
    0 = "N/A"
    1 = "No bedroom"
    2 = "1 bedroom"
    3 = "2 bedrooms"
    4 = "3 bedrooms"
    5 = "4 bedrooms"
    6-high = "5 or more bedrooms";
run;

proc sql noprint;
  create table ACS_micro_ward as
  select ACS_micro.*, Wt.BrSize, Wt.Puma, Wt.Ward2012, Wt.adjwt, perwt * adjwt as wperwt, hhwt * adjwt as whhwt from 
  ACS_micro
  full join
  Puma12_ward2012_weights as Wt
  on ACS_micro.puma = Wt.puma and put( ACS_micro.bedrooms, bedrooms_to_brsize. ) = Wt.BrSize
  order by serial, pernum;
quit;

title3 '--- ORIGINAL WEIGHTED 2012-16 ACS MICRODATA ---';

proc tabulate data=ACS_micro format=comma12.0 noseps missing;
  where pernum = 1;
  class puma bedrooms;
  var total;
  weight hhwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Occupied housing units' * sum=' ' * ( all='DC' puma='By PUMA' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

title3 '--- REWEIGHTED 2012-16 ACS MICRODATA ---';

proc tabulate data=ACS_micro_ward format=comma12.0 noseps missing;
  where pernum = 1;
  class puma bedrooms;
  var total;
  weight whhwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Occupied housing units' * sum=' ' * ( all='DC' puma='By PUMA' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

proc tabulate data=ACS_micro_ward format=comma9.0 noseps missing;
  where pernum = 1;
  class ward2012 bedrooms;
  var total;
  weight whhwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Housing units' * sum=' ' * ( all='DC' ward2012='By Ward' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

title2;


title3 '--- ORIGINAL WEIGHTED DATA ---';

proc tabulate data=ACS_micro format=comma12.0 noseps missing;
  class puma bedrooms;
  var total;
  weight perwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Persons' * sum=' ' * ( all='DC' puma='By PUMA' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

title3 '--- REWEIGHTED DATA ---';

proc tabulate data=ACS_micro_ward format=comma12.0 noseps missing;
  class puma bedrooms;
  var total;
  weight wperwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Persons' * sum=' ' * ( all='DC' puma='By PUMA' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

proc tabulate data=ACS_micro_ward format=comma9.0 noseps missing;
  class ward2012 bedrooms;
  var total;
  weight wperwt;
  table 
    /** Rows **/
    all='Total' bedrooms,
    /** Columns **/
    total='Persons' * sum=' ' * ( all='DC' ward2012='By Ward' )
  ;
  format bedrooms bedrooms_to_brsize.;
run;

title2;
