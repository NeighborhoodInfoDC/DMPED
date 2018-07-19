/**************************************************************************
 Program:  Gross_rent_large_2005_2016.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  06/20/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Creates adjusted gross rent ranges for 
 DC rental housing units by gross rent trend chart. 

 Data from ACS 1-year table B25063/GROSS RENT downloaded from American
 Factfinder. 
 
 Copy and paste lastest ACS data into DATALINES statement below.
 
 Upper ranges for 2015 and later were collapsed into $2,000 or more.

 Modifications: 
07/16/18 LH Modify for table B25068 for large units. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

%let START_YR = 2005;
%let END_YR = 2016;
%let output_path = &_dcdata_default_path\DPMED\Prog\;
libname raw "L:\Libraries\DMPED\Raw\"; 

%let year=05 06 07 08 09 10 11 12 13 14 15 16;

%macro all_years; 

%do i = 1 %to 10;  
%let yr=%scan(&year.,&i.," "); 

data WORK.grossrent_&yr.   ;
     %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
     infile "L:\Libraries\DMPED\Raw\ACS_&yr._1YR_B25068_with_ann.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3
  ;
       informat GEO_id $11. ;
       informat statecd $2. ;
       informat GEO_display_label $20. ;
       informat HD01_VD01 best32. ;
       informat HD02_VD01 best32. ;
       informat HD01_VD02 best32. ;
       informat HD02_VD02 best32. ;
       informat HD01_VD03 best32. ;
       informat HD02_VD03 best32. ;
       informat HD01_VD04 best32. ;
       informat HD02_VD04 best32. ;
       informat HD01_VD05 best32. ;
       informat HD02_VD05 best32. ;
       informat HD01_VD06 best32. ;
       informat HD02_VD06 best32. ;
       informat HD01_VD07 best32. ;
       informat HD02_VD07 best32. ;
       informat HD01_VD08 best32. ;
       informat HD02_VD08 best32. ;
       informat HD01_VD09 best32. ;
       informat HD02_VD09 best32. ;
       informat HD01_VD10 best32. ;
       informat HD02_VD10 best32. ;
       informat HD01_VD11 best32. ;
       informat HD02_VD11 best32. ;
       informat HD01_VD12 best32. ;
       informat HD02_VD12 best32. ;
       informat HD01_VD13 best32. ;
       informat HD02_VD13 best32. ;
       informat HD01_VD14 best32. ;
       informat HD02_VD14 best32. ;
       informat HD01_VD15 best32. ;
       informat HD02_VD15 best32. ;
       informat HD01_VD16 best32. ;
       informat HD02_VD16 best32. ;
       informat HD01_VD17 best32. ;
       informat HD02_VD17 best32. ;
       informat HD01_VD18 best32. ;
       informat HD02_VD18 best32. ;
       informat HD01_VD19 best32. ;
       informat HD02_VD19 best32. ;
       informat HD01_VD20 best32. ;
       informat HD02_VD20 best32. ;
       informat HD01_VD21 best32. ;
       informat HD02_VD21 best32. ;
       informat HD01_VD22 best32. ;
       informat HD02_VD22 best32. ;
       informat HD01_VD23 best32. ;
       informat HD02_VD23 best32. ;
       informat HD01_VD24 best32. ;
       informat HD02_VD24 best32. ;
       informat HD01_VD25 best32. ;
       informat HD02_VD25 best32. ;
       informat HD01_VD26 best32. ;
       informat HD02_VD26 best32. ;
       informat HD01_VD27 best32. ;
       informat HD02_VD27 best32. ;
       informat HD01_VD28 best32. ;
       informat HD02_VD28 best32. ;
       informat HD01_VD29 best32. ;
       informat HD02_VD29 best32. ;
       informat HD01_VD30 best32. ;
       informat HD02_VD30 best32. ;
       informat HD01_VD31 best32. ;
       informat HD02_VD31 best32. ;
       informat HD01_VD32 best32. ;
       informat HD02_VD32 best32. ;
       informat HD01_VD33 best32. ;
       informat HD02_VD33 best32. ;
       informat HD01_VD34 best32. ;
       informat HD02_VD34 best32. ;
       informat HD01_VD35 best32. ;
       informat HD02_VD35 best32. ;
       informat HD01_VD36 best32. ;
       informat HD02_VD36 best32. ;
       informat HD01_VD37 best32. ;
       informat HD02_VD37 best32. ;
      
    input
                GEO_id $
                statecd $
                GEO_display_label $
                HD01_VD01
                HD02_VD01
                HD01_VD02
                HD02_VD02
                HD01_VD03
                HD02_VD03
                HD01_VD04
                HD02_VD04
                HD01_VD05
                HD02_VD05
                HD01_VD06
                HD02_VD06
                HD01_VD07
                HD02_VD07
                HD01_VD08
                HD02_VD08
                HD01_VD09
                HD02_VD09
                HD01_VD10
                HD02_VD10
                HD01_VD11
                HD02_VD11
                HD01_VD12
                HD02_VD12
                HD01_VD13
                HD02_VD13
                HD01_VD14
                HD02_VD14
                HD01_VD15
                HD02_VD15
                HD01_VD16
                HD02_VD16
                HD01_VD17
                HD02_VD17
                HD01_VD18
                HD02_VD18
                HD01_VD19
                HD02_VD19
                HD01_VD20
                HD02_VD20
                HD01_VD21
                HD02_VD21
                HD01_VD22
                HD02_VD22
                HD01_VD23
                HD02_VD23
                HD01_VD24
                HD02_VD24
                HD01_VD25
                HD02_VD25
                HD01_VD26
                HD02_VD26
                HD01_VD27
                HD02_VD27
                HD01_VD28
                HD02_VD28
                HD01_VD29
                HD02_VD29
                HD01_VD30
                HD02_VD30
                HD01_VD31
                HD02_VD31
                HD01_VD32
                HD02_VD32
                HD01_VD33
                HD02_VD33
                HD01_VD34
                HD02_VD34
                HD01_VD35
                HD02_VD35
                HD01_VD36
                HD02_VD36
                HD01_VD37
                HD02_VD37
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

	label 

		HD01_VD01=" Total: Renter-occupied housing units"
		HD02_VD01="Margin of Error Total:	Renter-occupied housing units"
		HD01_VD02=" No bedroom"
		HD02_VD02="Margin of Error No bedroom"
		HD01_VD03=" No bedroom: - With cash rent"
		HD02_VD03="Margin of Error No bedroom: - With cash rent"
		HD01_VD04=" No bedroom: - With cash rent: - Less than $200"
		HD02_VD04="Margin of Error No bedroom: - With cash rent: - Less than $200"
		HD01_VD05=" No bedroom: - With cash rent: - $200 to $299"
		HD02_VD05="Margin of Error No bedroom: - With cash rent: - $200 to $299"
		HD01_VD06=" No bedroom: - With cash rent: - $300 to $499"
		HD02_VD06="Margin of Error No bedroom: - With cash rent: - $300 to $499"
		HD01_VD07=" No bedroom: - With cash rent: - $500 to $749"
		HD02_VD07="Margin of Error No bedroom: - With cash rent: - $500 to $749"
		HD01_VD08=" No bedroom: - With cash rent: - $750 to $999"
		HD02_VD08="Margin of Error No bedroom: - With cash rent: - $750 to $999"
		HD01_VD09=" No bedroom: - With cash rent: - $1,000 or more"
		HD02_VD09="Margin of Error No bedroom: - With cash rent: - $1,000 or more"
		HD01_VD10=" No bedroom: - No cash rent"
		HD02_VD10="Margin of Error No bedroom: - No cash rent"
		HD01_VD11=" 1 bedroom"
		HD02_VD11="Margin of Error 1 bedroom"
		HD01_VD12=" 1 bedroom: - With cash rent"
		HD02_VD12="Margin of Error 1 bedroom: - With cash rent"
		HD01_VD13=" 1 bedroom: - With cash rent: - Less than $200"
		HD02_VD13="Margin of Error 1 bedroom: - With cash rent: - Less than $200"
		HD01_VD14=" 1 bedroom: - With cash rent: - $200 to $299"
		HD02_VD14="Margin of Error 1 bedroom: - With cash rent: - $200 to $299"
		HD01_VD15=" 1 bedroom: - With cash rent: - $300 to $499"
		HD02_VD15="Margin of Error 1 bedroom: - With cash rent: - $300 to $499"
		HD01_VD16=" 1 bedroom: - With cash rent: - $500 to $749"
		HD02_VD16="Margin of Error 1 bedroom: - With cash rent: - $500 to $749"
		HD01_VD17=" 1 bedroom: - With cash rent: - $750 to $999"
		HD02_VD17="Margin of Error 1 bedroom: - With cash rent: - $750 to $999"
		HD01_VD18=" 1 bedroom: - With cash rent: - $1,000 or more"
		HD02_VD18="Margin of Error 1 bedroom: - With cash rent: - $1,000 or more"
		HD01_VD19=" 1 bedroom: - No cash rent"
		HD02_VD19="Margin of Error 1 bedroom: - No cash rent"
		HD01_VD20=" 2 bedrooms"
		HD02_VD20="Margin of Error 2 bedrooms"
		HD01_VD21=" 2 bedrooms: - With cash rent"
		HD02_VD21="Margin of Error 2 bedrooms: - With cash rent"
		HD01_VD22=" 2 bedrooms: - With cash rent: - Less than $200"
		HD02_VD22="Margin of Error 2 bedrooms: - With cash rent: - Less than $200"
		HD01_VD23=" 2 bedrooms: - With cash rent: - $200 to $299"
		HD02_VD23="Margin of Error 2 bedrooms: - With cash rent: - $200 to $299"
		HD01_VD24=" 2 bedrooms: - With cash rent: - $300 to $499"
		HD02_VD24="Margin of Error 2 bedrooms: - With cash rent: - $300 to $499"
		HD01_VD25=" 2 bedrooms: - With cash rent: - $500 to $749"
		HD02_VD25="Margin of Error 2 bedrooms: - With cash rent: - $500 to $749"
		HD01_VD26=" 2 bedrooms: - With cash rent: - $750 to $999"
		HD02_VD26="Margin of Error 2 bedrooms: - With cash rent: - $750 to $999"
		HD01_VD27=" 2 bedrooms: - With cash rent: - $1,000 or more"
		HD02_VD27="Margin of Error 2 bedrooms: - With cash rent: - $1,000 or more"
		HD01_VD28=" 2 bedrooms: - No cash rent"
		HD02_VD28="Margin of Error 2 bedrooms: - No cash rent"
		HD01_VD29=" 3 or more bedrooms"
		HD02_VD29="Margin of Error 3 or more bedrooms"
		HD01_VD30=" 3 or more bedrooms: - With cash rent"
		HD02_VD30="Margin of Error 3 or more bedrooms: - With cash rent"
		HD01_VD31=" 3 or more bedrooms: - With cash rent: - Less than $200"
		HD02_VD31="Margin of Error 3 or more bedrooms: - With cash rent: - Less than $200"
		HD01_VD32=" 3 or more bedrooms: - With cash rent: - $200 to $299"
		HD02_VD32="Margin of Error 3 or more bedrooms: - With cash rent: - $200 to $299"
		HD01_VD33=" 3 or more bedrooms: - With cash rent: - $300 to $499"
		HD02_VD33="Margin of Error 3 or more bedrooms: - With cash rent: - $300 to $499"
		HD01_VD34=" 3 or more bedrooms: - With cash rent: - $500 to $749"
		HD02_VD34="Margin of Error 3 or more bedrooms: - With cash rent: - $500 to $749"
		HD01_VD35=" 3 or more bedrooms: - With cash rent: - $750 to $999"
		HD02_VD35="Margin of Error 3 or more bedrooms: - With cash rent: - $750 to $999"
		HD01_VD36=" 3 or more bedrooms: - With cash rent: - $1,000 or more"
		HD02_VD36="Margin of Error 3 or more bedrooms: - With cash rent: - $1,000 or more"
		HD01_VD37=" 3 or more bedrooms: - No cash rent"
		HD02_VD37="Margin of Error 3 or more bedrooms: - No cash rent"

		;

    run;

	data grossrent_&yr.a (drop=HD01_VD31 HD01_VD32 HD01_VD33 HD01_VD34 HD01_VD35 
							rename=(new_HD01_VD31=HD01_VD31
									new_HD01_VD32=HD01_VD32
									new_HD01_VD33=HD01_VD33
									new_HD01_VD34=HD01_VD34);
		set grossrent_&yr.;

	new_HD01_VD31=HD01_VD31+HD01_VD32;
	new_HD01_VD32=HD01_VD33;
	new_HD01_VD33=HD01_VD34;
	new_HD01_VD34=HD01_VD35;
	
	run;


	proc transpose data=grossrent_&yr.a . out=long_grossrent_&yr.;
		
		run;

	data long_grossrent_&yr.a; 

		set long_grossrent_&yr. (rename=(COL1=acs_20&yr.));

		if _name_ in("_TYPE_" "_FREQ_") then delete;
		run;

	proc sort data=long_grossrent_&yr.a;
	by _name_;
	run;
%mend all_years;
%all_years;

%let yearsht=15 16;

%macro all_years_1516; 

%do i = 1 %to 2;  
%let yr=%scan(&yearsht.,&i.," "); 
	data WORK.grossrent_&yr.   ;
     %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
     infile "L:\Libraries\DMPED\Raw\ACS_&yr._1YR_B25068_with_ann.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=3
  ;
       informat GEO_id $11. ;
       informat statecd $2. ;
       informat GEO_display_label $20. ;
       informat HD01_VD01 best32. ;
       informat HD02_VD01 best32. ;
       informat HD01_VD02 best32. ;
       informat HD02_VD02 best32. ;
       informat HD01_VD03 best32. ;
       informat HD02_VD03 best32. ;
       informat HD01_VD04 best32. ;
       informat HD02_VD04 best32. ;
       informat HD01_VD05 best32. ;
       informat HD02_VD05 best32. ;
       informat HD01_VD06 best32. ;
       informat HD02_VD06 best32. ;
       informat HD01_VD07 best32. ;
       informat HD02_VD07 best32. ;
       informat HD01_VD08 best32. ;
       informat HD02_VD08 best32. ;
       informat HD01_VD09 best32. ;
       informat HD02_VD09 best32. ;
       informat HD01_VD10 best32. ;
       informat HD02_VD10 best32. ;
       informat HD01_VD11 best32. ;
       informat HD02_VD11 best32. ;
       informat HD01_VD12 best32. ;
       informat HD02_VD12 best32. ;
       informat HD01_VD13 best32. ;
       informat HD02_VD13 best32. ;
       informat HD01_VD14 best32. ;
       informat HD02_VD14 best32. ;
       informat HD01_VD15 best32. ;
       informat HD02_VD15 best32. ;
       informat HD01_VD16 best32. ;
       informat HD02_VD16 best32. ;
       informat HD01_VD17 best32. ;
       informat HD02_VD17 best32. ;
       informat HD01_VD18 best32. ;
       informat HD02_VD18 best32. ;
       informat HD01_VD19 best32. ;
       informat HD02_VD19 best32. ;
       informat HD01_VD20 best32. ;
       informat HD02_VD20 best32. ;
       informat HD01_VD21 best32. ;
       informat HD02_VD21 best32. ;
       informat HD01_VD22 best32. ;
       informat HD02_VD22 best32. ;
       informat HD01_VD23 best32. ;
       informat HD02_VD23 best32. ;
       informat HD01_VD24 best32. ;
       informat HD02_VD24 best32. ;
       informat HD01_VD25 best32. ;
       informat HD02_VD25 best32. ;
       informat HD01_VD26 best32. ;
       informat HD02_VD26 best32. ;
       informat HD01_VD27 best32. ;
       informat HD02_VD27 best32. ;
       informat HD01_VD28 best32. ;
       informat HD02_VD28 best32. ;
       informat HD01_VD29 best32. ;
       informat HD02_VD29 best32. ;
       informat HD01_VD30 best32. ;
       informat HD02_VD30 best32. ;
       informat HD01_VD31 best32. ;
       informat HD02_VD31 best32. ;
       informat HD01_VD32 best32. ;
       informat HD02_VD32 best32. ;
       informat HD01_VD33 best32. ;
       informat HD02_VD33 best32. ;
       informat HD01_VD34 best32. ;
       informat HD02_VD34 best32. ;
       informat HD01_VD35 best32. ;
       informat HD02_VD35 best32. ;
       informat HD01_VD36 best32. ;
       informat HD02_VD36 best32. ;
       informat HD01_VD37 best32. ;
       informat HD02_VD37 best32. ;
      
    input
                GEO_id $
                statecd $
                GEO_display_label $
                HD01_VD01
                HD02_VD01
                HD01_VD02
                HD02_VD02
                HD01_VD03
                HD02_VD03
                HD01_VD04
                HD02_VD04
                HD01_VD05
                HD02_VD05
                HD01_VD06
                HD02_VD06
                HD01_VD07
                HD02_VD07
                HD01_VD08
                HD02_VD08
                HD01_VD09
                HD02_VD09
                HD01_VD10
                HD02_VD10
                HD01_VD11
                HD02_VD11
                HD01_VD12
                HD02_VD12
                HD01_VD13
                HD02_VD13
                HD01_VD14
                HD02_VD14
                HD01_VD15
                HD02_VD15
                HD01_VD16
                HD02_VD16
                HD01_VD17
                HD02_VD17
                HD01_VD18
                HD02_VD18
                HD01_VD19
                HD02_VD19
                HD01_VD20
                HD02_VD20
                HD01_VD21
                HD02_VD21
                HD01_VD22
                HD02_VD22
                HD01_VD23
                HD02_VD23
                HD01_VD24
                HD02_VD24
                HD01_VD25
                HD02_VD25
                HD01_VD26
                HD02_VD26
                HD01_VD27
                HD02_VD27
                HD01_VD28
                HD02_VD28
                HD01_VD29
                HD02_VD29
                HD01_VD30
                HD02_VD30
                HD01_VD31
                HD02_VD31
                HD01_VD32
                HD02_VD32
                HD01_VD33
                HD02_VD33
                HD01_VD34
                HD02_VD34
                HD01_VD35
                HD02_VD35
                HD01_VD36
                HD02_VD36
                HD01_VD37
                HD02_VD37
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

	label 

		HD01_VD01=" Total: Renter-occupied housing units"
		HD02_VD01="Margin of Error Total:	Renter-occupied housing units"
		HD01_VD02=" No bedroom"
		HD02_VD02="Margin of Error No bedroom"
		HD01_VD03=" No bedroom: - With cash rent"
		HD02_VD03="Margin of Error No bedroom: - With cash rent"
		HD01_VD04=" No bedroom: - With cash rent: - Less than $300"
		HD02_VD04="Margin of Error No bedroom: - With cash rent: - Less than $300"
		HD01_VD05=" No bedroom: - With cash rent: - $300 to $499"
		HD02_VD05="Margin of Error No bedroom: - With cash rent: - $300 to $449"
		HD01_VD06=" No bedroom: - With cash rent: - $500 to $749"
		HD02_VD06="Margin of Error No bedroom: - With cash rent: - $500 to $749"
		HD01_VD07=" No bedroom: - With cash rent: - $750 to $999"
		HD02_VD07="Margin of Error No bedroom: - With cash rent: - $750 to $999"
		HD01_VD08=" No bedroom: - With cash rent: - $1,000 to $1,499"
		HD02_VD08="Margin of Error No bedroom: - With cash rent: - $1,000 to $1,499"
		HD01_VD09=" No bedroom: - With cash rent: - $1,500 or more"
		HD02_VD09="Margin of Error No bedroom: - With cash rent: - $1,500 or more"
		HD01_VD10=" No bedroom: - No cash rent"
		HD02_VD10="Margin of Error No bedroom: - No cash rent"
		HD01_VD11=" 1 bedroom"
		HD02_VD11="Margin of Error 1 bedroom"
		HD01_VD12=" 1 bedroom: - With cash rent"
		HD02_VD12="Margin of Error 1 bedroom: - With cash rent"
		HD01_VD13=" 1 bedroom: - With cash rent: - Less than $300"
		HD02_VD13="Margin of Error 1 bedroom: - With cash rent: - Less than $300"
		HD01_VD14=" 1 bedroom: - With cash rent: - $300 to $499"
		HD02_VD14="Margin of Error 1 bedroom: - With cash rent: - $300 to $499"
		HD01_VD15=" 1 bedroom: - With cash rent: - $500 to $749"
		HD02_VD15="Margin of Error 1 bedroom: - With cash rent: - $500 to $749"
		HD01_VD16=" 1 bedroom: - With cash rent: - $750 to $999"
		HD02_VD16="Margin of Error 1 bedroom: - With cash rent: - $750 to $999"
		HD01_VD17=" 1 bedroom: - With cash rent: - $1,000 to $1,499"
		HD02_VD17="Margin of Error 1 bedroom: - With cash rent: - $1,000 to $1,499"
		HD01_VD18=" 1 bedroom: - With cash rent: - $1,500 or more"
		HD02_VD18="Margin of Error 1 bedroom: - With cash rent: - $1,500 or more"
		HD01_VD19=" 1 bedroom: - No cash rent"
		HD02_VD19="Margin of Error 1 bedroom: - No cash rent"
		HD01_VD20=" 2 bedrooms"
		HD02_VD20="Margin of Error 2 bedrooms"
		HD01_VD21=" 2 bedrooms: - With cash rent"
		HD02_VD21="Margin of Error 2 bedrooms: - With cash rent"
		HD01_VD22=" 2 bedrooms: - With cash rent: - Less than $300"
		HD02_VD22="Margin of Error 2 bedrooms: - With cash rent: - Less than $300"
		HD01_VD23=" 2 bedrooms: - With cash rent: - $300 to $499"
		HD02_VD23="Margin of Error 2 bedrooms: - With cash rent: - $300 to $499"
		HD01_VD24=" 2 bedrooms: - With cash rent: - $500 to $749"
		HD02_VD24="Margin of Error 2 bedrooms: - With cash rent: - $500 to $749"
		HD01_VD25=" 2 bedrooms: - With cash rent: - $750 to $999"
		HD02_VD25="Margin of Error 2 bedrooms: - With cash rent: - $750 to $999"
		HD01_VD26=" 2 bedrooms: - With cash rent: - $1,000 to $1,4999"
		HD02_VD26="Margin of Error 2 bedrooms: - With cash rent: - $1,000 to $1,499"
		HD01_VD27=" 2 bedrooms: - With cash rent: - $1,500 or more"
		HD02_VD27="Margin of Error 2 bedrooms: - With cash rent: - $1,500 or more"
		HD01_VD28=" 2 bedrooms: - No cash rent"
		HD02_VD28="Margin of Error 2 bedrooms: - No cash rent"
		HD01_VD29=" 3 or more bedrooms"
		HD02_VD29="Margin of Error 3 or more bedrooms"
		HD01_VD30=" 3 or more bedrooms: - With cash rent"
		HD02_VD30="Margin of Error 3 or more bedrooms: - With cash rent"
		HD01_VD31=" 3 or more bedrooms: - With cash rent: - Less than $300"
		HD02_VD31="Margin of Error 3 or more bedrooms: - With cash rent: - Less than $300"
		HD01_VD32=" 3 or more bedrooms: - With cash rent: - $300 to $499"
		HD02_VD32="Margin of Error 3 or more bedrooms: - With cash rent: - $300 to $499"
		HD01_VD33=" 3 or more bedrooms: - With cash rent: - $500 to $749"
		HD02_VD33="Margin of Error 3 or more bedrooms: - With cash rent: - $500 to $749"
		HD01_VD34=" 3 or more bedrooms: - With cash rent: - $750 to $999"
		HD02_VD34="Margin of Error 3 or more bedrooms: - With cash rent: - $750 to $999"
		HD01_VD35=" 3 or more bedrooms: - With cash rent: - $1,000 to $1,4999"
		HD02_VD35="Margin of Error 3 or more bedrooms: - With cash rent: - $1,000 to $1,499"
		HD01_VD36=" 3 or more bedrooms: - With cash rent: - $1,500 or more"
		HD02_VD36="Margin of Error 3 or more bedrooms: - With cash rent: - $1,500 or more"
		HD01_VD37=" 3 or more bedrooms: - No cash rent"
		HD02_VD37="Margin of Error 3 or more bedrooms: - No cash rent"

		;

    run;

	proc transpose data=grossrent_&yr. out=long_grossrent_&yr.;
		
		run;

	data long_grossrent_&yr.a; 

		set long_grossrent_&yr. (rename=(COL1=acs_20&yr.));

		if _name_ in("_TYPE_" "_FREQ_") then delete;
		run;

	proc sort data=long_grossrent_&yr.a;
	by _name_;
	run;

%end;
%mend all_years_1516;
%all_years_1516;


data all_years_large;
merge long_grossrent_05a long_grossrent_06a long_grossrent_07a long_grossrent_08a long_grossrent_09a long_grossrent_10a long_grossrent_11a long_grossrent_12a
		long_grossrent_13a long_grossrent_14a long_grossrent_15a long_grossrent_16a;
by _name_;

if _name_ in ("HD01_VD30" "HD01_VD31" "HD01_VD32" "HD01_VD33" "HD01_VD34" "HD01_VD35" "HD01_VD36" "HD01_VD37");

run;
proc export data=all_years_large 
   outfile="&_dcdata_default_path\DMPED\Prog\grossrent_largeunits_2005_2016.csv"
   dbms=csv
   replace;
	run;


%macro rename_all( varA, varB );

  %do i = &START_YR %to &END_YR;
    &varA.&i=&varB.&i 
  %end;
  
%mend rename_all;

%macro enum_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i 
  %end;
  
%mend enum_all;

%macro label_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i = "&i"
  %end;
  
%mend label_all;

data 
  Base
    (keep=rcount_output low high Units&START_YR-Units&END_YR UnitsAdj&START_YR-UnitsAdj&END_YR
     Low&START_YR-Low&END_YR High&START_YR-High&END_YR)
  Carry_fwd
    (keep=rcount_output Carry_fwd&START_YR-Carry_fwd&END_YR
     rename=(%rename_all(Carry_fwd, UnitsAdj)))
  Carry_bck
    (keep=rcount_output Carry_bck&START_YR-Carry_bck&END_YR
     rename=(%rename_all(Carry_bck, UnitsAdj)))
  ;

    rcount_input + 1;

    infile datalines missover dlm='09'x;

    input
      %enum_all( Units )
      Low
      High
     ;
     
   ** Create low and high rent levels adjusted for inflation **;
   
   array a_low{&START_YR:&END_YR} Low&START_YR-Low&END_YR;
   array a_high{&START_YR:&END_YR} High&START_YR-High&END_YR;
   
   do i = &START_YR to &END_YR;
   
     %dollar_convert( Low, a_low{i}, i, &END_YR, series=CUUR0000SA0L2 )
     %dollar_convert( High, a_high{i}, i, &END_YR, series=CUUR0000SA0L2 )
        
   end;
   
   **retain Carry&START_YR-Carry&END_YR 0;
   
   array a_units{&START_YR:&END_YR} Units&START_YR-Units&END_YR;
   array a_unitsadj{&START_YR:&END_YR} UnitsAdj&START_YR-UnitsAdj&END_YR;
   array a_carry_fwd{&START_YR:&END_YR} Carry_fwd&START_YR-Carry_fwd&END_YR;
   array a_carry_bck{&START_YR:&END_YR} Carry_bck&START_YR-Carry_bck&END_YR;
   array a_rcount{&START_YR:&END_YR} Rcount&START_YR-Rcount&END_YR;
   
   do i = &START_YR to &END_YR;
   
     if high = . then do;
     
       if a_low{i} < low then do;
       
         a_unitsadj{i} = a_units{i} * 0.5;
         a_carry_bck{i} = a_units{i} * 0.5;
           
       end;
       else do;
       
         a_unitsadj{i} = a_units{i};
         
       end;
     
     end;
     else if a_high{i} > high then do;
     
       a_unitsadj{i} = a_units{i} * ( ( high - a_low{i} ) / ( a_high{i} - a_low{i} ) );
       a_carry_fwd{i} = a_units{i} * ( ( a_high{i} - high ) / ( a_high{i} - a_low{i} ) );
         
     end;
     else if a_high{i} <= high then do;
     
       a_unitsadj{i} = a_units{i} * ( ( a_high(i) - low ) / ( a_high{i} - a_low{i} ) );
       a_carry_bck{i} = a_units{i} * ( ( low - a_low{i} ) / ( a_high{i} - a_low{i} ) );

     end;
     
   end;
   
   rcount_output = rcount_input;
   output base;
   
   if rcount_input > 1 then do;
     rcount_output = rcount_input - 1;
     output carry_bck;
   end;
   
   if high ~= . then do;
     rcount_output = rcount_input + 1;
     output carry_fwd;
   end;
   
   *drop i Low&START_YR-Low&END_YR High&START_YR-High&END_YR Carry&START_YR-Carry&END_YR;

datalines;
2211	1616	1481	1972	1923	1364	745	1086	1148	1195	1152	2889	0	100
2324	2744	1551	1504	874	1070	1268	1191	1637	1010	709	991	100	150
3883	5436	3543	3828	3440	2999	2856	3218	2132	1659	1095	1533	150	200
2563	2672	2725	2286	2169	2107	2810	2236	4649	3324	4641	4733	200	250
2229	2210	1842	2361	3270	1891	2470	2596	2892	3008	2230	2614	250	300
1919	2131	1273	2603	2262	2339	2802	1329	1562	2030	1870	1690	300	350
2249	2579	1818	1071	1913	1413	1968	2007	1150	1713	1828	2226	350	400
2978	1854	2695	1468	1001	1222	1970	1586	1160	1569	1703	2536	400	450
4108	1907	2221	1347	1876	1967	1513	1954	944	1641	2233	1342	450	500
4119	4214	3283	3981	3149	2232	2033	2951	1267	1329	1179	753	500	550
6017	3812	4317	2922	1683	1988	2827	1765	1657	1493	1646	1368	550	600
7504	4892	5957	3808	3035	2583	2196	2732	1796	1203	2536	1695	600	650
7003	5448	5919	5284	3117	3017	3125	2360	2030	2021	1614	2543	650	700
9488	6452	7215	4907	4698	4282	4137	3257	2737	2394	2427	2598	700	750
7856	5495	6397	6582	4167	3222	3321	3766	4133	3121	2195	2393	750	800
11569	11124	11688	12304	13519	11739	11811	11139	9205	9874	7445	7837	800	900
13492	12249	10115	10060	9919	9882	10101	9769	10280	10542	9158	9462	900	1000
18437	21907	20368	22937	21710	18883	22200	22838	23547	22928	23858	23248	1000	1250
11314	12332	13860	14350	16240	21077	22244	20226	19068	16401	18579	20639	1250	1500
11767	11353	14381	16689	16373	22599	26570	27905	28618	28183	34371	30320	1500	2000
7348	10110	12074	16365	17911	22618	25325	26934	34887	41867	41352	42337	2000	.
;

run;

data All;

  set Base Carry_fwd Carry_bck;
  
run;

proc summary data=All nway;
  class rcount_output;
  id low high Units&START_YR-Units&END_YR;
  var unitsadj: ;
  output out=Gross_rent_&START_YR._&END_YR. sum=;
run;

/*** UNCOMMENT TO CHECK ***

%let testyr = 2012;

proc print data=Base;
  id rcount_output;
  var low high low&testyr high&testyr units&testyr unitsadj&testyr;
  sum units&testyr;
run;

proc print data=Carry_fwd;
  id rcount_output;
  var unitsadj&testyr ;
run;

proc print data=Carry_bck;
  id rcount_output;
  var unitsadj&testyr ;
run;

proc print data=All_sum;
  id rcount_output low high;
  var unitsadj&testyr ;
  sum unitsadj&testyr ;
run;

/**********************************/


