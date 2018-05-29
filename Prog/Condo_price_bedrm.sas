/**************************************************************************
 Program:  Condo_price_bedrm.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description: Calculate annual condo prices by unit bedroom size.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( RealProp )

proc sql noprint;
  create table Sales_cama as
  select *, saleprice/CAMA.landarea as price_sqft from 
    RealProp.CAMACondoPt (keep=ssl bedrm landarea) as CAMA, 
    RealProp.Sales_res_clean (keep=ssl saleprice saledate ui_proptype where=(ui_proptype='11')) as Sales
  where CAMA.SSL = Sales.SSL
;

proc tabulate data=Sales_cama format=comma10.0 noseps missing;
  where bedrm in ( '0', '1', '2', '3' );
  class bedrm saledate;
  var saleprice;
  table 
    /** Pages **/
    mean='Average sales price ($)' * saleprice=' '
    median='Median sales price ($)' * saleprice=' '
    n='Number of sales' * saleprice=' ',
    /** Rows **/
    saledate='Year',
    /** Columns **/
    bedrm='Bedroom size'
  ;
  format saledate year4.;
run;

