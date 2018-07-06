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
%DCData_lib( DMPED)
%DCData_lib( MAR)

proc sort data= DMPED.SFCondo_year_2017;
by ssl;
run;

proc sort data= MAR.address_ssl_xref;
by ssl;
run;
data DMPED.SFCondo_year_2017;
  set DMPED.SFCondo_year_2017;
  refyear=year(report_dt);
run;

data merge_SFCondo;
	merge DMPED.SFCondo_year_2017 MAR.address_ssl_xref; 
	by ssl;
run;
proc sort data=merge_SFCondo;
by Address_Id;
run;
proc sort data=mar.address_points_2018_16;
by Address_Id;
run;

data merge_SFCondo_Wards;
	merge merge_SFCondo mar.address_points_2018_16;
    by Address_Id;
	total_sale=1
run;

proc summary data=merge_SFCondo_Wards;
	class city refyear;
	var total_sales govtown corporations cdcNFP otherind;
	output	out=City_level	sum= ;
	format city $CITY16.;
run;

proc summary data=merge_SFCondo_Wards;
	class wd12 refyear;
	var total_sales govtown corporations cdcNFP otherind;
	output	out=City_level	sum= ;
	format city $CITY16.;
run;


data owner_category (label="percent of large units by owner category" drop=_type_ _freq_);

	set city_level ward_level; 

	Pctgov=govtown/total_sales*100; 
	Pctcorporations=corporations/total_sales*100; 
    PctcdcNFP=cdcNFP/total_sales*100; 
	Pctotherind=otherind/total_sales*100; 

	label Pctgov="Pct. of large units owned by government"
	      Pctcorporations="Pct. of large units owned by taxable corporations"
          PctcdcNFP="Pct. of large units owned by Church, community, development corporation or other non profit"
          Pctotherind="Pct. of Other individual (not owner occupied)"
			;
run;

	
proc export data=owner_category
	outfile="D:\DCDATA\Libraries\DMPED\Prog\sf_condo_owner_category.csv"
	dbms=csv replace;
run;
