/**************************************************************************
 Program:  Parcel_units_2000_2023.sas
 Library:  DMPED
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/31/24
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  130
 
 Description:  Compile unit counts for real property parcels.
 Based on RealProp\Prog\Num_units_all.sas.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( RealProp )
%DCData_lib( MAR )

%let start_yr = 2003;
%let end_yr = 2023;


/** Parcel_base + Geo = 185744 obs **/
/** Parcel_base + Geo + Xref = 194547 obs **/
/** Parcel_base + Geo + Xref + AddrPts = 194547 obs **/

proc sql noprint;

  create table Parcel_mar as
  
    select BaseGeo.*, XrefUnits.*
    
    from
  
      ( select 
          Base.ssl, Base.ownerpt_extractdat_first, Base.ownerpt_extractdat_last, Base.ui_proptype, Base.no_units, 
          Geo.Ward2022, Geo.Cluster2017, Geo.GeoBlk2020, Geo.Geo2020 
        from RealProp.Parcel_base as Base left join RealProp.Parcel_geo as Geo
        on Base.ssl = Geo.SSL 
        where ui_proptype in ( '10', '11', '12', '13', '19' ) and 
          ( year( ownerpt_extractdat_first ) <= &end_yr and year( ownerpt_extractdat_last ) >= &start_yr )
      ) as BaseGeo

      left join
      
      ( select 
          XrefAddrPts.ssl,
          sum( XrefAddrPts.active_res_occupancy_count ) as active_res_occupancy_count 
        from
          ( select 
              coalesce( Xref.address_id, AddrPts.address_id ) as address_id, 
              Xref.ssl, 
              AddrPts.active_res_occupancy_count 
            from Mar.Address_ssl_xref as Xref left join Mar.Address_points_view as AddrPts 
            on Xref.address_id = AddrPts.address_id
          ) as XrefAddrPts
        group by ssl
      ) as XrefUnits
      
    on BaseGeo.ssl = XrefUnits.ssl
      
    order by BaseGeo.ssl;
    
  quit;


%File_info( data=Parcel_mar, printobs=10 )


proc print data=Parcel_mar (obs=40);
  where ui_proptype = '10';
  by ui_proptype;
  var ssl active_: ;
run;
  
proc print data=Parcel_mar (obs=100);
  where ui_proptype = '11';
  by ui_proptype;
  var ssl active_: ;
run;

proc print data=Parcel_mar (obs=100);
  where ui_proptype = '12';
  by ui_proptype;
  var ssl active_: no_units;
run;
  
proc print data=Parcel_mar (obs=100);
  where ui_proptype = '13';
  by ui_proptype;
  var ssl active_: ;
run;
  
proc print data=Parcel_mar (obs=100);
  where ui_proptype = '19';
  by ui_proptype;
  var ssl active_: ;
run;


ENDSAS;
  
  
** Create count vars **;

data Num_units_raw (compress=no);

  merge 
    RealProp.Parcel_base 
      (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last ui_proptype no_units
       where=(ui_proptype in ( '10', '11', '12', '13', '19' ))
       in=in1)
    RealProp.Parcel_geo
      (drop=x_coord y_coord);
  by ssl;
  
  if in1;
  
  if ui_proptype = '10' then units_sf = 1;
  else if ui_proptype = '11' then units_condo = 1;
  
  units_coop = no_units;
  
  units_sf_condo = sum( units_sf, units_condo, 0 );
  units_owner = sum( units_sf, units_condo, units_coop, 0 );
  
  ** Output individual obs. for each year **;
  
  do year = &start_yr to &end_yr;
  
    if year( ownerpt_extractdat_first ) <= max( year, 2001 ) <= year( ownerpt_extractdat_last ) 
      then output;
  
  end;

  label
    units_sf = 'Number of single-family homes'
    units_condo = 'Number of condominium units'
    units_coop = 'Number of cooperative units'
    units_sf_condo = 'Number of single-family homes and condominium units'
    units_owner = 'Number of ownership units (s.f./condo/coop)';
  
run;



run;
