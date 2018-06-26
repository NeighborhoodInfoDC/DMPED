/**************************************************************************
 Program:  SFCondo_large_units.sas
 Library:  DMPED
 Project:  DMPED large units
 Author:   Yipeng Su
 Created:  6/21/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Creates analysis file for SF Homes and Parcels

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Realprop )
%DCData_lib( DMPED )

%let revisions=New file.;
%let label="DC Sales SF/Condo parcels with CAMA (2018_05) and property owner types";

data merged;
    
	merge realpr_r.sales_master (in=a) realprop.cama_parcel (in=b drop=SALEDATE usecode sale_num landarea); 
	by ssl;

	length source $5.;
	if a and b then source ="both";
	else if a then source="sales";
	else if b then source="cama";
	

run;

data SF_Condo;
     set merged;
	 where ui_proptype="10" or ui_proptype="11";
run;

	*added check that sales not matching to cama file are not recent sales or not in sales master (those could be new?); 
	proc freq data=SF_condo;
	where source="sales"; 
	tables ownerpt_extractdat_last;
	run;

%macro SF_Condo_who_owns( RegExpFile=Owner type codes reg expr.txt);
  %local MaxExp Outlib parcel_base_file_dtmf dtm dtmf;
   %let MaxExp     = 480000;  /** NOTE: This number should be larger than the number of rows in the above spreadsheet **/

  
  ** Read in regular expressions **;

  filename xlsfile "&_dcdata_default_path\RealProp\Prog\Updates\&RegExpFile" lrecl=2500;

  data RegExp (compress=no);
    length OwnerCat_re $ 3 RegExp $ 2000;
    infile xlsfile missover dsd firstobs=2;
    input OwnerCat_re RegExp;
    OwnerCat_re = put( 1 * OwnerCat_re, z3. );
    if RegExp = '' then stop;
    put OwnerCat_re= RegExp=;
  run;

  ** Add owner-occupied sale flag to Parcel records **;

 ** %create_own_occ( inlib=realprop, inds=parcel_base, outds=parcel_base_ownocc );

  ** Match regular expressions against owner data file **;

  data Sales_who_owns_SF_Condo (label="DC real property parcels - property owner types");

     set SF_Condo;
              
     %ownername_full()

     length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
     retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
     array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
     array a_re{*}     re1-re&MaxExp;

     ** Load & parse regular expressions **;
    if _n_ = 1 then do;
      i = 1;
     do until ( eof );
        set RegExp end=eof;
        a_OwnerCat{i} = OwnerCat_re;
        a_re{i} = prxparse( regexp );
        if missing( a_re{i} ) then do;
          putlog "Error" regexp=;
          stop;
        end;
        i = i + 1;
      end;

       num_rexp = i - 1;
       
    end;

    i = 1;
    match = 0;

   do while ( i <= num_rexp and not match );
      if prxmatch( a_re{i}, upcase( ownername_full ) ) then do;
        OwnerCat = a_OwnerCat{i};
        match = 1;
      end;

      i = i + 1;

    end;
    
    ** Assign codes for special cases **;
    
      if ownername_full ~= '' then do;
    
        ** Owner-occupied Single Family, Condo, and multifamily rental **;
    
        if ui_proptype='10' and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '010';
    
         if ui_proptype in ( '11', '13' ) and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '020';
    
        ** Cooperatives are owner-occupied (OwnerCat=20), unless special owner **;
        ** NOTE: PROBABLY NEED TO CHANGE THIS, MAYBE CREATE A SEPARATE OWNER CATEGORY FOR COOPS **;
    
        else if ui_proptype = '12' and OwnerCat in ( '', '030', '110' ) then do;
          OwnerCat = '020';
        end;
    
        else if OwnerCat in ( '', '030' ) then do;
          OwnerCat = '030';
        end;
    
    end;

    ** Separate corporate (110) into for profit & nonprofit by tax status **;
    
    if OwnerCat = '110' then do;
      if mix1txtype = 'TX' then OwnerCat = '115';
      else OwnerCat = '111';
    end;
    
    ownername_full = propcase( ownername_full );
    
    drop i match num_rexp regexp OwnerCat_re OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;
    
    label OwnerCat = 'Property owner type';
    
    format OwnerCat $owncat.;
    
    *keep ssl premiseadd premiseadd_std premiseadd_m hstd_code OwnerCat AYB SALEDATE
         Ownername_full owneraddress owneraddress_std owneraddress_m address3 
         ui_proptype in_last_ownerpt Owner_occ_sale mix1txtype mix2txtype;

  run;


