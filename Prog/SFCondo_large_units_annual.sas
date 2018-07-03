
/**************************************************************************
 Program:  SFCondo_large_units_annual.sas
 Library:  DMPED
 Project:  DMPED large units
 Author:   L. Hendey
 Created:  7/3/18
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description: Creates quarterly and annual parcel level files. 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Realprop )
%DCData_lib( DMPED )

%let revisions=New file.;
%let label="DC Sales SF/Condo parcels with CAMA (2018_05) and property owner types";


data getnext0; 
	set dmped_r.Sales_who_owns_SF_Condo;
rename saledate=saledate_orig; 

run;

proc sql;
       create table Work.getnext1 as
       select getnext0.*, sales.ssl, sales.saledate
	 from getnext0 left join realpr_r.sales_master 
       		as sales on (getnext0.ssl = sales.ssl)
      	
	 having saledate gt saledate_orig; 
     quit;
  run;

**sorting to removing additional sales if more than one after foreclosure;
proc sort data=getnext1 nodupkey out=getnext2;
by ssl sale_num;
run;
data getnext3;
set getnext2;

rename saledate=next_saledate;

run;
proc sort data=getnext0;
by ssl sale_num;
proc sort data=getnext3;
by ssl sale_num;
data getnext4;
merge getnext0 (in=a rename=(saledate_orig=saledate)) getnext3 (keep=ssl sale_num next_saledate);
if a;
by ssl sale_num;
run;


%macro create_annual( out_ds=, unit=, rpt_start_dt='01jan2000'd, rpt_end_dt=, label= , revisions= );

  data &out_ds;

    set getnext4 (drop=BldgAgeGT2000);
  
	if not( missing( saledate ) ) then start_dt = saledate; 
	else if saledate in (.n .u) then start_date=ownerpt_extractdat_first;
	
    if not( missing( next_saledate ) ) then end_dt = next_saledate;
	else end_dt = ownerpt_extractdat_last;

	if missing( start_dt ) then delete;
    
    ** Align start and end dates with beginning of quarter **;
    
 	adj_start_dt = intnx( "&unit", start_dt, 1, 'beginning' );
    adj_end_dt = intnx( "&unit", end_dt, 0, 'beginning' );

    ** Create obs. for each ssl/episode/yr with outcome vars. **;
    
    length 
       renter BldgAgeGT2000 senior corporations cdcNFP otherind govtown 3;
    
    report_dt = intnx( "&unit", max( adj_start_dt, &rpt_start_dt ), 0, 'beginning' );
    
   	 do while ( report_dt <= min( adj_end_dt, &rpt_end_dt ) );
    
      report_dt_end = intnx( "&unit", report_dt, 0, 'end' );

	  /*if owner_occ_sale = 0 and ( start_dt < report_dt and end_dt >= report_dt ) then renter = 1;
      else if owner_occ_sale=1 then renter= 0;*/

	  if owner_occ_sale = 0 then renter = 1;
      else if owner_occ_sale=1 then renter= 0;
	  
	  
      if AYB >= 2000 then BldgAgeGT2000 = 1;
      else if AYB ne . then BldgAgeGT2000 = 0;
	
	  if hstd_code in ("5" "B") then senior = 1;
      else if hstd_code in("0" "1" "2" "3") then senior= 0;

	  *Taxable corporations, partnerships, associations, banks, GSEs;
	  if ownercat in ("115" "120" "130") then corporations = 1;
      else if ownercat in ("010" "020" "030" "040" "050" "060" "070" "080" "090" "100" "111") then corporations= 0;

	  *churches, CDCs, nonprofits; 
	  if ownercat in ("100" "080" "111") and then cdcNFP = 1;
	  else if ownercat in ("010" "020" "030" "040" "050" "060" "070" "090" "115" "120" "130")  then cdcNFP= 0;

	  *other individuals; 
	  if ownercat in ("030") and then otherind = 1;
      else if ownercat in ("010" "020"  "040" "050" "060" "070" "090" "115" "120" "130" "100" "080" "111")  then otherind= 0;

	  *local or federal govt or quasi public;
		if ownercat in ("040" "050" "070") then govtown = 1;
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
      ssl largeunit saledate saleyear next_saledate  ownerpt_extractdat_first ownerpt_extractdat_last city ward2012 zip geo2010 cluster2017 cluster_tr2000 x_coord y_coord usecode 
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

