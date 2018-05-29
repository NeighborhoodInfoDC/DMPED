/**************************************************************************
 Program: Process Preservation Catalogue.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Simone Zhang
 Created:  10/24/2014
 Version:  SAS 9.2
 
 Description: Analyze preservation catalogue pull

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

%DCData_lib( DMPED )

/*count everything except FHA*/
data units_expiring_2020;
	set DMPED.Units_expiring_2020_At_Risk;
	if year(MaxOfMFA_END)>2020 or MaxOfMFA_END=. then MFA_ASSUNITS=0;
	if year(MaxOf202_END)>2020 or MaxOf202_END=. then v202_UNITS=0;
	if year(MaxOf236_END)>2020 or MaxOf236_END=. then v236_UNITS=0;
	if year(MaxOfLIHTC_END)>2020 or MaxOfLIHTC_END =. then LIHTC_ASSUNITS=0;
	if year(MaxOfCDBG_END)>2020 or MaxOfCDBG_END =. then CDBG_ASSUNITS=0;
	if year(MaxOfHOME_END)>2020 or MaxOfHOME_END=. then HOME_ASSUNITS=0;
	if year(MaxOfHPTF_END)>2020 or MaxOfHPTF_END=. then HPTF_ASSUNITS=0;
	if year(MaxOfTEBOND_END)>2020 or MaxOfTEBOND_END=. then TEBOND_ASSUNITS=0;

	max_assisted_units = max(MFA_ASSUNITS,v202_UNITS, v236_UNITS, LIHTC_ASSUNITS,CDBG_ASSUNITS,HOME_ASSUNITS,HPTF_ASSUNITS,TEBOND_ASSUNITS);
run;

data DMPED.units_expiring_2020_geo;
	merge units_expiring_2020 (in=a) DMPED.project_geocode (keep=NLIHC_ID ward2012 Cluster_tr2000 Cluster_tr2000_name Proj_x proj_y Proj_lat proj_lon);
	by NLIHC_ID;
	if a;
run;
