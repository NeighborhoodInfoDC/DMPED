/**************************************************************************
 Program:  Aggregate Projections v2.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Graham MacDonald
 Created:  2/11/2014
 Version:  SAS 9.2
 
 Description: Aggregate Austin's projections by cluster and ward.

 Modifications:
  08/18/14 PAT Version 2 projections. 
  08/18/14 PAT Adapted to SAS1 server. Input data set is now
               DMPED.Projections_v1.
               Location of weighting files changed to General.
               Location of output CSV files changed to
               L:\Libraries\DMPED\Raw\Projections\v1.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

data proj;
	set DMPED.Projections_v2;
	where hhsize ~= 0; * Remove GQ people;
	proj = p * prob;
run;

proc sort data = General.wt_tr10_cltr00 (where=(Popwt > 0) keep = Geo2010 Popwt Cluster_tr2000) 
  out = cluster; 
  by Geo2010; 
  run;

proc sort data = General.wt_tr10_ward12 (where=(Popwt > 0) keep = Geo2010 Popwt Ward2012) 
  out = ward; 
  by Geo2010; 
  run;

proc sort data = DMPED.tract_cluster_POP2010_xwalk (rename = (GeoID = Geo2010)) 
  out = octo_cluster; 
  by Geo2010; 
  run;

proc sort data = proj; by Geo2010; run;

data ward; set ward; rename Popwt = Popwt_Ward; run;

data cluster; set cluster; rename Popwt = Popwt_Cltr; run;

proc sql noprint;
	create table proj_geo_Ward as select * from ward, proj
	where ward.Geo2010 = proj.Geo2010 order by ward.Geo2010;
quit;

proc sql noprint;
	create table proj_geo_Cluster as select * from cluster, proj
	where cluster.Geo2010 = proj.Geo2010 order by cluster.Geo2010;
quit;

proc sql noprint;
	create table proj_geo_Cluster_OCTO as select * from octo_cluster, proj
	where octo_cluster.Geo2010 = proj.Geo2010 order by octo_cluster.Geo2010;
quit;

data proj_geo_Cluster; set proj_geo_Cluster; proj_Cltr = proj * Popwt_Cltr; run;

data proj_geo_Ward; set proj_geo_Ward; proj_Ward = proj * Popwt_Ward; run;

data proj_geo_Cluster_Octo; set proj_geo_Cluster_OCTO; proj_Cltr_OCTO = proj * count_weight; run;

%macro get_sums;

	%let vars = race lowinc hhsize hhacat;

	%do i = 1 %to 4;

		%let thisvar = %scan(&vars.,&i.," ");

		proc means data = proj_geo_Cluster noprint missing sum;
			var proj_Cltr;
			class Cluster_tr2000 year &thisvar.;
			output out = Cluster_&thisvar. (drop = _TYPE_ _FREQ_) sum=;
		run;

		proc export data = Cluster_&thisvar. outfile = "L:\Libraries\DMPED\Raw\Projections\v2\Cluster_&thisvar..csv" dbms = csv replace; run;

		proc means data = proj_geo_Ward noprint missing sum;
			var proj_Ward;
			class Ward2012 year &thisvar.;
			output out = Ward_&thisvar. (drop = _TYPE_ _FREQ_) sum=;
		run;

		proc export data = Ward_&thisvar. outfile = "L:\Libraries\DMPED\Raw\Projections\v2\Ward_&thisvar..csv" dbms = csv replace; run;

		proc means data = proj_geo_Cluster_OCTO noprint missing sum;
			var proj_Cltr_OCTO;
			class Name year &thisvar.;
			output out = Cluster_OCTO_&thisvar. (drop = _TYPE_ _FREQ_) sum=;
		run;

		proc export data = Cluster_OCTO_&thisvar. outfile = "L:\Libraries\DMPED\Raw\Projections\v2\Cluster_OCTO_&thisvar..csv" dbms = csv replace; run;

	%end;

%mend get_sums;
%get_sums;

/* Check for sum errors */

proc means data = proj noprint missing sum;
	var proj;
	class year;
	output out = test_data_proj (drop = _TYPE_ _FREQ_) sum=;
run;

proc means data = proj_geo_Cluster noprint missing sum;
	var proj_Cltr;
	class year;
	output out = test_data_proj_Cltr (drop = _TYPE_ _FREQ_) sum=;
run;

proc means data = proj_geo_Ward noprint missing sum;
	var proj_Ward;
	class year;
	output out = test_data_proj_Ward (drop = _TYPE_ _FREQ_) sum=;
run;

%File_info( data=test_data_proj_Ward )

proc means data = proj_geo_Cluster_OCTO noprint missing sum;
	var proj_Cltr_OCTO;
	class year;
	output out = test_data_proj_Cltr_OCTO (drop = _TYPE_ _FREQ_) sum=;
run;

%File_info( data=test_data_proj_Cltr_OCTO, printobs=50 )

/* 

%macro check_me;

	%do i = 1 %to 240;

		%let filter = %eval(&i. * 10000);
		%let up = %eval(&filter. - 10000);

		data test_proj_geo;
			set proj_geo;
			n = _n_;
			if n < &filter. and n >= &up.;
		run;

		proc means data = test_proj_geo noprint missing sum;
			var proj proj_Ward proj_Cltr;
			class year;
			output out = test_data (drop = _TYPE_ _FREQ_) sum=;
		run;

		data test_data_&i.;
			length min 8. max 8.;
			set test_data;
			where year = .;
			min = (&i. - 1) * 10000;
			max = &i. * 10000;
		run;

	%end;

	data all_tests;
		set
			%do i = 1 %to 240;
				test_data_&i. (drop = year) 
			%end;
		;
	run;

%mend check_me;
%check_me;

data testing;	
	set proj_geo;
	n = _n_;
	if n >= 40000 and n <50000;
	if proj ~= proj_Ward then flag = 1;
	else flag = 0;
run;

*/
