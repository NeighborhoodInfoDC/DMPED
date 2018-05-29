/**************************************************************************
 Program:  Parcel_profile_review.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/24/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Review parcel profile data.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( RealProp )

%File_info( data=dmped.parcel_profile, freqvars=ui_proptype Owner_occ_sale )

run;

proc tabulate data=dmped.parcel_profile format=comma8.0 noseps missing;
  class ui_proptype;
  class Owner_occ_sale;
  var adj_unit_count;
  table 
    /** Rows **/
    all='Total' ui_proptype,
    /** Columns **/
    n='Parcels' * (all='Total' Owner_occ_sale)
    /rts=40
  ;
  table 
    /** Rows **/
    all='Total' ui_proptype,
    /** Columns **/
    sum=' ' *adj_unit_count='Units (adj_unit_count)' * (all='Total' Owner_occ_sale)
    /rts=40
  ;
  format ui_proptype $uiprtyp. owner_occ_sale yesno.;
run;

