/************************************************************************** 
Program:  LargeUnits_ACS Table 1B.sas 
Library:  
Project:  NeighborhoodInfo DC 
Author:   Yipeng Su 
Created:  6/20/18
Version:  SAS 9.4 
Environment:  Windows with SAS/Connect  
Description: Create calculate percent affordability of large rental units and then calculate concentration by tract
Modifications: 
**************************************************************************/ 

%include "L:\SAS\Inc\StdLocal.sas";

%DCData_lib( ACS );
%DCData_lib( Police );
%DCData_lib( Vital );
%DCData_lib( Realprop );
%DCData_lib( HUD );

%let _years = 2012_16;


data calculate_pct;
     set ACS.acs_2012_16_dc_sum_tr_tr10;
	 keep geo2010 numrenterhsgunits_&_years. numownocchu3plusbd_&_years. numrentocchu3bd_&_years.
          numrtohu3b500to749_&_years. numrtohu3b750to999_&_years.  numrtohu3bunder500_&_years. numrtohu3b1500plus_&_years.
          pct3baffordable1000 pct3baffordable1500 aff1000median aff1000threequarter aff1500median aff1500threequarter
		  geo2010 popaloneh_&_years.  popblacknonhispbridge_&_years.  popalonew_&_years.  popwithrace_&_years. pop25andoveryears_&_years.
          pop25andoverwcollege_&_years. pop25andoverwouths_&_years. popunemployed_&_years. poppoorpersons_&_years. totpop_&_years. 
	      famincomelt75k_&_years. numfamilies_&_years. nonfamilyhhtot_&_years. medfamincm_&_years. numhshlds_&_years.
		  pop25andoveryears&_years. popincivlaborforce_&_years.	numrenteroccupiedhu_&_years. popwhitenonhispbridge_&_years.
          NumRtOHU1u_&_years. NumRtOHU2to4u_&_years. NumRtOHU5to9u_&_years. NumRtOHU10to19u_&_years. NumRtOHU20plusu_&_years.
          personspovertydefined_&_years.
;

          pct3baffordable1500= (numrentocchu3plusbd_&_years.-numrtohu3b1500plus_&_years.)/numrentocchu3plusbd_&_years.;
          pct3baffordable1000= sum(numrtohu3b500to749_&_years.,numrtohu3b750to999_&_years., numrtohu3bunder500_&_years.)/numrentocchu3plusbd_&_years.;

run;
/*get percentiles*/
proc univariate data = calculate_pct;
	var pct3baffordable1000 pct3baffordable1500;
run;


data ACScharacteristics;
     set calculate_pct;
	 keep geo2010 pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty pctfambelow75000 pctnonfam
		  rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus 
		  aff1000median aff1000threequarter aff1500median aff1500threequarter
;  

  if   pct3baffordable1000 >=0.2476156 then aff1000median=1;
	      else aff1000median=0;
	 if  pct3baffordable1000 >=0.4090909 then  aff1000threequarter=1;
	      else aff1000threequarter=0;
     if   pct3baffordable1500 >=0.417598 then aff1500median=1;
	      else aff1500median=0;
	 if  pct3baffordable1500 >=0.674603 then  aff1500threequarter=1;
	      else aff1500threequarter=0;

pctnonhispwht= popwhitenonhispbridge_&_years./popwithrace_&_years.*100;
pcthispan= (popaloneh_&_years.)/popwithrace_&_years.*100;
pctnonhisblk= (popblacknonhispbridge_&_years.)/popwithrace_&_years.*100;
pctcollege= (pop25andoverwcollege_&_years.)/pop25andoveryears_&_years.*100;
pctwouths= (pop25andoverwouths_&_years.)/pop25andoveryears_&_years.*100;
pctunemployed= (popunemployed_&_years.)/popincivlaborforce_&_years.*100;
pctpoverty= (poppoorpersons_&_years.)/personspovertydefined_&_years. *100;
pctfambelow75000 = (famincomelt75k_&_years.)/numfamilies_&_years.*100;
pctnonfam= (nonfamilyhhtot_&_years.)/numhshlds_&_years.*100;
rentersinglefam=  (NumRtOHU1u_&_years.)/numrenteroccupiedhu_&_years.*100;
renter2to4 = (NumRtOHU2to4u_&_years.) /numrenteroccupiedhu_&_years.*100;
renter5to9= (NumRtOHU5to9u_&_years.)/numrenteroccupiedhu_&_years.*100;
renter10to19 = (NumRtOHU10to19u_&_years.) /numrenteroccupiedhu_&_years.*100;
renter20plus = (NumRtOHU20plusu_&_years. )/numrenteroccupiedhu_&_years.*100

