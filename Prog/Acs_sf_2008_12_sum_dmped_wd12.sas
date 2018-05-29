/**************************************************************************
 Program:  ACS_2008_12_sum_dmped_wd12.sas
 Library:  ACS
 Project:  NeighborhoodInfo DC
 Author:   M. Woluchem
 Created:  02/02/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create summary file from ACS 5-year data: 2008-12 solely for Ward 2012 for DMPED analysis.
 
 Modifications:
  01/21/14 PAT  Updated for new SAS1 server (not tested).
  01/31/14 MSW	Adapted from ACS_2007_11_sum_all.sas
  02/02/14 MSW	Adapted to add additional summary variables for DMPED analysis. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )

%global year year_lbl year_dollar;

%** Program parameters **;

%let year = 2008_12;
%let year_lbl = 2008-12;
%let year_dollar = 2012;

/** Macro Summary_geo - Start Definition **/

%macro Summary_geo( geo, source_geo );

  %local geo_name geo_wt_file geo_var geo_suffix geo_label count_vars moe_vars;

  %let geo_name = %upcase( &geo );
  %let geo_wt_file = %sysfunc( putc( &geo_name, &source_geo_wt_file_fmt ) );;
  %let geo_var = %sysfunc( putc( &geo_name, $geoval. ) );
  %let geo_suffix = %sysfunc( putc( &geo_name, $geosuf. ) );
  %let geo_label = %sysfunc( putc( &geo_name, $geodlbl. ) );

  %if %upcase( &source_geo ) = BG00 or %upcase( &source_geo ) = BG10 %then %do;
  
    %** Count and MOE variables for block group data **;

    %let count_vars = 
           Unwtd: TotPop: PopUnder: Pop25: Pop65: 
           PopWithRace: PopBlack: PopWhite: PopHisp: PopAsian: PopNative: PopOther: PopMulti: 
           Num: Agg: 
		   FamHH: FemaleHead: NonFam: HH: Occupied: Owner: Renter: AddHH: PopWith: Pop16: Civ: Pop: Vac: 
			Housing: Mobile: Boat: Unit: Rent: Owned: Lack: Own: Over: Sev:;
           
    %let moe_vars =
           mTotPop_&year mNumHshlds_&year mNumFamilies_&year
           mPopUnder5Years_&year mPopUnder18Years_&year mPop65andOverYears_&year
           mPopWithRace_&year mPopBlackNonHispBridge_&year
           mPopWhiteNonHispBridge_&year
           mPopAsianPINonHispBridge_&year mPopHisp_&year
           mPopNativeAmNonHispBr_&year
           mPopOtherNonHispBridge_&year
           mPopMultiracialNonHisp_&year
           mPopOtherRaceNonHispBr_&year
           mNumHshldPhone_&year
           mNumHshldCar_&year mAggFamilyIncome_&year
           mNumOccupiedHsgUnits_&year
           mNumOwnerOccupiedHU_&year
           mNumRenterOccupiedHU_&year mNumVacantHsgUnits_&year
           mNumVacantHUForRent_&year
           mNumVacantHUForSale_&year mNumRenterHsgUnits_&year           
           ;
              
	%let prop_vars =
			AverageHHSize_&year			
			AverageHHSizeOwnerOcc_&year	
			AverageHHSizeRenterOcc_&year 	
			MedMonthHousCost_&year 
			MedMonthOwnCost_&year
			MedGrossRent_&year 
			MedAge_&year;
  %end;
  %else %do;
  
    %** Count and MOE variables for tract data **;
  
    %let count_vars = 
           Unwtd: TotPop: PopUnder: Pop16: Pop25: Pop65: PopForeignBorn: 
           PopWithRace: PopBlack: PopWhite: PopHisp: PopAsian: PopNative: PopOther: PopMulti: 
           PopPoor: PopInCivLaborForce: PopCivilian: PopUnemployed:
           Persons: Children: Elderly: Num: Agg: 		
		   FamHH: FemaleHead: NonFam: HH: Occupied: Owner: Renter: AddHH: PopWith: Below100: MidPov: 
			Above150: Pop16: Civ: Pop: Vac: Housing: Mobile: Boat: Unit: Rent: Owned: Lack: Own: Over: Sev:;
           
    %let moe_vars =
           mTotPop_&year mNumHshlds_&year mNumFamilies_&year
           mPopUnder5Years_&year mPopUnder18Years_&year mPop65andOverYears_&year
           mPopForeignBorn_&year
           mPopWithRace_&year mPopBlackNonHispBridge_&year
           mPopWhiteNonHispBridge_&year
           mPopAsianPINonHispBridge_&year mPopHisp_&year
           mPopNativeAmNonHispBr_&year
           mPopOtherNonHispBridge_&year
           mPopMultiracialNonHisp_&year
           mPopOtherRaceNonHispBr_&year mPopPoorPersons_&year
           mPersonsPovertyDefined_&year mPopPoorChildren_&year
           mChildrenPovertyDefined_&year mPopPoorElderly_&year
           mElderlyPovertyDefined_&year mPopCivilianEmployed_&year
           mPopUnemployed_&year mPopInCivLaborForce_&year
           mPop16andOverEmployed_&year mPop16andOverYears_&year
           mNumFamiliesOwnChildren_&year
           mNumFamiliesOwnChildFH_&year mNumHshldPhone_&year
           mNumHshldCar_&year mAggFamilyIncome_&year
           mNumOccupiedHsgUnits_&year
           mNumOwnerOccupiedHU_&year
           mNumRenterOccupiedHU_&year mNumVacantHsgUnits_&year
           mNumVacantHUForRent_&year
           mNumVacantHUForSale_&year mNumRenterHsgUnits_&year           
           ;
               
	%let prop_vars =
		AverageHHSize_&year			
		AverageHHSizeOwnerOcc_&year	
		AverageHHSizeRenterOcc_&year 	
		MedMonthHousCost_&year 
		MedMonthOwnCost_&year
		MedGrossRent_&year 
		MedAge_&year
		;

  %end;
  
  %put _local_;
  
  %if ( &geo_name = GEO2000 and %upcase( &source_geo_var ) = GEO2000 ) or 
      ( &geo_name = GEO2010 and %upcase( &source_geo_var ) = GEO2010 ) %then %do;

    ** Census tracts from census tract source: just recopy selected vars **;
    
    data ACS_r.&source_ds_work&geo_suffix (label="ACS summary, &year_lbl, &source_geo_label source, DC, &geo_label");
    
      set &source_ds_work (keep=&geo_var &count_vars &moe_vars);

    run;

  %end;
  %else %do;
  
    ** Transform data from source geography (&source_geo_var) to target geography (&geo_var) **;
    
    *OPTIONS MPRINT SYMBOLGEN MLOGIC;


    %Transform_geo_data(
      dat_ds_name=&source_ds_work,
      dat_org_geo=&source_geo_var,
      dat_count_vars=&count_vars,
      dat_count_moe_vars=&moe_vars,
      dat_prop_vars=&prop_vars,
      wgt_ds_name=General.&geo_wt_file,
      wgt_org_geo=&source_geo_var,
      wgt_new_geo=&geo_var,
      wgt_id_vars=,
      wgt_wgt_var=popwt,
	  wgt_prop_var=popwt_prop,
      out_ds_name=ACS_r.&source_ds_work&geo_suffix,
      out_ds_label=%str(ACS summary, &year_lbl, &source_geo_label source, DC, &geo_label),
      calc_vars=,
      calc_vars_labels=,
      keep_nonmatch=N,
      show_warnings=10,
      print_diag=Y,
      full_diag=N
    )
    
  %end;  

  proc datasets library=ACS memtype=(data) nolist;
    modify &source_ds_work&geo_suffix (sortedby=&geo_var);
  quit;

  %File_info( data=ACS_r.&source_ds_work&geo_suffix, printobs=0 )

