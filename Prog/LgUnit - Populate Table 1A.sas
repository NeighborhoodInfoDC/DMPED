/**************************************************************************
 Program:  LgUnit - Populate Table 1A.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Wilton and Rob
 Created:  6/19/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Use NCDB and ACS data to populte table 1A for the large
			   units study.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( NCDB )
%DCData_lib( ACS )

%let geo = ward2012;

%let geo_name = %upcase( &geo );
  %let geo_var = %sysfunc( putc( &geo_name, $geoval. ) );
  %let geo_suffix = %sysfunc( putc( &geo_name, $geosuf. ) );
  %let geo_label = %sysfunc( putc( &geo_name, $geodlbl. ) );


/* 1980 data */

%macro table1a (geo);

data x1980 ;
	set ncdb.ncdb_sum&geo_suffix. /*ncdb.ncdb_master_update*/;
	keep &geo. numhsgunits_1980 numhsgunits1bdrm_1980 numhsgunits2bdrms_1980 numhsgunits3bdrms_1980 
	numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980;
run;

data RenterOcc1980; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";

	rename bdtot08=numhsgunits0bdrms_1980;

	rename rntocc8 =renthsgunits_1980;
	rename bdrnt08=renthsgunits0bdrms_1980;
	rename bdrnt18=renthsgunits1bdrm_1980;
	rename bdrnt28=renthsgunits2bdrms_1980;
	rename bdrnt38=renthsgunits3bdrms_1980;
	rename bdrnt48=renthsgunits4bdrms_1980;
	rename bdrnt58=renthsgunits5plusbdrms_1980; 

	rename ownocc8 = ownhsgunits_1980;

	ownhsgunits0bdrms_1980 = bdocc08 - bdrnt08;
	ownhsgunits1bdrm_1980 = bdocc18 - bdrnt18;
	ownhsgunits2bdrms_1980 = bdocc28 - bdrnt28;
	ownhsgunits3bdrms_1980 = bdocc38 - bdrnt38;
	ownhsgunits4bdrms_1980 = bdocc48 - bdrnt48;
	ownhsgunits5plusbdrms_1980 = bdocc58 - bdrnt58;

run; 

%let summaryvars80 = numhsgunits0bdrms_1980 renthsgunits_1980 renthsgunits0bdrms_1980 renthsgunits1bdrm_1980 renthsgunits2bdrms_1980 renthsgunits3bdrms_1980 renthsgunits4bdrms_1980
	renthsgunits5plusbdrms_1980 ownhsgunits_1980 ownhsgunits0bdrms_1980 ownhsgunits1bdrm_1980 ownhsgunits2bdrms_1980 ownhsgunits3bdrms_1980 ownhsgunits4bdrms_1980 
	ownhsgunits5plusbdrms_1980;

%if &geo_name. = WARD2012 %then %do;

	    %Transform_geo_data(
		 dat_ds_name=RenterOcc1980,
		 dat_org_geo=geo2010,
		 dat_count_vars=&summaryvars80.,
		 dat_prop_vars=,
		 wgt_ds_name=General.Wt_tr10_ward12,
		 wgt_org_geo=geo2010,
		 wgt_new_geo=&geo_var,
		 wgt_id_vars=,
		 wgt_wgt_var=popwt,
		 out_ds_name=RenterOwnerOcc1980_new,
		 out_ds_label=%str(NCDB 1980 summary by &geo.),
		 calc_vars=,
		 calc_vars_labels=,
		 keep_nonmatch=N,
		 show_warnings=10,
		 print_diag=Y,
		 full_diag=N,
		 mprint=Y
	    )
%end;

%else %do;

proc summary data = RenterOcc1980;
	class &geo.;
	var &summaryvars80.;
	output out = RenterOwnerOcc1980_new (where = (_type_ = 1 )) sum = ;
run;

%end;

data m1980;
	merge x1980 RenterOwnerOcc1980_new ;
	by &geo. ;
	drop _type_ _freq_ ;

	pct3brall_1980 = sum(of numhsgunits3bdrms_1980 numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980) / numhsgunits_1980;
	pct3brrent_1980 = sum(of renthsgunits3bdrms_1980 renthsgunits4bdrms_1980 renthsgunits5plusbdrms_1980) / renthsgunits_1980;
	pct3brown_1980 = sum(of ownhsgunits3bdrms_1980 ownhsgunits4bdrms_1980 ownhsgunits5plusbdrms_1980) / ownhsgunits_1980;

