/**************************************************************************
 Program:  ParcelProfile.sas
 Library:  DMPED
 Project:  DMPED
 Author:   M. Woluchem
 Created:  09/30/14
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Creates a master data set that contains the data for the DMPED parcel profiles
 Modifications:
**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas"; 

**Define libraries**;
%DCData_lib( DHCD )
%DCData_lib( DMPED)
%DCData_lib( RealProp )
%DCData_lib( PresCat )

options nofmterr;
**For parcel_base file**;

%create_own_occ(
  inds=  parcel_base,
  outds=  parcel_base_test,
  inlib= Realprop,
  outlib=  work
);

proc freq data=parcel_base_test;
tables no_ownocct;
run;

proc freq data=parcel_base_test (where=(ui_proptype in ("10","11","12","13","19")));
tables owner_occ_sale*ui_proptype/ missing;
run;

proc freq data=dhcd.units_regression;
tables ui_proptype;
run;

data parcel_base
	(keep=ssl parcel_base ui_proptype owner_occ_sale assess_val sf_unit condo_unit coop_unit rental_build other assess_val_sf_lt100k 
		assess_val_sf_100k assess_val_sf_200k assess_val_sf_300k assess_val_sf_400k
		assess_val_sf_500k assess_val_sf_600k assess_val_sf_700k assess_val_sf_800k assess_val_sf_900k assess_val_sf_1mil
		assess_val_condo_lt100k assess_val_condo_100k assess_val_condo_200k assess_val_condo_300k assess_val_condo_400k
		assess_val_condo_500k assess_val_condo_600k assess_val_condo_700k assess_val_condo_800k assess_val_condo_900k assess_val_condo_1mil);
	set parcel_base_test (where=(ui_proptype in ("10","11","12","13","19") and in_last_ownerpt=1));
	parcel_base=1;
	if ui_proptype=10 then do;
		if 0<assess_val<100000 then assess_val_sf_lt100k=1;
		if 99999<assess_val<200000 then assess_val_sf_100k=1;
		if 199999<assess_val<300000 then assess_val_sf_200k=1;
		if 299999<assess_val<400000 then assess_val_sf_300k=1;
		if 399999<assess_val<500000 then assess_val_sf_400k=1;
		if 499999<assess_val<600000 then assess_val_sf_500k=1;
		if 599999<assess_val<700000 then assess_val_sf_600k=1;
		if 699999<assess_val<800000 then assess_val_sf_700k=1;
		if 799999<assess_val<900000 then assess_val_sf_800k=1;
		if 899999<assess_val<1000000 then assess_val_sf_900k=1;
		if 999999<assess_val then assess_val_sf_1mil=1;
		end;
	if ui_proptype=10 then sf_unit=1;
	if ui_proptype=11 then do;
		if 0<assess_val<100000 then assess_val_condo_lt100k=1;
		if 99999<assess_val<200000 then assess_val_condo_100k=1;
		if 199999<assess_val<300000 then assess_val_condo_200k=1;
		if 299999<assess_val<400000 then assess_val_condo_300k=1;
		if 399999<assess_val<500000 then assess_val_condo_400k=1;
		if 499999<assess_val<600000 then assess_val_condo_500k=1;
		if 599999<assess_val<700000 then assess_val_condo_600k=1;
		if 699999<assess_val<800000 then assess_val_condo_700k=1;
		if 799999<assess_val<900000 then assess_val_condo_800k=1;
		if 899999<assess_val<1000000 then assess_val_condo_900k=1;
		if 999999<assess_val then assess_val_condo_1mil=1;
		end;
	if ui_proptype=11 then condo_unit=1;
	if ui_proptype=12 then coop_unit=1;
	if ui_proptype=13 then rental_build=1;
	if ui_proptype=19 then other=1;
run;



proc datasets lib=work;
	modify parcel_base;
	attrib _all_ format=;
	run;

data parcel_rental_units
	(keep=ssl parcel_rental units_active);
	set realprop.parcel_rental_units;
	parcel_rental=1;
run;

data camares_ayb (keep=ssl ayb camares);
	set realprop.camarespt_2014_03;
	camares=1;
	run;

data camacondo_ayb (keep=ssl ayb camacondo);
	set realprop.camacondopt_2013_08;
	camacondo=1;
	run;

data cama_ayb;
	set camares_ayb (where=(ayb^=0)) camacondo_ayb (where=(ayb^=0));
	cama=1;
	if 1753<ayb<1901 then ayb_1900=1;
	if 1900<ayb<1911 then ayb_1901=1;
	if 1910<ayb<1921 then ayb_1911=1;
	if 1920<ayb<1931 then ayb_1921=1; 
	if 1930<ayb<1941 then ayb_1931=1; 
	if 1940<ayb<1951 then ayb_1941=1; 
	if 1950<ayb<1961 then ayb_1951=1; 
	if 1960<ayb<1971 then ayb_1961=1; 
	if 1970<ayb<1981 then ayb_1971=1; 
	if 1980<ayb<1991 then ayb_1981=1; 
	if 1990<ayb<2001 then ayb_1991=1; 
	if 2000<ayb<2011 then ayb_2001=1; 
	if 2010<ayb<2015 then ayb_2011=1; 
	run;

data parcel_subsidy
	(keep=ssl prescat sub_all_proj Sub_CDBG_proj Sub_HOME_proj Sub_HPTF_proj Sub_LIHTC_proj Sub_McKinney_proj Sub_Other_proj 
	Sub_ProjectBased_proj Sub_PublicHsng_proj Sub_TEBond_proj Sub_all_units Sub_CDBG_units Sub_HOME_units Sub_HPTF_units 
	Sub_LIHTC_units Sub_McKinney_units Sub_Other_units Sub_ProjectBased_units Sub_PublicHsng_units Sub_TEBond_units Sub_Private_proj
	Sub_Private_units);
	set prescat.parcel_subsidy;
	prescat=1;
	Sub_Private_proj=Sub_all_proj-Sub_PublicHsng_proj;
	Sub_Private_units=Sub_all_units-Sub_PublicHsng_units;
	run;

data rent_control 
	(keep=ssl rent_controlled adj_unit_count);
	set dhcd.parcels_rent_control;
	run;

proc datasets lib=work;
	modify rent_control;
	attrib _all_ format=;
	run;

proc sort data=parcel_base
	out=sort_parcel_base;
	by ssl;
	run;

proc sort data=parcel_rental_units
	out=sort_parcel_rental;
	by ssl;
	run;

proc sort data=cama_ayb
	out=sort_cama_ayb;
	by ssl;
	run;

proc sort data=parcel_subsidy
	out=sort_parcel_subsidy;
	by ssl;
	run;

proc sort data=rent_control
	out=sort_rent_control;
	by ssl;
	run;
	
proc sort data=realprop.parcel_geo
	out=sort_parcel_geo;
	by ssl;
	run;


data parcel_profile;
retain ssl parcel_base parcel_rental cama prescat camares camacondo;
	merge sort_parcel_base (in=a) sort_parcel_rental (in=b) sort_cama_ayb (in=c) sort_parcel_subsidy (in=d) sort_rent_control (in=e) sort_parcel_geo;
	by ssl;
	if a=1 or b=1 or c=1 or d=1 or e=1; 
	run;

data dmped.parcel_profile;
	set parcel_profile (where=(parcel_base=1 or prescat=1));
	if owner_occ_sale=1 then owner_occ=1;
		else owner_occ=0;
	if owner_occ_sale=0 then renter_occ=1;
		else renter_occ=0;
	label 	sf_unit					='Count: Single Family Units'
			condo_unit				='Count: Condo Units'
			coop_unit				='Count: Cooperative Building'
			rental_build			='Count: Rental Apt. Building'
			other					='Count: Other Prop Type'
			owner_occ				='Owner Occupied'
			renter_occ				='Renter Occupied'
			Sub_Private_units		='Privately Owned Units'
			Sub_Private_proj		='Privately Owned Projects'
			ayb_1900				='AYB: 1900 and earlier'
			ayb_1901				='AYB: 1901-1910'
			ayb_1911				='AYB: 1911-1920'
			ayb_1921				='AYB: 1921-1930'
			ayb_1931				='AYB: 1931-1940'
			ayb_1941				='AYB: 1941-1950'
			ayb_1951				='AYB: 1951-1960'
			ayb_1961				='AYB: 1961-1970'
			ayb_1971				='AYB: 1971-1980'
			ayb_1981				='AYB: 1981-1990'
			ayb_1991				='AYB: 1991-2000'
			ayb_2001				='AYB: 2001-2010'
			ayb_2011				='AYB: After 2011'
			assess_val_sf_lt100k		='Assessed Value SF: LT 100K'
			assess_val_sf_100k			='Assessed Value SF: 100k-199k'
			assess_val_sf_200k			='Assessed Value SF: 200k-299k'
			assess_val_sf_300k			='Assessed Value SF: 300k-399k'
			assess_val_sf_400k			='Assessed Value SF: 400k-499k'
			assess_val_sf_500k			='Assessed Value SF: 500k-599k'
			assess_val_sf_600k			='Assessed Value SF: 600k-699k'
			assess_val_sf_700k			='Assessed Value SF: 700k-799k'
			assess_val_sf_800k			='Assessed Value SF: 800k-899k'
			assess_val_sf_900k			='Assessed Value SF: 900k-999k'
			assess_val_sf_1mil			='Assessed Value SF: 1mil and over'
			assess_val_condo_lt100k		='Assessed Value condo: LT 100K'
			assess_val_condo_100k		='Assessed Value condo: 100k-199k'
			assess_val_condo_200k		='Assessed Value condo: 200k-299k'
			assess_val_condo_300k		='Assessed Value condo: 300k-399k'
			assess_val_condo_400k		='Assessed Value condo: 400k-499k'
			assess_val_condo_500k		='Assessed Value condo: 500k-599k'
			assess_val_condo_600k		='Assessed Value condo: 600k-699k'
			assess_val_condo_700k		='Assessed Value condo: 700k-799k'
			assess_val_condo_800k		='Assessed Value condo: 800k-899k'
			assess_val_condo_900k		='Assessed Value condo: 900k-999k'
			assess_val_condo_1mil		='Assessed Value condo: 1mil and over'
;
	run;

%File_info( data=dmped.parcel_profile )

/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

  %local filesuf level_lbl level_fmt file_lbl;

  %** Get standard geography information **;

  %let level = %upcase( &level );

  %if &level = WARD2012 %then %do;
    %let filesuf = wd12;
    %let level_lbl = Wards (2012);
    %let level_fmt = $ward02a.;
  %end;
  %else %if &level = CITY %then %do;
    %let filesuf = city;
    %let level_lbl = City;
    %let level_fmt = $1.;
  %end;
  %else %if &level = CLUSTER_TR2000 %then %do;
    %let filesuf = cltr00;
    %let level_lbl = Neighborhood cluster (tract-based, 2000);
    %let level_fmt = $clus00a.;
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  %let file_lbl = "Parcel profile, DMPED, &level_lbl";

  ** Summarize by specified geographic level all variables except for rent control **;

  proc summary data=dmped.parcel_profile nway completetypes;
      class &level /preloadfmt;
      format &level &level_fmt;
    	var owner_occ_sale assess_val
		units_active
		ayb
		sub_all_proj Sub_CDBG_proj Sub_HOME_proj Sub_HPTF_proj Sub_LIHTC_proj Sub_McKinney_proj 
		Sub_Other_proj Sub_ProjectBased_proj Sub_PublicHsng_proj Sub_TEBond_proj Sub_all_units 
		Sub_CDBG_units Sub_HOME_units Sub_HPTF_units Sub_LIHTC_units Sub_McKinney_units 
		Sub_Other_units Sub_ProjectBased_units Sub_PublicHsng_units Sub_TEBond_units
		rent_controlled 
		sf_unit condo_unit coop_unit rental_build other owner_occ renter_occ
		Sub_Private_units Sub_Private_proj
		ayb_1900 ayb_1901 ayb_1911 ayb_1921 ayb_1931 ayb_1941 ayb_1951 ayb_1961
		ayb_1971 ayb_1981 ayb_1991 ayb_2001 ayb_2011
		assess_val_sf_lt100k assess_val_sf_100k assess_val_sf_200k assess_val_sf_300k assess_val_sf_400k
		assess_val_sf_500k assess_val_sf_600k assess_val_sf_700k assess_val_sf_800k assess_val_sf_900k assess_val_sf_1mil
		assess_val_condo_lt100k assess_val_condo_100k assess_val_condo_200k assess_val_condo_300k assess_val_condo_400k
		assess_val_condo_500k assess_val_condo_600k assess_val_condo_700k assess_val_condo_800k assess_val_condo_900k assess_val_condo_1mil;
    output 
		out=dmped.parcel_profile_sum_&filesuf (drop= _type_) 
      sum (units_active sub_all_proj Sub_CDBG_proj Sub_HOME_proj Sub_HPTF_proj Sub_LIHTC_proj Sub_McKinney_proj 
		Sub_Other_proj Sub_ProjectBased_proj Sub_PublicHsng_proj Sub_TEBond_proj Sub_all_units 
		Sub_CDBG_units Sub_HOME_units Sub_HPTF_units Sub_LIHTC_units Sub_McKinney_units 
		Sub_Other_units Sub_ProjectBased_units Sub_PublicHsng_units Sub_TEBond_units
		sf_unit condo_unit coop_unit rental_build rent_controlled adj_unit_count owner_occ renter_occ
		Sub_Private_units Sub_Private_proj
		ayb_1900 ayb_1901 ayb_1911 ayb_1921 ayb_1931 ayb_1941 ayb_1951 ayb_1961
		ayb_1971 ayb_1981 ayb_1991 ayb_2001 ayb_2011
		assess_val_sf_lt100k assess_val_sf_100k assess_val_sf_200k assess_val_sf_300k assess_val_sf_400k
		assess_val_sf_500k assess_val_sf_600k assess_val_sf_700k assess_val_sf_800k assess_val_sf_900k assess_val_sf_1mil
		assess_val_condo_lt100k assess_val_condo_100k assess_val_condo_200k assess_val_condo_300k assess_val_condo_400k
		assess_val_condo_500k assess_val_condo_600k assess_val_condo_700k assess_val_condo_800k assess_val_condo_900k assess_val_condo_1mil)=
      median=
	  mean=
	  ;


    /** Note: Add labels here if variables are not labeled **/
  run;

      proc summary data=dmped.parcel_profile (where=(rent_controlled=1)) nway completetypes;
      class &level /preloadfmt;
      format &level &level_fmt;
    	var adj_unit_count;
    output 
		out=dmped.rent_controlled_sum_&filesuf (drop= _type_) 
      sum (adj_unit_count)=
      median=
	  mean=
	  ;
    /** Note: Add labels here if variables are not labeled **/
  run;

  %file_info( data=dmped.parcel_profile_sum_&filesuf, printobs=5 )
  %file_info( data=dmped.rent_controlled_sum_&filesuf, printobs=5 )

  run;

  %exit:

