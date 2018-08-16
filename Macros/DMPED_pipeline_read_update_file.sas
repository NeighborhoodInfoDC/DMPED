/**************************************************************************
 Program:  DMPED_pipeline_read_update_file.sas
 Library:  HUD
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  7/4/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Macro to read DMPED Pipeline database and create separate files for
 HPTF and IZ projects.

 Modifications:
**************************************************************************/


/** Macro DMPED_pipeline_read_update_file - Start Definition **/

%macro DMPED_pipeline_read_update_file( 
  filedate=,                      /** File extract date (SAS date value) **/
  folder=&_dcdata_r_path\DMPED,     /** Folder for input raw files **/ 
  revisions=%str(New file.)       /** Metadata revision description **/
  );
  
  %local month year filedate_fmt ds_label;

  %let month = %sysfunc( month( &filedate ), z2. );
  %let year  = %sysfunc( year( &filedate ), z4. );
  %let filedate_fmt = %sysfunc( putn( &filedate, mmddyyd10. ) );
  %let ds_label = DMPED pipeline, &filedate_fmt update; 

  data
    HPTF_&year._&month (label="&ds_label") ;
 infile "&folder\raw\Housing Pipeline\hptf_&filedate_fmt..csv" dsd stopover lrecl=2000 firstobs=2;
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
    label
	project_name = "Project name"
	address = "Project address"
	status = "Completion status"
	total_affordable_units = "Affordable units"
	units_0_30_AMI = "Number of units at 0-30% of AMI"
	units_31_50_AMI = "Number of units at 31-50% of AMI"
	units_51_60_AMI = "Number of units at 51-60% of AMI"
	units_61_80_AMI = "Number of units at 61-80% of AMI"
	mar_ward = "MAR Ward"
	inclusionary_zoning = "Property is inclusionary zoning"
	agency = "DC Government Agency"
	PUD = "Property is part of a PUD"
	Start_closing_date = "Closing date"
	Estimated_or_Actual_start = "Actual or estimated start date?"
	Construction_End_Date = "Construction completion date"
	Estimated_or_Actual_End_Date = "Actual or estimated end date?"
	Address_Postal_Code = "Zip code"
	ADU = "Project is an ADU"
	Affordable_units_manual_entry = "Manual entry of number of units"
	DCHA_Units_0_30_AMI = "Number of DCHA units at 0-30% of AMI"
	DCHA_Units_31_50_AMI = "Number of DCHA units at 31-50% of AMI"
	DCHA_Units_51_60_AMI = "Number of DCHA units at 51-60% of AMI"
	DCHA_Units_61_80_AMI = "Number of DCHA units at 61-80% of AMI"
	DCHA_Units_Affordable_total = "Total number of DCHA affordable units"
	DCHFA_UnitsUnits_0_30_AMI = "Number of DCHFA units at 0-30% of AMI"
	DCHFA_Units_31_50_AMI = "Number of DCHFA units at 31-50% of AMI"
	DCHFA_Units_51_60_AMI = "Number of DCHFA units at 51-60% of AMI"
	DCHFA_Units_61_80_AMI = "Number of DCHFA units at 61-80% of AMI"
	DCHFA_Units_Affordable = "Total number of DCHFA affordable units"
	DHCD_DFD_0_30_AMI = "Number of DHCD-DFD units at 0-30% of AMI"
	DHCD_DFD_31_40_AMI = "Number of DHCD-DFD units at 31-40% of AMI"
	DHCD_DFD_41_50_AMI = "Number of DHCD-DFD units at 41-50% of AMI"
	DHCD_DFD_51_60_AMI = "Number of DHCD-DFD units at 51-60% of AMI"
	DHCD_DFD_61_80_AMI = "Number of DHCD-DFD units at 61-80% of AMI"
	DHCD_DFD_allsubsidy = "Total number of DHCD-DFD subsidized units"
	DHCD_DFD_pubhousing = "Total number DHCD-DFD public housing units"
	DHCD_DFD_total = "Total number of DHCD-DFD affordable units"
	DMPED_PPD_0_30_AMI ="Number of DMPED-PPD units at 0-30% of AMI"
	DMPED_PPD_31_50_AMI ="Number of DMPED-PPD units at 31-50% of AMI"
	DMPED_PPD_51_60_AMI ="Number of DMPED-PPD units at 51-60% of AMI"
	DMPED_PPD_61_80_AMI ="Number of DMPED-PPD units at 61-80% of AMI"
	HPTF_Affordable_Units = "Number of Housing Production Trust Fund affordable units"
	IZ_Database_total = "Total number of IZ units"
	IZ_Database_0_50_AMI = "Number of IZ units at 0-50% of AMI"
	IZ_Database_51_60_AMI = "Number of IZ units at 51-60% of AMI"
	IZ_Database_61_80_AMI = "Number of IZ units at 61-80% of AMI"
	PUD_Affordable_Units = "Total number of PUD affordable units"
	PUD_Units_0_30_MFI = "Number of PUD units at 0-30% of MFI"
	PUD_Units_31_60_MFI = "Number of PUD units at 31-60% of MFI"
	PUD_Units_61_80_MFI = "Number of PUD units at 61-80% of MFI"
	PUD_Units_81_MFI = "Number of PUD units over 81% of MFI"
	TOPA = "TOPA Project"
	DHCD_0_30_AMI = "Number of DHCD units at 0-30% of AMI"
	DHCD_31_50_AMI = "Number of DHCD units at 31-50% of AMI"
	DHCD_51_60_AMI = "Number of DHCD units at 51-60% of AMI"
	DHCD_61_80_AMI = "Number of DHCD-DFD units at 61-80% of AMI";

  run;

  data 
    IZ_&year._&month (label="&ds_label, DC") ;
 infile "&folder\raw\Housing Pipeline\iz_&filedate_fmt..csv" dsd stopover lrecl=2000 firstobs=2;
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
       label
	project_name = "Project name"
	address = "Project address"
	status = "Completion status"
	total_affordable_units = "Affordable units"
	units_0_30_AMI = "Number of units at 0-30% of AMI"
	units_31_50_AMI = "Number of units at 31-50% of AMI"
	units_51_60_AMI = "Number of units at 51-60% of AMI"
	units_61_80_AMI = "Number of units at 61-80% of AMI"
	mar_ward = "MAR Ward"
	inclusionary_zoning = "Property is inclusionary zoning"
	agency = "DC Government Agency"
	PUD = "Property is part of a PUD"
	Start_closing_date = "Closing date"
	Estimated_or_Actual_start = "Actual or estimated start date?"
	Construction_End_Date = "Construction completion date"
	Estimated_or_Actual_End_Date = "Actual or estimated end date?"
	Address_Postal_Code = "Zip code"
	ADU = "Project is an ADU"
	Affordable_units_manual_entry = "Manual entry of number of units"
	DCHA_Units_0_30_AMI = "Number of DCHA units at 0-30% of AMI"
	DCHA_Units_31_50_AMI = "Number of DCHA units at 31-50% of AMI"
	DCHA_Units_51_60_AMI = "Number of DCHA units at 51-60% of AMI"
	DCHA_Units_61_80_AMI = "Number of DCHA units at 61-80% of AMI"
	DCHA_Units_Affordable_total = "Total number of DCHA affordable units"
	DCHFA_UnitsUnits_0_30_AMI = "Number of DCHFA units at 0-30% of AMI"
	DCHFA_Units_31_50_AMI = "Number of DCHFA units at 31-50% of AMI"
	DCHFA_Units_51_60_AMI = "Number of DCHFA units at 51-60% of AMI"
	DCHFA_Units_61_80_AMI = "Number of DCHFA units at 61-80% of AMI"
	DCHFA_Units_Affordable = "Total number of DCHFA affordable units"
	DHCD_DFD_0_30_AMI = "Number of DHCD-DFD units at 0-30% of AMI"
	DHCD_DFD_31_40_AMI = "Number of DHCD-DFD units at 31-40% of AMI"
	DHCD_DFD_41_50_AMI = "Number of DHCD-DFD units at 41-50% of AMI"
	DHCD_DFD_51_60_AMI = "Number of DHCD-DFD units at 51-60% of AMI"
	DHCD_DFD_61_80_AMI = "Number of DHCD-DFD units at 61-80% of AMI"
	DHCD_DFD_allsubsidy = "Total number of DHCD-DFD subsidized units"
	DHCD_DFD_pubhousing = "Total number DHCD-DFD public housing units"
	DHCD_DFD_total = "Total number of DHCD-DFD affordable units"
	DMPED_PPD_0_30_AMI ="Number of DMPED-PPD units at 0-30% of AMI"
	DMPED_PPD_31_50_AMI ="Number of DMPED-PPD units at 31-50% of AMI"
	DMPED_PPD_51_60_AMI ="Number of DMPED-PPD units at 51-60% of AMI"
	DMPED_PPD_61_80_AMI ="Number of DMPED-PPD units at 61-80% of AMI"
	HPTF_Affordable_Units = "Number of Housing Production Trust Fund affordable units"
	IZ_Database_total = "Total number of IZ units"
	IZ_Database_0_50_AMI = "Number of IZ units at 0-50% of AMI"
	IZ_Database_51_60_AMI = "Number of IZ units at 51-60% of AMI"
	IZ_Database_61_80_AMI = "Number of IZ units at 61-80% of AMI"
	PUD_Affordable_Units = "Total number of PUD affordable units"
	PUD_Units_0_30_MFI = "Number of PUD units at 0-30% of MFI"
	PUD_Units_31_60_MFI = "Number of PUD units at 31-60% of MFI"
	PUD_Units_61_80_MFI = "Number of PUD units at 61-80% of MFI"
	PUD_Units_81_MFI = "Number of PUD units over 81% of MFI"
	TOPA = "TOPA Project"
	DHCD_0_30_AMI = "Number of DHCD units at 0-30% of AMI"
	DHCD_31_50_AMI = "Number of DHCD units at 31-50% of AMI"
	DHCD_51_60_AMI = "Number of DHCD units at 51-60% of AMI"
	DHCD_61_80_AMI = "Number of DHCD-DFD units at 61-80% of AMI";

  run;

  data 
    IZ_Units_&year._&month (label="&ds_label, DC") ;
 infile "&folder\raw\Housing Pipeline\iz_units_&filedate_fmt..csv" dsd stopover lrecl=2000 firstobs=2;
