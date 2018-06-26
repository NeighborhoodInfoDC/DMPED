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


/* 1980 data */

data ;
	set ncdb.ncdb_sum_city /*ncdb.ncdb_master_update*/;
	keep city numhsgunits_1980 numhsgunits1bdrm_1980 numhsgunits2bdrms_1980 numhsgunits3bdrms_1980 
	numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980;
run;

data RenterOcc1980; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";

	Keep Geo2010 city bdrnt08 bdrnt18 bdrnt28 bdrnt38 bdrnt48 bdtot08
	bdrnt58 ownhsgunits0bdrms_1980 ownhsgunits1bdrm_1980 ownhsgunits2bdrms_1980 ownhsgunits3bdrms_1980 ownhsgunits4bdrms_1980 
	ownhsgunits5plusbdrms_1980;	

	rename bdtot08=numhsgunits0bdrms_1980;

	rename bdrnt08=renthsgunits0bdrms_1980;
	rename bdrnt18=renthsgunits1bdrm_1980;
	rename bdrnt28=renthsgunits2bdrms_1980;
	rename bdrnt38=renthsgunits3bdrms_1980;
	rename bdrnt48=renthsgunits4bdrms_1980;
	rename bdrnt58=renthsgunits5plusbdrms_1980; 

	ownhsgunits0bdrms_1980 = bdocc08 - bdrnt08;
	ownhsgunits1bdrm_1980 = bdocc18 - bdrnt18;
	ownhsgunits2bdrms_1980 = bdocc28 - bdrnt28;
	ownhsgunits3bdrms_1980 = bdocc38 - bdrnt38;
	ownhsgunits4bdrms_1980 = bdocc48 - bdrnt48;
	ownhsgunits5plusbdrms_1980 = bdocc58 - bdrnt58;

run; 


proc summary data = RenterOcc1980;
	class city;
	var renthsgunits0bdrms_1980 renthsgunits1bdrm_1980;
	output out = RenterOcc1980_new (where = (_type_ = 1 )) sum = ;
run;


data m1980;
	merge x1980 RenterOcc1980_new ;
	by city ;
	drop _type_ _freq_ ;
run;



/* 1990 data */

data x1990;
	set ncdb.ncdb_sum_city ncdb.ncdb_master_update;
	keep city bdtot09 numhsgunits_1990 numhsgunits1bdrm_1990 numhsgunits2bdrms_1990 numhsgunits3bdrms_1990 
	numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990;
	rename bdtot09=numhsgunits0bdrms_1990;
run;

data RenterOcc1990; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";

	Keep Geo2010 city bdrnt09 bdrnt19 bdrnt29 bdrnt39 bdrnt49
	bdrnt59 ownhsgunits0bdrms_1990 ownhsgunits1bdrm_1990 ownhsgunits2bdrms_1990 ownhsgunits3bdrms_1990 ownhsgunits4bdrms_1990 
	ownhsgunits5plusbdrms_1990;	

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


/* 2000 data */

data x2000;
	set ncdb.ncdb_sum_city;
	keep city numhsgunits_2000 numhsgunits0bdrms_2000 numhsgunits1bdrm_2000 numhsgunits2bdrms_2000 numhsgunits3bdrms_2000 
	numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000;
run;

data RenterOcc2000; /* Summarize */
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	city = "1";

	Keep Geo2010 city bdrnt00 bdrnt10 bdrnt20 bdrnt30 bdrnt40
	bdrnt50;	

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


/* ACS data */
data xACS_2006_10; 
	set acs.acs_2006_10_dc_sum_tr_city;
	keep city numhsgunits0bd_2006_10 numhsgunits1bd_2006_10 numhsgunits2bd_2006_10 numhsgunits3bd_2006_10 numhsgunits3plusbd_2006_10
	numhsgunits4bd_2006_10 numhsgunits5plusbd_2006_10;
run;

data xACS_2012_16;
	set ACS.Acs_2012_16_dc_sum_tr_city;
	keep city numhsgunits0bd_2012_16 numhsgunits1bd_2012_16 numhsgunits2bd_2012_16 numhsgunits3bd_2012_16 numhsgunits3plusbd_2012_16
	numhsgunits4bd_2012_16 numhsgunits5plusbd_2012_16; 
run;


data RenterOcc2006_10;
	set acs.acs_2006_10_dc_sum_tr_city;
	Keep city numrentocchu0bd_2006_10 numrentocchu1bd_2006_10 numrentocchu2bd_2006_10 numrentocchu3bd_2006_10
	numrentocchu3plusbd_2006_10 numrentocchu4bd_2006_10 numrentocchu5plusbd_2006_10 numownocchu0bd_2006_10 numownocchu1bd_2006_10
	numownocchu2bd_2006_10 numownocchu3bd_2006_10 numownocchu3plusbd_2006_10 numownocchu4bd_2006_10 numownocchu5plusbd_2006_10;
	run;

data RenterOcc2012_16;
	set ACS.Acs_2012_16_dc_sum_tr_city;
	Keep city numrentocchu0bd_2012_16 numrentocchu1bd_2012_16 numrentocchu2bd_2012_16 numrentocchu3bd_2012_16
	numrentocchu3plusbd_2012_16 numrentocchu4bd_2012_16 numrentocchu5plusbd_2012_16 numownocchu0bd_2012_16 numownocchu1bd_2012_16
	numownocchu2bd_2012_16 numownocchu3bd_2012_16 numownocchu3plusbd_2012_16 numownocchu4bd_2012_16 numownocchu5plusbd_2012_16;
	run;
data RentOcc3plusbd2006_10;
	set acs.acs_2006_10_dc_sum_tr_city;
	Keep city numrtohu3bunder500_2006_10 numrtohu3b500to749_2006_10 numrtohu3b750to999_2006_10 numrtohu3b1000plus_2006_10;
	run;
data RentOcc3plusbd2012_16;
	set ACS.Acs_2012_16_dc_sum_tr_city;
	Keep city numrtohu3bunder500_2012_16 numrtohu3b500to749_2012_16 numrtohu3b750to999_2012_16 numrtohu3b1000plus_2012_16
	numrtohu3b1000to1499_2012_16 numrtohu3b1500plus_2012_16;
	run;

