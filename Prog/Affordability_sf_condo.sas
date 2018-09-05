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
%DCData_lib( DMPED );
%DCData_lib( equity );
%DCData_lib( realprop );
%DCData_lib( MAR );
%DCData_lib( ACS );
%DCData_lib( police );
%DCData_lib( vital );

%let _years = 2012_16;

%Sales_pars();
%Clean_sales( inds=DMPED.Sales_who_owns_SF_Condo, outds=Sales_who_owns_SF_Condo_clean) ;

proc contents data= Sales_who_owns_SF_Condo_clean; run;

proc sort data=Sales_who_owns_SF_Condo_clean;
by ssl;
run;
proc sort data= MAR.address_ssl_xref nodupkey out = address_ssl_xref;
by ssl;
run;
data merge_who_owns_SF_Condo_clean;
	merge Sales_who_owns_SF_Condo_clean (in=a) address_ssl_xref; 
	by ssl;
	if a;
run;

proc sort data=merge_who_owns_SF_Condo_clean;
by Address_Id;
run;
proc sort data=mar.address_points_2018_06 out = address_points_2018_06;
by Address_Id;
run;

data merge_who_owns_SF_Condo_wards;
	merge merge_who_owns_SF_Condo_clean (in=a drop = ward2012) address_points_2018_06;
    by Address_Id;
	if a;
run;

proc contents data=merge_who_owns_SF_Condo_wards; run;

data create_flags;
  set merge_who_owns_SF_Condo_wards (where=(clean_sale=1 and (2000 <= saleyear <= 2017)));
  
  /*pull in effective interest rates - for example: 
  http://www.fhfa.gov/DataTools/Downloads/Documents/Historical-Summary-Tables/Table15_2015_by_State_and_Year.xls*/
  
    eff_int_rate_2000= 7.90;
	eff_int_rate_2001= 7.07;
	eff_int_rate_2002= 6.62;
	eff_int_rate_2003= 5.73;
	eff_int_rate_2004= 5.53;
	eff_int_rate_2005= 5.67;
	eff_int_rate_2006= 6.53;
	eff_int_rate_2007= 6.54;
	eff_int_rate_2008= 6.14;
	eff_int_rate_2009= 5.02;
    eff_int_rate_2010= 4.93;
	eff_int_rate_2011= 4.62;
	eff_int_rate_2012= 3.72;
	eff_int_rate_2013= 3.95;
	eff_int_rate_2014= 4.22;
	eff_int_rate_2015= 3.95;
	eff_int_rate_2016= 3.69;
    eff_int_rate_2017= 3.69; *2017 not available, using 2016;
	%macro yearloop ();

	%do year = 2000 %to 2017 ;

	month_int_rate_&year. = (eff_int_rate_&year./12/100);

	loan_multiplier_&year. =  month_int_rate_&year. *	( ( 1 + month_int_rate_&year. )**360	) / ( ( ( 1+ month_int_rate_&year. )**360 )-1 );

	*calculate monthly Principal and Interest for First time Homebuyer (10% down);
	if saleyear=&year. then PI_First&year.=saleprice*.9*loan_multiplier_&year.;

   *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for First Time Homebuyer (34% of PI = TI);
	if saleyear=&year. then PITI_First=PI_First&year.*1.34;

  *calculate monthly Principal and Interest for Repeat Homebuyer (20% down);
    if saleyear=&year. then PI_Repeat&year.=saleprice*.8*loan_multiplier_&year.;

   *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for Repeat Homebuyer (25% of PI = TI);
	if saleyear=&year. then PITI_Repeat=PI_Repeat&year.*1.25;

	%end;

	%mend yearloop;
	%yearloop


	/*Here are numbers for Average Household Income at the city level. 2012-16 ACS 
Black	NH-White	Hispanic	AIOM	 
61923	 165970 	92543 	 	 80028		
numhshldsb_2012_16 numhshldsw_2012_16 numhshldsh_2012_16 numhshldsaiom_2012_16*/ 

	/*80%AMI and 50% AMI as the new affordability category  
2000  $82,800
2001  $85,600
2002  $91,500
2003  $84,800
2004  $85,400
2005  $89,300
2006  $90,300
2007  $94,500
2008  $99,000
2009  $102,700
2010  $103,500
2011  $106,100
2012  $107,500
2013  $107,300
2014  $107,000
2015  $109,200
2016  $108,600
2017  $110,300
	*/


	total_sales=1;

	if PITI_First in (0,.) then do;
			AMI80_first_afford = .;
			AMI50_first_afford = .;
			AMI30_first_afford= .;
			AMI80_repeat_afford = .;
			AMI50_repeat_afford = .;
			AMI30_repeat_afford= .;
			total_sales=0;
	end;

	else do;
		%macro calc_affordbyAMI;

		%let areamedian=82800 85600 91500 84800 85400 89300 90300 94500 99000 102700 103500 106100 107500 107300 107000 109200 108600 110300;
		%let yearlist=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017;

			%do i=1 %to 18;

			%let ami=%scan(&areamedian.,&i.," "); 
			%let yr=%scan(&yearlist.,&i.," "); 


			if saleyear =&yr. then do;

			       if PITI_First <= (&ami.*0.8 / 12*.28) then AMI80_first_afford=1; else AMI80_first_afford=0; 
			       if PITI_First <= (&ami.*0.5 / 12*.28) then AMI50_first_afford=1; else AMI50_first_afford=0;
				   if PITI_First <= (&ami.*0.3 / 12*.28) then AMI30_first_afford=1; else AMI30_first_afford=0; 
				   if PITI_Repeat <= (&ami.*0.8 / 12*.28) then AMI80_repeat_afford=1; else AMI80_repeat_afford=0; 
			       if PITI_Repeat <= (&ami.*0.5 / 12*.28) then AMI50_repeat_afford=1; else AMI50_repeat_afford=0; 
				   if PITI_Repeat <= (&ami.*0.3 / 12*.28) then AMI30_repeat_afford=1; else AMI30_repeat_afford=0;
				end; 


			%end;

		%mend calc_affordbyAMI;

		%calc_affordbyAMI;

	end;
	
