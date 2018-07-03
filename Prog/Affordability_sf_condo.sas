/**************************************************************************
Program:  Affordability_sf_condo.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description: *Methodology for affordability adapted from Zhong Yi Tong paper 
http://content.knowledgeplex.org/kp2/cache/documents/22736.pdf
Homeownership Affordability in Urban America: Past and Future;
 Modifications: 
**************************************************************************/


%include "L:\SAS\Inc\StdLocal.sas";


** Define libraries **;
%DCData_lib( realprop );
%DCData_lib( equity );


data create_flags;
  set realpr_r.sales_res_clean (where=(ui_proptype in ('10' '11') and 2010 <= year(saledate) <= 2014))
/*add code for saledate [between 1/1/10 and 12/31/14]*/;
  
  /*pull in effective interest rates - for example: 
  http://www.fhfa.gov/DataTools/Downloads/Documents/Historical-Summary-Tables/Table15_2015_by_State_and_Year.xls*/
  
	sale_yr = year(saledate);
  
	eff_int_rate_2010= 4.93;
	eff_int_rate_2011= 4.62;
	eff_int_rate_2012= 3.72;
	eff_int_rate_2013= 3.95;
	eff_int_rate_2014= 4.22;
	eff_int_rate_2015= 3.95;
	eff_int_rate_2016= 3.69;

	%macro yearloop ();

	%do year = 2010 %to 2016 ;

	month_int_rate_&year. = (eff_int_rate_&year./12/100);

	loan_multiplier_&year. =  month_int_rate_&year. *	( ( 1 + month_int_rate_&year. )**360	) / ( ( ( 1+ month_int_rate_&year. )**360 )-1 );

	if sale_yr=&year. then PI_First&year.=saleprice*.9*loan_multiplier_&year.;

	%dollar_convert(PI_first&year.,PI_first&year.r,&year.,2017);

	if sale_yr=&year. then PITI_First=PI_First&year.r*1.34;

	%dollar_convert(PI_Repeat&year.,PI_Repeat&year.r,&year.,2017);

	if sale_yr=&year. then PITI_Repeat=PI_Repeat&year.r*1.25;


	%end;

	%mend yearloop;
	%yearloop

		month_int_rate_2010 = (eff_int_rate_2010/12/100);
		month_int_rate_2011 = (eff_int_rate_2011/12/100); 
		month_int_rate_2012 = (eff_int_rate_2012/12/100); 
		month_int_rate_2013 = (eff_int_rate_2013/12/100); 
		month_int_rate_2014 = (eff_int_rate_2014/12/100); 
		month_int_rate_2015 = (eff_int_rate_2015/12/100); 
		month_int_rate_2016 = (eff_int_rate_2016/12/100); 
		
	loan_multiplier_2010 =  month_int_rate_2010 *	( ( 1 + month_int_rate_2010 )**360	) / ( ( ( 1+ month_int_rate_2010 )**360 )-1 );
  	loan_multiplier_2011 =  month_int_rate_2011 *	( ( 1 + month_int_rate_2011 )**360	) / ( ( ( 1+ month_int_rate_2011 )**360 )-1 );
  	loan_multiplier_2012 =  month_int_rate_2012 *	( ( 1 + month_int_rate_2012 )**360	) / ( ( ( 1+ month_int_rate_2012 )**360 )-1 );
  	loan_multiplier_2013 =  month_int_rate_2013 *	( ( 1 + month_int_rate_2013 )**360	) / ( ( ( 1+ month_int_rate_2013 )**360 )-1 );
  	loan_multiplier_2014 =  month_int_rate_2014 *	( ( 1 + month_int_rate_2014 )**360	) / ( ( ( 1+ month_int_rate_2014 )**360 )-1 );
	loan_multiplier_2015 =  month_int_rate_2015 *	( ( 1 + month_int_rate_2015 )**360	) / ( ( ( 1+ month_int_rate_2015 )**360 )-1 );
	loan_multiplier_2016 =  month_int_rate_2016 *	( ( 1 + month_int_rate_2016 )**360	) / ( ( ( 1+ month_int_rate_2016 )**360 )-1 );

  *calculate monthly Principal and Interest for First time Homebuyer (10% down);
    if sale_yr=2010 then PI_First2010=saleprice*.9*loan_multiplier_2010;
	if sale_yr=2011 then PI_First2011=saleprice*.9*loan_multiplier_2011;
	if sale_yr=2012 then PI_First2012=saleprice*.9*loan_multiplier_2012;
	if sale_yr=2013 then PI_First2013=saleprice*.9*loan_multiplier_2013;
	if sale_yr=2014 then PI_First2014=saleprice*.9*loan_multiplier_2014;
	if sale_yr=2015 then PI_First2015=saleprice*.9*loan_multiplier_2015;
	if sale_yr=2016 then PI_First2016=saleprice*.9*loan_multiplier_2016;

	%dollar_convert(PI_first2010,PI_first2010r,2010,2017);
	%dollar_convert(PI_first2011,PI_first2011r,2011,2017);
 	%dollar_convert(PI_first2012,PI_first2012r,2012,2017);
	%dollar_convert(PI_first2013,PI_first2013r,2013,2017);
	%dollar_convert(PI_first2014,PI_first2014r,2014,2017);
	%dollar_convert(PI_first2015,PI_first2015r,2015,2017);
	%dollar_convert(PI_first2016,PI_first2016r,2016,2017);

  *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for First Time Homebuyer (34% of PI = TI);
	if sale_yr=2010 then PITI_First=PI_First2010r*1.34;
	if sale_yr=2011 then PITI_First=PI_First2011r*1.34;
	if sale_yr=2012 then PITI_First=PI_First2012r*1.34;
	if sale_yr=2013 then PITI_First=PI_First2013r*1.34;
	if sale_yr=2014 then PITI_First=PI_First2014r*1.34;
	if sale_yr=2015 then PITI_First=PI_First2015r*1.34;
	if sale_yr=2016 then PITI_First=PI_First2016r*1.34;

  *calculate monthly Principal and Interest for Repeat Homebuyer (20% down);
    if sale_yr=2010 then PI_Repeat2010=saleprice*.8*loan_multiplier_2010;
	if sale_yr=2011 then PI_Repeat2011=saleprice*.8*loan_multiplier_2011;
	if sale_yr=2012 then PI_Repeat2012=saleprice*.8*loan_multiplier_2012;
	if sale_yr=2013 then PI_Repeat2013=saleprice*.8*loan_multiplier_2013;
	if sale_yr=2014 then PI_Repeat2014=saleprice*.8*loan_multiplier_2014;
	if sale_yr=2015 then PI_Repeat2014=saleprice*.8*loan_multiplier_2015;
	if sale_yr=2016 then PI_Repeat2014=saleprice*.8*loan_multiplier_2016;

	%dollar_convert(PI_Repeat2010,PI_Repeat2010r,2010,2017);
	%dollar_convert(PI_Repeat2011,PI_Repeat2011r,2011,2017);
 	%dollar_convert(PI_Repeat2012,PI_Repeat2012r,2012,2017);
	%dollar_convert(PI_Repeat2013,PI_Repeat2013r,2013,2017);
	%dollar_convert(PI_Repeat2014,PI_Repeat2014r,2014,2017);
	%dollar_convert(PI_Repeat2015,PI_Repeat2014r,2015,2017);
	%dollar_convert(PI_Repeat2016,PI_Repeat2014r,2016,2017);

	*calculate monthly PITI (Principal, Interest, Taxes and Insurance) for Repeat Homebuyer (25% of PI = TI);
	if sale_yr=2010 then PITI_Repeat=PI_Repeat2010r*1.25;
	if sale_yr=2011 then PITI_Repeat=PI_Repeat2011r*1.25;
	if sale_yr=2012 then PITI_Repeat=PI_Repeat2012r*1.25;
	if sale_yr=2013 then PITI_Repeat=PI_Repeat2013r*1.25;
	if sale_yr=2014 then PITI_Repeat=PI_Repeat2014r*1.25;
	if sale_yr=2015 then PITI_Repeat=PI_Repeat2015r*1.25;
	if sale_yr=2016 then PITI_Repeat=PI_Repeat2016r*1.25;


	/*Here are numbers for Average Household Income at the city level. 2012-16 ACS 
Black	NH-White	Hispanic	AIOM	 
59630	 157618		89997 	 	 76271		
numhshldsb_2012_16 numhshldsw_2012_16 numhshldsh_2012_16 numhshldsaiom_2012_16*/ 

	if PITI_First <= (157618 / 12*.28) then white_first_afford=1; else white_first_afford=0; 
		if PITI_Repeat <= (157618/ 12 *.28) then white_repeat_afford=1; else white_repeat_afford=0; 
	if PITI_First <= (59630 / 12 *.28) then black_first_afford=1; else black_first_afford=0; 
		if PITI_Repeat <= (59630 / 12 *.28) then black_repeat_afford=1; else black_repeat_afford=0; 
	if PITI_First <= (89997 / 12*.28) then hispanic_first_afford=1; else hispanic_first_afford=0; 
		if PITI_Repeat <= (89997/ 12*.28 ) then hispanic_repeat_afford=1; else hispanic_repeat_afford=0; 
	if PITI_First <= (76271 / 12*.28 ) then aiom_first_afford=1; else aiom_first_afford=0; 
		if PITI_Repeat <= (76271 / 12*.28 ) then aiom_repeat_afford=1; else aiom_repeat_afford=0; 


	total_sales=1;

	label 	PITI_First = "Principal, Interest, Tax and Insurance for FT Homebuyer"
			PITI_Repeat = "Principal, Interest, Tax and Insurance for Repeat Homebuyer"
			white_first_afford = "Property Sale is Affordable for FT White Owners"
			black_first_afford = "Property Sale is Affordable for FT Black Owners"
			hispanic_first_afford = "Property Sale is Affordable for FT Hispanic Owners"
			AIOM_first_afford = "Property Sale is Affordable for FT Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"
			white_repeat_afford = "Property Sale is Affordable for Repeat White Owners"
			black_repeat_afford = "Property Sale is Affordable for Repeat Black Owners"
			hispanic_repeat_afford = "Property Sale is Affordable for Repeat Hispanic Owners"
			AIOM_repeat_afford = "Property Sale is Affordable for Repeat Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"
