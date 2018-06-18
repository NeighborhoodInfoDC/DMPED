/**************************************************************************
 Program:  DMPED_pipeline_6_2018.sas
 Library:  HUD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/15/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read DMPED Pipeline database and create separate files for
 HPTF and IZ projects.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )


%DMPED_pipeline_read_update_file( year=2018, filedate='18jun2018'd, finalize = Y )