run;

proc transpose data=m1980 out=table1980_&geo.;
	var numhsgunits_1980 numhsgunits0bdrms_1980 numhsgunits1bdrm_1980 numhsgunits2bdrms_1980 numhsgunits3bdrms_1980 
	numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980 pct3brall_1980

	renthsgunits_1980 renthsgunits0bdrms_1980 renthsgunits1bdrm_1980 renthsgunits2bdrms_1980 renthsgunits3bdrms_1980 
	renthsgunits4bdrms_1980 renthsgunits5plusbdrms_1980 pct3brrent_1980

	ownhsgunits_1980 ownhsgunits0bdrms_1980 ownhsgunits1bdrm_1980 ownhsgunits2bdrms_1980 ownhsgunits3bdrms_1980 
	ownhsgunits4bdrms_1980  ownhsgunits5plusbdrms_1980 pct3brown_1980
	 	;

	id &geo.; 
run; 


/* 1990 data */

data x1990;
	set ncdb.ncdb_sum&geo_suffix. /*ncdb.ncdb_master_update*/;
	keep &geo. numhsgunits_1990 numhsgunits1bdrm_1990 numhsgunits2bdrms_1990 numhsgunits3bdrms_1990 
	numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990;
	run;

data RenterOcc1990; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";

	rename bdtot09=numhsgunits0bdrms_1990;

	rename bdrnt09=renthsgunits0bdrms_1990;
	rename bdrnt19=renthsgunits1bdrm_1990;
	rename bdrnt29=renthsgunits2bdrms_1990;
	rename bdrnt39=renthsgunits3bdrms_1990;
	rename bdrnt49=renthsgunits4bdrms_1990;
	rename bdrnt59=renthsgunits5plusbdrms_1990; 

	ownhsgunits0bdrms_1990 = bdocc09 - bdrnt09;
	ownhsgunits1bdrm_1990 = bdocc19 - bdrnt19;
	ownhsgunits2bdrms_1990 = bdocc29 - bdrnt29;
	ownhsgunits3bdrms_1990 = bdocc39 - bdrnt39;
	ownhsgunits4bdrms_1990 = bdocc49 - bdrnt49;
	ownhsgunits5plusbdrms_1990 = bdocc59 - bdrnt59;

run; 

%let summaryvars90 = numhsgunits0bdrms_1990 renthsgunits0bdrms_1990 renthsgunits1bdrm_1990 renthsgunits2bdrms_1990 renthsgunits3bdrms_1990 renthsgunits4bdrms_1990
	renthsgunits5plusbdrms_1990 ownhsgunits0bdrms_1990 ownhsgunits1bdrm_1990 ownhsgunits2bdrms_1990 ownhsgunits3bdrms_1990 ownhsgunits4bdrms_1990 
	ownhsgunits5plusbdrms_1990;

%if &geo_name. = WARD2012 %then %do;

	    %Transform_geo_data(
		 dat_ds_name=RenterOcc1990,
		 dat_org_geo=geo2010,
		 dat_count_vars=&summaryvars90.,
		 dat_prop_vars=,
		 wgt_ds_name=General.Wt_tr10_ward12,
		 wgt_org_geo=geo2010,
		 wgt_new_geo=&geo_var,
		 wgt_id_vars=,
		 wgt_wgt_var=popwt,
		 out_ds_name=RenterOwnerOcc1990_new,
		 out_ds_label=%str(NCDB 1980 summary by &geo.),
		 calc_vars=,
		 calc_vars_labels=,
		 keep_nonmatch=N,
		 show_warnings=10,
		 print_diag=Y,
		 full_diag=N,
		 mprint=Y
	    )
%end;

%else %do;

proc summary data = RenterOcc1990;
	class &geo.;
	var &summaryvars90.;
	output out = RenterOwnerOcc1990_new (where = (_type_ = 1 )) sum = ;
run;

%end;

