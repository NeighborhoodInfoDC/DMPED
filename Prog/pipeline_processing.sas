/**************************************************************************
 Program:  pipeline_processing.sas
 Library:  DMPED
 Project:  DMPED
 Author:   M. Woluchem
 Created:  09/30/14
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Creates a master list of all development pipeline
 Modifications:
**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas"; 

**Define libraries**;

%DCData_lib( DMPED)

proc contents data=dmped.a10x20_projects;
run;
proc contents data=dmped.cizctrackinglist;
run;
data developQuery
(keep=develactivityid name address ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure developtag);
set dmped.DevelopmentActivityPublicQuery (where=((landuse='Multi-Family Residential' or landuse='Residential' or landuse='Single Family Residential') and timing > '01JAN2013'd));
developtag=1;
run;

data cizc2014
(keep=develactivityid name address ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure tag2014);
set dmped.cizctrackinglist (where=((landuse='Multi-Family Residential' or landuse='Residential' or landuse='Single Family Residential') and timing > '01JAN2013'd));
tag2014=1;
run;

data cizc2013
(keep=develactivityid name address ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure tag2013);
set dmped.Pipeline2013 (where=((landuse='Multi-Family Residential' or landuse='Residential' or landuse='Single Family Residential') and timing > '01JAN2013'd));
tag2013=1;
run;

proc sort data=developQuery
out=a;
by develactivityid;
run;

proc sort data=cizc2014
out=b;
by develactivityid;
run;

proc sort data=cizc2013
out=c;
by develactivityid;
run;

data dmped.join_iz;
retain address_match;
merge a b c;
by develactivityid;
jointag=1;
length name $72
	address $80
	tenure $13;
run;

**dmped.join_iz sent through MAR Geocoder for cleaning. SAS Output is dmped.join_iz_clean**;

**Check to find out how many are expected to have missing addresses and the source of each observation**;

proc freq data=dmped.join_iz_clean;
table mar_matchaddress/list missing nopercent;
run;

proc freq data=dmped.join_iz_clean;
table jointag*tag2014*tag2013*developtag/list missing nopercent;
run;

**Process 10x20 data**;

data dmped.tenby
(keep= PROJECT_NAME            
v10x20                  
Agency__Calculated_     
Agency__DCHA_Project_   
Agency__DCHFA_Project_  
Agency__DGS_Project_    
Agency__DHCD_Project_   
Agency__DMPED_Project_  
Status 
Report__Units__0_30_     
Report__Units__31_60_    
Report__Units__61_80_    
Report__Units__81_       
Report__Units__Affordable
Report__Units__Market
Report__Units__Total 
v100_ 
v120_
v30_ 
v40_ 
v50_ 
v60_ 
v80_ 
Address__Street_1 
Address
ADU_
Affordable
Inclusionary_Zoning_Units
Inclusionary_Zoning_
IZ_Database___AMI50
IZ_Database___AMI80           
IZ_Database___CIZCDate        
IZ_Database___CompletionDate  
IZ_Database___IZUnits         
IZ_Database___Project_Name    
IZ_Database___Related_Project 
IZ_Database___Status          
IZ_Database___Units   
Market 
Mixed_Use
Preservation_   
Priv_Grant_Funds
Tenure
Total
Total_Subsidy
Voucher_Type tenbytag);
set dmped.a10x20_projects;
tenbytag=1;
run;

**dmped.tenby sent through MAR Geocoder for cleaning. SAS Output is dmped.tenby_clean**;
proc freq data=dmped.tenby_clean;
table mar_matchaddress/missing list nopercent;
run;

data iz_clean;
length name $72
	address $87
	tenure $13;
set dmped.join_iz_clean;
	drop mar_error;
	run;

data tenby_clean;
set dmped.tenby_clean;
	name=project_name;
	drop mar_error;
	run;

proc sort data=iz_clean;
by mar_matchaddress name;
run;

proc sort data=tenby_clean;
by mar_matchaddress name;
run;

**Merge addresses that can be matched**;

data addressmerge;
retain address develactivityid name ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure jointag tenbytag;
merge iz_clean tenby_clean;
by mar_matchaddress;
where mar_matchaddress ne "";
drop tag2014 tag2013 developtag;
addressmerge=1;
run;

**Merge names for properties that can not be matched by address**;

data namemerge;
retain address develactivityid name ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure jointag tenbytag;
merge iz_clean tenby_clean;
by name;
where mar_matchaddress="";
drop tag2014 tag2013 developtag;
namemerge=1;
run;

**QC Tests**;
proc freq data=addressmerge;
table jointag*tenbytag/list missing nopercent;
run;

proc freq data=namemerge;
table jointag*tenbytag/list missing nopercent;
run;

*Combine all merged properties into one dataset;
data dmped.pipelineproperties;
retain address develactivityid name ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure jointag tenbytag address
develactivityid name ward parcelid statusID timing landuse units mrktunits affunits sfnonres type afford tenure jointag tenbytag addressmerge namemerge
PROJECT_NAME v10x20 Agency__Calculated_ Status Report__Units__0_30_ Report__Units__31_60_ Report__Units__61_80_ Report__Units__81_ Report__Units__Affordable
Report__Units__Market Report__Units__Total v100_ v120_ v30_ v40_ v50_ v60_ v80_ Address__Street_1 ADU_ Affordable Agency__DCHA_Project_
Agency__DCHFA_Project_ Agency__DGS_Project_ Agency__DHCD_Project_ Agency__DMPED_Project_ Inclusionary_Zoning_Units Inclusionary_Zoning_
IZ_Database___AMI50 IZ_Database___AMI80 IZ_Database___CIZCDate IZ_Database___CompletionDate IZ_Database___IZUnits IZ_Database___Project_Name IZ_Database___Related_Project
IZ_Database___Status IZ_Database___Units Market Mixed_Use Preservation_ Priv_Grant_Funds Total Total_Subsidy Voucher_Type;
set addressmerge namemerge;
label Agency__Calculated_		="Agency (Calculated)"					
Report__Units__0_30_		="Report: Units: 0-30%"
Report__Units__31_60_		="Report: Units: 31-60%"
Report__Units__61_80_		="Report: Units: 61-80%"
Report__Units__81_			="Report: Units: 81%+"
Report__Units__Affordable	="Report: Units: Affordable"
Report__Units__Market		="Report: Units: Market"
Report__Units__Total		="Report: Units: Total"
v100_						="100%"	
v120_						="120%"	
v30_						="30%"	
v40_						="40%"	
v50_						="50%"	
v60_						="60%"	
v80_						="80%"	
Address__Street_1			="Address: Street 1"
ADU_						="ADU?"
Agency__DCHA_Project_		="Agency: DCHA Project?"
Agency__DCHFA_Project_		="Agency: DCHFA Project?"
Agency__DGS_Project_		="Agency: DGS Project?"
Agency__DHCD_Project_		="Agency: DHCD Project?"
Agency__DMPED_Project_		="Agency: DMPED Project?"
Inclusionary_Zoning_Units	="Inclusionary Zoning Units"
Inclusionary_Zoning_		="Inclusionary Zoning?"
IZ_Database___AMI50			="IZ Database - AMI50"
IZ_Database___AMI80			="IZ Database - AMI80"
IZ_Database___CIZCDate		="IZ Database - CIZCDate"
IZ_Database___CompletionDate	="IZ Database - CompletionDate"
IZ_Database___IZUnits		="IZ Database - IZUnits"
IZ_Database___Project_Name	="IZ Database - Project Name"
IZ_Database___Related_Project	="IZ Database - Related Project"
IZ_Database___Status		="IZ Database - Status"
IZ_Database___Units			="IZ Database - Units"
Mixed_Use					="Mixed Use"
Preservation_				="Preservation?"
Priv_Grant_Funds			="Priv Grant Funds"	
Total_Subsidy				="Total Subsidy"
Voucher_Type				="Voucher Type"
;

run;

proc freq data=dmped.pipelineproperties;
table jointag*tenbytag/list missing nopercent;
table addressmerge*namemerge/list missing nopercent;
table addressmerge*namemerge*jointag*tenbytag/list missing nopercent;
run;