/**** Diagnostics ****;

  proc sort data=Parcel_base_who_owns_SF_Condo (where=(Ownercat not in ( '010', '020', '030' )))
    out=Parcel_base_who_owns_SF_Condo_diagnostic;
    by OwnerCat;
  run;

  ods listing close;
  ods tagsets.excelxp file="&_dcdata_default_path\RealProp\Prog\Updates\Parcel_base_who_owns_SF_Condo_diagnostic.xls" style=Minimal options(sheet_interval='Bygroup' );

  proc freq data=Parcel_base_who_owns_SF_Condo_diagnostic;
    by OwnerCat;
    tables Ownername_full / missing;
  run;

  ods tagsets.excelxp close;
  ods listing;*/
  
  
 *create variables needed for analysis;

 data Sales_who_owns_SF_Condo1;
  set Sales_who_owns_SF_Condo (where=cama in ("ResPt" "CondoP")); *dropping observations that appear in COMM PT cama file (no bedroom info). 

  BldgAgeGT2000=.;
  if AYB >= 2000 then BldgAgeGT2000=1;
  else if AYB ~=. then BldgAgeGT2000=0; 

  LargeUnit=.;
  if BEDRM >= 3 then LargeUnit=1;
  else if Bedrm ~=. then LargeUnit=0; 

  
  saleyear = year(SALEDATE);   

  label BldgAgeGT2000="Primary Building on Parcel was Built in 2000 or later"
  	    LargeUnit="Primary Building on Parcel has 3 or more bedrooms"
		Saleyear="Year of Sale";


 run;

  **** Finalize data set ****;

  %Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Sales_who_owns_SF_Condo1,
  out=Sales_who_owns_SF_Condo,
  outlib=DMPED,
  label=&label.,
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5,
  freqvars=OwnerCat Owner_occ_sale largeunit
  );

%mend SF_Condo_who_owns;

%SF_Condo_who_owns; 

/** Macro create annual file - Start Definition **/

