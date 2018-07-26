/**************************************************************************
 Program:  DMPED_pipeline_read_update_file.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  06/18/2018
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro to read DMPED Pipeline update file.

 Modifications:
**************************************************************************/

/** Macro DMPED_pipeline_read_update_file - Start Definition **/

%macro DMPED_pipeline_read_update_file( 
  year=,                          /** Project placed in service through year **/
  filedate=,                      /** File extract date (SAS date value) **/
  folder=&_dcdata_r_path\DMPED\Raw\Housing Pipeline,     /** Folder for input raw files **/ 
  rawfile = pipeline,             /** Name of input data set **/
  revisions=%str(New file.)       /** Metadata revision description **/
);

  ** Check parameters **;
 
  %if not( %sysevalf( &filedate >= '01jan1990'd ) and %sysevalf( &filedate <= %sysfunc( today() ) ) ) %then %do;
    %err_mput( macro=DMPED_pipeline_read_update_file,
               msg=Must provide a valid file extract date: FILEDATE=&filedate.. )
    %goto exit_macro;
  %end;
 
 
  %** Define local macro variables **;
  
  %local recode_yesno month year filedate ds_label;

  %let recode_yesno = inclusionary_zoning pud adu topa;
  %let month = %sysfunc( month( &filedate ), z2. );
  %let year  = %sysfunc( year( &filedate ), z4. );
  %let filedate_fmt = %sysfunc( putn( &filedate, mmddyyd10. ) );
  %let ds_label = DMPED Pipeline, placed in service through &year;

  data 
    HPTF_&year._&month._dc (label="&ds_label, DC") ;
 infile "&folder\hptf_&filedate_fmt..csv" dsd stopover lrecl=2000 firstobs=2;
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
	    retain Extract_date &filedate;
    
    ** Recode variables **;
    
    label  ;

    /*format 
      &recode_yesno dyesno.
      extract_date mmddyy10.;*/

  run;



  data 
    IZ_&year._&month._dc (label="&ds_label, DC") ;
 infile "&folder\IZ_&filedate_fmt..csv" dsd stopover lrecl=2000 firstobs=2;
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
	    retain Extract_date &filedate;
    
    ** Recode variables **;
    
    label  ;

    /*format 
      &recode_yesno dyesno.
      extract_date mmddyy10.;*/

  run;


    %Finalize_data_set( 
      /** Finalize data set parameters **/
      data=HPTF_&year._&month._dc,
      out=HPTF_&year._&month._dc,
      outlib=DMPED,
      label="&ds_label",
      sortby=project_name,
      /** Metadata parameters **/
      restrictions=None,
      revisions=%str(&revisions),
      /** File info parameters **/
      printobs=5,
      freqvars=
    )

  %exit_macro:
  
  %note_mput( macro=DMPED_pipeline_read_update_file, msg=Exiting macro. )

%mend DMPED_pipeline_read_update_file;

/** End Macro Definition **/
