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
%let Census_2020_race = %str(P16H_001N,P16I_001N,P16J_001N,P16K_001N,P16L_001N,P16M_001N,P16N_001N,P16O_001N);

%Get_census_api(

  api="https://api.census.gov/data/2020/dec/dhc?get=NAME,%trim(&Census_2020_total),%trim(&Census_2020_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2020
  
)

data Census_2020;

  set Census_2020;
  
  retain Year 2020;
  
  %Convert_vars( vars=&Census_2020_total )
  %Convert_vars( vars=&Census_2020_race )
  
  Check_sum = sum( &Census_2020_race );
  
run;

%File_info( data=Census_2020 )

run;


****  2010   ****;

%let Census_2010_total = P015001;
%let Census_2010_race = %str(P015003,P015004,P015005,P015006,P015007,P015008,P015009,P015010);

%Get_census_api(

  api="https://api.census.gov/data/2010/dec/sf1?get=NAME,%trim(&Census_2010_total),%trim(&Census_2010_race)&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2010
  
)

data Census_2010;

  set Census_2010;
  
  retain Year 2010;
  
  %Convert_vars( vars=&Census_2010_total )
  %Convert_vars( vars=&Census_2010_race )
  
  Check_sum = sum( &Census_2010_race );
  
run;

%File_info( data=Census_2010 )

run;
