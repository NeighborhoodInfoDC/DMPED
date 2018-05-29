/**************************************************************************
 Program:  Merge_iz_data.sas
 Library:  DMPED.IZ
 Project:  DM. Woluchem
 Created:  05/02/14
 Version:  SAS 9.1
 Environment:  Local Windows session (desktop)

 Description:  Merge geocoded IZ data to attach standard geographies.
 Modifications:

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";
%DCData_lib( DMPED)

%let keep = projID project address status cizcdate zone contype tenure type units market izunits ami50 ami80;
%let map_prefix = CIZC_join_;
%let xfer_files = ;

/** Macro Xfer - Start Definition **/

%macro Xfer ( inds=, var=, keep= projID project address status cizcdate zone contype tenure type units market izunits ami50 ami80);

  %let xfer_files = &xfer_files &inds;

  data &inds;

    set DMPED.&map_prefix.&inds;

    %Octo_&var( )

    format _all_;
    informat _all_;

    keep projid &var &keep;

  run;

  proc sort data=&inds;
  by projid;
  run;

%mend Xfer;

/** End Macro Definition **/


** Creating standard variables for **;

%Xfer( inds=block, var=GeoBlk2000, keep=CJRTRACTBL x_coord y_coord )
%Xfer( inds=block10, var=GeoBlk2010 )

%Xfer( inds=ward02, var=ward2002 )
%Xfer( inds=ward12, var=ward2012 )

%Xfer( inds=polsaply, var=psa2004 )
%Xfer( inds=polsaply12, var=psa2012 )

%Xfer( inds=anc02, var=anc2002 )
%Xfer( inds=anc12, var=anc2012 )

%Xfer( inds=zipcodeply, var=zip )

%Xfer( inds=nbhclus, var=cluster2000 )

** Merge files together, create remaining geographic IDs **;

data DMPED.CIZCcomplete;

  length CJRTRACTBL $ 12;

  merge &xfer_files;
  by projid;

  ** Census tract 2000 **;

  length Geo2000 $ 11;

  Geo2000 = GeoBlk2000;

  label
  Geo2000 = "Full census tract ID (2000): ssccctttttt"; 

  ** Census tract 2010 **;

  length Geo2010 $ 11;

  Geo2010 = GeoBlk2010;

  label
  Geo2010 = "Full census tract ID (2010): ssccctttttt";

  ** Tract-based neighborhood clusters **;

  %Block00_to_cluster_tr00()

  ** East of the river **;

  %Tr00_to_eor()

  ** City **;

  length City $ 1;

  city = "1";

  label city = "Washington, D.C.";

  format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. 
         ward2002 $ward02a. zip $zipa. cluster2000 $clus00a. 
         city $city.;

  label
    CJRTRACTBL = "OCTO tract/block ID"
    Ssl = "Property Identification Number (Square/Suffix/Lot)"
  ;

run;