input
	Project :$80.
	Construction_Status :$40.
	Project_Address :$80.
	IZ_Unit_Num :$10.
	Tenure :$10.
	Bedrooms :1.
	AMI :$10.
	Estimated_Availability_Date :$12.
	Bedrooms_iz_def : 2.
	Unit_Total :3.;
	    retain Extract_date;
       label
	project = "Project name"
	construction_status = "Construction status"
	project_address = "Project address"
	iz_unit_num = "Unit Number"
	tenure = "Rental or owner"
	bedrooms = "Number of bedrooms"
	AMI = "AMI level of unit"
	estimated_availability_date = "Date of availability"
	bedrooms_iz_def = "Number of bedrooms using IZ definition"
	unit_total = "Total number of IZ units in building"
run;

  ** Finalize data sets **;

    %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=iz_&year._&month,
      out=iz_&year._&month,
      outlib=DMPED,
      label="&ds_label, %upcase(&v)",
      sortby=Project_name,
      /** Metadata parameters **/
      restrictions=None,
      revisions=%str(&revisions),
      /** File info parameters **/
      printobs=5,
      freqvars=
    )

  %end;

    %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=iz_units_&year._&month,
      out=iz_units_&year._&month,
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
      data=hptf_&year._&month,
      out=hptf_&year._&month,
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
    
  %exit_macro:

%mend DMPED_pipeline_read_update_file;

/** End Macro Definition **/
