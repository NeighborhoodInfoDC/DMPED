/**************************************************************************
 Program:  Contents_projection_files.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/11/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Contents of projection data files (transfered from
STATA).

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

%File_info( data=DMPED.agedist )

%File_info( data=DMPED.dcpop, freqvars=year )

run;
