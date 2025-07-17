/**************************************************************************
 Program:  Components_pop_chg_2010_2023.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/31/24
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  130
 
 Description:  Process Census data on components of pop change for DC. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

** Read 2010 - 2020 populations components data **;

filename fimport "&_dcdata_r_path\Census\Raw\Census population estimates\co-est2020-alldata.csv" lrecl=5000;

proc import out=Co_est2020
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;
  guessingrows=max;
run;

filename fimport clear;

/*%File_info( data=Co_est2020, printobs=0 )*/

run;

proc print data=Co_est2020;
  where state = 11 and county = 1;
  id state county;
  var POPESTIMATE2020 BIRTHS2020 DEATHS2020 INTERNATIONALMIG2020 DOMESTICMIG2020;
  title2 'Co_est2020';
run;


** Read 2020 - 2023 populations components data **;

filename fimport "&_dcdata_r_path\Census\Raw\Census population estimates\co-est2023-alldata.csv" lrecl=5000;

proc import out=Co_est2023
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;
  guessingrows=max;
run;

filename fimport clear;

/*%File_info( data=Co_est2023, printobs=0 )*/

run;

proc print data=Co_est2023;
  where state = 11 and county = 1;
  id state county;
  var POPESTIMATE2020 BIRTHS2020 DEATHS2020 INTERNATIONALMIG2020 DOMESTICMIG2020;
  title2 'Co_est2023';
run;


** Combine data sets **;

data Components;

  length ucounty $ 5 CTYNAME $ 40;
  
  merge 
    Co_est2020 (drop=NATURALINC2020)
    Co_est2023;
  by state county;
  
  where state in ( 11, 24, 51 );
  
  ucounty = cat( put( state, z2. ), put( county, z3. ) );
  
  if ucounty in (
    "11001", "24017", "24021", "24031", "24033", 
    "51013", "51059", "51107", "51153", "51510", 
    "51600", "51610", "51683", "51685" );

  format _all_ ;
  informat _all_ ;
  
  ** Rename older natural change vars to match newer names **;

  rename
    NATURALINC2010=NATURALCHG2010
    NATURALINC2011=NATURALCHG2011
    NATURALINC2012=NATURALCHG2012
    NATURALINC2013=NATURALCHG2013
    NATURALINC2014=NATURALCHG2014
    NATURALINC2015=NATURALCHG2015
    NATURALINC2016=NATURALCHG2016
    NATURALINC2017=NATURALCHG2017
    NATURALINC2018=NATURALCHG2018
    NATURALINC2019=NATURALCHG2019;

run;

%File_info( data=Components, printobs=40, printchar=Y )


** Transpose components data **;

%let start_yr = 2011;
%let end_yr = 2023;

data Components_tr;

  set Components;
  
  array antr{&start_yr.:&end_yr.} naturalchg&start_yr.-naturalchg&end_yr.; 
  array aint{&start_yr.:&end_yr.} internationalmig&start_yr.-internationalmig&end_yr.; 
  array adom{&start_yr.:&end_yr.} domesticmig&start_yr.-domesticmig&end_yr.; 
  array anet{&start_yr.:&end_yr.} netmig&start_yr.-netmig&end_yr.; 

  do Year = &start_yr. to &end_yr.;

    naturalchg = antr{Year};
    internationalmig = aint{Year};
    domesticmig = adom{Year};
    netmig = anet{Year};
    totalchg = naturalchg + netmig;
    
    output;
    
  end;

  keep ucounty Year totalchg naturalchg internationalmig domesticmig netmig;

  label
    naturalchg = 'Natural'
    internationalmig = 'International'
    domesticmig = 'Domestic'
    netmig = 'Net migration'
    totalchg = 'Total change';

run;


** Create format for labeling years **;

/** Macro Create_year_labels - Start Definition **/

%macro Create_year_labels( start, end );

  proc format;
    value yearpopchg
    
    %do i = &start %to &end;
      &i = "%eval(&i-1)-&i"
    %end;
    ;
    
  run;

%mend Create_year_labels;

/** End Macro Definition **/


%Create_year_labels( &start_yr, &end_yr )

ods csvall body="&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Components_pop_chg_2010_2023.csv";

proc tabulate data=Components_tr format=comma10.0 noseps missing;
  var totalchg naturalchg netmig internationalmig domesticmig;
  class year ucounty;  
  table 
    /** Pages **/
    ( all='Greater DC Region' ucounty=' ' ) * sum=' ',
    /** Rows **/
    totalchg naturalchg netmig internationalmig domesticmig,
    /** Columns **/
    year=' '
    / condense box='Components of population change';
  format year yearpopchg. ucounty $cnty22allf.;
run;

ods csvall close;

