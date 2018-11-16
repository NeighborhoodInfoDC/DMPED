/**************************************************************************
 Program:  SFCondo_large_units - parcelbase.sas
 Library:  DMPED
 Project:  DMPED large units
 Author:   Yipeng Su
 Created:  6/21/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Creates base file for SF Homes and Condos by merging sales, cama and who owns code.

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Realprop )
%DCData_lib( DMPED )

%let revisions=New file.;
%let label="DC Sales SF/Condo parcels with CAMA (2018_05) and property owner types (with Parcel base)";

data merged;
    
	merge realpr_r.sales_master (in=a drop= ui_proptype ownerpt_extractdat_first ownerpt_extractdat_last) realprop.cama_parcel (in=b drop=SALEDATE usecode sale_num landarea) 
		   realpr_r.parcel_base (in=c keep= ui_proptype ssl ownerpt_extractdat_first ownerpt_extractdat_last); 
	by ssl;

	length source $15.;
	if a and b and c then source ="all";
	else if a and c then source="sales & base";
	else if a and b then source="sales & cama";
	else if a then source="sales";
	else if b and c then source="cama & base";
	else if c then source="base";
	

run;

data SF_Condo;
     set merged;
	 where ui_proptype="10" or ui_proptype="11";
run;
proc freq data=sf_condo;
tables source;
run; 
proc print data=sf_condo (obs=20);
where source="sales";
run;
	*added check that sales not matching to cama file are not recent sales or not in sales master (those could be new?); 
	proc freq data=SF_condo;
	where source="sales & base"; 
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


**** Diagnostics ****;

  proc sort data=Sales_who_owns_SF_Condo (where=(Ownercat not in ( '010', '020', '030' )))
    out=Sales_diagnostic;
    by OwnerCat;
  run;

  ods listing close;
  ods tagsets.excelxp file="&_dcdata_default_path\DMPED\Prog\Sales_diagnostic.xls" style=Minimal options(sheet_interval='Bygroup' );

  proc freq data=Sales_diagnostic;
    by OwnerCat;
    tables Ownername_full / missing;
  run;

  ods tagsets.excelxp close;
  ods listing;*/
  
  
 *create variables needed for analysis;

 data Sales_who_owns_SF_Condo1;
  set Sales_who_owns_SF_Condo (where=(cama in ("ResPt" "CondoP"))); *dropping observations that appear in COMM PT cama file (no bedroom info). ;

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
  out=Sales_who_owns_SF_Condo_withbase,
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
