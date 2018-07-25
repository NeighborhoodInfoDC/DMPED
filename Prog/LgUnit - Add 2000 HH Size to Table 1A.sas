/**************************************************************************
 Program:  LgUnit - Add 2000 HH Size to Table 1A.sas
 Library:  IPUMS
 Project:  NeighborhoodInfo DC
 Author:    Rob
 Created:  07/25/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read-in SF3 data to create indicators for Table 1A.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

%let filepath = "&_dcdata_r_path.\DMPED\Raw";
%let filename = DEC_00_SF3_H016_with_ann.csv;


filename fimport "&filepath.&Salesfile." lrecl=2000;

data Itspe_property_sales;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3 ;

  	informat GEOID $20 ;
	informat GEOID2 $11 ;
	informat GEONAME $99 ;
	informat VD01 best32.;
	informat VD02 best32.;
	informat VD03 best32.;
	informat VD04 best32.;
	informat VD05 best32.;
	informat VD06 best32.;
	informat VD07 best32.;
	informat VD08 best32.;

	input
	GEOID $
	GEOID2 $
	GEONAME $
	VD01
	VD02
	VD03
	VD04
	VD05
	VD06
	VD07
	VD08
	;

	label GEOID = "GeoID Full"
		  GEOID2 = "Census Tract ID"
		  GEONAME "Census Tract Name"
		  VD01 = "Total Households"
		  VD02 = "1-person household"
		  VD03 = "2-person household"
		  VD04 = "3-person household"
		  VD05 = "4-person household"
		  VD06 = "5-person household"
		  VD07 = "6-person household"
		  VD08 = "7-or-more-person household"
	;

run;
