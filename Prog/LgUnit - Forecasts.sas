/**************************************************************************
 Program:  LgUnit - Forecasts.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  08/31/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)

 Description:  Summarize OP population and household forecasts by ward.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( Planning )

ods csvall body="&_dcdata_default_path\DMPED\Prog\LgUnit - Forecasts.csv";

proc tabulate data=Planning.Pop_forecast_r9_dc_wd12 format=comma9.0 noseps missing;
  class Ward2012;
  var hh: ;
  table
    /** Rows **/
    hh2015 hh2020 hh2025 hh2030 hh2035 hh2040 hh2045,
    /** Columns **/
    sum='Households' * ( all='City' Ward2012=' ' )
  ;
  table
    /** Rows **/
    hhpop2015 hhpop2020 hhpop2025 hhpop2030 hhpop2035 hhpop2040 hhpop2045,
    /** Columns **/
    sum='Persons in Households' * ( all='City' Ward2012=' ' )
  ;
  label
    hh2015 = '2015'
    hh2020 = '2020'
    hh2025 = '2025'
    hh2030 = '2030'
    hh2035 = '2035'
    hh2040 = '2040'
    hh2045 = '2045'
    hhpop2015 = '2015'
    hhpop2020 = '2020'
    hhpop2025 = '2025'
    hhpop2030 = '2030'
    hhpop2035 = '2035'
    hhpop2040 = '2040'
    hhpop2045 = '2045';
run;

ods csvall close;
