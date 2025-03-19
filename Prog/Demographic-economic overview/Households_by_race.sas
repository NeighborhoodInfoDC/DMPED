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
  
  TotalHHs = P16_001N;
  BlackHHs = P16B_001N;
  AIANHHs = P16C_001N;
  AsianHHs = P16D_001N;
  NHOPIHHs = P16E_001N;
  OtherRacHHs = P16F_001N;
  MultiRacHHs = P16G_001N;
  LatinoHHs = P16H_001N;
  NHWhteHHs = P16I_001N;
  
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
  
  TotalHHs = P015001;
  BlackHHs = P018B001;
  AIANHHs = P018C001;
  AsianHHs = P018D001;
  NHOPIHHs = P018E001;
  OtherRacHHs = P018F001;
  MultiRacHHs = P018G001;
  LatinoHHs = P018H001;
  NHWhteHHs = P018I001;
  
run;

%File_info( data=Census_2010 )

run;


****  2000   ****;

%let Census_2000_total = P015001;
%let Census_2000_race = %str(P018B001,P018C001,P018D001,P018E001,P018F001,P018G001,P018H001,P018I001);


%Get_census_api(

  api="https://api.census.gov/data/2000/dec/sf1?get=NAME,%trim(&Census_2000_total),%trim(&Census_2000_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2000
  
)

data Census_2000;

  set Census_2000;
  
  retain Year 2000;
  
  %Convert_vars( vars=&Census_2000_total )
  %Convert_vars( vars=&Census_2000_race )
  
  TotalHHs = P015001;
  BlackHHs = P018B001;
  AIANHHs = P018C001;
  AsianHHs = P018D001;
  NHOPIHHs = P018E001;
  OtherRacHHs = P018F001;
  MultiRacHHs = P018G001;
  LatinoHHs = P018H001;
  NHWhteHHs = P018I001;
  
run;

%File_info( data=Census_2000 )

run;