%macro create_annual( out_ds=, unit=, rpt_start_dt='01jan2000'd, rpt_end_dt=, label= , revisions= );

  data &out_ds;

    set Sales_who_owns_SF_Condo1 (drop=BldgAgeGT2000);
  
	if not( missing( saledate ) ) then start_dt = saledate; 
	else if saledate in (.n .u) then start_date=ownerpt_extractdat_first;
	
    if not( missing( ownerpt_extractdat_last) ) then end_dt = ownerpt_extractdat_last;
	else end_dt = &rpt_end_dt;

	if missing( start_dt ) then delete;
    
    ** Align start and end dates with beginning of quarter **;
    
 	adj_start_dt = intnx( "&unit", start_dt, 0, 'beginning' );
    adj_end_dt = intnx( "&unit", end_dt, 0, 'beginning' );

    ** Create obs. for each ssl/episode/yr with outcome vars. **;
    
    length 
       renter BldgAgeGT2000 senior corporations cdcNFP otherind govtown 3;
    
    report_dt = intnx( "&unit", max( adj_start_dt, &rpt_start_dt ), 0, 'beginning' );
    
   	 do while ( report_dt <= min( adj_end_dt, &rpt_end_dt ) );
    
      report_dt_end = intnx( "&unit", report_dt, 0, 'end' );

	  if owner_occ_sale = 0 and ( start_dt < report_dt and end_dt >= report_dt ) then renter = 1;
      else if owner_occ_sale=1 then renter= 0;
	  
      if AYB >= 2000 and ( start_dt < report_dt_end and end_dt >= report_dt_end ) then BldgAgeGT2000 = 1;
      else if AYB ne . then BldgAgeGT2000 = 0;
	
	  if hstd_code in ("5" "B") and (start_dt < report_dt_end and end_dt >= report_dt_end) then senior = 1;
      else if hstd_code in("0" "1" "2" "3") then senior= 0;

	  *Taxable corporations, partnerships, associations, banks, GSEs;
	  if ownercat in ("115" "120" "130") and ( start_dt < report_dt_end and end_dt >= report_dt_end ) then corporations = 1;
      else if ownercat in ("010" "020" "030" "040" "050" "060" "070" "080" "090" "100" "111") then corporations= 0;

	  *churches, CDCs, nonprofits; 
	  if ownercat in ("100" "080" "111") and ( start_dt < report_dt_end and end_dt >= report_dt_end) then cdcNFP = 1;
	  else if ownercat in ("010" "020" "030" "040" "050" "060" "070" "090" "115" "120" "130")  then cdcNFP= 0;

	  *other individuals; 
	  if ownercat in ("030") and ( start_dt < report_dt_end and end_dt >= report_dt_end ) then otherind = 1;
      else if ownercat in ("010" "020"  "040" "050" "060" "070" "090" "115" "120" "130" "100" "080" "111")  then otherind= 0;

	  *local or federal govt or quasi public;
		if ownercat in ("040" "050" "070") and ( start_dt < report_dt_end and end_dt >= report_dt_end ) then govtown = 1;
       else if ownercat in ("010" "020" "030" "060"  "090" "115" "120" "130" "100" "080" "111") then govtown= 0;

     
 	  output;
	  report_dt = intnx( "&unit", report_dt, 1, 'beginning' );

  	end;
    
    format report_dt start_dt end_dt adj_start_dt adj_end_dt  mmddyy10.;
    
    label 
      report_dt = 'Report reference date'
      start_dt = 'Episode start date'
      end_dt = 'Episode end date'
	  renter="Renter-occupied, beginning of the period"
	  BldgAgeGT2000 ="Primary building on parcel built 2000 or later"
	  senior="Owner has the senior or disabled homestead exemption, beginning of the period"
	  corporations="Owner is a taxable corporation, association (including banks and GSEs), beginning of the period" 
	  cdcNFP="Owner is a church, CDC or nonprofit, beginning of the period"
	  otherind="Owner is an individual (not owner-occupied), beginning of the period" 
	  govtown="Owner is DC or US government or quasi-public entity, beginning of the period"
	  adj_start_dt="Beginning of the period"
	  adj_end_dt = "End of the period"
    ;
    
    keep 
      ssl largeunit saledate saleyear  city ward2012 zip geo2010 cluster2017 cluster_tr2000 x_coord y_coord usecode 
      report_dt start_dt end_dt adj_start_dt adj_end_dt renter BldgAgeGT2000 AYB hstd_code Owner_occ_sale ownercat senior corporations cdcNFP otherind govtown
	 ;
    
  run;

  **** Finalize data set ****;

  %Finalize_data_set( 
  /** Finalize data set parameters **/
  data=&out_ds,
  out=&out_ds.,
  outlib=DMPED,
  label=&label.,
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5,
  freqvars=largeunit senior corporations cdcNFP otherind govtown Owner_occ_sale renter BldgAgeGT2000
  );

 

%mend create_annual;

%create_annual( out_ds=SFCondo_qtr_2017, unit=qtr, rpt_end_dt='31mar2018'd, label="Quarterly SF-Condo Parcels for Large Units Study", revisions=New file.)

%create_annual( out_ds=SFCondo_year_2017, unit=year, rpt_end_dt='31mar2018'd, label="Annual SF-Condo Parcels for Large Units Study", revisions=New file. )

options symbolgen;