data m1990;
	merge x1990 RenterOwnerOcc1990_new ;
	by &geo. ;
	drop _type_ _freq_ ;

	pct3brall_1990 = sum(of numhsgunits3bdrms_1990 numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990) / numhsgunits_1990;
	pct3brrent_1990 = sum(of renthsgunits3bdrms_1990 renthsgunits4bdrms_1990 renthsgunits5plusbdrms_1990) / renthsgunits_1990;
	pct3brown_1990 = sum(of ownhsgunits3bdrms_1990 ownhsgunits4bdrms_1990 ownhsgunits5plusbdrms_1990) / ownhsgunits_1990;
run;

proc transpose data=m1990 out=table1990_&geo.;
	var numhsgunits_1990 numhsgunits0bdrms_1990 numhsgunits1bdrm_1990 numhsgunits2bdrms_1990 numhsgunits3bdrms_1990 
	numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990 pct3brall_1990

	renthsgunits_1990 renthsgunits0bdrms_1990 renthsgunits1bdrm_1990 renthsgunits2bdrms_1990 renthsgunits3bdrms_1990 
	renthsgunits4bdrms_1990 renthsgunits5plusbdrms_1990 pct3brrent_1990

	ownhsgunits_1990 ownhsgunits0bdrms_1990 ownhsgunits1bdrm_1990 ownhsgunits2bdrms_1990 ownhsgunits3bdrms_1990 
	ownhsgunits4bdrms_1990  ownhsgunits5plusbdrms_1990 pct3brown_1990
	 	;

	id &geo.; 
run; 



/* 2000 data */

data x2000;
	set ncdb.ncdb_sum&geo_suffix. /*ncdb.ncdb_master_update*/;
	keep &geo. numhsgunits_2000 numhsgunits0bdrms_2000 numhsgunits1bdrm_2000 numhsgunits2bdrms_2000 numhsgunits3bdrms_2000 
	numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000;
run;

data RenterOcc2000; 
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";
	
	rename bdtot00=numhsgunits0bdrms_2000;

	rename bdrnt00=renthsgunits0bdrms_2000;
	rename bdrnt10=renthsgunits1bdrm_2000;
	rename bdrnt20=renthsgunits2bdrms_2000;
	rename bdrnt30=renthsgunits3bdrms_2000;
	rename bdrnt40=renthsgunits4bdrms_2000;
	rename bdrnt50=renthsgunits5plusbdrms_2000; 

	ownhsgunits0bdrms_2000 = bdocc00 - bdrnt00;
	ownhsgunits1bdrm_2000 = bdocc10 - bdrnt10;
	ownhsgunits2bdrms_2000 = bdocc20 - bdrnt20;
	ownhsgunits3bdrms_2000 = bdocc30 - bdrnt30;
	ownhsgunits4bdrms_2000 = bdocc40 - bdrnt40;
	ownhsgunits5plusbdrms_2000 = bdocc50 - bdrnt50;

run; 


%let summaryvars00 = numhsgunits0bdrms_2000 renthsgunits0bdrms_2000 renthsgunits1bdrm_2000 renthsgunits2bdrms_2000 renthsgunits3bdrms_2000 renthsgunits4bdrms_2000
	renthsgunits5plusbdrms_2000 ownhsgunits0bdrms_2000 ownhsgunits1bdrm_2000 ownhsgunits2bdrms_2000 ownhsgunits3bdrms_2000 ownhsgunits4bdrms_2000 
	ownhsgunits5plusbdrms_2000;

%if &geo_name. = WARD2012 %then %do;

	    %Transform_geo_data(
		 dat_ds_name=RenterOcc2000,
		 dat_org_geo=geo2010,
		 dat_count_vars=&summaryvars00.,
		 dat_prop_vars=,
		 wgt_ds_name=General.Wt_tr10_ward12,
		 wgt_org_geo=geo2010,
		 wgt_new_geo=&geo_var,
		 wgt_id_vars=,
		 wgt_wgt_var=popwt,
		 out_ds_name=RenterOwnerOcc2000_new,
		 out_ds_label=%str(NCDB 1980 summary by &geo.),
		 calc_vars=,
		 calc_vars_labels=,
		 keep_nonmatch=N,
		 show_warnings=10,
		 print_diag=Y,
		 full_diag=N,
		 mprint=Y
	    )
%end;

%else %do;

proc summary data = RenterOcc2000;
	class &geo.;
	var &summaryvars00.;
	output out = RenterOwnerOcc2000_new (where = (_type_ = 1 )) sum = ;
run;

%end;

