/**************************************************************************
 Program:  Households_by_race.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  03/18/25
 Version:  SAS 9.4
 Environment:  Remote Windows session (SAS1)
 GitHub issue:  130
 
 Description:  Get data on households by race from decennial census,
 2000, 2010, 2020. 

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( DMPED )

/** Macro Convert_vars - Start Definition **/

%macro Convert_vars( vars= );

%local i v;

%let i = 1;
%let v = %scan( &vars, &i, %str(,) );

%do %until ( &v = );

  _&v = input( &v, best32. );
  
  drop &v;
  rename _&v = &v;

  %let i = %eval( &i + 1 );
  %let v = %scan( &vars, &i, %str(,) );

%end;

%mend Convert_vars;

/** End Macro Definition **/


****  2020  ****;

%let Census_2020_total = P16_001N;
/**%let Census_2020_race = %str(P16H_001N,P16I_001N,P16J_001N,P16K_001N,P16L_001N,P16M_001N,P16N_001N,P16O_001N);**/
%let Census_2020_race = %str(P16B_001N,P16C_001N,P16D_001N,P16E_001N,P16F_001N,P16G_001N,P16H_001N,P16I_001N);

%Get_census_api(

  api="https://api.census.gov/data/2020/dec/dhc?get=NAME,%trim(&Census_2020_total),%trim(&Census_2020_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2020
  
)

data Census_2020;

  set Census_2020;
  
  retain Year 2020;
  
  %Convert_vars( vars=&Census_2020_total )
  %Convert_vars( vars=&Census_2020_race )
  
  TotalHHs = _P16_001N;
  BlackHHs = _P16B_001N;
  AIANHHs = _P16C_001N;
  AsianHHs = _P16D_001N;
  NHOPIHHs = _P16E_001N;
  OtherRacHHs = _P16F_001N;
  MultiRacHHs = _P16G_001N;
  LatinoHHs = _P16H_001N;
  NHWhiteHHs = _P16I_001N;
  
  AsnPIHHs = AsianHHs + NHOPIHHs;
  AllOtherHHs = AIANHHs + OtherRacHHs + MultiRacHHs;
  
run;

%File_info( data=Census_2020 )

run;


****  2010   ****;

%let Census_2010_total = P015001;
/**%let Census_2010_race = %str(P015003,P015004,P015005,P015006,P015007,P015008,P015009,P015010);**/
%let Census_2010_race = %str(P018B001,P018C001,P018D001,P018E001,P018F001,P018G001,P018H001,P018I001);


%Get_census_api(

  api="https://api.census.gov/data/2010/dec/sf1?get=NAME,%trim(&Census_2010_total),%trim(&Census_2010_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2010
  
)

data Census_2010;

  set Census_2010;
  
  retain Year 2010;
  
  %Convert_vars( vars=&Census_2010_total )
  %Convert_vars( vars=&Census_2010_race )
  
  TotalHHs = _P015001;
  BlackHHs = _P018B001;
  AIANHHs = _P018C001;
  AsianHHs = _P018D001;
  NHOPIHHs = _P018E001;
  OtherRacHHs = _P018F001;
  MultiRacHHs = _P018G001;
  LatinoHHs = _P018H001;
  NHWhiteHHs = _P018I001;
  
  AsnPIHHs = AsianHHs + NHOPIHHs;
  AllOtherHHs = AIANHHs + OtherRacHHs + MultiRacHHs;

run;

%File_info( data=Census_2010 )

run;


****  2000   ****;

%let Census_2000_total = P015001;
%let Census_2000_race = %str(P015B001,P015C001,P015D001,P015E001,P015F001,P015G001,P015H001,P015I001);


%Get_census_api(

  api="https://api.census.gov/data/2000/dec/sf1?get=NAME,%trim(&Census_2000_total),%trim(&Census_2000_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2000
  
)

data Census_2000;

  set Census_2000;
  
  retain Year 2000;
  
  %Convert_vars( vars=&Census_2000_total )
  %Convert_vars( vars=&Census_2000_race )
  
  TotalHHs = _P015001;
  BlackHHs = _P015B001;
  AIANHHs = _P015C001;
  AsianHHs = _P015D001;
  NHOPIHHs = _P015E001;
  OtherRacHHs = _P015F001;
  MultiRacHHs = _P015G001;
  LatinoHHs = _P015H001;
  NHWhiteHHs = _P015I001;
  
  AsnPIHHs = AsianHHs + NHOPIHHs;
  AllOtherHHs = AIANHHs + OtherRacHHs + MultiRacHHs;

run;

%File_info( data=Census_2000 )

run;


** Combine data **;

data Census_all;

  set Census_2000 Census_2010 Census_2020;
  
  drop P015: P018: P16: ;
  
run;


ods csvall body="&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Households_by_race.csv";

proc tabulate data=Census_all format=comma12.0 noseps missing;
  class Year;
  var TotalHHs AsnPIHHs BlackHHs LatinoHHs NHWhiteHHs AllOtherHHs;
  table 
    /** Rows **/
    Year=' ',
    /** Columns **/
    sum='Households by race/ethnicity of householder' * ( TotalHHs AsnPIHHs BlackHHs LatinoHHs NHWhiteHHs AllOtherHHs )
  ;
  label
    TotalHHs = "Total"
	AsnPIHHs = "Asian + Pacific Islander alone"
    BlackHHs = "Black alone"
    LatinoHHs = "Latino"
    NHWhiteHHs = "Non-Latino white alone"
    AllOtherHHs = "All other races";

run;

ods csvall close;
