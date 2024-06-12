/**************************************************************************
 Program:  DCHousing_needs_units_targets-Alt.sas
 Library:  DMPED
 Project:  DMPED Housing Forecast
 Author:   AK from L. Hendey
 Created:  05/22/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  

***** UPDATE OF 2019 script for NCHsg*****

 ****Housing_needs_units_targets-Alt.sas USES ACTUAL COSTS FOR OWNERS NOT COSTS FOR FIRST TIME HOMEBUYERS
	AS IN Housing_needs_units_targets.sas*** 

***aS OF 4-26-19 -CURRENT NEEDS WILL BE BASED ON THE ALT PROGRAM AND FUTURE NEEDS ON THE ORIGINAL TARGET PROGRAM***

 Produce numbers for housing needs and targets analysis from 2013-17
 ACS IPUMS data. Program outputs counts of units based on distribution of income categories
 and housing cost categories for the region and jurisdictions for 3 scenarios:

 a) actual distribution of units by income category and unit cost category
 b) desired (ideal) distribution of units by income category and unit cost category in which
	all housing needs are met and no households have cost burden.
 c) halfway - distribution of units by income category and unit cost category in which
	cost burden rates are cut in half for households below 120% of AMI as a more pausible 
	set of targets for the future. 

 Modifications: 02-12-19 LH Adjust weights using Calibration from Steven's projections 
						 	so that occupied units match COG 2015 HH estimation.
                02-17-19 LH Readjust weights after changes to calibration to move 2 HH w/ GQ=5 out of head of HH
				03-30-19 LH Remove hard coding and merge in contract rent to gross rent ratio for vacant units. 
				04-23-19 LH Test using actual costs for current gap (renters and owners). 
				05-02-19 LH Add couldpaymore flag
                01/20    YS update for NC housing 
				05/24 	 AK update for DC
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( Ipums )

%let date=05312024Alt; 

proc format;

  value hud_inc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-50%'
    3 = '51-80%'
    4 = '81-120%'
    5 = '120-200%'
    6 = 'More than 200%'
	;

  value rcost
	  1= "$0 to $349"
	  2= "$350 to $699"
	  3= "$700 to $999"
	  4= "$1,000 to $1,499"
	  5= "$1,500 to $2,499"
	  6= "More than $2,500"
  ;

  value ocost
	  1= "$0 to $349"
	  2= "$350 to $699"
	  3= "$700 to $999"
	  4= "$1,000 to $1,499"
	  5= "$1,500 to $2,499"
	  6= "More than $2,500"
  ;

  value acost
	  1= "$0 to $349"
	  2= "$350 to $699"
	  3= "$700 to $999"
	  4= "$1,000 to $1,499"
	  5= "$1,500 to $2,499"
	  6= "More than $2,500"
   ;

  value inc_cat

    1 = '20 percentile'
    2 = '40 percentile'
    3 = '60 percentile'
	4 = '80 percentile'
	5= '100 percentile'
    6= 'vacant'
	;

	value structure
	1= 'Single family attached and detached'
	2= '2-9 units in strucutre'
	3= '10+ units in strucutre'
	4= 'Mobile or other'
	5= 'NA'
	;
  	  
	 /* value afford

 1= 'natural affordable (rent < $750)'
  0= 'not natural affordable'; */
run;


%macro single_year(year);

	DATA DCvacant_&year. ;
		SET Ipums.Acs_2018_22_vacant_DC ;
		WHERE MULTYEAR = &year.;
	RUN;

	DATA DCarea_&year.;
		SET Ipums.Acs_2018_22_dc;
		WHERE MULTYEAR = &year.;
	RUN;

	PROC SORT DATA = DCvacant_&year.;
		BY upuma;
	RUN;

	PROC SORT DATA = DCarea_&year.;
		BY upuma;
	RUN;

/** NOTE: This is where we'll merge in PUMA crosswalk once we resolve that**/

 %**create ratio for rent to rentgrs to adjust rents on vacant units**;
	DATA Ratio_&year.;

		  SET DCarea_&year.
		    (keep= rent rentgrs pernum gq ownershpd upuma
		     where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )));
		     
		  Ratio_rentgrs_rent_&year. = rentgrs / rent;
	run;

		proc means data=Ratio_&year.;
		  var  Ratio_rentgrs_rent_&year. rentgrs rent;
		  output out=Ratio_&year (keep=Ratio_rentgrs_rent_&year.) mean=;
		run;