data m2000;
	merge x2000 RenterOwnerOcc2000_new ;
	by &geo. ;
	drop _type_ _freq_ ;

	pct3brall_2000 = sum(of numhsgunits3bdrms_2000 numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000) / numhsgunits_2000;
	pct3brrent_2000 = sum(of renthsgunits3bdrms_2000 renthsgunits4bdrms_2000 renthsgunits5plusbdrms_2000) / renthsgunits_2000;
	pct3brown_2000 = sum(of ownhsgunits3bdrms_2000 ownhsgunits4bdrms_2000 ownhsgunits5plusbdrms_2000) / ownhsgunits_2000;
run;

proc transpose data=m2000 out=table2000_&geo.;
	var numhsgunits_2000 numhsgunits0bdrms_2000 numhsgunits1bdrm_2000 numhsgunits2bdrms_2000 numhsgunits3bdrms_2000 
	numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000 pct3brall_2000

	renthsgunits_2000 renthsgunits0bdrms_2000 renthsgunits1bdrm_2000 renthsgunits2bdrms_2000 renthsgunits3bdrms_2000 
	renthsgunits4bdrms_2000 renthsgunits5plusbdrms_2000 pct3brrent_2000

	ownhsgunits_2000 ownhsgunits0bdrms_2000 ownhsgunits1bdrm_2000 ownhsgunits2bdrms_2000 ownhsgunits3bdrms_2000 
	ownhsgunits4bdrms_2000  ownhsgunits5plusbdrms_2000 pct3brown_2000
	 	;

	id &geo.; 
run; 


%mend table1a;
%table1a (ward2012);


/* ACS data */
data xACS_2006_10; 
	set acs.acs_2006_10_dc_sum_tr&geo_suffix.;
	keep &geo. numhsgunits0bd_2006_10 numhsgunits1bd_2006_10 numhsgunits2bd_2006_10 numhsgunits3bd_2006_10 numhsgunits3plusbd_2006_10
	numhsgunits4bd_2006_10 numhsgunits5plusbd_2006_10;
run;

data xACS_2012_16;
	set ACS.Acs_2012_16_dc_sum_tr&geo_suffix.;
	keep &geo. numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3bd_2012_16 numhsgunits3plusbd_2012_16
	numhsgunits4bd_2012_16 numhsgunits5plusbd_2012_16; 
run;


data RenterOcc2006_10;
	set acs.acs_2006_10_dc_sum_tr&geo_suffix.;
	Keep &geo. numrentocchu0bd_2006_10 numrentocchu1bd_2006_10 numrentocchu2bd_2006_10 numrentocchu3bd_2006_10
	numrentocchu3plusbd_2006_10 numrentocchu4bd_2006_10 numrentocchu5plusbd_2006_10 numownocchu0bd_2006_10 numownocchu1bd_2006_10
	numownocchu2bd_2006_10 numownocchu3bd_2006_10 numownocchu3plusbd_2006_10 numownocchu4bd_2006_10 numownocchu5plusbd_2006_10;
	run;

data RenterOcc2012_16;
	set ACS.Acs_2012_16_dc_sum_tr&geo_suffix.;
	Keep &geo. numrentocchu0bd_2012_16 numrentocchu1bd_2012_16 numrentocchu2bd_2012_16 numrentocchu3bd_2012_16
	numrentocchu3plusbd_2012_16 numrentocchu4bd_2012_16 numrentocchu5plusbd_2012_16 numownocchu0bd_2012_16 numownocchu1bd_2012_16
	numownocchu2bd_2012_16 numownocchu3bd_2012_16 numownocchu3plusbd_2012_16 numownocchu4bd_2012_16 numownocchu5plusbd_2012_16;
	run;
data RentOcc3plusbd2006_10;
	set acs.acs_2006_10_dc_sum_tr&geo_suffix.;
	Keep &geo. numrtohu3bunder500_2006_10 numrtohu3b500to749_2006_10 numrtohu3b750to999_2006_10 numrtohu3b1000plus_2006_10;
	run;
data RentOcc3plusbd2012_16;
	set ACS.Acs_2012_16_dc_sum_tr&geo_suffix.;
	Keep city numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16 numrtohu3b1000plus_2012_16
	numrtohu3b1000to1499_2012_16 numrtohu3b1500plus_2012_16;
	run;

