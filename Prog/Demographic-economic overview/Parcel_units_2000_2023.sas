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

%let start_yr = 2010;
%let end_yr = 2023;


** Merge Parcal and MAR unit count data **;

proc sql noprint;

  create table Parcel_mar as
  
    select BaseGeo.*, XrefUnits.*
    
    from
  
      /** Parcels with geography **/
      ( select 
          Base.ssl, Base.ownerpt_extractdat_first, Base.ownerpt_extractdat_last, Base.ui_proptype, Base.no_units, 
          Base.usecode, Base.proptype, Base.premiseadd,
          Geo.Ward2022, Geo.Cluster2017, Geo.GeoBlk2020, Geo.Geo2020 
        from RealProp.Parcel_base as Base left join RealProp.Parcel_geo as Geo
        on Base.ssl = Geo.SSL 
        where ui_proptype in ( '10', '11', '12', '13', '19' ) and 
          ( year( ownerpt_extractdat_first ) <= &end_yr and year( ownerpt_extractdat_last ) >= &start_yr )
      ) as BaseGeo

      left join
      
      /** MAR unit counts by SSL **/
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


** Check matched records by property type **;

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
  var ssl active_: proptype usecode premiseadd;
run;

proc freq data=Parcel_mar;
  where ui_proptype = '19';
  tables proptype usecode;
run;

proc means data=Parcel_mar;
  where ui_proptype = '19';
  var active_res_occupancy_count;
run;

  
** Create count vars **;

data Units_parcel_year;

  set Parcel_mar;
  
  retain parcels 1;
  
  units_sf = 0;
  units_condo = 0;
  units_coop = 0;
  units_rental = 0;
  
  select ( ui_proptype );
  
    when ( '10' ) units_sf = 1;

    when ( '11' ) units_condo = 1;
    
    when ( '12' ) do;
      if active_res_occupancy_count > 0 then units_coop = active_res_occupancy_count;
      else units_coop = no_units;
    end;
    
    when ( '13', '19' ) units_rental = active_res_occupancy_count;
    
  end;
  
  units_total = sum( units_sf, units_condo, units_coop, units_rental );
  
  ** Property type including smaller and larger multifamily **;
  
  length new_proptype $ 3;
  
  if ui_proptype in ( '13', '19' ) then do;
    if units_total < 5 then new_proptype = '131';
    else new_proptype = '132';
  end;
  else new_proptype = ui_proptype;
    
  ** Output individual obs. for each year **;
  
  do year = &start_yr to &end_yr;
  
    if year( ownerpt_extractdat_first ) <= max( year, 2001 ) <= year( ownerpt_extractdat_last ) 
      then output;
  
  end;

  label
    year = 'Year'
    units_sf = 'Single-family houses'
    units_condo = 'Condominium units'
    units_coop = 'Cooperative units'
    units_rental = 'Multifamily rental units'
    units_total = 'Total residential units'
    parcels = 'Parcels';
  
run;


%File_info( data=Units_parcel_year, printobs=5 )


** Tables **;

proc format;
  value $ui_proptype (notsorted)
    '10' = 'Single family'
    '11' = 'Condominium'
    '12' = 'Cooperative'
    '13' = 'Multifamily rental'
    '19' = 'Other residential';
  value $new_proptype (notsorted)
    '10' = 'Single family'
    '11' = 'Condominium'
    '12' = 'Cooperative'
    '131' = '2-4 units rental'
    '132' = '5+ units rental';
run;    

%fdate()

options orientation=landscape;
options nodate nonumber;
options missing='0';

ods rtf file="&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Parcel_units_2000_2023.rtf" style=Styles.Rtf_arial_9pt;
ods listing close;

footnote1 height=9pt "Prepared by Urban-Greater DC (greaterdc.urban.org), &fdate..";
footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

ods csvall body="&_dcdata_default_path\DMPED\Prog\Demographic-economic overview\Parcel_units_2000_2023_total.csv";

title2 ' ';
title3 'Residential Units by Property Type and Year, DC';

proc tabulate data=Units_parcel_year format=comma8.0 noseps missing;
  class Year;
  class new_proptype /order=data preloadfmt;
  var parcels units_total;
  table 
    /** Rows **/
    all='Total' new_proptype=' ',
    /** Columns **/
    units_total='Residential units' * year=' ' * sum=' '
  ;
  format new_proptype $new_proptype.;
run;

ods csvall close;

title3 'Residential Units by Property Type, Ward, and Year, DC';

proc tabulate data=Units_parcel_year format=comma8.0 noseps missing;
  where not( missing( Ward2022 ) );
  class Year Ward2022;
  class new_proptype /order=data preloadfmt;
  var parcels units_total;
  table 
    /** Pages **/
    all='Total residential' new_proptype=' ',
    /** Rows **/
    all='Total' Ward2022=' ',
    /** Columns **/
    units_total='Residential units' * year=' ' * sum=' '
  ;
  format new_proptype $new_proptype.;
run;

title3 'Residential Units by Property Type, Neighborhood Cluster, and Year, DC';

proc tabulate data=Units_parcel_year format=comma8.0 noseps missing;
  where not( missing( Cluster2017 ) );
  class Year Cluster2017;
  class new_proptype /order=data preloadfmt;
  var parcels units_total;
  table 
    /** Pages **/
    all='Total residential' new_proptype=' ',
    /** Rows **/
    all='Total' Cluster2017=' ',
    /** Columns **/
    units_total='Residential units' * year=' ' * sum=' '
  ;
  format new_proptype $new_proptype.;
run;

title2;
footnote1;

ods rtf close;
ods listing;


