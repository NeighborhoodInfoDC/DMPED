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


%macro table1a (geo);

%let geo_name = %upcase( &geo );
  %let geo_var = %sysfunc( putc( &geo_name, $geoval. ) );
  %let geo_suffix = %sysfunc( putc( &geo_name, $geosuf. ) );
  %let geo_label = %sysfunc( putc( &geo_name, $geodlbl. ) );

  /* 1980 data */

data RenterOcc1980; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";
	format city $city.;

	numhsgunits_1980 = sum(of bdtot08 bdtot18 bdtot28 bdtot38 bdtot48 bdtot58);

	rename bdtot08=numhsgunits0bdrms_1980;
	rename bdtot18=numhsgunits1bdrm_1980;
	rename bdtot28=numhsgunits2bdrms_1980;
	rename bdtot38=numhsgunits3bdrms_1980;
	rename bdtot48=numhsgunits4bdrms_1980;
	rename bdtot58=numhsgunits5plusbdrms_1980;

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

%let summaryvars80 = numhsgunits_1980 numhsgunits0bdrms_1980 numhsgunits1bdrm_1980 numhsgunits2bdrms_1980 numhsgunits3bdrms_1980 numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980
	renthsgunits_1980 renthsgunits0bdrms_1980 renthsgunits1bdrm_1980 renthsgunits2bdrms_1980 renthsgunits3bdrms_1980 renthsgunits4bdrms_1980
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
	set RenterOwnerOcc1980_new ;

	pct3brall_1980 = sum(of numhsgunits3bdrms_1980 numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980) / numhsgunits_1980;
	pct3brrent_1980 = sum(of renthsgunits3bdrms_1980 renthsgunits4bdrms_1980 renthsgunits5plusbdrms_1980) / renthsgunits_1980;
	pct3brown_1980 = sum(of ownhsgunits3bdrms_1980 ownhsgunits4bdrms_1980 ownhsgunits5plusbdrms_1980) / ownhsgunits_1980;

	label pct3brall_1980 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_1980 = "Pct. of Rental  Units with 3+ bedrooms"
		  ownhsgunits0bdrms_1980 = "Owner-occupied housing units with 0 bedrooms"
		  ownhsgunits1bdrm_1980 = "Owner-occupied housing units with 1 bedrooms"
		  ownhsgunits2bdrms_1980 = "Owner-occupied housing units with 2 bedrooms"
		  ownhsgunits3bdrms_1980 = "Owner-occupied housing units with 3 bedrooms"
		   ownhsgunits4bdrms_1980 = "Owner-occupied housing units with 4 bedrooms"
		  ownhsgunits5plusbdrms_1980 = "Owner-occupied housing units with 5+ bedrooms"
		  pct3brown_1980 = "Pct. of Owner Units with 3+ bedrooms"
	;

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

data RenterOcc1990; 
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";
	format city $city.;

	numhsgunits_1990 = sum(of bdtot09 bdtot19 bdtot29 bdtot39 bdtot49 bdtot59);

	rename bdtot09=numhsgunits0bdrms_1990;
	rename bdtot19=numhsgunits1bdrm_1990;
	rename bdtot29=numhsgunits2bdrms_1990;
	rename bdtot39=numhsgunits3bdrms_1990;
	rename bdtot49=numhsgunits4bdrms_1990;
	rename bdtot59=numhsgunits5plusbdrms_1990;

	rename rntocc9 =renthsgunits_1990;
	rename bdrnt09=renthsgunits0bdrms_1990;
	rename bdrnt19=renthsgunits1bdrm_1990;
	rename bdrnt29=renthsgunits2bdrms_1990;
	rename bdrnt39=renthsgunits3bdrms_1990;
	rename bdrnt49=renthsgunits4bdrms_1990;
	rename bdrnt59=renthsgunits5plusbdrms_1990; 

	rename ownocc9 = ownhsgunits_1990;

	ownhsgunits0bdrms_1990 = bdocc09 - bdrnt09;
	ownhsgunits1bdrm_1990 = bdocc19 - bdrnt19;
	ownhsgunits2bdrms_1990 = bdocc29 - bdrnt29;
	ownhsgunits3bdrms_1990 = bdocc39 - bdrnt39;
	ownhsgunits4bdrms_1990 = bdocc49 - bdrnt49;
	ownhsgunits5plusbdrms_1990 = bdocc59 - bdrnt59;