run;
proc contents data=create_flags;
run;

proc print data= create_flags (obs=25);
var saleprice saleyear PITI_FIRST PITI_repeat AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford;
run;
proc freq data=create_flags; 
tables AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford AMI30_first_afford AMI30_repeat_afford; 
run;
/*% of sales that were large units* - new table*/
	proc sort data=create_flags;
	by saleyear ;
	proc summary data=create_flags;
	 by saleyear;
	 var largeunit total_sales;
	 output out=city_large sum=;
	 run;
	proc sort data=create_flags;
	by ward2012 saleyear ;
	proc summary data=create_flags;
	 by ward2012 saleyear;
	 var largeunit total_sales;
	 output out=ward_large sum=;
	 run;

/*Proc Summary: Affordability for Owners by 80AMI and 50AMI*/
proc sort data=create_flags;
by saleyear;
run;

proc summary data=create_flags;
	where largeunit=1;
	by saleyear;
	var total_sales AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford AMI30_first_afford AMI30_repeat_afford;
	output	out=City_level	sum= ;
run;
proc sort data=create_flags;
by ward2012 saleyear;
run;

proc summary data=create_flags;
	where largeunit=1;
	by ward2012 saleyear;
	var total_sales AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford AMI30_first_afford AMI30_repeat_afford;
	output 	out=Ward_Level 
	sum= ; 
	format ward2012 $wd12.;
run;

data city (drop=_type_ _freq_);
merge city_large city_level (rename=(total_sales=total_sales_lg));
by saleyear;
run;
data city;
set city;
city="1";
run;

data ward (drop=_type_ _freq_);
merge ward_large ward_level (rename=(total_sales=total_sales_lg));
by WARD2012 saleyear;
run;

data sales_afford_SF_Condo (label="DC Single Family Home Sales Affordabilty for 80%, 50% Area Median Income, 2000-17");

	set city ward ; 

	PctSales_Large=largeunit/total_sales; 

	PctAffordFirst_80AMI=AMI80_first_afford/total_sales_lg*100; 
	PctAffordFirst_50AMI=AMI50_first_afford/total_sales_lg*100; 
    PctAffordRepeat_80AMI=AMI80_repeat_afford/total_sales_lg*100; 
	PctAffordRepeat_50AMI=AMI50_repeat_afford/total_sales_lg*100; 
    PctAffordFirst_30AMI=AMI30_first_afford/total_sales_lg*100; 
    PctAffordRepeat_30AMI=AMI30_repeat_afford/total_sales_lg*100; 
    if city = "1" then Ward2012 = "City";
	label PctAffordFirst_80AMI="Pct. of SF/Condo Sales Affordable at 80% AMI for First-time Buyer"
	;