;

run;

proc import datafile='L:\Libraries\DMPED\Raw\DCpull_forLeah.csv'
out=affh
dbms=csv
replace;
run;

data affh1;
	set affh;
	Geo2010 = put(tractid,z11.);
run;

data crimedata;
     set Police.Crimes_sum_tr10;
	 keep geo2010 crimes_pt1_property_2017 crimes_pt1_violent_2017 crime_rate_pop_2017 pctpropertycrime pctviolentcrime ;
     pctpropertycrime= crimes_pt1_property_2017/crime_rate_pop_2017*100;
     pctviolentcrime=crimes_pt1_violent_2017/crime_rate_pop_2017*100;
	 ;
run;

data prenatal;
     set vital.births_sum_tr10;
     keep births_prenat_adeq_2016 births_w_prenat_2016 births_total_2016 pctprenatal geo2010;
	 pctprenatal= births_prenat_adeq_2016/births_w_prenat_2016*100
	 ;
run;

data ressale;
     set realprop.sales_res_clean ;
     keep geo2010 saleprice saledate saleyear ;
	 saleyear=year(saledate)
	 ;
run;
proc sort data= ressale;
by geo2010;
run;

proc means median data = ressale (where=(saleyear=2017)); 
by geo2010;
var saleprice;
output out=medianhomesale median=;
run;

proc sort data= ACScharacteristics;
by geo2010;
run;

proc summary data=ACScharacteristics;
var aff1000median aff1000threequarter aff1500median aff1500threequarter;
output out=tract_count sum=;
run; 

proc sort data= crimedata;
by geo2010;
run;

proc sort data= prenatal;
by geo2010;
run;

proc sort data= medianhomesale;
by geo2010;
run;

proc sort data= affh1;
by geo2010;
run;

data tract_character ;
	merge  ACScharacteristics (in=a) crimedata prenatal medianhomesale affh1;
	by geo2010;
	if a;
run;

proc summary data=tract_character;
class aff1000median;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost
;
	output	out=aff1000median	mean= ;
run;

proc transpose data=aff1000median out=aff1000median;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost;
id aff1000median;
run;
data aff1000median1;
set aff1000median;
length category $11.;
category="1000median";
run;

proc summary data=tract_character;
class aff1000threequarter;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost
;
	output	out=aff1000threequarter	mean= ;
run;
proc transpose data=aff1000threequarter out=aff1000threequarter;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost;
id aff1000threequarter;
run;
data aff1000threequarter1;
set aff1000threequarter;
category="1000quarter";
run;

proc summary data=tract_character;
class aff1500median;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost
;
	output	out=aff1500median	mean= ;
run;
proc transpose data=aff1500median out=aff1500median;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost;
id aff1500median;
run;
data aff1500median1;
set aff1500median;length category $11.;
category="1500median";
run;

proc summary data=tract_character;
class aff1500threequarter;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost
;
	output	out=aff1500threequarter	mean= ;
run;

proc transpose data=aff1500threequarter out=aff1500threequarter;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost;
id aff1500threequarter;
run;
data aff1500threequarter1;
set aff1500threequarter;
category="1500quarter";
run;

data tractsummary;
set aff1000median1 aff1000threequarter1 aff1500median1 aff1500threequarter1;
run;

proc transpose data=tract_count out=num_tracts;
run;
data num_tracts1 (drop=_name_);
	set num_tracts (rename=(col1=num_tracts));

	if _name_ in ("_TYPE_" "_FREQ_" ) then delete;

	length category $11.; 

	if _name_ = "aff1000median" then category="1000median";
	if _name_="aff1000threequarter" then category="1000quarter";
	if _name_ = "aff1500median" then category="1500median";
	if _name_="aff1500threequarter" then category="1500quarter";





	run; 

proc sort data=tractsummary;
	by category;
data tractsummary1;
	merge tractsummary (rename=( _1=LargeAffConctr
		  						 _0=NotLargeAffCont))
		  num_tracts1;
	by category;

		label LargeAffConctr="Average for Tracts with Concentration of Large Affordable Rental Units"
		 NotLargeAffCont="Average for Tracts without Concentration of Large Affordable Rental Units"
		  ;
	
run; 
proc export data=tractsummary1
	outfile="&_dcdata_default_path\DMPED\Prog\ACS table 1B.csv"
	dbms=csv replace;
run;
