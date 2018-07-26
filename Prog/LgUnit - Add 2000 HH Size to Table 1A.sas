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

%let filepath = &_dcdata_r_path.\DMPED\Raw\;
%let filename = DEC_00_SF3_H016_with_ann.csv;


filename fimport "&filepath.&filename." lrecl=2000;

data SF3_in;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3 ;

  	informat GEOID $20. ;
	informat geo2000 $11. ;
	informat GEONAME $99. ;
	informat totalhh_2000 best32.;
	informat hh1person_2000 best32.;
	informat hh2person_2000 best32.;
	informat hh3person_2000 best32.;
	informat hh4person_2000 best32.;
	informat hh5person_2000 best32.;
	informat hh6person_2000 best32.;
	informat hh7person_2000 best32.;

	input
	GEOID $
	geo2000 $
	GEONAME $
	totalhh_2000
	hh1person_2000
	hh2person_2000
	hh3person_2000
	hh4person_2000
	hh5person_2000
	hh6person_2000
	hh7person_2000
	;

	label GEOID = "GeoID Full"
		  geo2000 = "Census Tract ID"
		  GEONAME = "Census Tract Name"
		  totalhh_2000 = "Total Households"
		  hh1person_2000 = "1-person household"
		  hh2person_2000 = "2-person household"
		  hh3person_2000 = "3-person household"
		  hh4person_2000 = "4-person household"
		  hh5person_2000 = "5-person household"
		  hh6person_2000 = "6-person household"
		  hh7person_2000 = "7-or-more-person household"
	;

run;


%let count_vars = totalhh_2000 hh1person_2000 hh2person_2000 hh3person_2000 
				  hh4person_2000 hh5person_2000 hh6person_2000 hh7person_2000;


%macro geo_out (geo);

%if &geo. = ward2012 %then %do;
	%let geo_s = ward12;
%end;

%else %if &geo. = city %then %do;
	%let geo_s = city;
%end;

%Transform_geo_data(
	  dat_ds_name=SF3_in,
	  dat_org_geo=geo2000,
	  dat_count_vars=&count_vars,
	  dat_count_moe_vars=,
	  dat_prop_vars=,
	  wgt_ds_name=General.Wt_tr00_&geo_s.,
	  wgt_org_geo=geo2000,
	  wgt_new_geo=&geo.,
	  wgt_id_vars=,
	  wgt_wgt_var=popwt,
	  out_ds_name=Cen2000_hhsize_&geo.,
	  out_ds_label=%str(Census 2000 SF3 Household Size, &geo.),
	  calc_vars=,
	  calc_vars_labels=,
	  keep_nonmatch=N,
	  show_warnings=10,
	  print_diag=Y,
	  full_diag=N,
	  mprint=Y
)

%mend geo_out;
%geo_out (ward2012);
%geo_out (city);


data Cen2000_hhsize_combined;
	set Cen2000_hhsize_ward2012 Cen2000_hhsize_city;
	if ward2012 = " " then ward2012 = "City";
run;


proc transpose data=Cen2000_hhsize_combined out=table_1a_extra;
	var &count_vars.;
	id ward2012; 
run; 



/* End of program */