run; 

%let summaryvars90 = numhsgunits_1990 numhsgunits0bdrms_1990 numhsgunits1bdrm_1990 numhsgunits2bdrms_1990 numhsgunits3bdrms_1990 numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990
	renthsgunits_1990 renthsgunits0bdrms_1990 renthsgunits1bdrm_1990 renthsgunits2bdrms_1990 renthsgunits3bdrms_1990 renthsgunits4bdrms_1990
	renthsgunits5plusbdrms_1990 ownhsgunits_1990 ownhsgunits0bdrms_1990 ownhsgunits1bdrm_1990 ownhsgunits2bdrms_1990 ownhsgunits3bdrms_1990 ownhsgunits4bdrms_1990 
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
	set RenterOwnerOcc1990_new ;

	pct3brall_1990 = sum(of numhsgunits3bdrms_1990 numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990) / numhsgunits_1990;
	pct3brrent_1990 = sum(of renthsgunits3bdrms_1990 renthsgunits4bdrms_1990 renthsgunits5plusbdrms_1990) / renthsgunits_1990;
	pct3brown_1990 = sum(of ownhsgunits3bdrms_1990 ownhsgunits4bdrms_1990 ownhsgunits5plusbdrms_1990) / ownhsgunits_1990;

	label pct3brall_1990 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_1990 = "Pct. of Rental  Units with 3+ bedrooms"
		  ownhsgunits0bdrms_1990 = "Owner-occupied housing units with 0 bedrooms"
		  ownhsgunits1bdrm_1990 = "Owner-occupied housing units with 1 bedrooms"
		  ownhsgunits2bdrms_1990 = "Owner-occupied housing units with 2 bedrooms"
		  ownhsgunits3bdrms_1990 = "Owner-occupied housing units with 3 bedrooms"
		  ownhsgunits4bdrms_1990 = "Owner-occupied housing units with 4 bedrooms"
		  ownhsgunits5plusbdrms_1990 = "Owner-occupied housing units with 5+ bedrooms"
		  pct3brown_1990 = "Pct. of Owner Units with 3+ bedrooms"
	;

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

data RenterOcc2000; 
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";
	format city $city.;

	numhsgunits_2000 = sum(of bdtot00 bdtot10 bdtot20 bdtot30 bdtot40 bdtot50);
	
	rename bdtot00=numhsgunits0bdrms_2000;
	rename bdtot10=numhsgunits1bdrm_2000;
	rename bdtot20=numhsgunits2bdrms_2000;
	rename bdtot30=numhsgunits3bdrms_2000;
	rename bdtot40=numhsgunits4bdrms_2000;
	rename bdtot50=numhsgunits5plusbdrms_2000;

	rename rntocc0 =renthsgunits_2000;
	rename bdrnt00=renthsgunits0bdrms_2000;
	rename bdrnt10=renthsgunits1bdrm_2000;
	rename bdrnt20=renthsgunits2bdrms_2000;
	rename bdrnt30=renthsgunits3bdrms_2000;
	rename bdrnt40=renthsgunits4bdrms_2000;
	rename bdrnt50=renthsgunits5plusbdrms_2000; 

	rename ownocc0 = ownhsgunits_2000;

	ownhsgunits0bdrms_2000 = bdocc00 - bdrnt00;
	ownhsgunits1bdrm_2000 = bdocc10 - bdrnt10;
	ownhsgunits2bdrms_2000 = bdocc20 - bdrnt20;
	ownhsgunits3bdrms_2000 = bdocc30 - bdrnt30;
	ownhsgunits4bdrms_2000 = bdocc40 - bdrnt40;
	ownhsgunits5plusbdrms_2000 = bdocc50 - bdrnt50;

run; 


