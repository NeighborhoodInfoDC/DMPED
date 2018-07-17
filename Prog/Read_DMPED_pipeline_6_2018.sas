/**************************************************************************
 Program:  DMPED_pipeline_6_2018.sas
 Library:  HUD
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  7/4/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read DMPED Pipeline database and create separate files for
 HPTF and IZ projects.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( MAR )

%let year = 2018;
%let month = 06;
%let ds_label = DMPED Pipeline, placed in service through &year;
  data 
    HPTF_&month._&year._dc (label="&ds_label, DC") ;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\HPTF_&month._&year..csv" dsd stopover lrecl=2000 firstobs=2;
input
                   PROJECT_NAME : $80.
                   Address : $80.
                   Status : $40.
                   Total_affordable_units : 4.
                   Units_0_30_AMI : 4.
                   Units_31_50_AMI : 4.
                   Units_51_60_AMI : 4.
                   Units_61_80_AMI : 4.
                   Units_81_AMI : 4.
                   MAR_WARD : $10.
                   Inclusionary_Zoning : $4.
                   Agency : $30.
                   PUD : $3.
                   Start_closing_date :$10.
                   Estimated_or_Actual_start :$10.
                   Construction_End_Date :$10.
                   Estimated_or_Actual_End_Date :$10.
                   Address_Postal_Code: $5.
                   ADU : $3.
                  Affordable_units_manual_entry : 4. 
                   DCHA_Units_0_30_AMI : 4.
                   DCHA_Units_31_50_AMI : 4.
                   DCHA_Units_51_60_AMI : 4.
                   DCHA_Units_61_80_AMI : 4.
                   DCHA_Units_Affordable_total : 4.
                   DCHFA_UnitsUnits_0_30_AMI : 4.
                   DCHFA_Units_31_50_AMI : 4.
                   DCHFA_Units_51_60_AMI : 4.
                   DCHFA_Units_61_80_AMI : 4.
                   DCHFA_Units_Affordable : 4.
                   DHCD_DFD_0_30_AMI : 4.
                   DHCD_DFD_31_40_AMI : 4.
                   DHCD_DFD_41_50_AMI : 4.
                   DHCD_DFD_51_60_AMI : 4.
                   DHCD_DFD_61_80_AMI : 4.
                   DHCD_DFD_allsubsidy : 4.
                   DHCD_DFD_pubhousing : 4.
                   DHCD_DFD_total : 4.
                   DMPED_PPD_0_30_AMI : 4.
                   DMPED_PPD_31_50_AMI : 4.
                   DMPED_PPD_51_60_AMI : 4.
                   DMPED_PPD_61_80_AMI : 4.
                   HPTF_Affordable_Units : 4.
                   IZ_Database_total : 4.
                   IZ_Database_0_50_AMI : 4.
                   IZ_Database_51_60_AMI : 4.
                   IZ_Database_61_80_AMI : 4.
                   PUD_Affordable_Units : 4.
                   PUD_Units_0_30_MFI : 4.
                   PUD_Units_31_60_MFI : 4.
                   PUD_Units_61_80_MFI : 4.
                   PUD_Units_81_MFI : 4.
                   TOPA : $3.
                   DHCD_0_30_AMI : 4.
                   DHCD_31_50_AMI : 4.
                   DHCD_51_60_AMI : 4.
                   DHCD_61_80_AMI : 4.
       ;
	    retain Extract_date;
    **Data Entry Fixes**;
		if address = "1919 14th Street, Washington, District of Columbia 20009" then address = "1919 14th Street NW, Washington, District of Columbia 20009";
    	if address = "2850 Douglass Place, Washington, District of Columbia 20020" then address = "2850 Douglass Place SE, Washington, District of Columbia 20020";
		if address = "3400-3429 10 PL SE, Washington, District of Columbia 20032" then address = "3400-3429 10th PL SE, Washington, District of Columbia 20032";
		if address = "4924 Nash Street, District of Columbia" then address = "4924 Nash Street NE, District of Columbia";
		if address = "3825 Georgia Avenue, Washington, District of Columbia" then address = "3825 Georgia Avenue NW, Washington, District of Columbia";
		if address = "6000 New Hampshire Ave, Washington, District of Columbia 20011" then address = "6000 New Hampshire Ave NE, Washington, District of Columbia 20011";
		if address = "627 Regent Pl, Washington, District of Columbia 20017" then address = "627 Regent Pl NE, Washington, District of Columbia 20017";
    label;

  run;

  data 
    IZ_&month._&year._dc (label="&ds_label, DC") ;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\IZ_&month._&year..csv" dsd stopover lrecl=2000 firstobs=2;
input
                   PROJECT_NAME : $80.
                   Address : $80.
                   Status : $40.
                   Total_affordable_units : 4.
                   Units_0_30_AMI : 4.
                   Units_31_50_AMI : 4.
                   Units_51_60_AMI : 4.
                   Units_61_80_AMI : 4.
                   Units_81_AMI : 4.
                   MAR_WARD : $10.
                   Inclusionary_Zoning : $4.
                   Agency : $20.
                   PUD : $3.
                   Start_closing_date :$10.
                   Estimated_or_Actual_start :$10.
                   Construction_End_Date :$10.
                   Estimated_or_Actual_End_Date :$10.
                   Address_Postal_Code: $5.
                   ADU : $3.
                  Affordable_units_manual_entry : 4. 
                   DCHA_Units_0_30_AMI : 4.
                   DCHA_Units_31_50_AMI : 4.
                   DCHA_Units_51_60_AMI : 4.
                   DCHA_Units_61_80_AMI : 4.
                   DCHA_Units_Affordable_total : 4.
                   DCHFA_UnitsUnits_0_30_AMI : 4.
                   DCHFA_Units_31_50_AMI : 4.
                   DCHFA_Units_51_60_AMI : 4.
                   DCHFA_Units_61_80_AMI : 4.
                   DCHFA_Units_Affordable : 4.
                   DHCD_DFD_0_30_AMI : 4.
                   DHCD_DFD_31_40_AMI : 4.
                   DHCD_DFD_41_50_AMI : 4.
                   DHCD_DFD_51_60_AMI : 4.
                   DHCD_DFD_61_80_AMI : 4.
                   DHCD_DFD_allsubsidy : 4.
                   DHCD_DFD_pubhousing : 4.
                   DHCD_DFD_total : 4.
                   DMPED_PPD_0_30_AMI : 4.
                   DMPED_PPD_31_50_AMI : 4.
                   DMPED_PPD_51_60_AMI : 4.
                   DMPED_PPD_61_80_AMI : 4.
                   HPTF_Affordable_Units : 4.
                   IZ_Database_total : 4.
                   IZ_Database_0_50_AMI : 4.
                   IZ_Database_51_60_AMI : 4.
                   IZ_Database_61_80_AMI : 4.
                   PUD_Affordable_Units : 4.
                   PUD_Units_0_30_MFI : 4.
                   PUD_Units_31_60_MFI : 4.
                   PUD_Units_61_80_MFI : 4.
                   PUD_Units_81_MFI : 4.
                   TOPA : $3.
                   DHCD_0_30_AMI : 4.
                   DHCD_31_50_AMI : 4.
                   DHCD_51_60_AMI : 4.
                   DHCD_61_80_AMI : 4.
       ;
	    retain Extract_date ;
    
        **Data Entry Fixes**;
		if address = "1919 14th Street, Washington, District of Columbia 20009" then address = "1919 14th Street NW, Washington, District of Columbia 20009";
    	if address = "3400-3429 10 PL SE, Washington, District of Columbia 20032" then address = "3400-3429 10th PL SE, Washington, District of Columbia 20032";
    label  ;


  run;

  data 
    IZ_Units_&month._&year._dc (label="&ds_label, DC") ;
 infile "L:\Libraries\DMPED\Raw\Housing Pipeline\IZ_Units_&month._&year..csv" dsd stopover lrecl=2000 firstobs=2;
input
	Project :$80.
	Construction_Status :$40.
	Project_Address :$80.
	IZ_Unit_Num :$10.
	Tenure :$10.
	Bedrooms :1.
	AMI :$10.
	Estimated_Availability_Date :$12.
	drop_ : 2.
	Unit_Total :3.;

run;

proc sort data = IZ_Units_&month._&year._dc out =IZ_Units_&month._&year._dc;
	by project;
run;

data iz_bedrooms;
	set IZ_Units_&month._&year._dc;
	by project;
	keep project construction_status tenure project_address bedrooms0-bedrooms5 ami50 ami60 ami80 estimated_availability_date unit_total;
	retain bedrooms0-bedrooms5 ami50 ami80;
	array abedrooms(0:5) bedrooms0-bedrooms5;
	array aami(0:2) ami50 ami60 ami80;
	if first.project then do; do i = 0 to 5; abedrooms(i)=0; 	end; do i = 0 to 2; aami(i) = 0; end; end;
	do i = 0 to 5;
	if bedrooms = i then abedrooms(i) +1;
	end;
	if ami = "50% AMI" then ami50 +1;
	if ami = "60% AMI" then ami60 +1;
	if ami = "80% AMI" then ami80 +1;
	if last.project then output;
run;

proc sort data = IZ_&month._&year._dc out =IZ_&month._&year._dc;
	by project_name;
run;

** Geocode **;

 %DC_mar_geocode(
  data = iz_bedrooms,
  staddr = project_address,
  zip=,
  out = iz_bed_mar,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

 %DC_mar_geocode(
  data = IZ_&month._&year._dc,
  staddr = address,
  zip=,
  out = iz_proj_mar,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

 %DC_mar_geocode(
  data = HPTF_&month._&year._dc,
  staddr = address,
  zip=,
  out = hptf_proj_mar,
  geo_match = Y,
  streetalt_file=,
  debug = Y,
  mprint = Y
);

proc sort data = iz_bed_mar;
	by _dcg_adr_streetname_clean _dcg_adr_begnum _dcg_adr_streettype _dcg_adr_quad;
run;

proc sort data = iz_proj_mar;
	by _dcg_adr_streetname_clean _dcg_adr_begnum _dcg_adr_streettype _dcg_adr_quad;
run;


  ** Finalize data sets **;

    %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=iz_bed_mar,
      out=DMPED_IZ_BED_&year,
      outlib=DMPED,
      label="&ds_label, %upcase(&v)",
      sortby=Project_name,
      /** Metadata parameters **/
      restrictions=None,
      revisions=%str(&revisions),
      /** File info parameters **/
      printobs=0,
      freqvars=
    )

  %end;


    %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=iz_proj_mar,
      out=DMPED_IZ_&year,
      outlib=DMPED,
      label="&ds_label, %upcase(&v)",
      sortby=Project_name,
      /** Metadata parameters **/
      restrictions=None,
      revisions=%str(&revisions),
      /** File info parameters **/
      printobs=0,
      freqvars=
    )

  %end;

      %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=hptf_proj_mar,
      out=DMPED_HPTF_&year,
      outlib=DMPED,
      label="&ds_label, %upcase(&v)",
      sortby=Project_name,
      /** Metadata parameters **/
      restrictions=None,
      revisions=%str(&revisions),
      /** File info parameters **/
      printobs=0,
      freqvars=
    )

  %end;