data Housing_needs_baseline_&year._1;

  set DCarea_&year.
        (keep=year serial pernum MET2013 hhwt hhincome numprec UNITSSTR BUILTYR2 bedrooms gq ownershp owncost ownershpd rentgrs valueh
         where=(pernum=1 and gq in (1,2) and ownershpd in ( 12,13,21,22 )));


	  *adjust all incomes to 2022 $ to match use of 2022 family of 4 income limit in projections (originally based on use of most recent 5-year IPUMS; 
		
	  if hhincome ~=.n or hhincome ~=9999999 then do; 
		 %dollar_convert( hhincome, hhincome_a, &year., 2022, series=CUUR0000SA0 )
	   end; 

	*create HUD_inc - uses 2022 limits but has categories for 120-200% and 200%+ AMI; 
	 %Hud_inc_2022_dmped( hhinc=hhincome, hhsize=numprec ); 
	 

  ** HUD income categories (<year>) **;
/* NOTE Commenting out code from macro, used to run test, until macro added to sas1, using the code here instead. Remove later
	  
  if (hhincome) in ( 9999999, .n ) then hud_inc = .n;
  else do;

      select ( numprec );
      when ( 1 )
        do;
          if hhincome <= 29900 then hud_inc = 1;
          else if 29900 < hhincome <= 49850 then hud_inc = 2;
          else if 49850 < hhincome <= 63000 then hud_inc = 3;
          else if 63000 < hhincome <= 119640 then hud_inc = 4;
          else if 119640 < hhincome <= 2*(49850/0.5)then hud_inc = 5;
		  else if 2*(49850/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 2 )
        do;
          if hhincome <= 34200 then hud_inc = 1;
          else if 34200 < hhincome <= 56950 then hud_inc = 2;
          else if 56950 < hhincome <= 72000 then hud_inc = 3;
          else if 72000 < hhincome <= 136680 then hud_inc = 4;
          else if 136680 < hhincome <= 2*(56950/0.5) then hud_inc = 5;
		  else if 2*(56950/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 3 )
        do;
          if hhincome <= 38450 then hud_inc = 1;
          else if 38450 < hhincome <= 64050 then hud_inc = 2;
          else if 64050 < hhincome <= 81000 then hud_inc = 3;
          else if 81000 < hhincome <= 153720 then hud_inc = 4;
          else if 153720 < hhincome <= 2*(64050/0.5) then hud_inc = 5;
		  else if 2*(64050/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 4 )
        do;
          if hhincome <= 42700 then hud_inc = 1;
          else if 42700 < hhincome <= 71150 then hud_inc = 2;
          else if 71150 < hhincome <= 90000 then hud_inc = 3;
          else if 90000 < hhincome <= 170760 then hud_inc = 4;
          else if 170760 < hhincome <= 2*(71150/0.5) then hud_inc = 5;
		  else if 2*(71150/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 5 )
        do;
          if hhincome <= 46150 then hud_inc = 1;
          else if 46150 < hhincome <= 76850 then hud_inc = 2;
          else if 76850 < hhincome <= 97200 then hud_inc = 3;
          else if 97200 < hhincome <= 184440 then hud_inc = 4;
          else if 184440 < hhincome <= 2*(76850/0.5) then hud_inc = 5;
		  else if 2*(76850/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 6 )
        do;
          if hhincome <= 49550 then hud_inc = 1;
          else if 49550 < hhincome <= 82550 then hud_inc = 2;
          else if 82550 < hhincome <= 104400 then hud_inc = 3;
          else if 104400 < hhincome <= 198120 then hud_inc = 4;
          else if 198120 < hhincome <= 2*(82550/0.5) then hud_inc = 5;
		  else if 2*(82550/0.5) < hhincome then hud_inc = 6;
        end;
      when ( 7 )
        do;
          if hhincome <= 52950 then hud_inc = 1;
          else if 52950 < hhincome <= 88250 then hud_inc = 2;
          else if 88250 < hhincome <= 111600 then hud_inc = 3;
          else if 111600 < hhincome <= 211800 then hud_inc = 4;
          else if 211800 < hhincome <= 2*(88250/0.5) then hud_inc = 5;
		  else if 2*(88250/0.5) < hhincome then hud_inc = 6; 
        end;
      otherwise
        do;
          if hhincome <= 56400 then hud_inc = 1;
          else if 56400 < hhincome <= 93950 then hud_inc = 2;
          else if 93950 < hhincome <= 118800 then hud_inc = 3;
          else if 118800 < hhincome <= 225480 then hud_inc = 4;
          else if 225480 < hhincome <= 2*(93950/0.5) then hud_inc = 5;
		  else if 2*(93950/0.5) < hhincome then hud_inc = 6; 
        end;
    end;

    end;

  label Hud_inc = "HUD income categories";
 
*/
label hud_inc = 'HUD Income Limits category for household (2022)';

run; 

data Housing_needs_baseline_2022_2;
  set Housing_needs_baseline_2022_1;

	 *adjust housing costs for inflation; 

	  %dollar_convert( rentgrs, rentgrs_a, 2022, 2022, series=CUUR0000SA0L2 )
	  %dollar_convert( owncost, owncost_a, 2022, 2022, series=CUUR0000SA0L2 )
	  %dollar_convert( valueh, valueh_a, 2022, 2022, series=CUUR0000SA0L2 )

  	** Cost-burden flag & create cost ratio **;
	    if ownershpd in (21, 22)  then do;

			if hhincome_a > 0 then Costratio= (rentgrs_a*12)/hhincome_a;
			  else if hhincome_a = 0 and rentgrs_a > 0 then costratio=1;
			  else if hhincome_a =0 and rentgrs_a = 0 then costratio=0; 
			  else if hhincome_a < 0 and rentgrs_a >= 0 then costratio=1; 
			  			  
		end;

	    else if ownershpd in ( 12,13 ) then do;
			if hhincome_a > 0 then Costratio= (owncost_a*12)/hhincome_a;
			  else if hhincome_a = 0 and owncost_a > 0 then costratio=1;
			  else if hhincome_a =0 and owncost_a = 0 then costratio=0; 
			  else if hhincome_a < 0 and owncost_a >= 0 then costratio=1; 
		end;
	    
			if Costratio >= 0.3 then costburden=1;
		    else if HHIncome_a~=. then costburden=0;
			if costratio >= 0.5 then severeburden=1;
			else if HHIncome_a~=. then severeburden=0; 

		tothh = 1;
 	
*run;  

/** for test run
%mend single_year; 

%single_year(2022);


 PROC MEANS Data= Housing_needs_baseline_2022_2;
	VAR costratio;
	CLASS hud_inc;
	RUN;


PROC UNIVARIATE Data= Housing_needs_baseline_2022_2;
	WHERE ownershpd in (21,22);
	VAR rentgrs_a;
	RUN;  

PROC MEANS Data= Housing_needs_baseline_2022_2 MEAN MIN Q1 MEDIAN Q3 MAX;
	WHERE ownershpd in (21,22);
	VAR rentgrs_a ;
	CLASS hud_inc costburden;
	RUN;

**/
		
    ****** Rental units ******;
    
   if ownershpd in (21, 22) then do;
        
    Tenure = 1;

	 *create maximum desired or affordable rent based on HUD_Inc categories*; 
		*NOTE: where do the decimals come from (other than 30)? do we develop these? NEED to update?;
	
	  if hud_inc in(1 2 3) then max_rent=HHINCOME_a/12*.3; *under 80% of AMI then pay 30% threshold; 
	  if hud_inc =4 then max_rent=HHINCOME_a/12*.261; *avg for all HH hud_inc=4 in DC 2022; 
	  if costratio <=.157 and hud_inc = 5 then max_rent=HHINCOME_a/12*.157; *avg for all HH hud_inc=5 in DC; 	
		else if hud_inc = 5 then max_rent=HHINCOME_a/12*costratio; *allow 120-200% above average to spend more; 
	  if costratio <=.121 and hud_inc = 6 then max_rent=HHINCOME_a/12*.121; *avg for all HH hud_inc=6 in NC; 
	  	else if hud_inc=6 then max_rent=HHINCOME_a/12*costratio; *allow 200%+ above average to spend more;  
     
	 *create flag for household could "afford" to pay more; 
		couldpaymore=.;

		if max_rent ~= . then do; 
			if max_rent > rentgrs_a*1.1 then couldpaymore=1; 
			else if max_rent <= rentgrs_a*1.1 then couldpaymore=0; 
		end; 

		/* NOTE: Updated using DC 2022 HUD incomes for families, between 2 -3 HH size. 
		Avg HH size in DC = 2.47*/
    	*rent cost categories that make more sense for rents - no longer used in targets;
			rentlevel=.;
			if 0 <=rentgrs_a<900 then rentlevel=1; *900 is between 30% monthly income for HH2 (855) and HH3 (961) extremely low income;
            if 900 <=rentgrs_a<1500 then rentlevel=2; *1500 is between 30% monthly income for HH2 (1424) and HH3 (1600) with very low income; 
            if 1500 <=rentgrs_a<1900 then rentlevel=3; *1900 is between 30% monthly income HH2 (1800) and HH3 (2025)with low incomes;
            if 1900 <=rentgrs_a<2400 then rentlevel=4;
            if 2400 <=rentgrs_a<2800 then rentlevel=5;
            if rentgrs_a >= 2800 then rentlevel=6;


			mrentlevel=.;
			if max_rent<900 then mrentlevel=1;
			if 900 <=max_rent<1500 then mrentlevel=2;
			if 1500 <=max_rent<1900 then mrentlevel=3;
			if 1900 <=max_rent<2400 then mrentlevel=4;
			if 2400 <=max_rent<2800 then mrentlevel=5;
			if max_rent >= 2800 then mrentlevel=6;

		 *rent cost categories now used in targets that provide a set of categories useable for renters and owners combined; 
			
			allcostlevel=.;
			if rentgrs_a<900 then allcostlevel=1;
            if 900 <=rentgrs_a<1500 then allcostlevel=2;
            if 1500 <=rentgrs_a<1900 then allcostlevel=3;
            if 1900 <=rentgrs_a<2800 then allcostlevel=4;
            if 2800 <=rentgrs_a<3600 then allcostlevel=5;
            if rentgrs_a >= 3600 then allcostlevel=6;


			mallcostlevel=.;

			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;

			if costburden=1 then do; 

			if max_rent<900 then mallcostlevel=1;
            if 900 <=max_rent<1500 then mallcostlevel=2;
            if 1500 <=max_rent<1900 then mallcostlevel=3;
            if 1900 <=max_rent<2800 then mallcostlevel=4;
            if 2800 <=max_rent<3600 then mallcostlevel=5;
            if max_rent >= 3600 then mallcostlevel=6;



			end; 

			else if costburden=0 then do;

				if rentgrs_a<900 then mallcostlevel=1;
                if 900 <=rentgrs_a<1500 then mallcostlevel=2;
                if 1500 <=rentgrs_a<1900 then mallcostlevel=3;
                if 1900 <=rentgrs_a<2800 then mallcostlevel=4;
                if 2800 <=rentgrs_a<3600 then mallcostlevel=5;
                if rentgrs_a >= 3600 then mallcostlevel=6;


			end; 




	end;

	
	  		
		
  	else if ownershpd in ( 12,13 ) then do;

	    ****** Owner units ******;
	    
	    Tenure = 2;

		*create maximum desired or affordable owner costs based on HUD_Inc categories*; 

		/*NOTE: NEED to update these*/
		if hud_inc in(1 2 3) then max_ocost=HHINCOME_a/12*.3; *under 80% of AMI then pay 30% threshold; 
		if hud_inc =4 then max_ocost=HHINCOME_a/12*.261; *avg for all HH hud_inc=4in DC;
		if costratio <=.157 and hud_inc = 5 then max_ocost=HHINCOME_a/12*.157; *avg for all HH HUD_inc=5; 
			else if hud_inc = 5 then max_ocost=HHINCOME_a/12*costratio; *allow 120-200% above average to pay more; 
		if costratio <=.121 and hud_inc=6 then max_ocost=HHINCOME_a/12*.121; *avg for all HH HUD_inc=6;
			else if hud_inc = 6 then max_ocost=HHINCOME_a/12*costratio; *allow 120-200% above average to pay more; 
		
		*create flag for household could "afford" to pay more; 
		couldpaymore=.;

		if max_ocost ~= . then do; 
			if max_ocost > owncost_a*1.1 then couldpaymore=1; 
			else if max_ocost <= owncost_a*1.1 then couldpaymore=0; 
		end; 

	    **** 
	    Calculate monthly payment for first-time homebuyers. 
	    Using 5.5% as the effective mortgage rate for DC in 2022 (pulled from overall US Freddie Mac), 
	    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
	    ******; 
	    
	    loan = .9 * valueh_a;
	    month_mortgage= (5.5 / 12) / 100; 
	    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

	    ****
	    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
	    ******;
	    
	    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
	    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
	    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

		
	
		*owner cost categories that make more sense for owner costs - no longer used in targets;
       /*NOTE: need to update for DC 2022*/
			ownlevel=.;
			if 0 <=total_month<1500 then ownlevel=1;
            if 1500 <=total_month<2200 then ownlevel=2;
            if 2200 <=total_month<2800 then ownlevel=3;
            if 2800 <=total_month<3500 then ownlevel=4;
            if 3500 <=total_month<4500 then ownlevel=5;
            if total_month >= 4500 then ownlevel=6;


		mownlevel=.;
			if 0 <=max_ocost<1500 then ownlevel=1;
            if 1500 <=max_ocost<2200 then ownlevel=2;
            if 2200 <=max_ocost<2800 then ownlevel=3;
            if 2800 <=max_ocost<3500 then ownlevel=4;
            if 3500 <=max_ocost<4500 then ownlevel=5;
            if max_ocost >= 4500 then ownlevel=6;



		 *owner cost categories now used in targets that provide a set of categories useable for renters and owners combined; 
			allcostlevel=.;
			if owncost_a<900 then allcostlevel=1;
			if 900 <=owncost_a<1500 then allcostlevel=2;
			if 1500 <=owncost_a<1900 then allcostlevel=3;
			if 1900 <=owncost_a<2800 then allcostlevel=4;
			if 2800 <=owncost_a<3600 then allcostlevel=5;
			if owncost_a >= 3600 then allcostlevel=6; 


	
			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;
			mallcostlevel=.;

			if costburden=1 then do; 

			if max_ocost<900 then mallcostlevel=1;
				if 900 <=max_ocost<1500 then mallcostlevel=2;
				if 1500 <=max_ocost<1900 then mallcostlevel=3;
				if 1900 <=max_ocost<2800 then mallcostlevel=4;
				if 2800 <=max_ocost<3600 then mallcostlevel=5;
				if max_ocost >= 3600 then mallcostlevel=6;
				end;

			else if costburden=0 then do; 

				if owncost_a<900 then mallcostlevel=1;
				if 900 <=owncost_a<1500 then mallcostlevel=2;
				if 1500 <=owncost_a<1900 then mallcostlevel=3;
				if 1900 <=owncost_a<2800 then mallcostlevel=4;
				if 2800 <=owncost_a<3600 then mallcostlevel=5;
				if owncost_a >= 3600 then mallcostlevel=6;

			end; 
  end;

  *add structure of housing variable;
    if UNITSSTR =00 then structure=5;
	if UNITSSTR in (01, 02) then structure=4;
	if UNITSSTR in (03, 04) then structure=1;
	if UNITSSTR in (05, 06, 07) then structure=2;
	if UNITSSTR in (08, 09, 10) then structure=3;

  		*costburden and couldpaymore do not overlap. create a category that measures who needs to pay less, 
		who pays the right amount, and who could pay more;
		paycategory=.;
		if costburden=1 then paycategory=1;
		if costburden=0 and couldpaymore=0 then paycategory=2;
		if couldpaymore=1 then paycategory=3; 

		if BUILTYR2 in ( 00, 9999999, .n , . ) then structureyear=.;
		else do; 
		    if BUILTYR2  in (07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22) then structureyear=1;
			else if BUILTYR2  in (04, 05, 06) then structureyear=2;
            else if BUILTYR2 in (01, 02, 03)  then structureyear=3;
		end;

		
/*	if rentgrs in ( 9999999, .n , . ) then affordable=.;
		else do; 
		    if rentgrs_a<750 then affordable=1;
			else if rentgrs_a>=750 then affordable=0;
			
		end; */

	 /* label affordable = 'Natural affordable rental unit';*/

	total=1;


			label rentlevel = 'Rent Level Categories based on Current Gross Rent'
		 		  mrentlevel='Rent Level Categories based on Max affordable-desired rent'
				  allcostlevel='Housing Cost Categories (tenure combined) based on Current Rent or Current Owner Costs'
				  mallcostlevel='Housing Cost Categories (tenure combined) based on Max affordable-desired Rent-Owner Cost'
				  ownlevel = 'Owner Cost Categories based on First-Time HomeBuyer Costs'
				  mownlevel = 'Owner Cost Categories based on Max affordable-desired First-Time HomeBuyer Costs'
				  couldpaymore = "Occupant Could Afford to Pay More - Costs+10% are > Max affordable cost"
				  paycategory = "Whether Occupant pays too much, the right amount or too little" 
                  structure = 'Housing structure type'
				  structureyear = 'Age of structure'
				;

	
format mownlevel ownlevel ocost. rentlevel mrentlevel rcost. allcostlevel mallcostlevel acost. hud_inc hud_inc. structure structure.; 
run;

data Housing_needs_vacant_&year. Other_vacant_&year. ;

  set DCvacant_&year.(keep=year serial hhwt bedrooms gq vacancy rent valueh upuma BUILTYR2 UNITSSTR);

  	if _n_ = 1 then set Ratio_&year.;

 	retain Total 1;

  *reassign vacant but rented or sold based on whether rent or value is available; 	
  vacancy_r=vacancy; 
  if vacancy=3 and rent ~= .n then vacancy_r=1; 
  if vacancy=3 and valueh ~= .u then vacancy_r=2; 
    
    ****** Rental units ******;
	 if  vacancy_r = 1 then do;
	    Tenure = 1;
	    
	    	** Impute gross rent for vacant units **;
	  		rentgrs = rent*Ratio_rentgrs_rent_&year.;

			  %dollar_convert( rentgrs, rentgrs_a, &year., 2022, series=CUUR0000SA0L2 )

		/* if rent in ( 9999999, .n , . ) then affordable_vacant=.;
		else do; 
		    if rentgrs_a<700 then affordable_vacant=1;
			else if rentgrs_a>=700 then affordable_vacant=0;

		end; */

	*  label affordable_vacant = 'Natural affordable vacant rental unit';

		/*create rent level categories*/ 
			
		rentlevel=.;
		if 0 <=rentgrs_a<900 then rentlevel=1; *900 is between 30% monthly income for HH2 (855) and HH3 (961) extremely low income;
         if 900 <=rentgrs_a<1500 then rentlevel=2; *1500 is between 30% monthly income for HH2 (1424) and HH3 (1600) with very low income; 
         if 1500 <=rentgrs_a<1900 then rentlevel=3; *1900 is between 30% monthly income HH2 (1800) and HH3 (2025)with low incomes;
         if 1900 <=rentgrs_a<2400 then rentlevel=4;
         if 2400 <=rentgrs_a<2800 then rentlevel=5;
         if rentgrs_a >= 2800 then rentlevel=6;


		/*create  categories now used in targets for renter/owner costs combined*/ 
				allcostlevel=.;
				if rentgrs_a<900 then allcostlevel=1;
	            if 900 <=rentgrs_a<1500 then allcostlevel=2;
	            if 1500 <=rentgrs_a<1900 then allcostlevel=3;
	            if 1900 <=rentgrs_a<2800 then allcostlevel=4;
	            if 2800 <=rentgrs_a<3600 then allcostlevel=5;
	            if rentgrs_a >= 3600 then allcostlevel=6;
	;
	  end;


	  else if vacancy_r = 2 then do;

	    ****** Owner units ******;
	    
	    Tenure = 2;

	    **** 
	    Calculate  monthly payment for first-time homebuyers. 
	    Using 5.5% as the effective mortgage rate for DC in 2022, 
	    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
	    ******; 
	    %dollar_convert( valueh, valueh_a, &year., 2022, series=CUUR0000SA0L2 )
	    loan = .9 * valueh_a;
	    month_mortgage= (5.5 / 12) / 100; 
	    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

	    ****
	    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
	    ******;
	    
	    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
	    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
	    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;
		
			/*create owner cost level categories*/ 
			ownlevel=.;
				if 0 <=total_month<1500 then ownlevel=1;
	            if 1500 <=total_month<2200 then ownlevel=2;
	            if 2200 <=total_month<2800 then ownlevel=3;
	            if 2800 <=total_month<3500 then ownlevel=4;
	            if 3500 <=total_month<4500 then ownlevel=5;
	            if total_month >= 4500 then ownlevel=6;

			
			/*create  categories now used in targets for renter/owner costs combined*/ 
				allcostlevel=.;
				if total_month<900 then allcostlevel=1;
				if 900 <=total_month<1500 then allcostlevel=2;
				if 1500 <=total_month<1900 then allcostlevel=3;
				if 1900 <=total_month<2800 then allcostlevel=4;
				if 2800 <=total_month<3600 then allcostlevel=5;
				if total_month >= 3600 then allcostlevel=6; 

	  end;


	  paycategory=4; *add vacant as a category to paycategory; 

		if BUILTYR2 in ( 00, 9999999, .n , . ) then structureyear=.;
		else do; 
		    if BUILTYR2  in (07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22) then structureyear=1;
			else if BUILTYR2  in (04, 05, 06) then structureyear=2;
            else if BUILTYR2 in (01, 02, 03)  then structureyear=3;
		end;

		
  *add structure of housing variable;
    if UNITSSTR =00 then structure=5;
	if UNITSSTR in (01, 02) then structure=4;
	if UNITSSTR in (03, 04) then structure=1;
	if UNITSSTR in (05, 06, 07) then structure=2;
	if UNITSSTR in (08, 09, 10) then structure=3;

		label rentlevel = 'Rent Level Categories based on Current Gross Rent'
		 		  allcostlevel='Housing Cost Categories (tenure combined) based on Current Rent or First-time Buyer Mtg'
				  ownlevel = 'Owner Cost Categories based on First-Time HomeBuyer Costs'
				  paycategory = "Whether Occupant pays too much, the right amount or too little" 
				  structureyear = 'Age of structure'
				  structure = 'Housing structure type'
				;
	format ownlevel ocost. rentlevel rcost. vacancy_r VACANCY_F. allcostlevel acost. ; 

	*output other vacant - seasonal separately ;
	if vacancy in (1, 2, 3) then output Housing_needs_vacant_&year.;
	else if vacancy in (4, 7, 9) then output other_vacant_&year.; 
	run;

%mend single_year; 

%single_year(2018);
%single_year(2019);
%single_year(2020); 
%single_year(2021);
%single_year(2022);


/* We are really just interested in the 2022 file (filtered by MULTYEAR), which has the new PUMA designations. 





/* pulling in Steven's files for HH projections */
data projectedHH;
set DMPED.projection_for_calibration;
upuma= puma;
run;

data fiveyeartotal1;
set Housing_needs_baseline_2013_3 Housing_needs_baseline_2014_3 Housing_needs_baseline_2015_3 Housing_needs_baseline_2016_3 Housing_needs_baseline_2017_3;
totalpop=0.2;
merge=1;

geoid=.;
if county2_char= "0100" then geoid=1;
else if  county2_char= "0200" then geoid=2;
else if  county2_char= "0300" then geoid=3;
else if  county2_char= "0400" then geoid=4;
else if  county2_char= "0500 or 0600" then geoid=5;
else if  county2_char= "0700" then geoid=6;
else if  county2_char= "0800" then geoid=7;
else if  county2_char= "0900" then geoid=8;
else if  county2_char= "1000" then geoid=9;
else if  county2_char= "1100" then geoid=10;
else if  county2_char= "1201 to 1208" then geoid=11;
else if  county2_char= "1301 to 1302" then geoid=12;
else if  county2_char= "1400" then geoid=13;
else if  county2_char= "1500" then geoid=14;
else if  county2_char= "1600" then geoid=15;
else if  county2_char= "1701 to 1704" then geoid=16;
else if  county2_char= "1801 to 1803" then geoid=17;
else if  county2_char= "1900 or 2900" then geoid=18;
else if  county2_char= "2000" then geoid=19;
else if  county2_char= "2100" then geoid=20;
else if  county2_char= "2201 to 2202" then geoid=21;
else if  county2_char= "2300 or 2400" then geoid=22;
else if  county2_char= "2500" then geoid=23;
else if  county2_char= "2600 or 2700" then geoid=24;
else if  county2_char= "2800" then geoid=25;
else if  county2_char= "3001 to 3003" then geoid=26;
else if  county2_char= "3101 to 3108" then geoid=27;
else if  county2_char= "3200 or 3300" then geoid=28;
else if  county2_char= "3400" then geoid=29;
else if  county2_char= "3500" then geoid=30;
else if  county2_char= "3600" then geoid=31;
else if  county2_char= "3700" then geoid=32;
else if  county2_char= "3800" then geoid=33;
else if  county2_char= "3900" then geoid=34;
else if  county2_char= "4000" then geoid=35;
else if  county2_char= "4100 or 4500" then geoid=36;
else if  county2_char= "4200" then geoid=37;
else if  county2_char= "4300" then geoid=38;
else if  county2_char= "4400" then geoid=39;
else if  county2_char= "4600 or 4700" then geoid=40;
else if  county2_char= "4800" then geoid=41;
else if  county2_char= "4900 or 5100" then geoid=42;
else if  county2_char= "5001 to 5003" then geoid=43;
else if  county2_char= "5200" then geoid=44;
else if  county2_char= "5300 or 5400" then geoid=45;

if hhincome_a in ( 9999999, .n ) then inc = .n;
  else do;
 /*hard code income categories to match the projections, since the calibrated distributino might be slightly different than the original one*/
		if hhincome_a < 20728.563641 then inc=1;
		if 20728.563641  =< hhincome_a < 39142.262306 then inc=2;
		if 39142.262306  =< hhincome_a < 62051.245269 then inc=3;
		if 62051.245269  =< hhincome_a < 100000 then inc=4;
		if 100000  =< hhincome_a =< 1570000 then inc=5;
  end;

    label /*hud_inc = 'HUD Income Limits category for household (2016)'*/
	    inc='Income quintiles statewide not account for HH size';
		format inc inc_cat.; 

run;

/*calculate average cost ratio for each hud_inc group that is used for maximum desired or affordable rent/owncost*/
proc sort data= fiveyeartotal1;
by hud_inc /*tenure*/;
run;

proc summary data= fiveyeartotal1;
by hud_inc /*tenure*/;
var costratio HHincome_a;
weight hhwt; 
output out= costratio_hudinc mean=;
run;

proc summary data= fiveyeartotal1;
by hud_inc /*tenure*/;
var HHincome_a owncost_a rentgrs_a;
weight hhwt; 
output out= incomecategories mean=;
run;

/*calibrate ipums to 2015 population projection*/ 
proc sort data= fiveyeartotal1;
by geoid;
run;
proc summary data=fiveyeartotal1;
by geoid;
var totalpop;
weight hhwt;
output out=geo_sum sum=ACS_13_17;
run; 
proc sort data= projectedHH;
by geoid;
run;

data calculate_calibration;
merge geo_sum(in=a) projectedHH;
by geoid;
if a;
calibration=(hh2015/ACS_13_17);
run;

data fiveyeartotal_c;
merge fiveyeartotal1 calculate_calibration;
by geoid;

hhwt_geo=.; 

hhwt_geo=hhwt*calibration*0.2; 
hhwt_ori= hhwt*0.2;

label hhwt_geo="Household Weight Calibrated to Steven Estimates for Households"
	  calibration="Ratio of Steven 2015 estimate to ACS 2013-17 for 45 geographic units"
	  hhwt_ori="Original Household Weight";

run; 

/*merge on county/puma categories*/
data categories;
	set NCHsg.Puma_categories_121;
run;

data fiveyeartotal;
	set fiveyeartotal_c (drop= County) ;
	by county2_char;
	retain group 0;
	if first.county2_char then group=group+1;
run;
data fiveyeartotal_cat;
	merge fiveyeartotal(in=a) categories;
	if a;
	by group ;

	label category="County/PUMA Group Designation";
run;

/*export dataset*/
 data NCHsg.fiveyeartotal_alt(label= "NC households 13-17 pooled alternative file"); 
   set fiveyeartotal_cat;
 run;

 proc contents data= NCHsg.fiveyeartotal_alt;
 run;

proc tabulate data=NCHsg.fiveyeartotal_alt format=comma12. noseps missing;
  class county2_char;
  var hhwt_ori hhwt_geo;
  table
    all='Total' county2_char=' ',
    sum='Sum of HHWTs' * ( hhwt_geo='Adjusted to 2015 estimates' hhwt_ori= 'Original 5-year'  )
  / box='Occupied housing units';
  *format county2_char county2_char.;
run;

data fiveyeartotal_vacant;
	set Housing_needs_vacant_2013 Housing_needs_vacant_2014 Housing_needs_vacant_2015 Housing_needs_vacant_2016 Housing_needs_vacant_2017;
totalpop=0.2;
merge=1;
 
geoid=.;
if county2_char= "0100" then geoid=1;
else if  county2_char= "0200" then geoid=2;
else if  county2_char= "0300" then geoid=3;
else if  county2_char= "0400" then geoid=4;
else if  county2_char= "0500 or 0600" then geoid=5;
else if  county2_char= "0700" then geoid=6;
else if  county2_char= "0800" then geoid=7;
else if  county2_char= "0900" then geoid=8;
else if  county2_char= "1000" then geoid=9;
else if  county2_char= "1100" then geoid=10;
else if  county2_char= "1201 to 1208" then geoid=11;
else if  county2_char= "1301 to 1302" then geoid=12;
else if  county2_char= "1400" then geoid=13;
else if  county2_char= "1500" then geoid=14;
else if  county2_char= "1600" then geoid=15;
else if  county2_char= "1701 to 1704" then geoid=16;
else if  county2_char= "1801 to 1803" then geoid=17;
else if  county2_char= "1900 or 2900" then geoid=18;
else if  county2_char= "2000" then geoid=19;
else if  county2_char= "2100" then geoid=20;
else if  county2_char= "2201 to 2202" then geoid=21;
else if  county2_char= "2300 or 2400" then geoid=22;
else if  county2_char= "2500" then geoid=23;
else if  county2_char= "2600 or 2700" then geoid=24;
else if  county2_char= "2800" then geoid=25;
else if  county2_char= "3001 to 3003" then geoid=26;
else if  county2_char= "3101 to 3108" then geoid=27;
else if  county2_char= "3200 or 3300" then geoid=28;
else if  county2_char= "3400" then geoid=29;
else if  county2_char= "3500" then geoid=30;
else if  county2_char= "3600" then geoid=31;
else if  county2_char= "3700" then geoid=32;
else if  county2_char= "3800" then geoid=33;
else if  county2_char= "3900" then geoid=34;
else if  county2_char= "4000" then geoid=35;
else if  county2_char= "4100 or 4500" then geoid=36;
else if  county2_char= "4200" then geoid=37;
else if  county2_char= "4300" then geoid=38;
else if  county2_char= "4400" then geoid=39;
else if  county2_char= "4600 or 4700" then geoid=40;
else if  county2_char= "4800" then geoid=41;
else if  county2_char= "4900 or 5100" then geoid=42;
else if  county2_char= "5001 to 5003" then geoid=43;
else if  county2_char= "5200" then geoid=44;
else if  county2_char= "5300 or 5400" then geoid=45;
run;

proc sort data=fiveyeartotal_vacant;
by geoid;
run;

data fiveyeartotal_vacant_c;
merge fiveyeartotal_vacant calculate_calibration;
by geoid;

hhwt_geo=.; 

hhwt_geo=hhwt*calibration*0.2; 
hhwt_ori= hhwt*0.2;
label hhwt_geo="Household Weight Calibrated to Steven Estimates for Households"
	  calibration="Ratio of Steven 2015 estimate to ACS 2013-17 for 45 geographic units"
	  	  hhwt_ori="Original Household Weight";

run; 

 data fiveyeartotal_vacant_C2; 
   set fiveyeartotal_vacant_c;
	by county2_char;
	retain group 0;
	if first.county2_char then group=group+1;
 run;
data fiveyeartotal_vacant_cat;
	merge fiveyeartotal_vacant_C2 (in=a) categories;
	if a;
	by group ;

	label category="County/PUMA Group Designation";
run;
/*export dataset*/
 data NCHsg.fiveyeartotal_vacant_alt(label= "NC vacant units 13-17 pooled alternative file"); 
   set fiveyeartotal_vacant_cat;
 run;

 proc contents data= NCHsg.fiveyeartotal_vacant_alt; run;

proc tabulate data=NCHsg.fiveyeartotal_vacant_alt format=comma12. noseps missing;
  class county2_char;
  var hhwt_geo hhwt_ori;
  table
    all='Total' county2_char=' ',
    sum='Sum of HHWTs' * ( hhwt_geo='Adjusted to 2015 estimates' hhwt_ori= 'Original 5-year')
  / box='Vacant (nonseasonal) housing units';
  *format county2_char county2_char.;
run;

/*need to account for other vacant units in baseline and future targets for the region to complete picture of the total housing stock*/

data fiveyeartotal_othervacant;
   set other_vacant_2013 other_vacant_2014 other_vacant_2015 other_vacant_2016 other_vacant_2017;
totalpop=0.2;
merge=1;

geoid=.;
if county2_char= "0100" then geoid=1;
else if  county2_char= "0200" then geoid=2;
else if  county2_char= "0300" then geoid=3;
else if  county2_char= "0400" then geoid=4;
else if  county2_char= "0500 or 0600" then geoid=5;
else if  county2_char= "0700" then geoid=6;
else if  county2_char= "0800" then geoid=7;
else if  county2_char= "0900" then geoid=8;
else if  county2_char= "1000" then geoid=9;
else if  county2_char= "1100" then geoid=10;
else if  county2_char= "1201 to 1208" then geoid=11;
else if  county2_char= "1301 to 1302" then geoid=12;
else if  county2_char= "1400" then geoid=13;
else if  county2_char= "1500" then geoid=14;
else if  county2_char= "1600" then geoid=15;
else if  county2_char= "1701 to 1704" then geoid=16;
else if  county2_char= "1801 to 1803" then geoid=17;
else if  county2_char= "1900 or 2900" then geoid=18;
else if  county2_char= "2000" then geoid=19;
else if  county2_char= "2100" then geoid=20;
else if  county2_char= "2201 to 2202" then geoid=21;
else if  county2_char= "2300 or 2400" then geoid=22;
else if  county2_char= "2500" then geoid=23;
else if  county2_char= "2600 or 2700" then geoid=24;
else if  county2_char= "2800" then geoid=25;
else if  county2_char= "3001 to 3003" then geoid=26;
else if  county2_char= "3101 to 3108" then geoid=27;
else if  county2_char= "3200 or 3300" then geoid=28;
else if  county2_char= "3400" then geoid=29;
else if  county2_char= "3500" then geoid=30;
else if  county2_char= "3600" then geoid=31;
else if  county2_char= "3700" then geoid=32;
else if  county2_char= "3800" then geoid=33;
else if  county2_char= "3900" then geoid=34;
else if  county2_char= "4000" then geoid=35;
else if  county2_char= "4100 or 4500" then geoid=36;
else if  county2_char= "4200" then geoid=37;
else if  county2_char= "4300" then geoid=38;
else if  county2_char= "4400" then geoid=39;
else if  county2_char= "4600 or 4700" then geoid=40;
else if  county2_char= "4800" then geoid=41;
else if  county2_char= "4900 or 5100" then geoid=42;
else if  county2_char= "5001 to 5003" then geoid=43;
else if  county2_char= "5200" then geoid=44;
else if  county2_char= "5300 or 5400" then geoid=45;

run;

proc sort data= fiveyeartotal_othervacant;
by geoid;
run;

data fiveyeartotal_othervacant_c;
merge fiveyeartotal_othervacant calculate_calibration;
by geoid;

hhwt_geo=.; 

hhwt_geo=hhwt*calibration*0.2; 
hhwt_ori= hhwt*0.2;
label hhwt_geo="Household Weight Calibrated to Steven Estimates for Households"
	  calibration="Ratio of Steven 2015 estimate to ACS 2013-17 for 45 geographic units"	
		hhwt_ori="Original Household Weight";
run; 

 data fiveyeartotal_othervacant_c2; 
   set fiveyeartotal_othervacant_c;
	by county2_char;
	retain group 0;
	if first.county2_char then group=group+1;
 run;
data fiveyeartotal_othervacant_cat;
	merge fiveyeartotal_othervacant_c2 (in=a) categories;
	if a;
	by group ;

	label category="County/PUMA Group Designation";
run;
/*export dataset*/
 data NCHsg.fiveyeartotal_othervacant_alt(label= "NC other vacant units 13-17 pooled alternative file"); 
   set fiveyeartotal_othervacant_cat;
 run;

 proc contents data= NCHsg.fiveyeartotal_othervacant_alt; run;

proc tabulate data=NCHsg.fiveyeartotal_othervacant_altformat=comma12. noseps missing;
  class county2_char;
  var hhwt_geo hhwt_ori;
  table
    all='Total' county2_char=' ',
    sum='Sum of HHWTs' * (hhwt_geo='Adjusted to 2015 estimates' hhwt_ori= 'Original 5-year')
  / box='Seasonal vacant housing units';
  *format county2_char county2_char.;
run;

proc freq data=NCHsg.fiveyeartotal_othervacant_alt;
by county2_char;
tables vacancy /nopercent norow nocol out=other_vacant;
weight hhwt_geo;
*format county2_char county2_char.;
run; 