run;

proc sort data = sales_afford_SF_Condo; by saleyear; run;

proc transpose data=sales_afford_SF_Condo out=sales_afford_SF_Condo_transpose(label="DC Single Family Home Sales Affordabilty by Area Median Income, 2000-17");
	var total_sales total_sales_lg PctSales_Large PctAffordFirst_80AMI PctAffordFirst_50AMI PctAffordRepeat_80AMI PctAffordRepeat_50AMI PctAffordFirst_30AMI PctAffordRepeat_30AMI
		;
	by saleyear; 
	id Ward2012;
run; 
proc sort data=sales_afford_SF_Condo_transpose;
by _name_ saleyear;
run; 
proc export data=sales_afford_SF_Condo_transpose
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_tabs_aff.csv"
	dbms=csv replace;
	run;


/*add tract characteristics of AffordFirst_80AMI concentrated neigborhoods*/

proc sort data=create_flags;
by geo2010 saleyear;
run;

proc summary data=create_flags (where=(saleyear=2017));
 by geo2010;
 var AMI80_first_afford total_sales;
 output out=tractsummary sum=;
 run;

data tractsummary;
set tractsummary;
PctAffordFirst_80AMI=AMI80_first_afford/total_sales*100; 
label PctAffordFirst_80AMI="Pct. of SF/Condo Sales Affordable at 80% AMI for First-time Buyer";
run;

proc sort data=tractsummary;
by geo2010;
run;
proc univariate data=tractsummary;
	var PctAffordFirst_80AMI;
run;

data affsfcondo;
set tractsummary;
if   PctAffordFirst_80AMI >=53.846154 then affsfcondo=1;
	     else affsfcondo=0;
run;
/*ACS data*/

data calculate_pct;
     set ACS.acs_2012_16_dc_sum_tr_tr10;
	 keep geo2010 numrenterhsgunits_&_years. numownocchu3plusbd_&_years. numrentocchu3bd_&_years.
          numrtohu3b500to749_&_years. numrtohu3b750to999_&_years.  numrtohu3bunder500_&_years. numrtohu3b1500plus_&_years.
		  geo2010 popaloneh_&_years.  popblacknonhispbridge_&_years.  popalonew_&_years.  popwithrace_&_years. pop25andoveryears_&_years.
          pop25andoverwcollege_&_years. pop25andoverwouths_&_years. popunemployed_&_years. poppoorpersons_&_years. totpop_&_years. 
	      famincomelt75k_&_years. numfamilies_&_years. nonfamilyhhtot_&_years. medfamincm_&_years. numhshlds_&_years.
		  pop25andoveryears&_years. popincivlaborforce_&_years.	numrenteroccupiedhu_&_years. popwhitenonhispbridge_&_years.
          NumRtOHU1u_&_years. NumRtOHU2to4u_&_years. NumRtOHU5to9u_&_years. NumRtOHU10to19u_&_years. NumRtOHU20plusu_&_years.
          personspovertydefined_&_years.
;

run;

data ACScharacteristics;
     set calculate_pct;
	 keep geo2010 pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty pctfambelow75000 pctnonfam
		  rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus 
;  

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
     pctpropertycrime= crimes_pt1_property_2017/crime_rate_pop_2017*1000;
     pctviolentcrime=crimes_pt1_violent_2017/crime_rate_pop_2017*1000;
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
	merge  ACScharacteristics (in=a) crimedata prenatal medianhomesale affh1 affsfcondo;
	by geo2010;
	if a;
run;

proc summary data=tract_character;
class affsfcondo;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal saleprice
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost
;
	output	out=SFCondo_Concentrate	mean= ;
run;


proc transpose data=SFCondo_Concentrate out=SFCondo_Concentrate1;
var pctnonhispwht pcthispan pctnonhisblk pctcollege pctwouths pctunemployed pctpoverty
    pctfambelow75000 pctnonfam pctpropertycrime pctviolentcrime pctprenatal saleprice
    rentersinglefam renter2to4 renter5to9 renter10to19 renter20plus lbreng envhealth transcost;
id affsfcondo;
run;

proc export data=SFCondo_Concentrate1
	outfile="&_dcdata_default_path\DMPED\Prog\neighborhood_sfcondo_afford.csv"
	dbms=csv replace;
run;
