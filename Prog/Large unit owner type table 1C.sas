/**************************************************************************
 Program:  Large unit owner type table 1C.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  07/06/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Calculate percent of large units by owner category
               Local or federal government
               taxable corporations, partnerships, associations, banks or government sponsored enterprises
               Church, community, development corporation or other non profit
               Other individual (not owner occupied)
               
**************************************************************************/


%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED);
%DCData_lib( MAR);

proc sort data= DMPED.SFCondo_year_2017 out = SFCondo_year_2017;
by ssl;
run;

proc sort data= MAR.address_ssl_xref out = address_ssl_xref;
by ssl;
run;

data SFCondo_year_2017;
  set SFCondo_year_2017;
  refyear=year(report_dt);
run;

data merge_SFCondo;
	merge SFCondo_year_2017 (in=a) address_ssl_xref ; 
	by ssl;
	if a;
run;
proc sort data=merge_SFCondo;
by Address_Id;
run;
proc sort data=mar.address_points_2018_06 out = address_points_2018_06;
by Address_Id;
run;

data fix_address_points_2018_06;
	set address_points_2018_06;
	city = "1";
run;


data merge_SFCondo_Wards;
	merge merge_SFCondo (in=a rename=(ward2012=ward_a)) 
		  fix_address_points_2018_06 (rename=(ward2012=ward_b));
    by Address_Id;
	if a;
	total_sales=1;

	if ward_a ^= " " then ward2012 = ward_a;
		else if ward_b ^= " " then ward2012 = ward_b;

run;

proc summary data=merge_SFCondo_Wards (where=(LargeUnit=1));
	class city refyear;
	var total_sales govtown corporations cdcNFP otherind renter Owner_occ_sale renter senior;
	output	out=City_level	sum= ;
	format city $CITY16.;
run;

proc summary data=merge_SFCondo_Wards(where=(LargeUnit=1));
	class ward2012 refyear;
	var total_sales govtown corporations cdcNFP otherind renter Owner_occ_sale renter senior;
	output	out=ward_level	sum= ;
	format city $CITY16.;
run;


data owner_category (label="percent of large units by owner category" drop=_type_ _freq_);

	set city_level ward_level; 

	Pctgov=govtown/total_sales*100; 
	Pctcorporations=corporations/total_sales*100; 
    PctcdcNFP=cdcNFP/total_sales*100; 
	Pctotherind=otherind/total_sales*100; 
	pctownerocc= Owner_occ_sale/total_sales*100; 
	pctrenterocc= renter/total_sales*100; 
	pctsenior= senior/Owner_occ_sale*100; 

	if city = "1" then Ward2012 = "0";

	label Pctgov="Pct. of large units owned by government"
	      Pctcorporations="Pct. of large units owned by taxable corporations"
          PctcdcNFP="Pct. of large units owned by Church, community, development corporation or other non profit"
          Pctotherind="Pct. of Other individual (not owner occupied)"
			;
run;
proc sort data=owner_category;
by refyear;
run;

proc transpose data=owner_category out=owner_category;
var Pctgov Pctcorporations PctcdcNFP Pctotherind pctownerocc pctrenterocc pctsenior;
by refyear;
id ward2012;run;
	
proc export data=owner_category
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_owner_category.csv"
	dbms=csv replace;
run;

/* percent SF and condo with 3+ bedrooms by age of building 2017*/

data age;
set merge_SFCondo_Wards;
if AYB<2000 then before2000 = 1; else before2000=0;
run;

proc summary data=age(where=(LargeUnit=1));
	class before2000 ward2012;
	var total_sales LargeUnit refyear;
	output	out=BuildingAge	sum= ;
run;
proc sort data=age;
by refyear;
run;

proc transpose data=age out=BuildingAge;
var total_sales LargeUnit;
by refyear;
id ward2012;
run;

proc export data=BuildingAge
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_BuildingAge.csv"
	dbms=csv replace;
run;
/* percent of units with 3+ bedrooms by property type*/

data property_type;
set merge_SFCondo_Wards (where=(LargeUnit=1));
if ui_proptype=001 or ui_proptype=011 or ui_proptype=012 or ui_proptype=013 then singlefamily=1; else singlefamily=0;
if ui_proptype= 016 or ui_proptype= 017 then condo=1; else condo=0;
if condo=1 or singlefamily=1 then combined=1; else combined=0;
run;

proc summary data=property_type(where=(LargeUnit=1));
class refyear ward2012;
var singlefamily condo combined total_sales;
output  out= PropertyType sum=;
run;
proc sort data=PropertyType;
by refyear;
run;
proc transpose data=PropertyType out=PropertyType;
var total_sales singlefamily condo combined;
by refyear;
id ward2012;
run;

proc export data=PropertyType
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_PropertyType.csv"
	dbms=csv replace;
run;