%let summaryvars00 = numhsgunits_2000 numhsgunits0bdrms_2000 numhsgunits0bdrms_2000 numhsgunits1bdrm_2000 numhsgunits2bdrms_2000 numhsgunits3bdrms_2000 numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000
	renthsgunits_2000 renthsgunits0bdrms_2000 renthsgunits1bdrm_2000 renthsgunits2bdrms_2000 renthsgunits3bdrms_2000 renthsgunits4bdrms_2000
	renthsgunits5plusbdrms_2000 ownhsgunits_2000 ownhsgunits0bdrms_2000 ownhsgunits1bdrm_2000 ownhsgunits2bdrms_2000 ownhsgunits3bdrms_2000 ownhsgunits4bdrms_2000 
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
	set RenterOwnerOcc2000_new ;

	numhsgunits3plusbd_2000 = sum(of numhsgunits3bdrms_2000 numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000);
	renthsgunits3plusbd_2000 = sum(of renthsgunits3bdrms_2000 renthsgunits4bdrms_2000 renthsgunits5plusbdrms_2000);
	ownhsgunits3plusbd_2000 = sum(of ownhsgunits3bdrms_2000 ownhsgunits4bdrms_2000 ownhsgunits5plusbdrms_2000);

	pct3brall_2000 = numhsgunits3plusbd_2000 / numhsgunits_2000;
	pct3brrent_2000 = renthsgunits3plusbd_2000 / renthsgunits_2000;
	pct3brown_2000 = ownhsgunits3plusbd_2000 / ownhsgunits_2000;

	label pct3brall_2000 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_2000 = "Pct. of Rental  Units with 3+ bedrooms"
		  ownhsgunits0bdrms_2000 = "Owner-occupied housing units with 0 bedrooms"
		  ownhsgunits1bdrm_2000 = "Owner-occupied housing units with 1 bedrooms"
		  ownhsgunits2bdrms_2000 = "Owner-occupied housing units with 2 bedrooms"
		  ownhsgunits3bdrms_2000 = "Owner-occupied housing units with 3 bedrooms"
		  ownhsgunits4bdrms_2000 = "Owner-occupied housing units with 4 bedrooms"
		  ownhsgunits5plusbdrms_2000 = "Owner-occupied housing units with 5+ bedrooms"
		  pct3brown_2000 = "Pct. of Owner Units with 3+ bedrooms"
	;
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


/* ACS 2006-10 */

