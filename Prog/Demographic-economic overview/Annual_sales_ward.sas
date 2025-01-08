/**************************************************************************
 Program:  Annual_sales_ward.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  01/07/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  130
 
 Description:  Download data for annual sales by ward chart.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( RealProp )

/** Macro Annual_sales - Start Definition **/

%macro Annual_sales( start_yr=, end_yr=, type=, geo=, geosuffix= );

  data Annual_sales_&type._&geosuffix;
  
    set Realprop.Sales_sum_&geosuffix (keep=&geo mprice_&type._&start_yr-mprice_&type._&end_yr);
    
    %do i = &start_yr %to &end_yr;
    
      %dollar_convert( mprice_&type._&i, r_mprice_&type._&i, &i, &end_yr, series=CUUR0000SA0L2 );
      
      label r_mprice_&type._&i = "&i";
      
    %end;
    
    format r_mprice_&type._&start_yr-r_mprice_&type._&end_yr 12.0;
    
    drop mprice_&type._&start_yr-mprice_&type._&end_yr;
    
  run;
  
  filename fexport "&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Annual_sales_&type._&geosuffix..csv" lrecl=1000;

  proc export data=Annual_sales_&type._&geosuffix
      outfile=fexport
      dbms=csv replace label;

  run;

  filename fexport clear;

%mend Annual_sales;

/** End Macro Definition **/


%Annual_sales( start_yr=1995, end_yr=2023, type=sf, geo=ward2022, geosuffix=wd22 )

%Annual_sales( start_yr=1995, end_yr=2023, type=condo, geo=ward2022, geosuffix=wd22 )

