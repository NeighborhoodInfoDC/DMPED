/**************************************************************************
 Program:  Afford_unit_chg_rent.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/20/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Calculate changes in occupied rental housing units 
 affordable by AMI levels in DC using Census/ACS microdata.
 
 Maximum HH size per bedrooms is based on DC HPTF standards 
 (http://dhcd.dc.gov/service/hptf-income-and-rent-limits).

 Modifications:
 08/26/14 KAA Added vacant-for-rent units. 
 09/11/14 PAT Added gross rent/rent calculation.
              Fixed problem with different year formats in 2000.
              Added checks to output for vacant units. 
              Changed HUD income limits from 1999 to 2000. (Rent amounts
              are in contemporary dollars.)
 11/04/14 PAT Adapted for DMPED study. Show detailed income groups.
              Added no cash units. 
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
  value hudinc_b
    1 = 'Extremely low (0-30% AMI)'
    2 = 'Very low (31-50%)'
    3 = 'Low (51-80%)'
    4-5 = 'Middle/High (over 80%)';
  value yearx
    0,2000 = '2000'
    2011 = '2009-11';
  value vacancyx
    ., 0 = 'Occupied'
    1 = 'Vacant';
run;    

*****   2000   *****;

** Calculate average ratio of gross rent to contract rent for occupied units **;

data Ratio2000;

  set Ipums.Ipums_2000_dc 
    (keep=rent rentgrs pernum gq ownershd
     where=(pernum=1 and gq in (1,2) and ownershd in ( 22 )));
     
  Ratio_rentgrs_rent_2000 = rentgrs / rent;
  
run;

proc means data=Ratio2000;
  var Ratio_rentgrs_rent_2000 rentgrs rent;
run;

%let RATIO_RENTGRS_RENT_2000 = 1.1693651;         %** Value copied from Proc Means output **;

** Select nongroup quarter renter-occupied housing units with cash rent **;

data Afford2000;

  set Ipums.Ipums_2000_dc 
			(keep=year serial pernum hhwt hhincome bedrooms gq ownershd rentgrs vacancy rent
    		where=(pernum=1 and gq in (1,2) and ownershd in ( 21,22 )))
		Ipums.Ipums_2000_vacant_dc
	  		(keep=year serial hhwt bedrooms gq vacancy rent where=(vacancy=1));
  ** set 2000 vacant unit data, and modify vacant to add rentgrs, can't use rentgrs in maxincome statement ** 

  ** Calculate affordability by HUD AMI categories **;
  if vacancy=1 then do;
  		** Impute gross rent for vacant units **;
		rentgrs = rent * &RATIO_RENTGRS_RENT_2000;
		Max_income = ( rentgrs * 12 ) / 0.30;
  end;
  else Max_income = ( rentgrs * 12 ) / 0.30;
  
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
    otherwise do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
  
  %Hud_inc_2000( hhinc=Max_income, hhsize=Max_hh_size )

run;

%File_info( data=Afford2000, printobs=20, freqvars=year vacancy bedrooms gq ownershd hud_inc )

proc print data=Afford2000 (obs=20);
  where vacancy = 1;
run;

proc freq data=Afford2000;
  tables vacancy * hud_inc / missing;
  weight hhwt;
run;

proc tabulate data=Afford2000 format=comma10.0 noseps missing;
  class bedrooms hud_inc;
  var rentgrs;
  table 
    /** Pages **/
    all='Total' bedrooms=' ',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    rentgrs * ( n sumwgt mean median min max )
    / condense box='2000';
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc. year yearx.;
run;


*****   2011   *****;

** Calculate average ratio of gross rent to contract rent for occupied units **;

data Ratio2011;

  set Ipums.ACS_2009_11_dc 
    (keep=rent rentgrs pernum gq ownershpd
     where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )));
     
  Ratio_rentgrs_rent_2011 = rentgrs / rent;
  
run;

proc means data=Ratio2011;
  var Ratio_rentgrs_rent_2011 rentgrs rent;
run;

%let RATIO_RENTGRS_RENT_2011 = 1.2690944;         %** Value copied from Proc Means output **;

** Select nongroup quarter renter-occupied housing units with cash rent **;

data Afford2011;

  set Ipums.ACS_2009_11_dc 
        (keep=year serial pernum hhwt hhincome bedrooms gq ownershpd rentgrs
         where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )))
	  Ipums.ACS_2009_11_vacant_dc
	  	(keep=year serial hhwt bedrooms gq vacancy rent where=(vacancy=1));

  if vacancy=1 then do;
  		** Impute gross rent for vacant units **;
		rentgrs = rent*&RATIO_RENTGRS_RENT_2011;
		Max_income = ( rentgrs * 12 ) / 0.30;
  end;
  else Max_income = ( rentgrs * 12 ) / 0.30;
  
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
  
  %Hud_inc_2011( hhinc=Max_income, hhsize=Max_hh_size )

run;

%File_info( data=Afford2011, printobs=20, freqvars=year vacancy bedrooms gq ownershpd hud_inc )

proc print data=Afford2011 (obs=20);
  where vacancy = 1;
run;

proc freq data=Afford2011;
  tables vacancy * hud_inc / missing;
  weight hhwt;
run;

proc tabulate data=Afford2011 format=comma10.0 noseps missing;
  class bedrooms hud_inc;
  var rentgrs;
  table 
    /** Pages **/
    all='Total' bedrooms=' ',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    rentgrs * ( n sumwgt mean median min max )
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

ods rtf file="&_dcdata_r_path\DMPED\Prog\Afford_unit_chg_rent.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Afford2000_2011 format=comma10.0 noseps missing;
  class year bedrooms hud_inc;
  var Total Change Base;
  table 
    /** Pages **/
    bedrooms=' ' all='All unit sizes',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    Total='\~Rental\~units' * Year=' ' * sum=' '
    Change='Change' * ( sum='Units' pctsum<Base>='%'*f=comma10.1 )
    / condense box=_page_;
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc. year yearx. vacancy vacancyx.;
  title1 "Numbers of occupied and vacant rental units by affordability level (HUD AMI), 2000 to 2009-11";
  title2 "Washington, DC";
  footnote1 height=9pt "Source: Census 2000 and ACS 2009-11 microdata (IPUMS), HUD AMI data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt "Note: Affordability based on household paying 30% of income on unit monthly gross rent (rent + utilities).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
