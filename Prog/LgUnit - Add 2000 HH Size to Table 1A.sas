/**************************************************************************
 Program:  LgUnit - Add 2000 HH Size to Table 1A.sas
 Library:  IPUMS
 Project:  NeighborhoodInfo DC
 Author:    Rob
 Created:  07/25/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read-in SF3 data to create indicators for Table 1A.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

libname dmpedraw "&_dcdata_r_path.\DMPED\Raw";