;


run;
proc print data= create_flags (obs=25);
var saleprice PITI_FIRST PITI_repeat white_first_afford black_first_afford hispanic_first_afford AIOM_first_afford;
run;
proc freq data=create_flags; 
tables white_first_afford black_first_afford hispanic_first_afford AIOM_first_afford; 
run;
*proc summary at city, ward, tract, and cluster levels - so you could get % of sales in Ward 7 affordable to 
median white family vs. median black family.;

	
/*Proc Summary: Affordability for Owners by Race*/

proc summary data=create_flags;
	class city;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford AIOM_first_afford AIOM_repeat_afford;
	output	out=City_level (where=(_type_^=0))	sum= ;
	
	format city $CITY16.;
		run;

proc summary data=create_flags;
	class ward2012;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford AIOM_first_afford AIOM_repeat_afford;
	output 	out=Ward_Level (where=(_type_^=0)) 
	sum= ; 
	format ward2012 $wd12.;
;
		run;

proc summary data=create_flags;
	class geo2010;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford AIOM_first_afford AIOM_repeat_afford;
	output out=Tract_Level (where=(_type_^=0)) sum= ;
		run;

proc summary data=create_flags;
	class cluster_tr2000;
	var total_sales white_first_afford white_repeat_afford black_first_afford black_repeat_afford
		hispanic_first_afford hispanic_repeat_afford AIOM_first_afford AIOM_repeat_afford;
	output 		out=Cluster_Level (where=(_type_^=0)) 	sum= ;
	
		run;



	data equity.sales_afford_all (label="DC Homes Sales Affordabilty for Average Household Income, 2010-14" drop=_type_ _freq_);

	set city_level ward_level cluster_level tract_level; 

	tractlabel=geo2010; 
	clustername=cluster_tr2000; 
	clusterlabel=cluster_tr2000;

	format tractlabel $GEO10A11. Clusterlabel $CLUS00A16. clustername $clus00s. geo2010 cluster_tr2000; 

	PctAffordFirst_White=white_first_afford/total_sales*100; 
	PctAffordFirst_Black=Black_first_afford/total_sales*100; 
	PctAffordFirst_Hispanic=Hispanic_first_afford/total_sales*100;
	PctAffordFirst_AIOM= AIOM_first_afford/total_sales*100;


	PctAffordRepeat_White=white_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Black=Black_Repeat_afford/total_sales*100; 
	PctAffordRepeat_Hispanic=Hispanic_Repeat_afford/total_sales*100;
	PctAffordRepeat_AIOM= AIOM_repeat_afford/total_sales*100;

	label PctAffordFirst_White="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc. NH White"
		  PctAffordFirst_Black="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc. Black Alone"
		  PctAffordFirst_Hispanic="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc. Hispanic"
		 PctAffordFirst_AIOM="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"
	
		PctAffordRepeat_White="Pct. of SF/Condo Sales 2010-14 Affordable to Repeat Buyer at Avg. Household Inc. NH White"
		PctAffordRepeat_Black="Pct. of SF/Condo Sales 2010-14 Affordable to Repeat Buyer at Avg. Household Inc. Black Alone"
		PctAffordRepeat_Hispanic="Pct. of SF/Condo Sales 2010-14 Affordable to Repeat Buyer at Avg. Household Inc. Hispanic"
		PctAffordRepeat_AIOM="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc. Asian, Native American, Other, Multiple Race"
	clusterlabel="Neighborhood Cluster Label" 
