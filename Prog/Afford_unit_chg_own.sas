/**************************************************************************
 Program:  Afford_unit_chg_own.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/25/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Calculate changes in occupied owned housing units 
 affordable by AMI levels in DC using Census/ACS microdata.
 
 Maximum HH size per bedrooms is based on DC HPTF standards 
 (http://dhcd.dc.gov/service/hptf-income-and-rent-limits).

 Modifications:
 09/11/14 PAT Fixed problem with different year formats in 2000.
              Added checks to output for vacant units. 
              Changed HUD income limits from 1999 to 2000. (Values
              are in contemporary dollars.)
 09/12/14 PAT Changed format for HUD income groups. 
 11/04/14 PAT Adapted for DMPED study. Show detailed income groups.
              Changed data from 2011 to 2009-11.
 11/25/14 PAT Added total for all unit sizes.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED, local=n )
%DCData_lib( OCC, local=n )
%DCData_lib( IPUMS, local=n )

** Create summary formats **;

proc format;
  value bedrm
    1 - 2 = 'Studio/1 bedroom'
    3 = '2 bedroom'
    4-high = '3+ bedroom';
  value hudinc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-50%'
    3 = '51-80%'
    4 = '81-120%'
    5 = 'Over 120%';
  value hudinc_c
    1-3 = 'Extremely/Very low/Low (0-80% AMI)'
    4 = 'Middle (81-120%)'
    5 = 'High (over 120%)';
  value yearx
    0,2000 = '2000'
    2011 = '2009-11';
  value vacancyx
    ., 0 = 'Occupied'
    2 = 'Vacant';
run;    

*****   2000   *****;

** Select nongroup quarter owner-occupied or vacant housing units for sale **;

data Afford2000;

  set Ipums.Ipums_2000_dc 
			(keep=year serial pernum hhwt hhincome bedrooms gq ownershd valueh vacancy
    		where=(pernum=1 and ownershd in (12,13) and gq in (1,2)))
		Ipums.Ipums_2000_vacant_dc
	  		(keep=year serial hhwt bedrooms gq vacancy valueh 
			where=(vacancy=2));

  /*Calculate max income for first-time homebuyers. 

  Using 7.9% as the effective mortgage rate for DC in 2000, 
  calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation; */
  loan = .9 * valueh;
  month_mortgage= (7.9 / 12) / 100; 
  monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

  /*Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment*/
  PMI = .007 * loan / 12; **typical annual PMI is .007 of loan amount;
  tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
  total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

  /*Calculate annual_income necessary to finance house*/
  Max_income = 12 * total_month / .28;
 
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
    when ( 6 ) /** 5+ bedroom **/
      Max_hh_size = 7;
    otherwise do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
  
  %Hud_inc_2000( hhinc=Max_income, hhsize=Max_hh_size )

run;

%File_info( data=Afford2000, printobs=20, freqvars=year vacancy bedrooms gq ownershd hud_inc )

proc print data=Afford2000 (obs=20);
  where vacancy = 2;
run;

proc freq data=Afford2000;
  tables vacancy * hud_inc / missing;
  weight hhwt;
run;

proc tabulate data=Afford2000 format=comma10.0 noseps missing;
  class bedrooms hud_inc;
  ** what should be used as var here? **;
  var valueh;
  table /**replace rentgrs with something**/
    /** Pages **/
    all='Total' bedrooms=' ',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    valueh * ( n sumwgt mean median min max )
    / condense box='2000';
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc. year yearx.;
run;


*****   2011   *****;

** Select nongroup quarter owner-occupied and vacant for sale housing units **;

data Afford2011;

  set Ipums.Acs_2009_11_dc 
			(keep=year serial pernum hhwt hhincome bedrooms gq ownershpd valueh vacancy 
    		where=(pernum=1 and ownershpd in (12,13) and gq in (1,2)))
	  Ipums.Acs_2009_11_vacant_dc
	  		(keep=year serial hhwt bedrooms gq vacancy valueh 
			where=(vacancy=2));

/*Calculate max income for first-time homebuyers. 

  Using 4.62% as the effective mortgage rate for DC in 2011, 
  calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation; */
  loan = .9 * valueh;
  month_mortgage= (4.62 / 12) / 100; 
  monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

  /*Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment*/
  PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
  tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
  total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

  /*Calculate annual_income necessary to finance house*/
  Max_income = 12 * total_month / .28;

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
    when ( 6, 7, 8, 9, 10, 11, 12 ) /** 5+ bedroom **/
      Max_hh_size = 7;
    otherwise
      do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
  
  %Hud_inc_2011( hhinc=Max_income, hhsize=Max_hh_size )

run;

%File_info( data=Afford2011, printobs=20, freqvars=year vacancy bedrooms gq ownershpd hud_inc )

proc print data=Afford2011 (obs=20);
  where vacancy = 2;
run;

proc freq data=Afford2011;
  tables vacancy * hud_inc / missing;
  weight hhwt;
run;

proc tabulate data=Afford2011 format=comma10.0 noseps missing;
  class bedrooms hud_inc;
  var valueh;
  table 
    /** Pages **/
    all='Total' bedrooms=' ',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    valueh * ( n sumwgt mean median min max )
    / condense box='2009-11';
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc. year yearx.;
run;

*** Combined table with both years ***;

data Afford2000_2011;

  set Afford2000 Afford2011;
  
  Total = 1;
  
  if put( year, yearx. ) = '2000' then Change = -1;
  else Change = 1;
  
  if put( year, yearx. ) = '2000' then Base = 1;
  else Base = 0;
  
run;

proc means data=Afford2000_2011 n sum mean min max;
  var total change base;
run;

%fdate()
options nodate nonumber;

ods rtf file="&_dcdata_r_path\DMPED\Prog\Afford_unit_chg_own.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Afford2000_2011 format=comma10.0 noseps missing;
  class year bedrooms hud_inc;
  var Total Change Base;
  table 
    /** Pages **/
    bedrooms=' ' all='All unit sizes',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    Total='Owner-occuped and vacant for sale units' * Year=' ' * sum=' '
    Change='Change' * ( sum='Units' pctsum<Base>='%'*f=comma10.1 )
    / condense box=_page_ rts=50;
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc. year yearx. vacancy vacancyx.;
  title1 "Numbers of owner-occupied and vacant for sale units by affordability level (HUD AMI), 2000 to 2009-11";
  title2 "Washington, DC";
  footnote1 height=9pt "Source: Census 2000 and ACS 2009-11 microdata (IPUMS), HUD AMI data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt "Note: Affordability based on household paying 28% of income on monthly mortgage payment, insurance, taxes, and utilities.";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
