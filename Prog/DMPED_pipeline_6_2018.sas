/**************************************************************************
 Program:  DMPED_pipeline_6_2018.sas
 Library:  HUD
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  08/07/2018
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read DMPED Pipeline database and create separate files for
 HPTF and IZ projects.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED );

*--- EDIT PARAMETERS BELOW -----------------------------------------;

%DMPED_pipeline_read_update_file(
  filedate = '18jun2018'd,  /** Enter date of DMPED database download as SAS date value, ex: '25nov2014'd **/
  revisions = %str(New file.)
)

run;
