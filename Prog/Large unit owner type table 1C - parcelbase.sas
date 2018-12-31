/**************************************************************************
 Program:  Large unit owner type table 1C - parcelbase.sas
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

Modification: 12/20/18 LH use newfiles that incorporate parcelbase
               
**************************************************************************/


%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED );
%DCData_lib( MAR );
%dcdata_lib( realprop );

proc sort data= dmped.SFCondo_year_2017_withbase out = SFCondo_year_2017;
by ssl;
run;

proc sort data= MAR.address_ssl_xref nodupkey out = address_ssl_xref;
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
		  fix_address_points_2018_06 (keep=address_id ssl ward2012 active_res_unit_count active_res_occupancy_count 
										rename=(ward2012=ward_b));
    by Address_Id;
	if a;
	total_sales=1;

	if ward_a ^= " " then ward2012 = ward_a;
		else if ward_b ^= " " then ward2012 = ward_b;

	if ui_proptype="10" then singlefamily=1; else singlefamily=0;
	if ui_proptype="11" then condo=1; else condo=0;
	if singlefamily=1 or condo=1 then combined=1; else combined=0;

	ownercat_denom=1;
	if ownercat=" " then ownercat_denom=.;

	owner_occ_sale_denom=1;
	if owner_occ_sale=. then owner_occ_sale_denom=.; 

run;
proc sort data=merge_SFCondo_Wards;
by city refyear;
run;
proc summary data=merge_SFCondo_Wards (where=(LargeUnit=1 and owner_occ_sale=0));
	by city refyear;
	var total govtown corporations cdcNFP otherind school foreign ownercat_denom renter Owner_occ_sale owner_occ_sale_denom
		senior BldgAgeGT2000 condo singlefamily;
	output	out=City_level	sum= ;
	format city $CITY16.;
run;
proc sort data=merge_SFCondo_Wards;
by ward2012 refyear;
run;
proc summary data=merge_SFCondo_Wards(where=(LargeUnit=1 and owner_occ_sale=0));
	by ward2012 refyear;
	var total govtown corporations cdcNFP otherind school foreign ownercat_denom renter Owner_occ_sale owner_occ_sale_denom 
		senior BldgAgeGT2000 condo singlefamily;
	output	out=ward_level	sum= ;
	format city $CITY16.;
run;

data owner_category (label="percent of large units by owner category" drop=_type_ _freq_);

	set city_level ward_level; 

	Pctgov=govtown/ownercat_denom*100; 
	Pctcorporations=corporations/ownercat_denom*100; 
    PctcdcNFP=cdcNFP/ownercat_denom*100; 
	Pctotherind=otherind/ownercat_denom*100; 
	Pctschool=school/ownercat_denom*100;
	Pctforeign=foreign/ownercat_denom*100;
	pctownerocc= Owner_occ_sale/owner_occ_sale_denom*100; 
	pctrenterocc= renter/owner_occ_sale_denom*100; 
	pctsenior= senior/Owner_occ_sale*100; 
	pctBldgAgeGE2000=BldgAgeGT2000 / total*100; 
	bldgAgeLT2000=total-BldgAgeGT2000;
	pctbldgAgeLT2000=bldgAgeLT2000/total*100; 
	Pctcondo=condo/total*100;
	PctSinglefamily=singlefamily/total*100; 

	if city = "1" then Ward2012 = "0";

	label Pctgov="Pct. of large units owned by government"
	      Pctcorporations="Pct. of large units owned by taxable corporations"
          PctcdcNFP="Pct. of large units owned by Church, community, development corporation or other non profit"
          Pctotherind="Pct. of large units owned Other individual (not owner occupied)"
          Pctschool="Pct. of large units owned by private university, college or school"
          Pctforeign="Pct. of large units owned by foreign government"
		  pctBldgAgeGE2000="Pct. of large units built 2000 or later"
		  pctsenior="Pct. owner-occupied large units with senior exemption"
		  condo="Number of large condominiums"
		  total="Number of large SF & condominiums"
		  singlefamily="Number of large single family homes"
		  bldgAgeLT2000="Number of SF & condos built before 2000"
		  BldgAgeGT2000="Number of SF & condos built 2000 or later"
			;
run;
proc sort data=owner_category;
by refyear;
run;

proc transpose data=owner_category out=owner_category;
var Pctgov Pctcorporations PctcdcNFP Pctotherind Pctschool Pctforeign pctownerocc pctrenterocc pctsenior bldgAgeLT2000 BldgAgeGT2000 pctBldgAgeGE2000 
pctbldgAgeLT2000 Pctcondo PctSinglefamily total condo singlefamily;
by refyear;
id ward2012;run;
	
proc export data=owner_category
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_owner_category_122018.csv"
	dbms=csv replace;
run;

/* percent SF and condo with 3+ bedrooms by age of building 2017*/

data age;
set merge_SFCondo_Wards;
if AYB<2000 then before2000 = 1; else before2000=0;

run;
proc sort data=age;
by ward2012 refyear before2000;
run;
proc summary data=age;
	by ward2012 refyear before2000;
	var total LargeUnit ;
	output	out=BuildingAge_ward sum= ;
run;
proc sort data=BuildingAge_ward;
by before2000 refyear;
run;
proc sort data=age;
by city refyear before2000;
run;
proc summary data=age;
	by city refyear before2000;
	var total LargeUnit ;
	output	out=BuildingAge_city sum= ;
run;
proc sort data=BuildingAge_city;
by before2000 refyear;
run;

data BuildingAge;
set BuildingAge_city BuildingAge_ward;
if city = "1" then Ward2012 = "0";
run;
proc sort data=BuildingAge;
by before2000 refyear;
run;

proc transpose data=BuildingAge (where=(refyear=2018)) out=BuildingAge_transpose;
var total LargeUnit;
by before2000 refyear;
id ward2012;
run;

proc export data=BuildingAge
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_BuildingAge_122018.csv"
	dbms=csv replace;
run;
/* percent of units with 3+ bedrooms by property type*/

/*percent large units for both SF and condo*/
data largeunits;
set merge_SFCondo_Wards;

if largeunit=1 and condo=1 then largecondo=1;
if largeunit=1 and singlefamily=1 then largesinglefamily=1; 
run;

proc sort data=largeunits;
by ward2012 refyear;
run;
proc summary data=largeunits;
	by ward2012 refyear;
	var total_sales LargeUnit largecondo condo largesinglefamily singlefamily;
	output	out=largeunits_ward sum= ;
run;
proc sort data=largeunits_ward;
by refyear;
run;
proc sort data=largeunits;
by city refyear;
run;
proc summary data=largeunits;
	by city refyear;
	var total_sales LargeUnit largecondo condo largesinglefamily singlefamily;
	output	out=largeunits_city sum= ;
run;
proc sort data=largeunits_city;
by refyear;
run;

data Pctlagre;
set largeunits_city largeunits_ward;
if city = "1" then Ward2012 = "0";
pctlargeunit= (LargeUnit/total_sales)*100;
pctlargecondo=(largecondo/condo)*100;
pctlargeSF=(largesinglefamily/singlefamily)*100;
run;
proc sort data=Pctlagre;
by refyear;
run;

proc transpose data=Pctlagre out=Pctlarge;
var total_sales LargeUnit pctlargeunit largecondo condo largesinglefamily singlefamily pctlargecondo pctlargeSF;
by refyear;
id ward2012;
run;

proc export data=Pctlarge
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_pctlarge_all_122018.csv"
	dbms=csv replace;
run;

