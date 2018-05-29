/**************************************************************************
 Program:  Afford_unit_chg.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/20/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Calculate changes in rental housing units affordable
 by AMI levels in DC using Census/ACS microdata.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( IPUMS )


proc format;
  value bedrm
    1 - 2 = 'Studio/1 bedroom'
    3 = '2 bedroom'
    4-high = '3+ bedroom';
  value hudinc_b
    1 = 'Extremely low (0-30% AMI)'
    2 = 'Very low (31-50%)'
    3 = 'Low (51-80%)'
    4-5 = 'Middle/High (over 80%)';
  value yearx
    0 = '2000';
run;    

*****   2000   *****;

** Select nongroup quarter occupied housing units with cash rent **;

data Afford2000;

  set Ipums.Ipums_2000_dc 
        (keep=year serial pernum hhwt hhincome bedrooms gq ownershd rentgrs
         where=(pernum=1 and gq in (1,2) and ownershd in ( /*21,*/ 22 )));

  ** Calculate affordability by HUD AMI categories **;
  
  Max_income = ( rentgrs * 12 ) / 0.30;
  
  select ( bedrooms );
    when ( 1 )       /** Efficiency **/
      Max_size = 1;
    when ( 2 )       /** 1 bedroom **/
      Max_size = 2;
    when ( 3 )       /** 2 bedroom **/
      Max_size = 3;
    when ( 4 )       /** 3 bedroom **/
      Max_size = 4;
    when ( 5 )       /** 4 bedroom **/
      Max_size = 5;
    when ( 6 )       /** 5+ bedroom **/
      Max_size = 7;
    otherwise
      do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
  
  %Hud_inc_1999( hhinc=Max_income, hhsize=Max_size )

run;

%File_info( data=Afford2000, printobs=20, freqvars=bedrooms gq ownershd hud_inc )

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
  format bedrooms bedrm. hud_inc hudinc_b. year yearx.;
run;


*****   2011   *****;

** Select nongroup quarter occupied housing units with cash rent **;

data Afford2011;

  set Ipums.Acs_2011_dc 
        (keep=year serial pernum hhwt hhincome bedrooms gq ownershpd rentgrs
         where=(pernum=1 and gq in (1,2) and ownershpd in ( /*21,*/ 22 )));

  ** Calculate affordability by HUD AMI categories **;
  
  Max_income = ( rentgrs * 12 ) / 0.30;
  
  select ( bedrooms );
    when ( 1 )       /** Efficiency **/
      Max_size = 1;
    when ( 2 )       /** 1 bedroom **/
      Max_size = 2;
    when ( 3 )       /** 2 bedroom **/
      Max_size = 3;
    when ( 4 )       /** 3 bedroom **/
      Max_size = 4;
    when ( 5 )       /** 4 bedroom **/
      Max_size = 5;
    when ( 6, 7, 8, 9, 10, 11, 12 )       /** 5+ bedroom **/
      Max_size = 7;
    otherwise
      do; 
        %err_put( msg="Invalid bedroom size: " serial= bedrooms= ) 
      end;
  end;
  
  %Hud_inc_2011( hhinc=Max_income, hhsize=Max_size )

run;

%File_info( data=Afford2011, printobs=20, freqvars=bedrooms gq ownershpd hud_inc )

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
    / condense box='2011';
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc_b. year yearx.;
run;

*** Combined table ***;

data Afford2000_2011;

  set Afford2000 Afford2011;
  
  Total = 1;
  
  if year = 0 then Change = -1;
  else if year = 2011 then Change = 1;
  
  if year = 0 then Base = 1;
  else Base = 0;
  
run;


%fdate()
options nodate nonumber;

ods rtf file="L:\Libraries\DMPED\Prog\Afford_unit_chg.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Afford2000_2011 format=comma10.0 noseps missing;
  class year bedrooms hud_inc;
  var Total Change Base;
  table 
    /** Pages **/
    all='All unit sizes' bedrooms=' ',
    /** Rows **/
    all='Total' hud_inc=' ',
    /** Columns **/
    Total='Occupied\~rental\~units' * Year=' ' * sum=' '
    Change='Change' * ( sum='Units' pctsum<Base>='%'*f=comma10.1 )
    / condense box=_page_;
  weight hhwt;
  format bedrooms bedrm. hud_inc hudinc_b. year yearx.;
  title1 "Changes in number of occupied rental units by affordability level (HUD AMI), 2000 - 2011";
  title2 "Washington, DC";
  footnote1 height=9pt "Source: Census 2000 and ACS 2011 microdata (IPUMS), HUD AMI data tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt "Note: Affordability based on household paying 30% of income on unit monthly gross rent (rent + utilities).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