%File_info( data=Gross_rent_&START_YR._&END_YR., printobs=50 )

proc format;
  value rntrang
    0-450 = 'Under $500'
    500-650 = '$500 to $699'
    700-750 = '$700 to $799'
    800-900 = '$800 to $999'
    1000-1250 = '$1,000 to $1,499'
    1500-2000 = '$1,500 or more';
run;

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var Units&START_YR.-Units&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( Units&START_YR.-Units&END_YR. )
  ;
  format low rntrang.;
  label 
    %label_all( Units )
  ;
  title2 "Renter-Occupied Housing Units by Gross Rent, District of Columbia (UNADJUSTED)";
run;
    
ods csvall body="&output_path\Gross_rent_&START_YR._&END_YR..csv";

proc tabulate data=Gross_rent_&START_YR._&END_YR. format=comma10.0 noseps missing;
  class low;
  var UnitsAdj&START_YR.-UnitsAdj&END_YR.;
  table 
    /** Rows **/
    Low=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( UnitsAdj&START_YR.-UnitsAdj&END_YR. )
  ;
  format low rntrang.;
  label 
    %label_all( UnitsAdj )
  ;
  title2 "Renter-Occupied Housing Units by Gross Rent, District of Columbia (constant &END_YR. $)";
run;

ods csvall close;
