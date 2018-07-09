/**************************************************************************
Program:  Affordability_sf_condo.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/28/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description: *Methodology for affordability adapted from Zhong Yi Tong paper 
http://content.knowledgeplex.org/kp2/cache/documents/22736.pdf
Homeownership Affordability in Urban America: Past and Future;
 Modifications: 
**************************************************************************/


%include "L:\SAS\Inc\StdLocal.sas";


** Define libraries **;
%DCData_lib( DMPED );
%DCData_lib( equity );
%DCData_lib( realprop );

%Sales_pars();
%Clean_sales( inds=DMPED.Sales_who_owns_SF_Condo, outds=Sales_who_owns_SF_Condo_clean) ;

proc contents data= Sales_who_owns_SF_Condo_clean; run;

data create_flags;
  set Sales_who_owns_SF_Condo_clean (where=(clean_sale=1 and (2000 <= saleyear <= 2017)));
  
  /*pull in effective interest rates - for example: 
  http://www.fhfa.gov/DataTools/Downloads/Documents/Historical-Summary-Tables/Table15_2015_by_State_and_Year.xls*/
  
    eff_int_rate_2000= 7.90;
	eff_int_rate_2001= 7.07;
	eff_int_rate_2002= 6.62;
	eff_int_rate_2003= 5.73;
	eff_int_rate_2004= 5.53;
	eff_int_rate_2005= 5.67;
	eff_int_rate_2006= 6.53;
	eff_int_rate_2007= 6.54;
	eff_int_rate_2008= 6.14;
	eff_int_rate_2009= 5.02;
    eff_int_rate_2010= 4.93;
	eff_int_rate_2011= 4.62;
	eff_int_rate_2012= 3.72;
	eff_int_rate_2013= 3.95;
	eff_int_rate_2014= 4.22;
	eff_int_rate_2015= 3.95;
	eff_int_rate_2016= 3.69;
    eff_int_rate_2017= 3.69; *2017 not available, using 2016;
	%macro yearloop ();

	%do year = 2000 %to 2017 ;

	month_int_rate_&year. = (eff_int_rate_&year./12/100);

	loan_multiplier_&year. =  month_int_rate_&year. *	( ( 1 + month_int_rate_&year. )**360	) / ( ( ( 1+ month_int_rate_&year. )**360 )-1 );

	*calculate monthly Principal and Interest for First time Homebuyer (10% down);
	if saleyear=&year. then PI_First&year.=saleprice*.9*loan_multiplier_&year.;

   *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for First Time Homebuyer (34% of PI = TI);
	if saleyear=&year. then PITI_First=PI_First&year.*1.34;

  *calculate monthly Principal and Interest for Repeat Homebuyer (20% down);
    if saleyear=&year. then PI_Repeat&year.=saleprice*.8*loan_multiplier_&year.;

   *calculate monthly PITI (Principal, Interest, Taxes and Insurance) for Repeat Homebuyer (25% of PI = TI);
	if saleyear=&year. then PITI_Repeat=PI_Repeat&year.*1.25;

	%end;

	%mend yearloop;
	%yearloop


	/*Here are numbers for Average Household Income at the city level. 2012-16 ACS 
Black	NH-White	Hispanic	AIOM	 
61923	 165970 	92543 	 	 80028		
numhshldsb_2012_16 numhshldsw_2012_16 numhshldsh_2012_16 numhshldsaiom_2012_16*/ 

	/*80%AMI and 50% AMI as the new affordability category  
2000  $82,800
2001  $85,600
2002  $91,500
2003  $84,800
2004  $85,400
2005  $89,300
2006  $90,300
2007  $94,500
2008  $99,000
2009  $102,700
2010  $103,500
2011  $106,100
2012  $107,500
2013  $107,300
2014  $107,000
2015  $109,200
2016  $108,600
2017  $110,300
	*/


	total_sales=1;

	if PITI_First in (0,.) then do;
			AMI80_first_afford = .;
			AMI50_first_afford = .;
			total_sales=0;
	end;

	else do;
		%macro calc_affordbyAMI;

		%let areamedian=82800 85600 91500 84800 85400 89300 90300 94500 99000 102700 103500 106100 107500 107300 107000 109200 108600 110300;
		%let yearlist=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017;

			%do i=1 %to 18;

			%let ami=%scan(&areamedian.,&i.," "); 
			%let yr=%scan(&yearlist.,&i.," "); 


			if saleyear =&yr. then do;

			       if PITI_First <= (&ami.*0.8 / 12*.28) then AMI80_first_afford=1; else AMI80_first_afford=0; 
			       if PITI_First <= (&ami.*0.5 / 12*.28) then AMI50_first_afford=1; else AMI50_first_afford=0;
				   if PITI_Repeat <= (&ami.*0.8 / 12*.28) then AMI80_repeat_afford=1; else AMI80_repeat_afford=0; 
			       if PITI_Repeat <= (&ami.*0.5 / 12*.28) then AMI50_repeat_afford=1; else AMI50_repeat_afford=0; 
				end; 


			%end;

		%mend calc_affordbyAMI;

		%calc_affordbyAMI;

	end;
	
run;
proc contents data=create_flags;
run;

proc print data= create_flags (obs=25);
var saleprice saleyear PITI_FIRST PITI_repeat AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford;
run;
proc freq data=create_flags; 
tables AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford; 
run;

/*Proc Summary: Affordability for Owners by 80AMI and 50AMI*/
proc sort data=create_flags;
by saleyear;
run;

proc summary data=create_flags;
	by saleyear;
	var total_sales AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford;
	output	out=City_level	sum= ;
	format city $CITY16.;
run;
proc sort data=create_flags;
by ward2012 saleyear;
run;

proc summary data=create_flags;
	by ward2012 saleyear;
	var total_sales AMI80_first_afford AMI50_first_afford AMI80_repeat_afford AMI50_repeat_afford;
	output 	out=Ward_Level 
	sum= ; 
	format ward2012 $wd12.;
run;

	data sales_afford_SF_Condo (label="DC Single Family Home Sales Affordabilty for 80%, 50% Area Median Income, 2000-17" drop=_type_ _freq_);

	set city_level ward_level; 

	PctAffordFirst_80AMI=AMI80_first_afford/total_sales*100; 
	PctAffordFirst_50AMI=AMI50_first_afford/total_sales*100; 
    PctAffordRepeat_80AMI=AMI80_repeat_afford/total_sales*100; 
	PctAffordRepeat_50AMI=AMI50_repeat_afford/total_sales*100; 

	/*add code for repeat buyer affordability*
	PctAffordRepeat_80AMI=80AMI_repeat_afford/total_sales*100; 
*/
	label PctAffordFirst_80AMI="Pct. of SF/Condo Sales 2000-17 Affordable to 80% AMI and 50% AMI"
			;
	run;

	
proc export data=sales_afford_SF_Condo
	outfile="&_dcdata_default_path\DMPED\Prog\sf_condo_tabs_aff.csv"
	dbms=csv replace;
	run;

