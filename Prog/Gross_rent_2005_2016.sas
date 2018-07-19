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
07/16/18 LH Modify for table B25068 for bedrooms size. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )

%let START_YR = 2005;
%let END_YR = 2016;
%let output_path = &_dcdata_default_path\DMPED\Prog;
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

	data grossrent_&yr.a (drop=HD01_VD04  HD01_VD05  HD01_VD13  HD01_VD14 HD01_VD06  HD01_VD15 HD01_VD07  HD01_VD16 HD01_VD08  HD01_VD17  HD01_VD09  HD01_VD18
		  		HD01_VD22 HD01_VD23 HD01_VD24 HD01_VD25 HD01_VD26 HD01_VD31 HD01_VD32 HD01_VD33 HD01_VD34 HD01_VD35 HD01_VD10 HD01_VD11 HD01_VD02 HD01_VD19 HD01_VD20 HD01_VD28 HD01_VD29
				HD01_VD37
							rename=(
									new_HD01_VD13=HD01_VD13
									new_HD01_VD14=HD01_VD14
									new_HD01_VD15=HD01_VD15
									new_HD01_VD16=HD01_VD16
									new_HD01_VD17=HD01_VD17 
									new_HD01_VD22=HD01_VD22
									new_HD01_VD23=HD01_VD23
									new_HD01_VD24=HD01_VD24
									new_HD01_VD25=HD01_VD25
									new_HD01_VD31=HD01_VD31
									new_HD01_VD32=HD01_VD32
									new_HD01_VD33=HD01_VD33
									new_HD01_VD34=HD01_VD34));
		set grossrent_&yr.;

	drop HD02: ;

	new_HD01_VD13=HD01_VD04 + HD01_VD05 + HD01_VD13 + HD01_VD14;
	new_HD01_VD14=HD01_VD06 + HD01_VD15;
	new_HD01_VD15=HD01_VD07 + HD01_VD16;
	new_HD01_VD16=HD01_VD08 + HD01_VD17;
	new_HD01_VD17=HD01_VD09 + HD01_VD18; 

	new_HD01_VD22=HD01_VD22+ HD01_VD23;
	new_HD01_VD23=HD01_VD24;
	new_HD01_VD24=HD01_VD25;
	new_HD01_VD25=HD01_VD26;

	new_HD01_VD31=HD01_VD31+HD01_VD32;
	new_HD01_VD32=HD01_VD33;
	new_HD01_VD33=HD01_VD34;
	new_HD01_VD34=HD01_VD35;
	
	label 

		  new_HD01_VD13=" 0 to 1 bedrooms: - With cash rent: - Less than $300"
		  new_HD01_VD14=" 0 to 1 bedrooms: - With cash rent: -  $300 to $499"
		  new_HD01_VD15=" 0 to 1 bedrooms: - With cash rent: -  $500 to $749" 
		  new_HD01_VD16=" 0 to 1 bedrooms: - With cash rent: - 	$750 to $999" 
		  new_HD01_VD17=" 0 to 1 bedrooms: - With cash rent: -  $1,000 or more"
		  
		  new_HD01_VD22=" 2 bedrooms: - With cash rent: - Less than $300"
		  new_HD01_VD23=" 2 bedrooms: - With cash rent: - $300 to $499"
		  new_HD01_VD24=" 2 bedrooms: - With cash rent: - $500 to $749" 
		  new_HD01_VD25=" 2 bedrooms: - With cash rent: - $750 to $999" 

	      new_HD01_VD31=" 3 or more bedrooms: - With cash rent: - Less than $300"
		  new_HD01_VD32=" 3 or more bedrooms: - With cash rent: - $300 to $499"
		  new_HD01_VD33=" 3 or more bedrooms: - With cash rent: - $500 to $749" 
		  new_HD01_VD34=" 3 or more bedrooms: - With cash rent: - $750 to $999" 

		
	run;


	proc transpose data=grossrent_&yr.a  out=long_grossrent_&yr.;
		
		run;

	data long_grossrent_&yr.a; 

		set long_grossrent_&yr. (rename=(COL1=acs_20&yr.));

		if _name_ in("_TYPE_" "_FREQ_") then delete;
		run;

	proc sort data=long_grossrent_&yr.a;
	by _name_;
	run;