data xACS_2006_10; 
	set acs.acs_2006_10_dc_sum_tr&geo_suffix.;

	/* Create sum variabels */
	numhsgunits_2006_10 = sum(of numhsgunits0bd_2006_10 numhsgunits1bd_2006_10 numhsgunits2bd_2006_10 numhsgunits3plusbd_2006_10);
	familyhh4plus_2006_10 = sum(of familyhh4person_2006_10 familyhh5person_2006_10 familyhh6person_2006_10 familyhh7person_2006_10);
	nonfamilyhh4plus_2006_10 = sum(of nonfamilyhh4person_2006_10 nonfamilyhh5person_2006_10 nonfamilyhh6person_2006_10 nonfamilyhh7person_2006_10);

	numrtohu02bnocash_2006_10 = sum(of numrtohu0bnocash_2006_10 numrtohu1bnocash_2006_10 numrtohu2bnocash_2006_10);
	numrtohu02bunder500_2006_10 = sum(of numrtohu0bunder500_2006_10 numrtohu1bunder500_2006_10 numrtohu2bunder500_2006_10);
	numrtohu02b500to749_2006_10 = sum(of numrtohu0b500to749_2006_10 numrtohu1b500to749_2006_10 numrtohu2b500to749_2006_10);
	numrtohu02b750to999_2006_10 = sum(of numrtohu0b750to999_2006_10 numrtohu1b750to999_2006_10 numrtohu2b750to999_2006_10);
	numrtohu02b1000plus_2006_10 = sum(of numrtohu0b1000plus_2006_10 numrtohu1b1000plus_2006_10 numrtohu2b1000plus_2006_10);

	numrentocchu02b_2006_10 = sum(of numrentocchu0bd_2006_10 numrentocchu1bd_2006_10 numrentocchu2bd_2006_10);

	/* Create percent variabels */
	pct3brall_2006_10 = numhsgunits3plusbd_2006_10 / numhsgunits_2006_10;
	pct3brrent_2006_10 = numrentocchu3plusbd_2006_10 / numrenteroccupiedhu_2006_10;
	pct3brown_2006_10 = numownocchu3plusbd_2006_10 / numowneroccupiedhu_2006_10;

	pctrtohu02bnocash_2006_10 = numrtohu02bnocash_2006_10 / numrentocchu02b_2006_10;
	pctrtohu02bunder500_2006_10 = numrtohu02bunder500_2006_10 / numrentocchu02b_2006_10;
	pctrtohu02b500to749_2006_10 = numrtohu02b500to749_2006_10 / numrentocchu02b_2006_10;
	pctrtohu02b750to999_2006_10 = numrtohu02b750to999_2006_10 / numrentocchu02b_2006_10;
	pctrtohu02b1000plus_2006_10 = numrtohu02b1000plus_2006_10 / numrentocchu02b_2006_10;

	pctrtohu3bnocash_2006_10 = numrtohu3bnocash_2006_10 / numrentocchu3plusbd_2006_10;
	pctrtohu3bunder500_2006_10 = numrtohu3bunder500_2006_10 / numrentocchu3plusbd_2006_10;
	pctrtohu3b500to749_2006_10 = numrtohu3b500to749_2006_10 / numrentocchu3plusbd_2006_10;
	pctrtohu3b750to999_2006_10 = numrtohu3b750to999_2006_10 / numrentocchu3plusbd_2006_10;
	pctrtohu3b1000plus_2006_10 = numrtohu3b1000plus_2006_10 / numrentocchu3plusbd_2006_10;

	pctfamily_2006_10 = familyhhtot_2006_10	/ numhshlds_2006_10;
	pctfamily4plus_2006_10 = familyhh4plus_2006_10 / numhshlds_2006_10;
	pctnonfamily_2006_10 = nonfamilyhhtot_2006_10 / numhshlds_2006_10;
	pctnonfamily4plus_2006_10 = nonfamilyhh4plus_2006_10 / numhshlds_2006_10;

	label pct3brall_2006_10 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_2006_10 = "Pct. of Rental Units with 3+ bedrooms" 
		  pct3brown_2006_10 = "Pct. of Owner Units with 3+ bedrooms" 
		  pctrtohu02bnocash_2006_10 = "Pct of renter units with no cash rent"
		  pctrtohu02bunder500_2006_10 = "Pct of 0-2 bedroom renter units Under $500"
		  pctrtohu02b500to749_2006_10 = "Pct of 0-2 bedroom renter units $500 - $749"
		  pctrtohu02b750to999_2006_10 = "Pct of 0-2 bedroom renter units $750 - $999"
		  pctrtohu02b1000plus_2006_10 = "Pct of 0-2 bedroom renter units $1,000+"
		  pctrtohu3bnocash_2006_10 = "Pct of 3+ bedroom renter units with no cash rent"
		  pctrtohu3bunder500_2006_10 = "Pct of 3+ bedroom renter units Under $500"
		  pctrtohu3b500to749_2006_10 = "Pct of 3+ bedroom renter units $500 - $749"
		  pctrtohu3b750to999_2006_10 = "Pct of 3+ bedroom renter units $750 - $999"
		  pctrtohu3b1000plus_2006_10 = "Pct of 3+ bedroom renter units $1,000+"
		  pctfamily_2006_10 = "Pct. of households that are family"
		  pctfamily4plus_2006_10 = "Pct. of households that are family with 4+ people"
		  pctnonfamily_2006_10 = "Pct. of households that are nonfamily" 
		  pctnonfamily4plus_2006_10 = "Pct. of households that are nonfamily with 4+ people"
	;

run;