%mend Summarize;

/** End Macro Definition **/
%Summarize( level=city )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2012 )

%macro Summarize( level= );

  %local filesuf level_lbl level_fmt file_lbl;

  %** Get standard geography information **;

  %let level = %upcase( &level );

  %if &level = WARD2012 %then %do;
    %let filesuf = wd12;
    %let level_lbl = Wards (2012);
    %let level_fmt = $ward02a.;
  %end;
  %else %if &level = CITY %then %do;
    %let filesuf = city;
    %let level_lbl = City;
    %let level_fmt = $1.;
  %end;
  %else %if &level = CLUSTER_TR2000 %then %do;
    %let filesuf = cltr00;
    %let level_lbl = Neighborhood cluster (tract-based, 2000);
    %let level_fmt = $clus00a.;
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  %let file_lbl = "Parcel profile, DMPED, &level_lbl";

    proc summary data=dmped.parcel_profile (where=(rent_controlled=1)) nway completetypes;
      class &level /preloadfmt;
      format &level &level_fmt;
    	var adj_unit_count;
    output 
		out=dmped.rent_controlled_sum_city (drop= _type_) 
      sum (adj_unit_count)=
      median=
	  mean=
	  ;
    /** Note: Add labels here if variables are not labeled **/
  run;

    %file_info( data=dmped.parcel_profile_sum_&filesuf, printobs=5 )

  run;

  %exit:

  %mend Summarize;
  %Summarize( level=city )
  %Summarize( level=cluster_tr2000 )
  %Summarize( level=ward2012 )