%end;
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
		HD01_VD35=" 3 or more bedrooms: - With cash rent: - $1,000 to $1,499"
		HD02_VD35="Margin of Error 3 or more bedrooms: - With cash rent: - $1,000 to $1,499"
		HD01_VD36=" 3 or more bedrooms: - With cash rent: - $1,500 or more"
		HD02_VD36="Margin of Error 3 or more bedrooms: - With cash rent: - $1,500 or more"
		HD01_VD37=" 3 or more bedrooms: - No cash rent"
		HD02_VD37="Margin of Error 3 or more bedrooms: - No cash rent"

		;

    run;

	data grossrent_&yr.a (drop=HD01_VD08 HD01_VD09 HD01_VD17 HD01_VD18 HD01_VD26 HD01_VD27 HD01_VD35 HD01_VD36 HD01_VD04 HD01_VD13 HD01_VD05 HD01_VD14 HD01_VD06 HD01_VD15  
							   HD01_VD07 HD01_VD16 HD01_VD02 HD01_VD10 HD01_VD11 HD01_VD19 HD01_VD20 HD01_VD28 HD01_VD29 HD01_VD37
						  rename=(
								  new_HD01_VD13=HD01_VD13
								  new_HD01_VD14=HD01_VD14
								  new_HD01_VD15=HD01_VD15
								  new_HD01_VD16=HD01_VD16
								  new_HD01_VD17=HD01_VD17
						  	      new_HD01_VD27=HD01_VD27
								  new_HD01_VD36=HD01_VD36)); 
		set grossrent_&yr.;
	
		drop HD02: ;

		new_HD01_VD13=HD01_VD04+HD01_VD13;
		new_HD01_VD14=HD01_VD05+HD01_VD14;
		new_HD01_VD15=HD01_VD06+HD01_VD15;
		new_HD01_VD16=HD01_VD07+HD01_VD16; 
		new_HD01_VD17=HD01_VD08+HD01_VD09+HD01_VD17+HD01_VD18;

		new_HD01_VD27=HD01_VD26+HD01_VD27;
		new_HD01_VD36=HD01_VD35+HD01_VD36;

		label 
			  new_HD01_VD13=" 0 to 1 bedroom: - With cash rent: - Less than $300"
			  new_HD01_VD14=" 0 to 1 bedroom: - With cash rent: - $300 to $499"
              new_HD01_VD15=" 0 to 1 bedroom: - With cash rent: - $500 to $749"
			  new_HD01_VD16=" 0 to 1 bedroom: - With cash rent: - $750 to $999"
			  new_HD01_VD17=" 0 to 1 bedroom: - With cash rent: - $1,000 or more"
			  new_HD01_VD27=" 2 bedrooms: - With cash rent: - $1,000 or more"
			  new_HD01_VD36=" 3 or more bedrooms: - With cash rent: - $1,000 or more"
			  ;

	proc transpose data=grossrent_&yr.a out=long_grossrent_&yr.;
		
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

    infile datalines missover dlm=',';

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
8442,7693,6815,6327,6313,5697,6494,6326,7455,6362,6216,8367,0,300
5381,4934,4608,3058,3629,3769,3695,3072,2269,4146,3375,4678,300,500
22163,15785,17315,12792,9268,9067,8213,7836,5354,4228,5058,5299,500,750
22685,17604,18130,17442,18087,14607,14631,15939,14200,13134,10662,11755,750,1000
26009,30166,32936,38745,38282,45769,56104,54926,56618,60561,62335,66987,1000,.
2150,4165,2615,3663,3923,2067,2606,2742,3658,2367,2918,2125,0,300
4311,2348,2314,1870,1908,2121,2778,2117,2242,1844,2572,1941,300,500
9121,7209,5455,5987,4456,2950,3865,3307,2790,2904,2522,2383,500,750
8217,8678,7932,9488,7289,8420,8159,7339,7771,8072,6193,5372,750,1000
13782,15532,17619,19152,21421,25064,26125,29119,29698,32314,36496,31881,1000,.
2618,2820,1712,1961,1440,1667,1049,1259,1345,1467,693,2268,0,300
1562,1189,1085,1561,1515,1051,1780,1687,305,963,1687,1175,300,500
2847,1824,3921,2123,1958,2085,2240,1922,1343,1308,1822,1275,500,750
2015,2586,2138,2016,2229,1816,2443,1396,1647,2331,1943,2565,750,1000
9075,10004,10128,12444,12531,14344,14110,13858,19804,16504,19329,17676,1000,.
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

data Gross_rent_&START_YR._&END_YR.a;
 	set Gross_rent_&START_YR._&END_YR. ;

if rcount_output <= 5 then bedrooms="0 to 1 bedrooms";
if 6 <=rcount_output <=10 then bedrooms="2 bedrooms";
if rcount_output > 10 then bedrooms="3+ bedrooms";

run; 
%File_info( data=Gross_rent_&START_YR._&END_YR.a, printobs=50 )

proc format;
  value rntrang
    0-299 = 'Under $300'
	300-499= '$300 to $500'
    500-749 = '$500 to $749'
    750-999 = '$750 to $1,000'
    1000-3000 = '$1,000 or more'
  
run;
proc sort data=Gross_rent_&START_YR._&END_YR.a;
by bedrooms;
proc tabulate data=Gross_rent_&START_YR._&END_YR.a format=comma10.0 noseps missing;
  by bedrooms; 
  class low ;
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
  title2 "Renter-Occupied Housing Units by Bedroom Size by Gross Rent, District of Columbia (UNADJUSTED)";
run;
    
ods csvall body="&output_path\Gross_bedrooms_rent_&START_YR._&END_YR..csv";

proc tabulate data=Gross_rent_&START_YR._&END_YR.a format=comma10.0 noseps missing;
 by bedrooms;
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
  title2 "Renter-Occupied Housing Units by Bedroom Size by Gross Rent, District of Columbia (constant &END_YR. $)";
run;

ods csvall close;