proc transpose data=xACS_2006_10 out=table2006_10_&geo.;
	var numhsgunits_2006_10 numhsgunits0bd_2006_10 numhsgunits1bd_2006_10 numhsgunits2bd_2006_10 numhsgunits3bd_2006_10
		numhsgunits4bd_2006_10 numhsgunits5plusbd_2006_10 pct3brall_2006_10

	numrenteroccupiedhu_2006_10 numrentocchu0bd_2006_10 numrentocchu1bd_2006_10 numrentocchu2bd_2006_10 numrentocchu3bd_2006_10
	numrentocchu4bd_2006_10 numrentocchu5plusbd_2006_10 pct3brrent_2006_10

	numowneroccupiedhu_2006_10 numownocchu0bd_2006_10 numownocchu1bd_2006_10 numownocchu2bd_2006_10 numownocchu3bd_2006_10
	numownocchu4bd_2006_10 numownocchu5plusbd_2006_10 pct3brown_2006_10
	 	;

	id &geo.; 
run; 

proc transpose data=xACS_2006_10 out=table2006_10_rent_&geo.;
	var pctrtohu02bnocash_2006_10 pctrtohu02bunder500_2006_10 pctrtohu02b500to749_2006_10 pctrtohu02b750to999_2006_10 pctrtohu02b1000plus_2006_10
		pctrtohu3bnocash_2006_10 pctrtohu3bunder500_2006_10 pctrtohu3b500to749_2006_10 pctrtohu3b750to999_2006_10 pctrtohu3b1000plus_2006_10
	 	;
	id &geo.; 
run; 

proc transpose data=xACS_2006_10 out=table2006_10_fam_&geo.;
	var numhshlds_2006_10 pctfamily_2006_10 pctfamily4plus_2006_10 pctnonfamily_2006_10 pctnonfamily4plus_2006_10
		familyhhtot_2006_10 familyhh2person_2006_10 familyhh3person_2006_10 familyhh4person_2006_10
		familyhh5person_2006_10 familyhh6person_2006_10 familyhh7person_2006_10
		nonfamilyhhtot_2006_10 nonfamilyhh1person_2006_10 nonfamilyhh2person_2006_10 nonfamilyhh3person_2006_10 nonfamilyhh4person_2006_10
		nonfamilyhh5person_2006_10 nonfamilyhh6person_2006_10 nonfamilyhh7person_2006_10
	 	;
	id &geo.; 
run; 


/* ACS 2012-16 */

