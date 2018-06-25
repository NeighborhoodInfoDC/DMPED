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


data x1980;
	set ncdb.ncdb_sum_city ncdb.ncdb_master_update;
	keep city bdtot08 numhsgunits_1980 numhsgunits1bdrm_1980 numhsgunits2bdrms_1980 numhsgunits3bdrms_1980 
	numhsgunits4bdrms_1980 numhsgunits5plusbdrms_1980;
	rename bdtot08=numhsgunits0bdrms_1980;
run;

data x1990;
	set ncdb.ncdb_sum_city ncdb.ncdb_master_update;
	keep city bdtot09 numhsgunits_1990 numhsgunits1bdrm_1990 numhsgunits2bdrms_1990 numhsgunits3bdrms_1990 
	numhsgunits4bdrms_1990 numhsgunits5plusbdrms_1990;
	rename bdtot09=numhsgunits0bdrms_1990;
run;

data x2000;
	set ncdb.ncdb_sum_city;
	keep city numhsgunits_2000 numhsgunits0bdrms_2000 numhsgunits1bdrm_2000 numhsgunits2bdrms_2000 numhsgunits3bdrms_2000 
	numhsgunits4bdrms_2000 numhsgunits5plusbdrms_2000;
run;

data xACS_2006_10; 
	set acs.acs_2006_10_dc_sum_tr_city;
	keep ;
run;

data xACS_2012_16;
	set ACS.Acs_2012_16_dc_sum_tr_city;
	keep ; 
run;

data RenterOcc1980;
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	Keep Geo2010 bdrnt08 bdrnt18 bdrnt28 bdrnt38 bdrnt48
	bdrnt58 ownhsgunits0bdrms_1980 ;	

	rename bdrnt08=renthsgunits0bdrms_1980;
	rename bdrnt18=renthsgunits1bdrm_1980;
	rename bdrnt28=renthsgunits2bdrms_1980;
	rename bdrnt38=renthsgunits3bdrms_1980;
	rename bdrnt48=renthsgunits4bdrms_1980;
	rename bdrnt58=renthsgunits5plusbdrms_1980; 

	ownhsgunits0bdrms_1980 = bdocc08 - bdrnt08;

run; 
data RenterOcc1990;
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	Keep Geo2010 bdrnt09 bdrnt19 bdrnt29 bdrnt39 bdrnt49
	bdrnt59;	

	rename bdrnt09=renthsgunits0bdrms_1990;
	rename bdrnt19=renthsgunits1bdrm_1990;
	rename bdrnt29=renthsgunits2bdrms_1990;
	rename bdrnt39=renthsgunits3bdrms_1990;
	rename bdrnt49=renthsgunits4bdrms_1990;
	rename bdrnt59=renthsgunits5plusbdrms_1990; 

run; 
data RenterOcc2000;
	set ncdb.ncdb_master_update;
	
	If statecd = "11";

	Keep Geo2010 bdrnt00 bdrnt10 bdrnt20 bdrnt30 bdrnt40
	bdrnt50;	

	rename bdrnt00=renthsgunits0bdrms_2000;
	rename bdrnt10=renthsgunits1bdrm_2000;
	rename bdrnt20=renthsgunits2bdrms_2000;
	rename bdrnt30=renthsgunits3bdrms_2000;
	rename bdrnt40=renthsgunits4bdrms_2000;
	rename bdrnt50=renthsgunits5plusbdrms_2000; 

run; 

