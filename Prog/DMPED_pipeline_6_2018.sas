/**************************************************************************
 Program:  DMPED_pipeline_6_2018.sas
 Library:  DMPED
 Project:  Urban-Greater DC 
 Author:   M. Cohen
 Created:  7/17/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read DMPED Pipeline database and create separate files for
 HPTF and IZ projects.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED );


%DMPED_pipeline_read_update_file(year=2018, filedate='18jun2018'd, revisions=New file.);