data xACS_2012_16; 
	set acs.acs_2012_16_dc_sum_tr&geo_suffix.;

	/* Create sum variabels */
	numhsgunits_2012_16 = sum(of numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3plusbd_2012_16);
	numhsgunits_2012_16 = sum(of numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3plusbd_2012_16);
	familyhh4plus_2012_16 = sum(of familyhh4person_2012_16 familyhh5person_2012_16 familyhh6person_2012_16 familyhh7person_2012_16);
	nonfamilyhh4plus_2012_16 = sum(of nonfamilyhh4person_2012_16 nonfamilyhh5person_2012_16 nonfamilyhh6person_2012_16 nonfamilyhh7person_2012_16);

	numrtohu02bnocash_2012_16 = sum(of numrtohu0bnocash_2012_16 numrtohu1bnocash_2012_16 numrtohu2bnocash_2012_16);
	numrtohu02bunder500_2012_16 = sum(of numrtohu0bunder500_2012_16 numrtohu1bunder500_2012_16 numrtohu2bunder500_2012_16);
	numrtohu02b500to749_2012_16 = sum(of numrtohu0b500to749_2012_16 numrtohu1b500to749_2012_16 numrtohu2b500to749_2012_16);
	numrtohu02b750to999_2012_16 = sum(of numrtohu0b750to999_2012_16 numrtohu1b750to999_2012_16 numrtohu2b750to999_2012_16);
	numrtohu02b1000plus_2012_16 = sum(of numrtohu0b1000plus_2012_16 numrtohu1b1000plus_2012_16 numrtohu2b1000plus_2012_16);
	numrtohu02b1000to1499_2012_16 = sum(of numrtohu0b1000to1499_2012_16 numrtohu1b1000to1499_2012_16 numrtohu2b1000to1499_2012_16);
	numrtohu02b1500plus_2012_16 = sum(of numrtohu0b1500plus_2012_16 numrtohu1b1500plus_2012_16 numrtohu2b1500plus_2012_16);

	numrentocchu02b_2012_16 = sum(of numrentocchu0bd_2012_16 numrentocchu1bd_2012_16 numrentocchu2bd_2012_16);

	/* Create percent variabels */
	pct3brall_2012_16 = numhsgunits3plusbd_2012_16 / numhsgunits_2012_16;
	pct3brrent_2012_16 = numrentocchu3plusbd_2012_16 / numrenteroccupiedhu_2012_16;
	pct3brown_2012_16 = numownocchu3plusbd_2012_16 / numowneroccupiedhu_2012_16;

	pctrtohu02bnocash_2012_16 = numrtohu02bnocash_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02bunder500_2012_16 = numrtohu02bunder500_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02b500to749_2012_16 = numrtohu02b500to749_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02b750to999_2012_16 = numrtohu02b750to999_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02b1000plus_2012_16 = numrtohu02b1000plus_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02b1000to1499_2012_16 = numrtohu02b1000to1499_2012_16 / numrentocchu02b_2012_16;
	pctrtohu02b1500plus_2012_16 = numrtohu02b1500plus_2012_16 / numrentocchu02b_2012_16;

	pctrtohu3bnocash_2012_16 = numrtohu3bnocash_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3bunder500_2012_16 = numrtohu3bunder500_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3b500to749_2012_16 = numrtohu3b500to749_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3b750to999_2012_16 = numrtohu3b750to999_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3b1000plus_2012_16 = numrtohu3b1000plus_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3b1000to1499_2012_16 = numrtohu3b1000to1499_2012_16 / numrentocchu3plusbd_2012_16;
	pctrtohu3b1500plus_2012_16 = numrtohu3b1500plus_2012_16 / numrentocchu3plusbd_2012_16;

	pctfamily_2012_16 = familyhhtot_2012_16	/ numhshlds_2012_16;
	pctfamily4plus_2012_16 = familyhh4plus_2012_16 / numhshlds_2012_16;
	pctnonfamily_2012_16 = nonfamilyhhtot_2012_16 / numhshlds_2012_16;
	pctnonfamily4plus_2012_16 = nonfamilyhh4plus_2012_16 / numhshlds_2012_16;


	label pct3brall_2012_16 = "Pct. of All Units with 3+ bedrooms"
		  pct3brrent_2012_16 = "Pct. of Rental Units with 3+ bedrooms" 
		  pct3brown_2012_16 = "Pct. of Owner Units with 3+ bedrooms" 
		  pctrtohu02bnocash_2012_16 = "Pct of 0-2 bedroom renter units with no cash rent"
		  pctrtohu02bunder500_2012_16 = "Pct of 0-2 bedroom renter units Under $500"
		  pctrtohu02b500to749_2012_16 = "Pct of 0-2 bedroom renter units $500 - $749"
		  pctrtohu02b750to999_2012_16 = "Pct of 0-2 bedroom renter units $750 - $999"
		  pctrtohu02b1000plus_2012_16 = "Pct of 0-2 bedroom renter units $1,000+"
		  pctrtohu02b1000to1499_2012_16 = "Pct of 0-2 bedroom renter units $1,000 - $1,499"
		  pctrtohu02b1500plus_2012_16 = "Pct of 0-2 bedroom renter units $1,000+" 
		  pctrtohu3bnocash_2012_16 = "Pct of 3+ bedroom renter units with no cash rent"
		  pctrtohu3bunder500_2012_16 = "Pct of 3+ bedroom renter units Under $500"
		  pctrtohu3b500to749_2012_16 = "Pct of 3+ bedroom renter units $500 - $749"
		  pctrtohu3b750to999_2012_16 = "Pct of  3+ bedroom renter units $750 - $999"
		  pctrtohu3b1000plus_2012_16 = "Pct of 3+ bedroom renter units $1,000+"
		  pctrtohu3b1000to1499_2012_16 = "Pct of 3+ bedroomrenter units $1,000 - $1,499"
		  pctrtohu3b1500plus_2012_16 = "Pct of 3+ bedroom renter units $1,000+" 
		  pctfamily_2012_16 = "Pct. of households that are family"
		  pctfamily4plus_2012_16 = "Pct. of households that are family with 4+ people"
		  pctnonfamily_2012_16 = "Pct. of households that are nonfamily" 
		  pctnonfamily4plus_2012_16 = "Pct. of households that are nonfamily with 4+ people"

	;