clustername="Name of Neighborhood Cluster"
total_sales="Total Number of Sales of Single Family Homes and Condiminium Units in Geography, 2010-14"
tractlabel="Census Tract Label"
		white_first_afford = "Number of SF/Condo Sales 2010-14 Affordable for FT White Owners"
			black_first_afford = "Number of SF/Condo Sales 2010-14 Affordable for FT Black Owners"
			hispanic_first_afford = "Number of SF/Condo Sales 2010-14 Affordable for FT Hispanic Owners"
			AIOM_first_afford = "Number of SF/Condo Sales 2010-14 Affordable for FT Owners of Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"
			white_repeat_afford = "Number of SF/Condo Sales 2010-14  Affordable for Repeat White Owners"
			black_repeat_afford = "Number of SF/Condo Sales 2010-14 Affordable for Repeat Black Owners"
			hispanic_repeat_afford = "Number of SF/Condo Sales 2010-14 Affordable for Repeat Hispanic Owners"
			AIOM_repeat_afford = "AffordableProperty Sale is Affordable Asian, Pacific Islander, American Indian, Alaskan Native Descent, Other, Two or More Races"
			;


	
	run;
	
	** Register metadata **;

%Dc_update_meta_file(
      ds_lib=Equity,
      ds_name=sales_afford_all,
      creator_process=Sales_Affordability.sas,
      restrictions=None,
      revisions=New file.
      )

