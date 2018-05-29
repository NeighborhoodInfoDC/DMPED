/**************************************************************************
 Program:  Housing_needs_baseline.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/03/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Produce numbers for housing needs analysis from 2009-11 
 ACS IPUMS data.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED, local=n )
%DCData_lib( Ipums, local=n )

** Calculate average ratio of gross rent to contract rent for occupied units **;

data Ratio;

  set Ipums.ACS_2009_11_dc 
    (keep=rent rentgrs pernum gq ownershpd
     where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )));
     
  Ratio_rentgrs_rent_2009_11 = rentgrs / rent;
  
run;

proc means data=Ratio;
  var Ratio_rentgrs_rent_2009_11 rentgrs rent;
run;

%let RATIO_RENTGRS_RENT_2009_11 = 1.2690944;         %** Value copied from Proc Means output **;

data DMPED.Housing_needs_baseline;

  set Ipums.Acs_2009_11_dc 
        (keep=year serial pernum hhwt hhincome numprec bedrooms gq ownershp ownershpd rentgrs valueh
         where=(pernum=1 and gq in (1,2) and ownershpd in ( 12,13,21,22 )))
	  Ipums.Acs_2009_11_vacant_dc
	  	(keep=year serial hhwt bedrooms gq vacancy rent valueh where=(vacancy in (1,2)));

  retain Total 1;

  if ownershpd in (21, 22) or vacancy = 1 then do;
    
    ****** Rental units ******;
    
    Tenure = 1;
    
    if vacancy=1 then do;
    		** Impute gross rent for vacant units **;
  		rentgrs = rent*&RATIO_RENTGRS_RENT_2009_11;
  		Max_income = ( rentgrs * 12 ) / 0.30;
    end;
    else Max_income = ( rentgrs * 12 ) / 0.30;
    
  end;
  else if ownershpd in ( 12,13 ) or vacancy = 2 then do;

    ****** Owner units ******;
    
    Tenure = 2;

    **** 
    Calculate max income for first-time homebuyers. 
    Using 4.62% as the effective mortgage rate for DC in 2011, 
    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
    ******; 
    
    loan = .9 * valueh;
    month_mortgage= (4.62 / 12) / 100; 
    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

    ****
    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
    ******;
    
    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

    ** Calculate annual_income necessary to finance house **;
    Max_income = 12 * total_month / .28;

  end;
  
  ** Determine maximum HH size based on bedrooms **;
  
  select ( bedrooms );
    when ( 1 )       /** Efficiency **/
      Max_hh_size = 1;
    when ( 2 )       /** 1 bedroom **/
      Max_hh_size = 2;
    when ( 3 )       /** 2 bedroom **/
      Max_hh_size = 3;
    when ( 4 )       /** 3 bedroom **/
      Max_hh_size = 4;
    when ( 5 )       /** 4 bedroom **/
      Max_hh_size = 5;
    when ( 6, 7, 8, 9, 10, 11, 12 )       /** 5+ bedroom **/
      Max_hh_size = 7;
    otherwise
      do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;

  if ownershpd in ( 12,13,21,22 ) then do;
    %Hud_inc_2011( hud_inc=Hud_inc_hh )
  end;
  else do;
    Hud_inc_hh = .n;
  end;
  
  %Hud_inc_2011( hhinc=Max_income, hhsize=Max_hh_size, hud_inc=Hud_inc_unit )
  
  label
    Hud_inc_hh = 'HUD income category for household'
    Hud_inc_unit = 'HUD income category for unit';

run;

%File_info( data=DMPED.Housing_needs_baseline, freqvars=Hud_inc_hh Hud_inc_unit )

proc freq data=DMPED.Housing_needs_baseline;
  tables tenure * ownershpd * vacancy * ( Hud_inc_hh Hud_inc_unit ) / list missing;
  format ownershpd vacancy ;
run;

proc format;
  value hudinc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-50%'
    3 = '51-80%'
    4 = '81-120%'
    5 = 'Over 120%';
  value tenure
    1 = 'Renter units'
    2 = 'Owner units';
run;

ods tagsets.excelxp file="L:\Libraries\DMPED\Prog\Housing_needs_baseline.xls" style=Minimal options(sheet_interval='Page' );

proc tabulate data=DMPED.Housing_needs_baseline format=comma12.0 noseps missing;
  class hud_inc_hh hud_inc_unit Tenure;
  var Total;
  weight hhwt;
  table 
    /** Pages **/
    all='All units' Tenure=' ',
    /** Rows **/
    all='Total' hud_inc_hh=' ',
    /** Columns **/
    sum='Units' * (all='Total' hud_inc_unit='Unit affordability') * Total=' '
    / box='HH income'
  ;
  format Hud_inc_hh Hud_inc_unit hudinc. tenure tenure.;
run;

ods tagsets.excelxp close;