run;

proc transpose data=xACS_2012_16 out=table2012_16_&geo.;
	var numhsgunits_2012_16 numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3bd_2012_16
		numhsgunits4bd_2012_16 numhsgunits5plusbd_2012_16 pct3brall_2012_16

	numrenteroccupiedhu_2012_16 numrentocchu0bd_2012_16 numrentocchu1bd_2012_16 numrentocchu2bd_2012_16 numrentocchu3bd_2012_16
	numrentocchu4bd_2012_16 numrentocchu5plusbd_2012_16 pct3brrent_2012_16

	numowneroccupiedhu_2012_16 numownocchu0bd_2012_16 numownocchu1bd_2012_16 numownocchu2bd_2012_16 numownocchu3bd_2012_16
	numownocchu4bd_2012_16 numownocchu5plusbd_2012_16 pct3brown_2012_16

	NumOwnOcc1person_2012_16 NumOwnOcc2person_2012_16 NumOwnOcc3person_2012_16 NumOwnOcc4person_2012_16 NumOwnOcc5person_2012_16
	NumOwnOcc6person_2012_16 NumOwnOcc7plusperson_2012_16

	NumRentOcc1person_2012_16 NumRentOcc2person_2012_16 NumRentOcc3person_2012_16 NumRentOcc4person_2012_16 NumRentOcc5person_2012_16
	NumRentOcc6person_2012_16 NumRentOcc7plusperson_2012_16
	 	;
	id &geo.; 
run; 

proc transpose data=xACS_2012_16 out=table2012_16_rent_&geo.;
	var pctrtohu02bnocash_2012_16 pctrtohu02bunder500_2012_16 pctrtohu02b500to749_2012_16 pctrtohu02b750to999_2012_16 
		pctrtohu02b1000plus_2012_16 pctrtohu02b1000to1499_2012_16 pctrtohu02b1500plus_2012_16
		pctrtohu3bnocash_2012_16 pctrtohu3bunder500_2012_16 pctrtohu3b500to749_2012_16 pctrtohu3b750to999_2012_16 
		pctrtohu3b1000plus_2012_16 pctrtohu3b1000to1499_2012_16 pctrtohu3b1500plus_2012_16
	 	;
	id &geo.; 
run; 

proc transpose data=xACS_2012_16 out=table2012_16_fam_&geo.;
	var numhshlds_2012_16 pctfamily_2012_16 pctfamily4plus_2012_16 pctnonfamily_2012_16 pctnonfamily4plus_2012_16
		familyhhtot_2012_16 familyhh2person_2012_16 familyhh3person_2012_16 familyhh4person_2012_16
		familyhh5person_2012_16 familyhh6person_2012_16 familyhh7person_2012_16
		nonfamilyhhtot_2012_16 nonfamilyhh1person_2012_16 nonfamilyhh2person_2012_16 nonfamilyhh3person_2012_16 nonfamilyhh4person_2012_16
		nonfamilyhh5person_2012_16 nonfamilyhh6person_2012_16 nonfamilyhh7person_2012_16
	 	;
	id &geo.; 
run; 

proc transpose data=xACS_2012_16 out=table2012_16_ten_&geo.;
	var NumOwnOcc1person_2012_16 NumOwnOcc2person_2012_16 NumOwnOcc3person_2012_16 NumOwnOcc4person_2012_16 NumOwnOcc5person_2012_16
	NumOwnOcc6person_2012_16 NumOwnOcc7plusperson_2012_16

	NumRentOcc1person_2012_16 NumRentOcc2person_2012_16 NumRentOcc3person_2012_16 NumRentOcc4person_2012_16 NumRentOcc5person_2012_16
	NumRentOcc6person_2012_16 NumRentOcc7plusperson_2012_16
	 	;
	id &geo.; 