data wardonly;
	set equity.sales_afford_all (where=(ward2012~=" ") keep=ward2012 pct:); 
	run; 
	proc transpose data=wardonly out=ward_long prefix=Ward_;
	id ward2012;
	run;

data cityonly;
	set equity.sales_afford_all (where=(city~=" ") keep=city pct:); 
	city=0;
	rename city=ward2012;
	run; 

	proc transpose data=cityonly out=city_long prefix=Ward_;
	id ward2012;
	run;
proc sort data=city_long;
by _name_;
proc sort data=ward_long;
by _name_; 

	data output_table;
	merge city_long ward_long;
	by _name_;
	run;

proc export data=output_table 
	outfile="D:\DCDATA\Libraries\Equity\Prog\profile_tabs_aff.csv"
	dbms=csv replace;
	run;


/***
	create out put file for comms
Geography	Race	Var1	Var2	Var3
City		All		Value	Value	Value
City		White	Value	Value	Value
City		Black	Value	Value	Value
City		Hispanic	Value	Value	Value
Ward 1		All	Value	Value	Value
Ward 1		White	Value	Value	Value
Ward 1		Black	Value	Value	Value
Ward 1		Hispanic	Value	Value	Value
*/
	

	data white;
		set equity.sales_afford_all (drop= PctAffordFirst_Black PctAffordFirst_Hispanic PctAffordFirst_AIOM
											PctAffordRepeat_Black PctAffordRepeat_Hispanic PctAffordRepeat_AIOM
											black_first_afford Hispanic_first_afford AIOM_first_afford 
											black_Repeat_afford Hispanic_Repeat_afford AIOM_Repeat_afford );

	length race $10. ID $11.;
	race="White"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_White=PctAffordFirst
		   PctAffordRepeat_White=PctAffordRepeat
		   white_first_afford=first_afford
		   white_Repeat_afford=repeat_afford;
	run;	

		data black;
		set equity.sales_afford_all (drop= PctAffordFirst_white PctAffordFirst_Hispanic PctAffordFirst_AIOM
											PctAffordRepeat_white PctAffordRepeat_Hispanic PctAffordRepeat_AIOM
											white_first_afford Hispanic_first_afford AIOM_first_afford 
											white_Repeat_afford Hispanic_Repeat_afford AIOM_Repeat_afford );

	length race $10. ID $11.;
	race="Black"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_black=PctAffordFirst
		   PctAffordRepeat_black=PctAffordRepeat
		   black_first_afford=first_afford
		   black_Repeat_afford=repeat_afford;
	run;	

	
		data hispanic;
		set equity.sales_afford_all (drop= PctAffordFirst_white PctAffordFirst_black PctAffordFirst_AIOM
											PctAffordRepeat_white PctAffordRepeat_black PctAffordRepeat_AIOM
											white_first_afford black_first_afford AIOM_first_afford 
											white_Repeat_afford black_Repeat_afford AIOM_Repeat_afford );

	length race $10. ID $11.;
	race="Hispanic"; 

	if city="1" then ID="0";
	if Ward2012~=" " then ID=Ward2012;
	if cluster_tr2000~=" " then ID=Cluster_Tr2000;
	if geo2010~=" " then ID=geo2010; 

	Rename PctAffordFirst_Hispanic=PctAffordFirst
		   PctAffordRepeat_Hispanic=PctAffordRepeat
		   Hispanic_first_afford=first_afford
		   Hispanic_Repeat_afford=repeat_afford;
	run;	

	data all_race (label="DC Sales Affordability for COMM" drop=PctAffordFirst PctAffordRepeat);
	set white black hispanic;
	
	 PctAffordFirst_dec= PctAffordFirst/100; 
	PctAffordRepeat_dec=PctAffordRepeat/100; 
	label 
	 PctAffordFirst_dec="Pct. of SF/Condo Sales 2010-14 Affordable to First-time Buyer at Avg. Household Inc."
		 PctAffordRepeat_dec="Pct. of SF/Condo Sales 2010-14 Affordable to Repeat Buyer at Avg. Household Inc."
		
		first_afford = "Number of SF/Condo Sales 2010-14 Affordable for First Time Buyer"
		repeat_afford = "Number of SF/Condo Sales 2010-14  Affordable for Repeat Owners"
		race="Race of Householder";

	
	
	run;

	proc sort data=all_race;
	by  geo2010 cluster_tr2000 ward2012 city  ;
	run;
proc export data=all_race 
	outfile="D:\DCDATA\Libraries\Equity\Prog\Sales_affordability_allgeo.csv"
	dbms=csv replace;
	run;
	proc contents data=all_race;
	run; 
