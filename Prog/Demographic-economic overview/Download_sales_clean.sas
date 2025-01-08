/**************************************************************************
 Program:  Download_sales_clean.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  1/7/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  130
 
 Description:  Download latest sales data for DMPED housing study. 
 
 Based on OCC/Prog/Ch3/Download_sales_clean.sas and OCC/Prog/Ch3/Qtrly_sales_ward.sas

 Modifications:
  07/09/13 LH  Moved from HsngMon Library to RealProp
  07/11/14 Moved from RealProp to OCC
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;

%DCData_lib( OCC )
%DCData_lib( RealProp )

%Init_macro_vars( rpt_yr=2023, rpt_qtr=4, sales_qtr_offset=0, sales_start_dt='01apr1995'd, sales_end_dt='31dec2023'd );

%let data = Sales_res_clean;
%let out  = Sales_clean_&g_rpt_yr._&g_rpt_qtr;

*options obs=100;

data &out (label="Clean property sales for &g_rpt_title DC Quarterly Sales Data" compress=no);

  set RealProp.&data;
  where &g_sales_start_dt <= saledate <= &g_sales_end_dt;
  
  saledate_yr = year( saledate );
  
  %dollar_convert( saleprice, saleprice_adj, saledate_yr, &g_sales_end_yr, series=CUUR0000SA0L2 );
  
  pct_owner_occ_sale = 100 * owner_occ_sale;

  label
    saledate_yr = "Property sale year"
    saleprice_adj = "Property sale price (&g_sales_end_yr $)"
    pct_owner_occ_sale = "Pct. owner-occupied sale";

  keep ssl saleprice saledate ui_proptype ward2022 cluster2017 geo2020 saledate_yr owner_occ_sale
       saleprice_adj pct_owner_occ_sale ;

run;

** End submitting commands to remote server **;

%file_info( data=&out, printobs=20, 
            freqvars=ward2022 cluster2017 ui_proptype saledate_yr owner_occ_sale )

proc freq data=&out;
  tables saledate;
  format saledate yyq.;

proc tabulate data=&out missing noseps;
  var pct_owner_occ_sale;
  class saledate_yr;
  table all='Total' saledate_yr=' ', pct_owner_occ_sale * (n nmiss mean);
run;


** Single-family home price trends by ward **;

data Sales_adj (compress=no);

  set &out;
  
  where 
    ( cluster2017 ~= '' and ward2022 ~= '' ) and
    ( intnx( 'qtr', intnx( 'year', &g_sales_start_dt, 0, 'beginning' ), -3, 'beginning' ) <= saledate <= &g_sales_end_dt ) and
    ui_proptype = '10';
  
run;

proc summary data=Sales_adj nway;
  class ward2022 saledate;
  var saleprice_adj;
  output out=Qtrly_sales_price (drop=_type_ _freq_ compress=no) median=;
  format saledate yyq.;
  
proc print data=Qtrly_sales_price;
  where ward2022 = '1';
run;

data Qtrly_sales_ward (compress=no);

  set Qtrly_sales_price;
  by ward2022;
  
  retain price1 price2 price3;
  
  if first.ward2022 then do;
    price1 = .;
    price2 = .;
    price3 = .;
  end;

  ** 4 quarter moving average **;
  
  mov_avg_price = ( saleprice_adj + price1 + price2 + price3 ) / 4;
  
  put (_all_) (=);
  
  if mov_avg_price ~= . then output;
  
  price3 = price2;
  price2 = price1;
  price1 = saleprice_adj;
  
  drop price1 price2 price3 saleprice_adj;
  
run;  
  
/*
proc print data=Qtrly_sales_ward;
  by ward2022;
  
run;
*/

proc sort data=Qtrly_sales_ward;
  by saledate;

proc transpose data=Qtrly_sales_ward 
    out=Qtrly_sales_ward_tr (drop=_name_ compress=no) 
    prefix=price_wd_;
  var mov_avg_price;
  id ward2022;
  by saledate;
  format ward2022 $1.;
run;

proc print;
run;

data Csv_out (compress=no);

  length year_fmt $ 4;

  set Qtrly_sales_ward_tr;
  
  if qtr( saledate ) = 1 then year_fmt = put( year( saledate ), 4. );
  else year_fmt = "";
  
  label
     price_wd_1 = "Ward 1"
     price_wd_2 = "Ward 2"
     price_wd_3 = "Ward 3"
     price_wd_4 = "Ward 4"
     price_wd_5 = "Ward 5"
     price_wd_6 = "Ward 6"
     price_wd_7 = "Ward 7"
     price_wd_8 = "Ward 8";
  
  drop saledate;
  
run;

filename fexport "&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Qtrly_sales_ward.csv" lrecl=256;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace label;

run;

filename fexport clear;



** Annual single-family home price trends by ward **;

data Sales_adj_yr (compress=no);

  set &out;
  
  where 
    ( cluster2017 ~= '' and ward2022 ~= '' ) and
    ( intnx( 'year', &g_sales_start_dt, 1, 'beginning' ) <= saledate <= &g_sales_end_dt ) and
    ui_proptype = '10';
  
run;

proc summary data=Sales_adj_yr nway;
  class saledate ward2022;
  var saleprice_adj;
  output out=Annual_sales_price (drop=_type_ _freq_ compress=no) median=;
  format saledate year.;
run;

proc transpose data=Annual_sales_price 
    out=Annual_sales_price_tr (drop=_name_ compress=no) 
    prefix=price_wd_;
  var saleprice_adj;
  id ward2022;
  by saledate;
  format ward2022 $1.;
run;

proc print;
run;

data Csv_out (compress=no);

  length year_fmt $ 4;

  set Annual_sales_price_tr;
  
  label
     price_wd_1 = "Ward 1"
     price_wd_2 = "Ward 2"
     price_wd_3 = "Ward 3"
     price_wd_4 = "Ward 4"
     price_wd_5 = "Ward 5"
     price_wd_6 = "Ward 6"
     price_wd_7 = "Ward 7"
     price_wd_8 = "Ward 8";
  
  format saledate year.;
  
run;

filename fexport "&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Annual_sales_ward.csv" lrecl=256;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace label;

run;

filename fexport clear;

