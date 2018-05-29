/**************************************************************************
 Program:  Population_density.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   M. Woluchem
 Created:  10/28/14
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Edits PT's Download_data.sas pgm from the NCDB library to 
 define population density by ward and nghbd cluster. 

 Modifications:
  11/02/14 PAT Added updated 2008-12 population from ACS (totpop_2008_12)
               and calculated population density (PersonsPerSqMi_2008_12).
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( NCDB )
%DCData_lib( Census )
%DCData_lib( ACS )
%DCData_lib( DMPED )

/** Macro Download_dat - Start Definition **/

%macro Download_dat( geo, geovar );

  %let geo=&geo;
  %let geovar=&geovar;

  %local keep_vars;

  %let keep_vars = totpop_: popwithrace_: popblacknonhispbridge_: 
                   popwhitenonhispbridge_: pophisp_: popasianpinonhispbridge_: 
                   popotherracenonhispbridge_: popunder18years_: 
                   NumOwnerHsgUnits_: NumRenterHsgUnits_: NumRenterOccupiedHsgUnits_: NumOwnerOccupiedHsgUnits_:
                   numoccupiedhsgunits_: PeopleInHshlds_: ;


  
  /*%syslput geo=&geo;
  *%syslput geovar=&geovar;
  *%syslput keep_vars=&keep_vars;

  ** Start submitting commands to remote server **;

  *rsubmit;*/
  
  ** Get population counts by age for 2000 **;
  
  data PopAge_2010_blk;
  
    set Census.Census_sf1_2010_dc_blks (keep=geoblk2010 p12i:);
    
    %if %upcase(&geo)=WD12 %then %do;
      %Block10_to_ward12()
    %end;
    %else %if %upcase(&geo)=CLTR00 %then %do;
      %Block10_to_cluster_tr00()
    %end;
    %else %if %upcase(&geo)=CITY %then %do;
      %Block10_to_city()
    %end;
    
    PopAge_0_17_2000 = sum( of p12i3-p12i6, of p12i27-p12i30 );
    PopAge_18_34_2000 = sum( of p12i7-p12i12, of p12i31-p12i36 );
    PopAge_35_64_2000 = sum( of p12i13-p12i19, of p12i37-p12i43 );
    PopAge_65_2000 = sum( of p12i20-p12i25, of p12i44-p12i49 );

  run;
  
  proc summary data=PopAge_2010_blk nway;
    class &geovar;
    var PopAge_: ;
    output out=PopAge_2010_&geo sum=;
  run;

  ** Get land area for wards and clusters **;
  
  proc sql noprint;
  create table Arealand_blk_a as
  select * from 
    Ncdb.Ncdb_2010_dc_blk (keep=geoblk2010 &geovar arealand) as Ncdb
    left join
    Census.Census_sf1_2010_dc_blks (keep=geoblk2010 h4i: h5i: p12i: p16i1) as Census
    on Ncdb.geoblk2010 = Census.geoblk2010
    order by Ncdb.geoblk2010; 
  run;

  data Arealand_blk;
   
    set Arealand_blk_a;
    
    if not( missing( &geovar ) );
    
    arealand_sqmi = arealand / 2589988.11;
    
    label arealand_sqmi = "Land area (square miles)";
    
    PopAge_0_17_2010 = sum( of p12i3-p12i6, of p12i27-p12i30 );
    PopAge_18_34_2010 = sum( of p12i7-p12i12, of p12i31-p12i36 );
    PopAge_35_64_2010 = sum( of p12i13-p12i19, of p12i37-p12i43 );
    PopAge_65_2010 = sum( of p12i20-p12i25, of p12i44-p12i49 );
    
		VACRT1= H5i2;
		VACFS1= H5i4;
		VACRS1 = H5i3+H5i5;
		VACOCC1 = H5i6;  
		VACMW1 = H5i7;
		VACOTX1 = H5i8;
		VACOTH1 = H5i8 + H5i7 + H5i3 + H5i5;
		RNTOCC1 = H4i4;
		OWNOCC1 = H4i2 + H4i3; 
		OWNMRT1 = H4i2;
		OWNFRC1 = H4i3;

		label
			VACRT1 = 'Vacant housing units for rent' 
			VACFS1 = 'Vacant housing units for sale only'
			VACRS1 = 'Vacant housing units rented or sold, not occupied'
			VACOCC1 = 'Vacant housing units for seasonal, recreational or occasional use'
			VACMW1 = 'Vacant housing for migrant workers'
			VACOTX1 = 'Vacant housing units, other vacant'
			VACOTH1 = 'Vacant housing units, other vacant (1990 def.)'
			RNTOCC1 = 'Total renter-occupied housing units'
			OWNOCC1 = 'Total owner-occupied housing units'
			OWNMRT1 =  'Owned with a mortgage or a loan'
			OWNFRC1 = 'Owned free and clear';
    
    PRSOCU1 = p16i1;
    
    label PRSOCU1 = 'Persons in households';
    
    NumOwnerHsgUnits_2010 = sum(OWNOCC1,VACFS1);
    NumRenterHsgUnits_2010 = sum(RNTOCC1,VACRT1);

    rename 
      VACRT1=NumVacantHsgUnitsForRent_2010
      VACFS1=NumVacantHsgUnitsForSale_2010
      RNTOCC1=NumRenterOccupiedHsgUnits_2010
      OWNOCC1=NumOwnerOccupiedHsgUnits_2010
      PRSOCU1=PeopleInHshlds_2010
    ;
    
    drop arealand h4i: h5i: p12i: p16i1;
    
  run;
  
  /**%File_info( data=AREALAND_BLK )**/
  
  proc summary data=Arealand_blk nway;
    class &geovar;
    var arealand_sqmi Num: People: PopAge: ;
    output out=Arealand_&geo sum=;
  run;
  
  /**%File_info( data=Arealand_&geo )**/

  data C100_&geo;

    merge
      Arealand_&geo
      Ncdb.Ncdb_sum_&geo
        (keep=&geovar &keep_vars)
      Ncdb.Ncdb_sum_2010_&geo
      PopAge_2010_&geo
      Acs.Acs_2008_12_sum_tr_&geo 
        (keep=&geovar totpop_2008_12);
    by &geovar;
    
    if numoccupiedhsgunits_2010 > 0 then AvgHHSize_2010 = PeopleInHshlds_2010 / numoccupiedhsgunits_2010;
    if numoccupiedhsgunits_2000 > 0 then AvgHHSize_2000 = PeopleInHshlds_2000 / numoccupiedhsgunits_2000;
    if numoccupiedhsgunits_1990 > 0 then AvgHHSize_1990 = PeopleInHshlds_1990 / numoccupiedhsgunits_1990;
    if numoccupiedhsgunits_1980 > 0 then AvgHHSize_1980 = PeopleInHshlds_1980 / numoccupiedhsgunits_1980;
    
    if arealand_sqmi > 0 then do;
      PersonsPerSqMi_2008_12 = totpop_2008_12 / arealand_sqmi;
      PersonsPerSqMi_2010 = TotPop_2010 / arealand_sqmi;
      PersonsPerSqMi_2000 = TotPop_2000 / arealand_sqmi;
      PersonsPerSqMi_1990 = TotPop_1990 / arealand_sqmi;
      PersonsPerSqMi_1980 = TotPop_1980 / arealand_sqmi;
    end;
    
    keep &geovar arealand_sqmi &keep_vars AvgHHSize_: PersonsPerSqMi_: PopAge_: ;
    
  run;

  /*proc download status=no
    inlib=Work 
    outlib=Ncdb memtype=(data);
   * select C100_&geo;
  *run;

  *endrsubmit;*/

  ** End submitting commands to remote server **;

  %File_info( data=C100_&geo, printobs=0 )
  
  proc sort data=C100_&geo;
    by descending PersonsPerSqMi_2008_12;
  run;
  
  proc print data=C100_&geo noobs label;
    id &geovar;
    var PersonsPerSqMi_2008_12;
    format PersonsPerSqMi_2008_12 comma12.0;
  run;

%mend Download_dat;

/** End Macro Definition **/
%Download_dat( city, city )
%Download_dat( wd12, ward2012 )
%Download_dat( cltr00, cluster_tr2000 )

run;

*signoff;

proc sort data=C100_wd12;
by ward2012;
run;