run; 

/* Combined files for change variables */
data allyear_&geo.;
	merge m2000 xACS_2006_10 xACS_2012_16;
	by &geo.;

	/* All units */
	ch_3brall_2000_to_2012_16 = numhsgunits3bd_2012_16 - numhsgunits3bdrms_2000;
	ch_4brall_2000_to_2012_16 = numhsgunits4bd_2012_16 - NumHsgUnits4Bdrms_2000;
	ch_5brall_2000_to_2012_16 = numhsgunits5plusbd_2012_16 - NumHsgUnits5plusBdrms_2000;

	pct_ch_tot_2000_to_2006_10 = (numhsgunits_2006_10 - numhsgunits_2000) / numhsgunits_2000;
	pct_ch_3p_2000_to_2006_10 = (numhsgunits3plusbd_2006_10 - numhsgunits3plusbd_2000) / numhsgunits3plusbd_2000;

	pct_ch_tot_2006_10_to_2012_16 = (numhsgunits_2012_16 - numhsgunits_2006_10) / numhsgunits_2006_10;
	pct_ch_3p_2006_10_to_2012_16 = (numhsgunits3plusbd_2012_16 - numhsgunits3plusbd_2006_10) / numhsgunits3plusbd_2006_10;


	label ch_3brall_2000_to_2012_16 = "Change in Units with 3 bedrooms 2000 to 2012-16"
		  ch_4brall_2000_to_2012_16 = "Change in Units with 4 bedrooms 2000 to 2012-16"
		  ch_5brall_2000_to_2012_16 = "Change in Units with 5+ bedrooms 2000 to 2012-16"
		  pct_ch_tot_2000_to_2006_10 = "Pct. change in total housing units 2000 to 2006-10"
		  pct_ch_3p_2000_to_2006_10 = "Pct. change in units with 3+ bedrooms 2000 to 2006-10" 
		  pct_ch_tot_2006_10_to_2012_16 = "Pct. change in total housing units 2006-10 to 2012-16" 
		  pct_ch_3p_2006_10_to_2012_16 = "Pct. change in units with 3+ bedrooms 2006-10 to 2012-16"
		  ;

run;

proc transpose data=allyear_&geo. out=table_ch_&geo.;
	var ch_3brall_2000_to_2012_16 ch_4brall_2000_to_2012_16 ch_5brall_2000_to_2012_16
		pct_ch_tot_2000_to_2006_10 pct_ch_3p_2000_to_2006_10
		pct_ch_tot_2006_10_to_2012_16 pct_ch_3p_2006_10_to_2012_16
	 	;
	id &geo.; 
run; 



%mend table1a;
%table1a (city);
%table1a (ward2012);

/* Combine all data into a single file */

data table_city_stack;
	set table1980_city table1990_city table2000_city Table2006_10_city Table2012_16_city Table_ch_city 
		Table2006_10_rent_city Table2012_16_rent_city table2006_10_fam_city table2012_16_fam_city table2012_16_ten_city;
	SortNo + 1;
run;

data table_ward2012_stack;
	set table1980_ward2012 table1990_ward2012 table2000_ward2012 Table2006_10_ward2012 Table2012_16_ward2012 Table_ch_ward2012 
		Table2006_10_rent_ward2012 Table2012_16_rent_ward2012 table2006_10_fam_ward2012 table2012_16_fam_ward2012 table2012_16_ten_ward2012;
	SortNo + 1;
run;

proc sort data = table_city_stack; by SortNo; run;
proc sort data = table_ward2012_stack; by SortNo; run;

data table_all_final;
	merge table_city_stack table_ward2012_stack;
	by SortNo;
	drop SortNo;
run;


/* Export final file */

proc export data = table_all_final
   outfile="&_dcdata_default_path.\DMPED\Prog\table1a_raw.csv"
   dbms=csv
   replace;
run;



/* End of program */
