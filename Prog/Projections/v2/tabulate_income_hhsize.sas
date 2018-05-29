/**************************************************************************
 Program:  Tabulate_income_hhsize.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Simone Zhang	
 Created:  Aug 28, 2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description: Tabulates household income by household size  

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

%DCData_lib( DMPED )

data projection;
	set DMPED.Projections_v2;
	where hhsize ~= 0; * Remove GQ people;
	proj = p * prob;
	count=1;
run;

ODS RTF file="\\SAS1\dcdata\Libraries\DMPED\Raw\Projections\v2\income_hhsize.rtf"; 
proc tabulate data=projection;
	class year lowinc hhsize;
	weight proj;
	var count;
	tables year, (lowinc ALL)*count*sumwgt*(F=20.), (hhsize ALL);
run;
ODS RTF close;