%mend Summary_geo;

/** End Macro Definition **/


/** Macro Summary_geo_source - Start Definition **/

%macro Summary_geo_source( source_geo );

  %global source_geo_var source_geo_suffix source_geo_wt_file_fmt source_ds source_ds_work source_geo_label;

  %if %upcase( &source_geo ) = BG00 %then %do;
     %let source_geo_var = GeoBg2000;
     %let source_geo_suffix = _bg;
     %let source_geo_wt_file_fmt = $geobw0f.;
     %let source_ds = Acs_sf_&year._bg00;
     %let source_geo_label = Block group;
  %end;
  %else %if %upcase( &source_geo ) = TR00 %then %do;
     %let source_geo_var = Geo2000;
     %let source_geo_suffix = _tr;
     %let source_geo_wt_file_fmt = $geotw0f.;
     %let source_ds = Acs_sf_&year._tr00;
     %let source_geo_label = Census tract;
  %end;
  %else %if %upcase( &source_geo ) = BG10 %then %do;
     %let source_geo_var = GeoBg2010;
     %let source_geo_suffix = _bg;
     %let source_geo_wt_file_fmt = $geobw1f.;
     %let source_ds = Acs_sf_&year._bg10;
     %let source_geo_label = Block group;
  %end;
  %else %if %upcase( &source_geo ) = TR10 %then %do;
     %let source_geo_var = Geo2010;
     %let source_geo_suffix = _tr;
     %let source_geo_wt_file_fmt = $geotw1f.;
     %let source_ds = Acs_sf_&year._tr10;
     %let source_geo_label = Census tract;
  %end;
  %else %do;
    %err_mput( macro=Summary_geo_source, msg=Geograpy &source_geo is not supported. )
    %goto macro_exit;
  %end;
     
  %let source_ds_work = ACS_&year._sum&source_geo_suffix;

  %put _global_;

  ** Create new variables for summarizing **;

  data &source_ds_work;

    set ACS_r.&source_ds;
    
    ** Unweighted sample counts **;
    
    UnwtdPop_&year = B00001e1;
    UnwtdHsgUnits_&year = B00002e1;

    label
      UnwtdPop_&year = "Unweighted sample population, &year_lbl"
      UnwtdHsgUnits_&year = "Unweighted sample housing units, &year_lbl";

    ** Demographics **;
    
    TotPop_&year = B01003e1;
    
    NumHshlds_&year = B11001e1;

    NumFamilies_&year = B11003e1;

    PopUnder5Years_&year = sum( B01001e3, B01001e27 );
    
    PopUnder18Years_&year = 
      sum( B01001e3, B01001e4, B01001e5, B01001e6, 
           B01001e27, B01001e28, B01001e29, B01001e30 );
    
    Pop65andOverYears_&year = 
      sum( B01001e20, B01001e21, B01001e22, B01001e23, B01001e24, B01001e25, 
           B01001e44, B01001e45, B01001e46, B01001e47, B01001e48, B01001e49 );

    mTotPop_&year = B01003m1;

    mNumHshlds_&year = B11001m1;

    mNumFamilies_&year = B11003m1;

    mPopUnder5Years_&year = %moe_sum( var=B01001m3 B01001m27 );
    
    mPopUnder18Years_&year = 
      %moe_sum( var=B01001m3 B01001m4 B01001m5 B01001m6 
           B01001m27 B01001m28 B01001m29 B01001m30 );
    
    mPop65andOverYears_&year = 
      %moe_sum( var=B01001m20 B01001m21 B01001m22 B01001m23 B01001m24 B01001m25 
           B01001m44 B01001m45 B01001m46 B01001m47 B01001m48 B01001m49 );


    label
      TotPop_&year = "Total population, &year_lbl"
      NumHshlds_&year = "Total HHs, &year_lbl"
      NumFamilies_&year = "Family HHs, &year_lbl"
      PopUnder5Years_&year = "Persons under 5 years old, &year_lbl"
      PopUnder18Years_&year = "Persons under 18 years old, &year_lbl"
      Pop65andOverYears_&year = "Persons 65 years old and over, &year_lbl"
      mTotPop_&year = "Total population, MOE, &year_lbl"
      mNumHshlds_&year = "Total HHs, MOE, &year_lbl"
      mNumFamilies_&year = "Family HHs, MOE, &year_lbl"
      mPopUnder5Years_&year = "Persons under 5 years old, MOE, &year_lbl"
      mPopUnder18Years_&year = "Persons under 18 years old, MOE, &year_lbl"
      mPop65andOverYears_&year = "Persons 65 years old and over, MOE, &year_lbl"
    ;
    
    %if %upcase( &source_geo ) = TR00 or %upcase( &source_geo ) = TR10 %then %do;
    
      ** Foreign born **;

      PopForeignBorn_&year = B05002e13;
      mPopForeignBorn_&year = B05002m13;
      
      label 
        PopForeignBorn_&year = "Foreign born population, &year_lbl"
        mPopForeignBorn_&year = "Foreign born population, MOE, &year_lbl";
    
    %end;
    
    ** Population by race/ethnicity **;
    
    PopWithRace_&year = totpop_&year;
    PopBlackNonHispBridge_&year = B03002e4;
    PopWhiteNonHispBridge_&year = B03002e3;
    PopHisp_&year = B03002e12;
    PopAsianPINonHispBridge_&year = sum( B03002e6, B03002e7 );
    PopNativeAmNonHispBridge_&year = B03002e5;
    PopOtherNonHispBridge_&year = B03002e8;
    PopMultiracialNonHisp_&year = B03002e9;
    
    PopOtherRaceNonHispBridg_&year = PopWithRace_&year - 
      sum( PopBlackNonHispBridge_&year, PopWhiteNonHispBridge_&year, PopHisp_&year, PopAsianPINonHispBridge_&year );

    mPopWithRace_&year = mtotpop_&year;
    mPopBlackNonHispBridge_&year = B03002m4;
    mPopWhiteNonHispBridge_&year = B03002m3;
    mPopHisp_&year = B03002m12;
    mPopAsianPINonHispBridge_&year = %moe_sum( var=B03002m6 B03002m7 );
    mPopNativeAmNonHispBr_&year = B03002m5;
    mPopOtherNonHispBridge_&year = B03002m8;
    mPopMultiracialNonHisp_&year = B03002m9;
    
    mPopOtherRaceNonHispBr_&year = 
      %moe_sum( var=B03002m5 B03002m8 B03002m9 );

    label
      PopWithRace_&year = "Total population for race/ethnicity, &year_lbl"
      PopBlackNonHispBridge_&year = "Non-Hispanic Black/African American population, &year_lbl"
      PopWhiteNonHispBridge_&year = "Non-Hispanic White population, &year_lbl"
      PopAsianPINonHispBridge_&year = "Non-Hispanic Asian, Hawaiian and other Pacific Islander pop., &year_lbl"
      PopHisp_&year = "Hispanic/Latino population, &year_lbl"
      PopNativeAmNonHispBridge_&year = "Non-Hispanic American Indian/Alaska Native population, &year_lbl"
      PopOtherNonHispBridge_&year = "Non-Hispanic other race population, &year_lbl"
      PopMultiracialNonHisp_&year = "Non-Hispanic multiracial population, &year_lbl"
      PopOtherRaceNonHispBridg_&year = "All remaining groups other than black, white, Hispanic, and Asian/PI, &year_lbl"
      mPopWithRace_&year = "Total population for race/ethnicity, MOE, &year_lbl"
      mPopBlackNonHispBridge_&year = "Non-Hispanic Black/African American population, MOE, &year_lbl"
      mPopWhiteNonHispBridge_&year = "Non-Hispanic White population, MOE, &year_lbl"
      mPopAsianPINonHispBridge_&year = "Non-Hispanic Asian, Hawaiian and other Pacific Islander pop., MOE, &year_lbl"
      mPopHisp_&year = "Hispanic/Latino population, MOE, &year_lbl"
      mPopNativeAmNonHispBr_&year = "Non-Hispanic American Indian/Alaska Native population, MOE, &year_lbl"
      mPopOtherNonHispBridge_&year = "Non-Hispanic other race population, MOE, &year_lbl"
      mPopMultiracialNonHisp_&year = "Non-Hispanic multiracial population, MOE, &year_lbl"
      mPopOtherRaceNonHispBr_&year = "All remaining groups other than black, white, Hispanic, and Asian/PI, MOE, &year_lbl"
    ;
    
    %if %upcase( &source_geo ) = TR00 or %upcase( &source_geo ) = TR10 %then %do;
    
      ** Poverty **;
      
      ChildrenPovertyDefined_&year = 
        sum( B17001e4, B17001e5, B17001e6, B17001e7, B17001e8, B17001e9, 
             B17001e18, B17001e19, B17001e20, B17001e21, B17001e22, B17001e23,
             B17001e33, B17001e34, B17001e35, B17001e36, B17001e37, B17001e38, 
             B17001e47, B17001e48, B17001e49, B17001e50, B17001e51, B17001e52
            );

      ElderlyPovertyDefined_&year = 
        sum( B17001e15, B17001e16, B17001e29, B17001e30,
             B17001e44, B17001e45, B17001e58, B17001e59
        );

      PersonsPovertyDefined_&year = B17001e1;
      
      PopPoorChildren_&year = 
        sum( B17001e4, B17001e5, B17001e6, B17001e7, B17001e8, B17001e9, 
             B17001e18, B17001e19, B17001e20, B17001e21, B17001e22, B17001e23 );

      PopPoorElderly_&year = 
        sum( B17001e15, B17001e16, B17001e29, B17001e30 );

      PopPoorPersons_&year = B17001e2;
      
      mChildrenPovertyDefined_&year = 
        %moe_sum( var=B17001m4 B17001m5 B17001m6 B17001m7 B17001m8 B17001m9 
             B17001m18 B17001m19 B17001m20 B17001m21 B17001m22 B17001m23
             B17001m33 B17001m34 B17001m35 B17001m36 B17001m37 B17001m38 
             B17001m47 B17001m48 B17001m49 B17001m50 B17001m51 B17001m52
            );

      mElderlyPovertyDefined_&year = 
        %moe_sum( var=B17001m15 B17001m16 B17001m29 B17001m30
             B17001m44 B17001m45 B17001m58 B17001m59
        );

      mPersonsPovertyDefined_&year = B17001m1;
      
      mPopPoorChildren_&year = 
        %moe_sum( var=B17001m4 B17001m5 B17001m6 B17001m7 B17001m8 B17001m9 
             B17001m18 B17001m19 B17001m20 B17001m21 B17001m22 B17001m23 );

      mPopPoorElderly_&year = 
        %moe_sum( var=B17001m15 B17001m16 B17001m29 B17001m30 );

      mPopPoorPersons_&year = B17001m2;
      
      label
        PopPoorPersons_&year = "Persons below the poverty level last year, &year_lbl"
        PersonsPovertyDefined_&year = "Persons with poverty status determined, &year_lbl"
        PopPoorChildren_&year = "Children under 18 years old below the poverty level last year, &year_lbl"
        ChildrenPovertyDefined_&year = "Children under 18 years old with poverty status determined, &year_lbl"
        PopPoorElderly_&year = "Persons 65 years old and over below the poverty level last year, &year_lbl"
        ElderlyPovertyDefined_&year = "Persons 65 years old and over with poverty status determined, &year_lbl"
        mPopPoorPersons_&year = "Persons below the poverty level last year, MOE, &year_lbl"
        mPersonsPovertyDefined_&year = "Persons with poverty status determined, MOE, &year_lbl"
        mPopPoorChildren_&year = "Children under 18 years old below the poverty level last year, MOE, &year_lbl"
        mChildrenPovertyDefined_&year = "Children under 18 years old with poverty status determined, MOE, &year_lbl"
        mPopPoorElderly_&year = "Persons 65 years old and over below the poverty level last year, MOE, &year_lbl"
        mElderlyPovertyDefined_&year = "Persons 65 years old and over with poverty status determined, MOE, &year_lbl"
      ;

    %end;
    
    %if %upcase( &source_geo ) = TR00 or %upcase( &source_geo ) = TR10 %then %do;
    
      ** Employment **;
      
      PopCivilianEmployed_&year = 
        sum( B23001e7, B23001e14, B23001e21, B23001e28, B23001e35, B23001e42, B23001e49, 
             B23001e56, B23001e63, B23001e70, B23001e75, B23001e80, B23001e85,
             B23001e93, B23001e100, B23001e107, B23001e114, B23001e121, B23001e128, 
             B23001e135, B23001e142, B23001e149, B23001e156, B23001e161, B23001e166, B23001e171 );

      PopUnemployed_&year = 
        sum( B23001e8, B23001e15, B23001e22, B23001e29, B23001e36, B23001e43, B23001e50, 
             B23001e57, B23001e64, B23001e71, B23001e76, B23001e81, B23001e86, 
             B23001e94, B23001e101, B23001e108, B23001e115, B23001e122, B23001e129, 
             B23001e136, B23001e143, B23001e150, B23001e157, B23001e162, B23001e167, B23001e172 );
      
      PopInCivLaborForce_&year = sum( PopCivilianEmployed_&year, PopUnemployed_&year );
      
      Pop16andOverEmployed_&year = PopCivilianEmployed_&year +
        sum( B23001e5, B23001e12, B23001e19, B23001e26, B23001e33, B23001e40, 
             B23001e47, B23001e54, B23001e61, B23001e68,
             B23001e91, B23001e98, B23001e105, B23001e112, B23001e119, B23001e126, 
             B23001e133, B23001e140, B23001e147, B23001e154 );

      Pop16andOverYears_&year = B23001e1;
      
      mPopCivilianEmployed_&year = 
        %moe_sum( var=B23001m7 B23001m14 B23001m21 B23001m28 B23001m35 B23001m42 B23001m49 
             B23001m56 B23001m63 B23001m70 B23001m75 B23001m80 B23001m85
             B23001m93 B23001m100 B23001m107 B23001m114 B23001m121 B23001m128 
             B23001m135 B23001m142 B23001m149 B23001m156 B23001m161 B23001m166 B23001m171 );

      mPopUnemployed_&year = 
        %moe_sum( var=B23001m8 B23001m15 B23001m22 B23001m29 B23001m36 B23001m43 B23001m50 
             B23001m57 B23001m64 B23001m71 B23001m76 B23001m81 B23001m86 
             B23001m94 B23001m101 B23001m108 B23001m115 B23001m122 B23001m129 
             B23001m136 B23001m143 B23001m150 B23001m157 B23001m162 B23001m167 B23001m172 );
      
      mPopInCivLaborForce_&year = %moe_sum( var=mPopCivilianEmployed_&year mPopUnemployed_&year );
      
      mPop16andOverEmployed_&year =
        %moe_sum( var=mPopCivilianEmployed_&year B23001m5 B23001m12 B23001m19 B23001m26 B23001m33 B23001m40 
             B23001m47 B23001m54 B23001m61 B23001m68
             B23001m91 B23001m98 B23001m105 B23001m112 B23001m119 B23001m126 
             B23001m133 B23001m140 B23001m147 B23001m154 );

      mPop16andOverYears_&year = B23001m1;
      
      label
        PopCivilianEmployed_&year = "Persons 16+ years old in the civilian labor force and employed, &year_lbl"
        PopUnemployed_&year = "Persons 16+ years old in the civilian labor force and unemployed, &year_lbl"
        PopInCivLaborForce_&year = "Persons 16+ years old in the civilian labor force, &year_lbl"
        Pop16andOverEmployed_&year = "Persons 16+ years old who are employed (includes armed forces), &year_lbl"
        Pop16andOverYears_&year = "Persons 16+ years old, &year_lbl"
        mPopCivilianEmployed_&year = "Persons 16+ years old in the civilian labor force and employed, &year_lbl"
        mPopUnemployed_&year = "Persons 16+ years old in the civilian labor force and unemployed, &year_lbl"
        mPopInCivLaborForce_&year = "Persons 16+ years old in the civilian labor force, &year_lbl"
        mPop16andOverEmployed_&year = "Persons 16+ years old who are employed (includes armed forces), &year_lbl"
        mPop16andOverYears_&year = "Persons 16+ years old, &year_lbl"
      ;
      
    %end;
    
    ** Education **;

    Pop25andOverYears_&year = B15002e1;
    
    Pop25andOverWoutHS_&year = 
      sum( B15003e3, B15003e4, B15003e5, B15003e6, B15003e7, B15003e8, B15003e9, B15003e10, B15003e11, B15003e12,
		   B15003e13, B15003e14, B15003e15, B15003e16);
           
    Pop25andOverWHS_&year = 
      sum( B15003e17, B15003e18, B15003e19, B15003e20 );

   
    
    label
      Pop25andOverWoutHS_&year = "Persons 25 years old and over without high school diploma, &year_lbl"
      Pop25andOverYears_&year = "Persons 25 years old and over, &year_lbl"
      Pop25andOverWHS_&year = "Persons 25 years old and over with a high school diploma or GED, &year_lbl"
      ;
      
    %if %upcase( &source_geo ) = TR00 or %upcase( &source_geo ) = TR10 %then %do;

      ** Household type **;

      NumFamiliesOwnChildren_&year = 
        sum( B11003e3, B11003e10, B11003e16 ) + 
        sum( B11013e3, B11013e5, B11013e6 );
      
      NumFamiliesOwnChildrenFH_&year = B11003e16 + B11013e5;

      mNumFamiliesOwnChildren_&year = 
        %moe_sum( var=B11003m3 B11003m10 B11003m16 B11013m3 B11013m5 B11013m6 );
      
      mNumFamiliesOwnChildFH_&year = %moe_sum( var=B11003m16 B11013m5 );

      label
        NumFamiliesOwnChildren_&year = "Total families and subfamilies with own children, &year_lbl"
        NumFamiliesOwnChildrenFH_&year = "Female-headed families and subfamilies with own children, &year_lbl"
        mNumFamiliesOwnChildren_&year = "Total families and subfamilies with own children, MOE, &year_lbl"
        mNumFamiliesOwnChildFH_&year = "Female-headed families and subfamilies with own children, MOE, &year_lbl"
      ;
      
    %end;
    
    ** Isolation **;
    
    NumHshldPhone_&year = sum( B25043e3, B25043e12 );
    
    NumHshldCar_&year = 
      sum( B25044e4, B25044e5, B25044e6, B25044e7, B25044e8, 
           B25044e11, B25044e12, B25044e13, B25044e14, B25044e15 );

    mNumHshldPhone_&year = %moe_sum( var=B25043m3 B25043m12 );
    
    mNumHshldCar_&year = 
      %moe_sum( var=B25044m4 B25044m5 B25044m6 B25044m7 B25044m8 
           B25044m11 B25044m12 B25044m13 B25044m14 B25044m15 );

    label
      NumHshldPhone_&year = "Occupied housing units with a telephone, &year_lbl"
      NumHshldCar_&year = "Occupied housing units with at least one vehicle available, &year_lbl"
      mNumHshldPhone_&year = "Occupied housing units with a telephone, MOE, &year_lbl"
      mNumHshldCar_&year = "Occupied housing units with at least one vehicle available, MOE, &year_lbl"
      ;
  
    ** Income **;
    
    AggFamilyIncome_&year = B19127e1;
    
    mAggFamilyIncome_&year = B19127m1;

    label 
      AggFamilyIncome_&year = "Aggregate family income ($ &year_dollar), &year_lbl"
      mAggFamilyIncome_&year = "Aggregate family income ($ &year_dollar), MOE, &year_lbl"
      ;
    
    ** Housing **;
    
    NumOccupiedHsgUnits_&year = B25003e1;
    NumOwnerOccupiedHsgUnits_&year = B25003e2;
    NumRenterOccupiedHsgUnit_&year = B25003e3;

    NumVacantHsgUnits_&year = B25004e1;
    NumVacantHsgUnitsForRent_&year = B25004e2;
    NumVacantHsgUnitsForSale_&year = B25004e4;
    
    NumRenterHsgUnits_&year = NumRenterOccupiedHsgUnit_&year + NumVacantHsgUnitsForRent_&year;

    mNumOccupiedHsgUnits_&year = B25003m1;
    mNumOwnerOccupiedHU_&year = B25003m2;
    mNumRenterOccupiedHU_&year = B25003m3;

    mNumVacantHsgUnits_&year = B25004m1;
    mNumVacantHUForRent_&year = B25004m2;
    mNumVacantHUForSale_&year = B25004m4;
    
    mNumRenterHsgUnits_&year = %moe_sum( var=mNumRenterOccupiedHU_&year mNumVacantHUForRent_&year );

    label
      NumOccupiedHsgUnits_&year = "Occupied housing units, &year_lbl"
      NumOwnerOccupiedHsgUnits_&year = "Owner-occupied housing units, &year_lbl"
      NumRenterOccupiedHsgUnit_&year = "Renter-occupied housing units, &year_lbl"
      NumVacantHsgUnits_&year = "Vacant housing units, &year_lbl"
      NumVacantHsgUnitsForRent_&year = "Vacant housing units for rent, &year_lbl"
      NumVacantHsgUnitsForSale_&year = "Vacant housing units for sale, &year_lbl"
      NumRenterHsgUnits_&year = "Total rental housing units, &year_lbl"
      mNumOccupiedHsgUnits_&year = "Occupied housing units, MOE, &year_lbl"
      mNumOwnerOccupiedHU_&year = "Owner-occupied housing units, MOE, &year_lbl"
      mNumRenterOccupiedHU_&year = "Renter-occupied housing units, MOE, &year_lbl"
      mNumVacantHsgUnits_&year = "Vacant housing units, MOE, &year_lbl"
      mNumVacantHUForRent_&year = "Vacant housing units for rent, MOE, &year_lbl"
      mNumVacantHUForSale_&year = "Vacant housing units for sale, MOE, &year_lbl"
      mNumRenterHsgUnits_&year = "Total rental housing units, MOE, &year_lbl"
    ;


  **Added by MSW for DMPED Profile**;

	FamHHMarriedKids_&year = B11005e4;
	FamHHMarriedNoKids_&year = B11005e13;
	FamHHMaleHeadKids_&year = B11005e6;
	FamHHMaleHeadNoKids_&year = B11005e15;
	FamHHFemaleHeadKids_&year = B11005e7;
	FamHHFemaleHeadNoKids_&year = B11005e16;

	FemaleHeadKid6andYounger = B11004e17;
	MedAge_&year = B06002e1;
	NonFamHHs_&year = 		B11001e7;
	HHLivingAlone_&year = 		B11001e8;
	HHLivingAlong65Plus_&year = 	B11010e5+B11010e12;					
	HHWithKids_&year =	B11005e2;
	HHWithSeniors_&year = 	B11007e2;
	HH1Person_&year =	B11016e10;
	HH2Person_&year =	B11016e3+B11016e11;
	HH3Person_&year = 	B11016e4+B11016e12;
	HH4PlusPerson_&year = 	B11016e5+B11016e6+B11016e7+B11016e8+B11016e13+B11016e14+B11016e15+B11016e16;

	
	OccupiedHHUnits_&year	= B25007e1;
	OwnerOccupied_&year	= B25007e2;
	OwnerOccupiedSub24_&year =	B25007e3;
	OwnerOccupied25to34_&year = 	B25007e4;
	OwnerOccupied35to64_&year = 	B25007e5+B25007e6+B25007e7+B25007e8;
	OwnerOccupied65plus_&year = 	B25007e9+B25007e10+B25007e11;
	RenterOccupied_&year = B25007e12;
	RenterOccupiedSub24_&year = 	B25007e13;
	RenterOccupied25to34_&year = 	B25007e14;
	RenterOccupied35to64_&year =	B25007e15+B25007e16+B25007e17+B25007e18;
	RenterOccupied65plus_&year =	B25007e19+B25007e20+B25007e21;
	AverageHHSize_&year =	B25010e1;
	AverageHHSizeOwnerOcc_&year =	B25010e2;
	AverageHHSizeRenterOcc_&year = B25010e3	;	
		
	HHIncLessThan10K_&year = B19001e2;
	HHIncBtwn10Kand25K_&year =	B19001e3+B19001e4+B19001e5;
	HHIncBtwn25Kand35K_&year = B19001e6+B19001e7;
	HHIncBtwn35Kand50K_&year = B19001e8+B19001e9+B19001e10;
	HHIncBtwn50Kand75K_&year = B19001e11+B19001e12;
	HHIncBtwn75Kand100K_&year = B19001e13;
	HHIncAbove100K_&year = B19001e14+B19001e15+B19001e16+B19001e17;
	HHIncMean = B19013e1;
		
	AddHHIncRetirement_&year = B19059e2;
	AddHHIncSuppSec_&year =	B19056e2;
	AddHHIncWelfare_&year = 	B19057e2;
	AddHHIncFoodStamp_&year = 	B19058e2;

	PopWithPovStatus_&year = 	B07012e1;
	Below100pctofPov_&year = B07012e2;
	Below100pctMovedSameCty_&year = B07012e10;
	Below100pctMovedDiffCty_&year = B07012e14;
	Below100pctMovedDiffSt_&year = B07012e18;
	Below100pctMovedAbroad_&year = B07012e22;
	MidPov_&year = B07012e3;
	MidPovMovedSameCty_&year = B07012e11;
	MidPovMovedDiffCty_&year = B07012e15;
	MidPovMovedDiffSt_&year = B07012e19;
	MidPovMovedAbroad_&year = B07012e23;
	Above150pctPov_&year =	B07012e4;
	Above150pctMovedSameCty_&year = B07012e12;
	Above150pctMovedDiffCty_&year = B07012e16;
	Above150pctMovedDiffSt_&year = 	B07012e20;
	Above150pctMovedAbroad_&year = 	B07012e24;
			
	Pop16yrsAndOver_&year =	B23025e1;
	CivLaborForce = B23025e3;
	PopEmployed = B23025e4;
	PopUnemployed =	B23025e5;
	
	Pop25andOverAssocDeg_&year = B15003e21;
	Pop25andOverBachDeg_&year = B15003e22;
	Pop25andOverGradDeg_&year = B15003e23+B15003e24+B15003e25;
		
	CivNonInstitPop_&year = 	B18101e1;
		
	PopUnder5Years_&year = 	B18101e4+B18101e23;
	PopUnder5HearingDiff_&year = B18102e4+B18102e23;
	PopUnder5VisionDiff_&year = 	B18103e4+B18103e23;

	Pop5to17Years_&year = 	B18101e7+B18101e26;
	Pop5to17HearingDiff_&year = 	B18102e7+B18102e26;
	Pop5to17VisionDiff_&year = 	B18103e7+B18103e26;
	Pop5to17CognitDiff_&year = 	B18104e4+B18104e20;
	Pop5to17AmbulDiff_&year =	B18105e4+B18105e20;
	Pop5to17SelfCareDiff_&year = 	B18106e4+B18106e20;

	Pop18to64Years_&year = 	B18101e10+B18101e13+B18101e29+B18101e32;
	Pop18to64HearingDiff_&year = 	B18102e10+B18102e13+B18102e29+B18102e32;
	Pop18to64VisionDiff_&year = 	B18103e10+B18103e13+B18103e29+B18103e32;
	Pop18to64CognitDiff_&year =	B18104e7+B18104e10+B18104e23+B18104e26;
	Pop18to64AmbulDiff_&year = B18105e7+B18105e10+B18105e23+B18105e26;
	Pop18to64SelfCareDiff_&year = B18106e7+B18106e10+B18106e23+B18106e26;

	Pop65andOver_&year = 	B18101e16+B18101e19+B18101e35+B18101e38;
	Pop65andOverHearingDiff_&year = B18102e16+B18102e19+B18102e35+B18102e38;
	Pop65andOverVisionDiff_&year = 	B18103e16+B18103e19+B18103e35+B18103e38;
	Pop65andOverCognitDiff_&year = B18104e13+B18104e16+B18104e29+B18104e32;
	Pop65andOverAmbulDiff_&year = 	B18105e13+B18105e16+B18105e29+B18105e32;
	Pop65andOverSelfCareDiff_&year =	B18106e13+B18106e16+B18106e29+B18106e32;

	VacantHUnits_&year = B25004e1;
	VacantRentUnits_&year = B25004e2;
	VacantBuyUnits_&year = B25004e4;

	HousingUnits_&year = B25024e1;
	Housing1DetUnits_&year = B25024e2;
	Housing1AttUnits_&year = B25024e3;
	Housing2Units_&year = B25024e4;
	Housing3to4Units_&year = B25024e5;
	Housing5to9Units_&year = B25024e6;
	Housing10to19Units_&year = B25024e7;
	Housing20to49Units_&year = B25024e8;
	Housing50PlusUnits_&year = B25024e9;
	MobileHome_&year = B25024e10;
	BoatRVVan_&year = B25024e11;

	UnitStudio_&year = B25041e2;
	Unit1Bed_&year = B25041e3;
	Unit2Bed_&year = B25041e4;
	Unit3Bed_&year = B25041e5;
	Unit4Bed_&year = B25041e6;
	Unit5plusBed_&year = B25041e7;

	MedMonthHousCost_&year = B25105e1;
	MedMonthOwnCost_&year = B25088e2;
	MedGrossRent_&year = B25064e1;

	RentLessThan10Pct_&year =	B25070e2;
	Rent10to15Pct_&year = 		B25070e3;
	Rent15to20Pct_&year = 		B25070e4;
	Rent20to25Pct_&year = 		B25070e5;
	Rent25to30Pct_&year = 		B25070e6;
	Rent30to35Pct_&year =		B25070e7;
	Rent35to40Pct_&year = 		B25070e8;
	Rent40to50Pct_&year = 		B25070e9;
	Rent50PctPlus_&year = 		B25070e10;
	RentNotComputed_&year = 	B25070e11;
		
	OwnerOccWMortgage_&year = 	B25091e2;
	OwnedLessThan10Pct_&year =	B25091e3;
	Owned10to15Pct_&year = 		B25091e4;
	Owned15to20Pct_&year = 		B25091e5;
	Owned20to25Pct_&year = 		B25091e6;
	Owned25to30Pct_&year = 		B25091e7;
	Owned30to35Pct_&year =		B25091e8;
	Owned35to40Pct_&year = 		B25091e9;
	Owned40to50Pct_&year = 		B25091e10;
	Owned50PctPlus_&year = 		B25091e11;
	OwnedNotComputed_&year = 	B25091e12;

	LackKitchen_&year = 	B25052e3;
	LackPlumbing_&year = 	B25049e4;
	RentBurdened_&year =	B25070e7+B25070e8+B25070e9;
	OwnBurdened_&year = 	B25091e8+B25091e9+B25091e10+B25091e19+B25091e20+B25091e21;
	RentSevBurdened_&year = B25070e10;
	OwnSevBurdened_&year = 	B25091e11+B25091e22;
	Overcrowded_&year = 	B25014e5+B25014e11;
	SevOvercrowded_&year =	B25014e6+B25014e7+B25014e12+B25014e13;


	label 

	FamHHMarriedKids_&year = "Family Households: Married Couple, kids under 18, &year_lbl"
	FamHHMarriedNoKids_&year = "Family Households: Married Couple, no kids, &year_lbl"
	FamHHMaleHeadKids_&year = "Family Households: Male head, kids under 18, &year_lbl"
	FamHHMarriedKids_&year = 		'Family Households: Married Couple, kids under 18'
	FamHHMarriedNoKids_&year = 		'Family Households: Married Couple, no kids'
	FamHHMaleHeadKids_&year = 		'Family Households: Male head, kids under 18'
	FamHHMaleHeadNoKids_&year = 		'Family Households: Male head, no kids'
	FamHHFemaleHeadKids_&year = 		'Family Households: Female head, kids under 18'
	FamHHFemaleHeadNoKids_&year =		'Family Households: Female head, no kids'

	NonFamHHs_&year = 			'Nonfamily households'
	HHLivingAlone_&year = 			'Householder living alone'
	HHLivingAlong65Plus_&year = 		'65 years and over'
	HHWithKids_&year =			'Households with one or more persons under 18 years'
	HHWithSeniors_&year = 			'Households with one or more persons 65 years or older'
	HH1Person_&year =			'Households 1-person'
	HH2Person_&year =			'Households 2-person'
	HH3Person_&year = 			'Households 3-person'
	HH4PlusPerson_&year = 			'Households 4-person+'

	MedMonthHousCost_&year = 	'Median Monthly Housing Cost'
	MedMonthOwnCost_&year = 	'Median Gross Monthly Rent'
	MedGrossRent_&year = 		'Median Monthly Owner Costs (Owner With Mortgage)'
		
	OccupiedHHUnits_&year	= 		'Universe--Occupied Housing Units'
	OwnerOccupied_&year	= 		'Owner Occupied'
	OwnerOccupiedSub24_&year =		'Owner Occ: Under 24 years'
	OwnerOccupied25to34_&year = 		'Owner Occ: 25 - 34 years'
	OwnerOccupied35to64_&year = 		'Owner Occ: 35 - 64 years'
	OwnerOccupied65plus_&year = 		'Owner Occ: 65 years and over'
	RenterOccupied_&year = 			'Renter Occupied'
	RenterOccupiedSub24_&year = 		'Renter Occ: Under 24 years'
	RenterOccupied25to34_&year = 		'Renter Occ: 25 - 34 years'
	RenterOccupied35to64_&year =		'Renter Occ: 35 - 64 years'
	RenterOccupied65plus_&year =		'Renter Occ: 65 years and over'
	AverageHHSize_&year =				'Average Household Size'
	AverageHHSizeOwnerOcc_&year =		'Average Owner Occupied HH Size'
	AverageHHSizeRenterOcc_&year = 		'Average Renter Occupied HH Size'
		
	HHIncLessThan10K_&year = 		'Household Income Less than $10,000'
	HHIncBtwn10Kand25K_&year =		'Household Income $10,000 to $24,999'
	HHIncBtwn25Kand35K_&year = 		'Household Income $25,000 to $34,999'
	HHIncBtwn35Kand50K_&year = 		'Household Income $35,000 to $49,999'
	HHIncBtwn50Kand75K_&year = 		'Household Income $50,000 to $74,999'
	HHIncBtwn75Kand100K_&year =		'Household Income $75,000 to $99,999'
	HHIncAbove100K_&year =			'Household Income $100,000 and above'
		
	AddHHIncRetirement_&year = 		'Households with retirement income'
	AddHHIncSuppSec_&year =			'Households with Supplemental Security income'
	AddHHIncWelfare_&year = 		'Households with TANF/welfare income'
	AddHHIncFoodStamp_&year = 		'Households with SNAP/food stamp benefits'

	PopWithPovStatus_&year = 		'Population 1 year and over for whom poverty status is determined' 
	Below100pctofPov_&year =		'Below 100 percent of poverty level'
	Below100pctMovedSameCty_&year =		'Below 100 pct: Moved within same county'
	Below100pctMovedDiffCty_&year =		'Below 100 pct: Moved from different county, same state'
	Below100pctMovedDiffSt_&year = 		'Below 100 pct: Moved from different state'
	Below100pctMovedAbroad_&year = 		'Below 100 pct: Moved from abroad'
	MidPov_&year = 		'100 to 149 percent of poverty level'
	MidPovMovedSameCty_&year = 		'100 to 149 pct: Moved within same county'
	MidPovMovedDiffCty_&year = 		'100 to 149 pct: Moved from different county, same state'
	MidPovMovedDiffSt_&year = 		'100 to 149 pct: Moved from different state'
	MidPovMovedAbroad_&year = 		'100 to 149 pct: Moved from abroad'
	Above150pctPov_&year =			'At or above 150 percent of poverty level'
	Above150pctMovedSameCty_&year = 	'At or above 150 pct: Moved within same county'
	Above150pctMovedDiffCty_&year = 	'At or above 150 pct: Moved from different county, same state'
	Above150pctMovedDiffSt_&year = 		'At or above 150 pct: Moved from different state'
	Above150pctMovedAbroad_&year = 		'At or above 150 pct: Moved from abroad'
			
	Pop16yrsAndOver_&year =			'Population 16 years and over'
	CivLaborForce =				'In civilian labor force'
	PopEmployed = 				'Employed'
	PopUnemployed =				'Unemployed'

	Pop25andOverAssocDeg_&year =		'Over 25: Associates degree'
	Pop25andOverBachDeg_&year = 		'Over 25: Bachelors degree'
	Pop25andOverGradDeg_&year = 		'Over 25: Graduate degree'
		
	CivNonInstitPop_&year = 		'Total civilian noninstitutionalized population'

	PopUnder5Years_&year = 			'Population under 5 years with disability'
	PopUnder5HearingDiff_&year = 		'Under 5 years with a hearing difficulty'
	PopUnder5VisionDiff_&year = 		'Under 5 years with a vision difficulty'

	Pop5to17Years_&year = 			'Population 5-17 with disability'
	Pop5to17HearingDiff_&year = 		'5 to 17 with a hearing difficulty'
	Pop5to17VisionDiff_&year = 		'5 to 17 with a vision difficulty'
	Pop5to17CognitDiff_&year = 		'5 to 17 with a cognitive difficulty'
	Pop5to17AmbulDiff_&year =		'5 to 17 with an ambulatory difficulty'
	Pop5to17SelfCareDiff_&year =		'5 to 17 with a self-care difficulty'

	Pop18to64Years_&year = 			'Population 18 to 64 with disability'
	Pop18to64HearingDiff_&year = 		'18 to 64 with a hearing difficulty'
	Pop18to64VisionDiff_&year = 		'18 to 64 with a vision difficulty'
	Pop18to64CognitDiff_&year =		'18 to 64 with a cognitive difficulty'
	Pop18to64AmbulDiff_&year = 		'18 to 64 with an ambulatory difficulty'
	Pop18to64SelfCareDiff_&year = 		'18 to 64 with a self-care difficulty'

	Pop65andOver_&year = 			'Population 65 and over with disability'
	Pop65andOverHearingDiff_&year = 	'65 and over with a hearing difficulty'
	Pop65andOverVisionDiff_&year = 		'65 and over with a vision difficulty'
	Pop65andOverCognitDiff_&year = 		'65 and over with a cognitive difficulty'
	Pop65andOverAmbulDiff_&year = 		'65 and over with an ambulatory difficulty'
	Pop65andOverSelfCareDiff_&year =	'65 and over with a self-care difficulty'

	VacantHUnits_&year = 			'All vacant housing units'
	VacantRentUnits_&year =			'Vacant, for rent  '
	VacantBuyUnits_&year = 			'Vacant, to buy'

	HousingUnits_&year = 			'Housing units'
	Housing1DetUnits_&year = 		'1, detached housing units'
	Housing1AttUnits_&year = 		'1, attached housing units'
	Housing2Units_&year = 			'2 housing units'
	Housing3to4Units_&year = 		'3 or 4 housing units'
	Housing5to9Units_&year = 		'5 to 9 housing units'
	Housing10to19Units_&year = 		'10 to 19 housing units'
	Housing20to49Units_&year = 		'20 to 49 housing units'
	Housing50PlusUnits_&year = 		'50 or more housing units'
	MobileHome_&year = 			'Mobile home'
	BoatRVVan_&year = 			'Boat, RV, van, etc.'

	UnitStudio_&year = 			'Studio'
	Unit1Bed_&year = 			'1 bedroom per unit'
	Unit2Bed_&year = 			'2 bedroom per units'
	Unit3Bed_&year = 			'3 bedroom per units'
	Unit4Bed_&year = 			'4 bedroom per units'
	Unit5plusBed_&year =			'5 or more bedroom per units'

	RentLessThan10Pct_&year =		'Gross Rent Less than 10.0 percent of income'
	Rent10to15Pct_&year = 			'Gross Rent 10.0 to 14.9 percent of income'
	Rent15to20Pct_&year = 			'Gross Rent 15.0 to 19.9 percent of income'
	Rent20to25Pct_&year = 			'Gross Rent 20.0 to 24.9 percent of income'
	Rent25to30Pct_&year = 			'Gross Rent 25.0 to 29.9 percent of income'
	Rent30to35Pct_&year =			'Gross Rent 30.0 to 34.9 percent of income'
	Rent35to40Pct_&year = 			'Gross Rent 35.0 to 39.9 percent of income'
	Rent40to50Pct_&year = 			'Gross Rent 40.0 to 49.9 percent of income'
	Rent50PctPlus_&year = 			'Gross Rent 50.0 percent of income or more'
	RentNotComputed_&year = 		'Gross Rent Not computed'
		
	OwnerOccWMortgage_&year = 		'Owner-occupied housing units with a mortgage'
	OwnedLessThan10Pct_&year =		'Monthly Owner Costs Less than 10.0 percent of income' 
	Owned10to15Pct_&year = 			'Monthly Owner Costs 10.0 to 14.9 percent of income' 
	Owned15to20Pct_&year = 			'Monthly Owner Costs 15.0 to 19.9 percent of income' 
	Owned20to25Pct_&year = 			'Monthly Owner Costs 20.0 to 24.9 percent of income' 
	Owned25to30Pct_&year = 			'Monthly Owner Costs 25.0 to 29.9 percent of income' 
	Owned30to35Pct_&year =			'Monthly Owner Costs 30.0 to 34.9 percent of income' 
	Owned35to40Pct_&year = 			'Monthly Owner Costs 35.0 to 39.9 percent of income' 
	Owned40to50Pct_&year = 			'Monthly Owner Costs 40.0 to 49.9 percent of income' 
	Owned50PctPlus_&year = 			'Monthly Owner Costs 50.0 percent of income or more' 
	OwnedNotComputed_&year = 		'Monthly Owner Costs Not computed'

	LackKitchen_&year = 			'Lacks kitchen facilities'
	LackPlumbing_&year = 			'Lacks plumbing facilities'
	RentBurdened_&year =			'Cost-Burdened (Rent)'
	OwnBurdened_&year = 			'Cost-Burdened (Owned)'
	RentSevBurdened_&year =			'Severely Cost-Burdened (Rent)'
	OwnSevBurdened_&year = 			'Severely Cost-Burdened (Owned)'
	Overcrowded_&year = 			'Overcrowded (1 to 1.5 people per bedroom)' 
	SevOvercrowded_&year =			'Severely overcrowded (>1.5)';

  run;

  %Summary_geo( city, &source_geo )
  %Summary_geo( ward2012, &source_geo )
  
  proc datasets library=work nolist;
    delete &source_ds_work /memtype=data;
  quit;
  
  %macro_exit:

%mend Summary_geo_source;

/** End Macro Definition **/


**** Create summary files from block group source ****;

%Summary_geo_source( bg10 )


**** Create summary files from census tract source ****;

%Summary_geo_source( tr10 )


