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


%let Census_2020_vars = P16_001N,P16H_001N,P16I_001N,P16J_001N,P16K_001N,P16L_001N,P16M_001N,P16N_001N,P16O_001N;

%Get_census_api(

  api="https://api.census.gov/data/2020/dec/dhc?get=NAME,&Census_2020_vars.&for=state:11%nrstr(&key)=&_dcdata_census_api_key",
  out=Census_2020
  
)

data Census_2020;

  set Census_2020;
  
  %Convert_vars( vars=&Census_2020_vars )
  
run;

%File_info( data=Census_2020 )

run;
