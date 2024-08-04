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

%let date=07252024; 

proc format;

  value hud_inc
   .n = 'Vacant'
    1 = '0-30% AMI'
    2 = '31-50%'
    3 = '51-80%'
    4 = '81-120%'
    5 = '120-200%'
    6 = 'More than 200%'
	7 = 'Vacant'
	;

  value rcost
	  1= "$0 to $899"
	  2= "$900 to $1,399"
	  3= "$1,400 to $1,799"
	  4= "$1,800 to $2,299"
	  5= "$2,300 to $2,799"
	  6= "More than $2,800"
  ;

    value ocost
	  1= "$0 to $1,399"
	  2= "$1,400 to $1,799"
	  3= "$1,800 to $2,499"
	  4= "$2,500 to $3,199"
	  5= "$3,200 to $4,199"
	  6= "More than $4,200"
  ;


  value acost
	  1= "$0 to $899"
	  2= "$900 to $1,299"
	  3= "$1,400 to $1,799"
	  4= "$1,800 to $2,799"
	  5= "$2,800 to $3,599"
	  6= "More than $3,600"
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

	value tenure
	1 = 'Rent'
	2 = 'Own'
	; 
  	 value paycategory
  1 = 'Cannot pay more'
  2 = 'Pays right amount' 
  3 = 'Could pay more'
  4 = 'Vacant';

	 /* value afford

 1= 'natural affordable (rent < $750)'
  0= 'not natural affordable'; */
run;

/* Because we downloaded 5-year data, no longer need the single year macro NCHsg and RegHsg used */


DATA DCvacant_2018_22 ;
	SET Ipums.Acs_2018_22_vacant_DC ;
RUN;

DATA DCarea_2018_22;
	SET Ipums.Acs_2018_22_dc;
	WHERE MULTYEAR NE .; /*QUICK FIX, REMOVE ONCE SINGLE YEAR DATA REMOVED FROM MULTIYEAR DATASET*/
RUN;

 **create ratio for rent to rentgrs to adjust rents on vacant units**;
	DATA Ratio_2018_22;

		  SET DCarea_2018_22
		    (keep= rent rentgrs pernum gq ownershpd upuma
		     where=(pernum=1 and gq in (1,2) and ownershpd in ( 22 )));
		     
		  Ratio_rentgrs_rent_2018_22 = rentgrs / rent;
	run;

		proc means data=Ratio_2018_22;
		  var  Ratio_rentgrs_rent_2018_22 rentgrs rent;
		  output out=Ratio_2018_22 (keep=Ratio_rentgrs_rent_2018_22) mean=;
		run;

*create HUD_inc - uses 2022 limits but has categories for 120-200% and 200%+ AMI; 
	%macro Hud_inc_22_dmped( hhinc=, hhsize= );

  ** HUD income categories (<year>) IN PLACE OF MACRO FOR NOW**;
  if (&hhinc.) in ( 9999999, .n ) then hud_inc = .n;
  else do;

           select ( numprec );
      when ( 1 )
        do;
          if &hhinc. <= 29900 then hud_inc = 1;
          else if 29900 < &hhinc. <= 49850 then hud_inc = 2;
          else if 49850 < &hhinc. <= 49850*2*0.8 then hud_inc = 3; *using mathematical 80% limit not HUDs; 
          else if 49850*2*0.8 < &hhinc. <= 119640 then hud_inc = 4;
          else if 119640 < &hhinc. <= 2*(49850/0.5)then hud_inc = 5;
		  else if 2*(49850/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 2 )
        do;
          if &hhinc. <= 34200 then hud_inc = 1;
          else if 34200 < &hhinc. <= 56950 then hud_inc = 2;
          else if 56950 < &hhinc. <= 56950*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 56950*2*0.8 < &hhinc. <= 136680 then hud_inc = 4;
          else if 136680 < &hhinc. <= 2*(56950/0.5) then hud_inc = 5;
		  else if 2*(56950/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 3 )
        do;
          if &hhinc. <= 38450 then hud_inc = 1;
          else if 38450 < &hhinc. <= 64050 then hud_inc = 2;
          else if 64050 < &hhinc. <= 64050*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 64050*2*0.8 < &hhinc. <= 153720 then hud_inc = 4;
          else if 153720 < &hhinc. <= 2*(64050/0.5) then hud_inc = 5;
		  else if 2*(64050/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 4 )
        do;
          if &hhinc. <= 42700 then hud_inc = 1;
          else if 42700 < &hhinc. <= 71150 then hud_inc = 2;
          else if 71150 < &hhinc. <= 71150*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 71150*2*0.8 < &hhinc. <= 170760 then hud_inc = 4;
          else if 170760 < &hhinc. <= 2*(71150/0.5) then hud_inc = 5;
		  else if 2*(71150/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 5 )
        do;
          if &hhinc. <= 46150 then hud_inc = 1;
          else if 46150 < &hhinc. <= 76850 then hud_inc = 2;
          else if 76850 < &hhinc. <= 76850*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 76850*2*0.8  < &hhinc. <= 184440 then hud_inc = 4;
          else if 184440 < &hhinc. <= 2*(76850/0.5) then hud_inc = 5;
		  else if 2*(76850/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 6 )
        do;
          if &hhinc. <= 49550 then hud_inc = 1;
          else if 49550 < &hhinc. <= 82550 then hud_inc = 2;
          else if 82550 < &hhinc. <= 82550*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 82550*2*0.8 < &hhinc. <= 198120 then hud_inc = 4;
          else if 198120 < &hhinc. <= 2*(82550/0.5) then hud_inc = 5;
		  else if 2*(82550/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 7 )
        do;
          if &hhinc. <= 52950 then hud_inc = 1;
          else if 52950 < &hhinc. <= 88250 then hud_inc = 2;
          else if 88250 < &hhinc. <= 88250*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 88250*2*0.8  < &hhinc. <= 211800 then hud_inc = 4;
          else if 211800 < &hhinc. <= 2*(88250/0.5) then hud_inc = 5;
		  else if 2*(88250/0.5) < &hhinc. then hud_inc = 6; /*200% plus*/
        end;
      otherwise
        do;
          if &hhinc. <= 56400 then hud_inc = 1;
          else if 56400 < &hhinc. <= 93950 then hud_inc = 2;
          else if 93950 < &hhinc. <= 93950*2*0.8 then hud_inc = 3;  *using mathematical 80% limit not HUDs; 
          else if 93950*2*0.8 < &hhinc. <= 225480 then hud_inc = 4;
          else if 225480 < &hhinc. <= 2*(93950/0.5) then hud_inc = 5;
		  else if 2*(93950/0.5) < hhincome then hud_inc = 6; /*200% plus*/
        end;
    end;

    end;

  label Hud_inc = "HUD income categories";
 

%mend Hud_inc_22_dmped;

  data Housing_needs_baseline_2018_22_1;
  set DCarea_2018_22
        (keep=year upuma serial pernum MET2013 hhwt hhincome numprec UNITSSTR BUILTYR2 bedrooms gq ownershp owncost ownershpd mortgage rentgrs valueh 
			empstat uhrswork wkswork2 occ  where=(pernum=1 and gq in (1,2) and ownershpd in ( 12,13,21,22 )));


	 /*  adjustment of income data is NOT needed for multiyear data, which is already adjusted to 2022 in this case
		
		if hhincome ~=.n or hhincome ~=9999999 then do; 
		 %dollar_convert( hhincome, hhincome_a, MULTYEAR, 2022, series=CUUR0000SA0L2 )
	   end; */ 

	/* Flag 35+ hours worked as full time */
  if uhrswork >= 35 then fulltime=1;
  else if uhrswork > 0 then fulltime=0;
  else fulltime = .n;

  /* Flag 50-52 weeks per year as year-round */
  if wkswork2 = 6  then yearround=1;
  else if wkswork2 > 0 then yearround=0;
  else yearround = .n;


%Hud_inc_22_dmped(hhinc=hhincome, hhsize = numprec); 
run; 

data Housing_needs_baseline_2018_22;
  set Housing_needs_baseline_2018_22_1;

	/* adjust housing costs for inflation IS NOT NEEDED FOR MULTI-YEAR DATA - see IPUMS documentation; 

	  %dollar_convert( rentgrs, rentgrs_a, 2022, 2022, series=CUUR0000SA0L2 )
	  %dollar_convert( owncost, owncost_a, 2022, 2022, series=CUUR0000SA0L2 )
	  %dollar_convert( valueh, valueh_a, 2022, 2022, series=CUUR0000SA0L2 ) */

  	** Cost-burden flag & create cost ratio **;
	    if ownershpd in (21, 22)  then do;

			if hhincome > 0 then Costratio= (rentgrs*12)/hhincome;
			  else if hhincome = 0 and rentgrs > 0 then costratio=1;
			  else if hhincome =0 and rentgrs = 0 then costratio=0; 
			  else if hhincome < 0 and rentgrs >= 0 then costratio=1; 
			  			  
		end;

	    else if ownershpd in ( 12,13 ) then do;
			if hhincome > 0 then Costratio= (owncost*12)/hhincome;
			  else if hhincome = 0 and owncost > 0 then costratio=1;
			  else if hhincome =0 and owncost = 0 then costratio=0; 
			  else if hhincome < 0 and owncost >= 0 then costratio=1; 
		end;
	    
			if Costratio >= 0.3 then costburden=1;
		    else if HHIncome~=. then costburden=0;
			if costratio >= 0.5 then severeburden=1;
			else if HHIncome~=. then severeburden=0; 

		tothh = 1;
 	

    ****** Rental units ******;
    
 if ownershpd in (21, 22) then do;
        
    Tenure = 1;

	 *create maximum desired or affordable rent based on HUD_Inc categories*; 
	
	  if hud_inc in(1 2 3) then max_rent=HHINCOME/12*.3; *under 80% of AMI then pay 30% threshold; 
	  if hud_inc =4 then max_rent=HHINCOME/12*.246; *avg for all renter HH hud_inc=4 in DC 2018-22 - see proc means output; 
	  if costratio <=.187 and hud_inc = 5 then max_rent=HHINCOME/12*.187; *avg for all renter HH hud_inc=5 in DC 2018-22 ; 	
		else if hud_inc = 5 then max_rent=HHINCOME/12*costratio; *allow 120-200% above average to spend more; 
	  if costratio <=.125 and hud_inc = 6 then max_rent=HHINCOME/12*.125; *avg for all renter HH hud_inc=6 in DC 2018-22; 
	  	else if hud_inc=6 then max_rent=HHINCOME/12*costratio; *allow 200%+ above average to spend more;  
     
	 *create flag for household could "afford" to pay more; 
		couldpaymore=.;

		if max_rent ~= . then do; 
			if max_rent > rentgrs*1.1 then couldpaymore=1; 
			else if max_rent <= rentgrs*1.1 then couldpaymore=0; 
		end; 

		/*Avg HH size in DC = 2.03; 1.9 for renters*/
    	*rent cost categories that make more sense for rents;
			rentlevel=.;
			if 0 <=rentgrs<900 then rentlevel=1; *900 is 30% of the monthly income for HH2 (34,200*.3/12 = 855) extremely low income, rounded to nearest 100;
            if 900 <=rentgrs<1400 then rentlevel=2; *1400 is 30% of the monthly income for HH2 (56,950*.3/12 = 1424) with very low income, rounded to nearest 100; 
            if 1400 <=rentgrs<1800 then rentlevel=3; *1800 is 30% monthly income HH2 (72,000*.3/12 = 1800) with low incomes, already rounded to nearest 100;
            if 1800 <=rentgrs<2300 then rentlevel=4;
            if 2300 <=rentgrs<2800 then rentlevel=5;
            if rentgrs >= 2800 then rentlevel=6;


			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;

				if costburden=1 then do;  		

					mrentlevel=.;
					if max_rent<900 then mrentlevel=1;
					if 900 <=max_rent<1400 then mrentlevel=2;
					if 1400 <=max_rent<1800 then mrentlevel=3;
					if 1800 <=max_rent<2300 then mrentlevel=4;
					if 2300 <=max_rent<2800 then mrentlevel=5;
					if max_rent >= 2800 then mrentlevel=6;

				end;

				else if costburden=0 then do;

					if rentgrs<900 then mrentlevel=1;
	                if 900 <=rentgrs<1400 then mrentlevel=2;
	                if 1400 <=rentgrs<1800 then mrentlevel=3;
	                if 1800 <=rentgrs<2800 then mrentlevel=4;
	                if 2800 <=rentgrs<3600 then mrentlevel=5;
	                if rentgrs >= 3600 then mrentlevel=6;


				end; 

				*for future housing needs categories are based on desired cost distribution;
					
					fmrentlevel=.;
					if max_rent<900 then fmrentlevel=1;
					if 900 <=max_rent<1400 then fmrentlevel=2;
					if 1400 <=max_rent<1800 then fmrentlevel=3;
					if 1800 <=max_rent<2300 then fmrentlevel=4;
					if 2300 <=max_rent<2800 then fmrentlevel=5;
					if max_rent >= 2800 then fmrentlevel=6;



		 *rent cost categories now used in targets that provide a set of categories useable for renters and owners combined; 
			
			allcostlevel=.;
			if rentgrs<900 then allcostlevel=1;
            if 900 <=rentgrs<1400 then allcostlevel=2;
            if 1400 <=rentgrs<1800 then allcostlevel=3;
            if 1800 <=rentgrs<2300 then allcostlevel=4;
            if 2300 <=rentgrs<3600 then allcostlevel=5;
            if rentgrs >= 3600 then allcostlevel=6;


			mallcostlevel=.;

			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;

			if costburden=1 then do; 

				if max_rent<900 then mallcostlevel=1;
	            if 900 <=max_rent<1400 then mallcostlevel=2;
	            if 1400 <=max_rent<1800 then mallcostlevel=3;
	            if 1800 <=max_rent<2800 then mallcostlevel=4;
	            if 2800 <=max_rent<3600 then mallcostlevel=5;
	            if max_rent >= 3600 then mallcostlevel=6;

			end; 

			else if costburden=0 then do;

				if rentgrs<900 then mallcostlevel=1;
                if 900 <=rentgrs<1400 then mallcostlevel=2;
                if 1400 <=rentgrs<1800 then mallcostlevel=3;
                if 1800 <=rentgrs<2800 then mallcostlevel=4;
                if 2800 <=rentgrs<3600 then mallcostlevel=5;
                if rentgrs >= 3600 then mallcostlevel=6;


			end; 

	end;
	  		
		
  	else if ownershpd in ( 12,13 ) then do;

	    ****** Owner units ******;
	    
	    Tenure = 2;

		*create maximum desired or affordable owner costs based on HUD_Inc categories*; 

		if hud_inc in(1 2 3) then max_ocost=HHINCOME/12*.3; *under 80% of AMI then pay 30% threshold; 
		if hud_inc =4 then max_ocost=HHINCOME/12*.241; *avg for all owner HH hud_inc=4in DC 2018-22 see proc means output;
		if costratio <=.184 and hud_inc = 5 then max_ocost=HHINCOME/12*.184; *avg for all owner HH HUD_inc=5 in DC 2018-22; 
			else if hud_inc = 5 then max_ocost=HHINCOME/12*costratio; *allow 120-200% above average to pay more; 
		if costratio <=.127 and hud_inc=6 then max_ocost=HHINCOME/12*.127; *avg for all owner HH HUD_inc=6 in DC 2018-22;
			else if hud_inc = 6 then max_ocost=HHINCOME/12*costratio; *allow 120-200% above average to pay more; 
		
		*create flag for household could "afford" to pay more; 
		couldpaymore=.;

		if max_ocost ~= . then do; 
			if max_ocost > owncost*1.1 then couldpaymore=1; 
			else if max_ocost <= owncost*1.1 then couldpaymore=0; 
		end; 

	    **** 
	    Calculate monthly payment for first-time homebuyers. 
	    Using 5.48% as the effective mortgage rate for DC in 2022 (pulled from overall US Freddie Mac) https://urbanorg.app.box.com/file/933065867963, 
	    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
	    ******; 
	    
	    loan = .9 * valueh;
	    month_mortgage= (5.48 / 12) / 100; 
	    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

	    ****
	    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
	    ******;
	    
	    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
	    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
	    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;

		
	
			/*create owner cost level categories (first-time homebuyer)*/ 
			

			ownlevel=.;
				if 0 <=total_month<1400 then ownlevel=1;
	           if 1400 <=total_month<1800 then ownlevel=2;
	           if 1800 <=total_month<2500 then ownlevel=3;
	           if 2500 <=total_month<3200 then ownlevel=4;
	           if 3200 <=total_month<4200 then ownlevel=5;
	           if total_month >= 4200 then ownlevel=6;


			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;
				mownlevel=.;

				if costburden=1 then do; 
				

					if max_ocost<1400 then mownlevel=1; *removed zero on one end to capture 2 HHs with negative HHINCOME and max_ocost;
		            if 1400 <=max_ocost<1800 then mownlevel=2;
		            if 1800 <=max_ocost<2500 then mownlevel=3;
		            if 2500 <=max_ocost<3200 then mownlevel=4;
		            if 3200 <=max_ocost<4200 then mownlevel=5;
		            if max_ocost >= 4200 then mownlevel=6;

				end;

				else if costburden=0 then do; 

					if owncost<1400 then mownlevel=1;
					if 1400 <=owncost<1800 then mownlevel=2;
					if 1800 <=owncost<2500 then mownlevel=3;
					if 2500 <=owncost<3200 then mownlevel=4;
					if 3200 <=owncost<4200 then mownlevel=5;
					if owncost >= 4200 then mownlevel=6;

				end; 

			*curownlevel based on owners current owner costs;
		
			curownlevel=.;
				if 0 <=owncost<1400 then curownlevel=1;
	           if 1400 <=owncost<1800 then curownlevel=2;
	           if 1800 <=owncost<2500 then curownlevel=3;
	           if 2500 <=owncost<3200 then curownlevel=4;
	           if 3200 <=owncost<4200 then curownlevel=5;
	           if owncost >= 4200 then curownlevel=6;

			*future housing needs categories based on desired cost distribution;

			   fmownlevel=.;
						if max_ocost<1400 then fmownlevel=1; *removed zero on one end to capture 2 HHs with negative HHINCOME and max_ocost;
		            if 1400 <=max_ocost<1800 then fmownlevel=2;
		            if 1800 <=max_ocost<2500 then fmownlevel=3;
		            if 2500 <=max_ocost<3200 then fmownlevel=4;
		            if 3200 <=max_ocost<4200 then fmownlevel=5;
		            if max_ocost >= 4200 then fmownlevel=6;


		 *owner cost categories now used in targets that provide a set of categories useable for renters and owners combined; 
			allcostlevel=.;
			if owncost<900 then allcostlevel=1;
			if 900 <=owncost<1400 then allcostlevel=2;
			if 1400 <=owncost<1800 then allcostlevel=3;
			if 1800 <=owncost<2800 then allcostlevel=4;
			if 2800 <=owncost<3600 then allcostlevel=5;
			if owncost >= 3600 then allcostlevel=6; 


	
			*for desired cost for current housing needs is current payment if not cost-burdened
			or income-based payment if cost-burdened;
			mallcostlevel=.;

			if costburden=1 then do; 

			if max_ocost<900 then mallcostlevel=1;
				if 900 <=max_ocost<1400 then mallcostlevel=2;
				if 1400 <=max_ocost<1800 then mallcostlevel=3;
				if 1800 <=max_ocost<2800 then mallcostlevel=4;
				if 2800 <=max_ocost<3600 then mallcostlevel=5;
				if max_ocost >= 3600 then mallcostlevel=6;
				end;

			else if costburden=0 then do; 

				if owncost<900 then mallcostlevel=1;
				if 900 <=owncost<1400 then mallcostlevel=2;
				if 1400 <=owncost<1800 then mallcostlevel=3;
				if 1800 <=owncost<2800 then mallcostlevel=4;
				if 2800 <=owncost<3600 then mallcostlevel=5;
				if owncost >= 3600 then mallcostlevel=6;

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
		 		  mrentlevel='Rent Level Categories based on Max affordable-desired rent - Current Needs'
				  fmrentlevel='Rent Level Categories based on Max affordable-desired rent - Future Needs'
				  allcostlevel='Housing Cost Categories (tenure combined) based on Current Rent or Current Owner Costs'
				  mallcostlevel='Housing Cost Categories (tenure combined) based on Max affordable-desired Rent-Owner Cost'
				  ownlevel = 'Owner Cost Categories based on First-Time HomeBuyer Costs'
				  mownlevel = 'Owner Cost Categories based on Max affordable-desired - Current needs'
				  fmownlevel = 'Owner Cost Categories based Max affordable-desired - Future needs'
				  curownlevel = 'Owner Cost Categories based on Current Owner Costs'
				  couldpaymore = "Occupant Could Afford to Pay More - Costs+10% are > Max affordable cost"
				  paycategory = "Whether Occupant pays too much, the right amount or too little" 
                  structure = 'Housing structure type'
				  structureyear = 'Age of structure'
				;

	
format fmownlevel mownlevel ownlevel curownlevel ocost. rentlevel fmrentlevel mrentlevel rcost. allcostlevel mallcostlevel acost. hud_inc hud_inc. structure structure. tenure tenure. paycategory paycategory.; 
run;
proc sort data=Housing_needs_baseline_2018_22;
by hud_inc tenure;
proc means data=Housing_needs_baseline_2018_22;
by hud_inc tenure;
var costratio;
weight hhwt;
run;

data Housing_needs_vacant_2018_22 Other_vacant_2018_22 ;

  set DCvacant_2018_22(keep=year serial hhwt owncost bedrooms gq vacancy rent valueh upuma BUILTYR2 UNITSSTR);

  	if _n_ = 1 then set Ratio_2018_22;

 	retain Total 1;
  * Add hud_inc variable for vacant = 7; 
	hud_inc = 7; 

  *reassign vacant but rented or sold based on whether rent or value is available; 	
  vacancy_r=vacancy; 
  if vacancy=3 and rent ~= .n then vacancy_r=1; 
  if vacancy=3 and valueh ~= .u then vacancy_r=2; 
    
    ****** Rental units ******;
	 if  vacancy_r = 1 then do;
	    Tenure = 1;
	    
	    	** Impute gross rent for vacant units **;
	  		rentgrs = rent*Ratio_rentgrs_rent_2018_22;

			 /* Don't need inflation adjustment for multiyear data %dollar_convert( rentgrs, rentgrs_a, &year., 2022, series=CUUR0000SA0L2 )*/

		/* if rent in ( 9999999, .n , . ) then affordable_vacant=.;
		else do; 
		    if rentgrs_a<700 then affordable_vacant=1;
			else if rentgrs_a>=700 then affordable_vacant=0;

		end; */

	*  label affordable_vacant = 'Natural affordable vacant rental unit';

		/*create rent level categories*/ 
			
		
		rentlevel=.;
		if 0 <=rentgrs<900 then rentlevel=1; *900 is 30% of the monthly income for HH2 (34,200*.3/12 = 855) extremely low income, rounded to nearest 100;
        if 900 <=rentgrs<1400 then rentlevel=2; *1400 is 30% of the monthly income for HH2 (56,950*.3/12 = 1424) with very low income, rounded to nearest 100; 
        if 1400 <=rentgrs<1800 then rentlevel=3; *1800 is 30% monthly income HH2 (72,000*.3/12 = 1800) with low incomes, already rounded to nearest 100;
        if 1800 <=rentgrs<2300 then rentlevel=4;
        if 2300 <=rentgrs<2800 then rentlevel=5;
        if rentgrs >= 2800 then rentlevel=6;


		/*create  categories now used in targets for renter/owner costs combined*/ 
				allcostlevel=.;
				if rentgrs<900 then allcostlevel=1;
	            if 900 <=rentgrs<1400 then allcostlevel=2;
	            if 1400 <=rentgrs<1800 then allcostlevel=3;
	            if 1800 <=rentgrs<2800 then allcostlevel=4;
	            if 2800 <=rentgrs<3600 then allcostlevel=5;
	            if rentgrs >= 3600 then allcostlevel=6;
	;
	  end;


	  else if vacancy_r = 2 then do;

	    ****** Owner units ******;
	    
	    Tenure = 2;

	    **** 
	    Calculate  monthly payment for first-time homebuyers. 
	    Using 5.48% as the effective mortgage rate for DC in 2022, https://urbanorg.app.box.com/file/933065867963
	    calculate monthly P & I payment using monthly mortgage rate and compounded interest calculation
	    ******; 
	    /* Don't need inflation conversion of housing/income values for multiyear ACS
		%dollar_convert( valueh, valueh_a, &year., 2022, series=CUUR0000SA0L2 )*/

	    loan = .9 * valueh;
	    month_mortgage= (5.48 / 12) / 100; 
	    monthly_PI = loan * month_mortgage * ((1+month_mortgage)**360)/(((1+month_mortgage)**360)-1);

	    ****
	    Calculate PMI and taxes/insurance to add to Monthly_PI to find total monthly payment
	    ******;
	    
	    PMI = (.007 * loan ) / 12; **typical annual PMI is .007 of loan amount;
	    tax_ins = .25 * monthly_PI; **taxes assumed to be 25% of monthly PI; 
	    total_month = monthly_PI + PMI + tax_ins; **Sum of monthly payment components;
		
			/*create owner cost level categories (first-time homebuyer)*/ 

			ownlevel=.;
				if 0 <=total_month<1400 then ownlevel=1;
	           if 1400 <=total_month<1800 then ownlevel=2;
	           if 1800 <=total_month<2500 then ownlevel=3;
	           if 2500 <=total_month<3200 then ownlevel=4;
	           if 3200 <=total_month<4200 then ownlevel=5;
	           if total_month >= 4200 then ownlevel=6;

			*curownlevel based on owners total month cost for owners, since owncost is not available for vacant units;
			curownlevel=.;
				if 0 <=total_month<1400 then curownlevel=1;
	           if 1400 <=total_month<1800 then curownlevel=2;
	           if 1800 <=total_month<2500 then curownlevel=3;
	           if 2500 <=total_month<3200 then curownlevel=4;
	           if 3200 <=total_month<4200 then curownlevel=5;
	           if total_month >= 4200 then curownlevel=6;

			
			/*create  categories now used in targets for renter/owner costs combined*/ 
				allcostlevel=.;
				if total_month<900 then allcostlevel=1;
				if 900 <=total_month<1400 then allcostlevel=2;
				if 1400 <=total_month<1800 then allcostlevel=3;
				if 1800 <=total_month<2800 then allcostlevel=4;
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
				  curownlevel = 'Owner Cost Categories based on Current Owner Costs'
				  paycategory = "Whether Occupant pays too much, the right amount or too little" 
				  structureyear = 'Age of structure'
				  structure = 'Housing structure type'
				;
	format hud_inc hud_inc. ownlevel curownlevel ocost. rentlevel rcost. vacancy_r VACANCY_F. allcostlevel acost. paycategory paycategory.; ; 

	*output other vacant - seasonal separately ;
	if vacancy in (1, 2, 3) then output Housing_needs_vacant_2018_22;
	else if vacancy in (4, 7, 9) then output other_vacant_2018_22; 
	run;



PROC CONTENTS data= Housing_needs_baseline_2018_22;
run;

/*export datasets*/

* Housing needs; 
%Finalize_data_set( 
  data=Housing_needs_baseline_2018_22,
  out=DC_2018_22_housing_needs,
  outlib=DMPED,
  label="DC households for DMPED Housing Needs 2018-2022 file",
  sortby=hud_inc,
  revisions=%str(New file.)
)

* Housing needs vacant; 
%Finalize_data_set( 
  data=Housing_needs_vacant_2018_22,
  out=DC_2018_22_housing_needs_vacant,
  outlib=DMPED,
  label="DC for sale/rent vacant units for DMPED Housing Needs 2018-2022 file",
  sortby=hud_inc,
  revisions=%str(New file.)
)

* Other vacant; 
%Finalize_data_set( 
  data=other_vacant_2018_22,
  out=DC_2018_22_other_vacant,
  outlib=DMPED,
  label="DC for other vacant for DMPED Housing Needs 2018-2022 file",
  sortby=hud_inc,
  revisions=%str(New file.)
)


 /*Make combined dataset of occupied/vacant */

data all(label= "DC units on housing market for DMPED Housing Needs 2018-22"); *excludes other vacant;
	set Housing_needs_baseline_2018_22 Housing_needs_vacant_2018_22 (in=a);
	if a then hud_inc=7; 
run; 


%Finalize_data_set( 
  data=all,
  out=DC_2018_22_all_housing_units,
  outlib=DMPED,
  label="DC on housing market for DMPED Housing Needs 2018-22",
  sortby=hud_inc,
  revisions=%str(New file.)
)



/*Export datasets for future projections
PROC EXPORT DATA = Housing_needs_baseline_2018_22
	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\Housing_needs_baseline_2018_22.csv"
   dbms=csv
   replace;
   run; 

PROC EXPORT DATA = Housing_needs_vacant_2018_22
	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\Housing_needs_vacant_2018_22.csv"
   dbms=csv
   replace;
   run; 

PROC EXPORT DATA = other_vacant_2018_22
	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\other_vacant_2018_22.csv"
   dbms=csv
   replace;
   run; 

*/


/* Desired tables 
• Household Tenure (e.g. Number/Share of Households: Renter, Owner, Total)
• Household Income (HUD AMI Categories)
• Housing Tenure by Household Income (HUD AMI categories)
• Housing Cost-burden by Income/Tenure
• Housing Unit costs renters
• Housing unit costs owners (current payment)
• Housing unit costs owners (for first time homebuyer)
• By Tenure: Households by “affordable/desired” housing cost band vs. supply at that level
• Cost mismatch/competition for lower cost units: Figure 20 in 2019 report by Housing Cost by Ability to Pay by Tenure
*/


/* HOUSING TENURE */

proc freq data=Housing_needs_baseline_2018_22;
tables tenure /  out=tenure_totals;
weight hhwt;
run; 

proc export data=tenure_totals
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\Tenure_totals_occupied_&date..csv"
   dbms=csv
   replace;
   run;

/* HOUSING INCOME */

proc freq data=Housing_needs_baseline_2018_22;
tables hud_inc /  out=hud_inc_cat;
weight hhwt;
run; 

proc export data=hud_inc_cat
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\hud_inc_cat_&date..csv"
   dbms=csv
   replace;
   run;
*look up relevant occupations;
 *https://usa.ipums.org/usa/volii/occ2018.shtml ; 
 proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=1 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;
 proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=2 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;
  proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=3 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;
  proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=4 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;
  proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=5 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;
  proc print data=Housing_needs_baseline_2018_22 (obs=10);
 where hud_inc=6 and numprec=2 and fulltime=1 and yearround=1;
 var tenure empstat occ hud_inc;
 run;

 proc freq data=Housing_needs_baseline_2018_22;
 where  numprec=2 and fulltime=1 and yearround=1;
 weight hhwt;
 tables occ*hud_inc / out=hud_inc_occ;
 run;

proc export data=hud_inc_occ
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\hud_inc_occ_&date..csv"
   dbms=csv
   replace;
   run;

/* Housing Tenure by Household Income (HUD AMI categories)*/
proc freq data=Housing_needs_baseline_2018_22;
tables hud_inc*tenure /nopercent norow  out=tenure_hud_inc_cat OUTPCT;
weight hhwt;
run; 


proc export data=tenure_hud_inc_cat
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\tenure_hud_inc_cat_&date..csv"
   dbms=csv
   replace;
   run;

/*HOUSING COST BURDEN BY INCOME/TENURE */
proc freq data=Housing_needs_baseline_2018_22;
tables tenure*costburden*hud_inc /  out=burden_tenure_hud_inc OUTPCT;
weight hhwt;
run;

proc export data=burden_tenure_hud_inc
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\burden_tenure_hud_inc_&date..csv"
   dbms=csv
   replace;
   run;

/*HOUSING UNIT COST - RENT*/
*Including occupied and vacant units;
proc freq data=all;
where tenure = 1;
tables rentlevel/  out=renter_costs_cat_all_units;
weight hhwt;
run;

proc export data=renter_costs_cat_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\renter_costs_cat_all_units_&date..csv"
   dbms=csv
   replace;
   run;

*NOTE FREQ in output is not a weighted count. Is the mean being successfully weighted?;
proc summary data= all (where = (tenure = 1));
var rentgrs;
weight hhwt; 
output out= rent_all_units mean=;
run;

/*Not exporting for now*/


/*HOUSING COSTS OWNERS (CURRENT PAYMENT)*/
*Including occupied and vacant units;
proc freq data=all;
where tenure = 2;
tables curownlevel /  out=own_costs_cat_all_units;
weight hhwt;
run;

proc export data=own_costs_cat_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\own_costs_cat_all_units_&date..csv"
   dbms=csv
   replace;
   run;
proc sort data=all;
by curownlevel;
proc means data=all;
by curownlevel;
var valueh;
weight hhwt;
run; 
proc means data=all;
var valueh;
weight hhwt;
run; 

/* HOUSING COSTS FOR FIRST-TIME OWNERS */
*Including occupied and vacant units;
proc freq data=all;
where tenure = 2;
tables ownlevel /  out=first_own_costs_cat_all_units;
weight hhwt;
run;

proc export data=first_own_costs_cat_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\first_own_costs_cat_all_units_&date..csv"
   dbms=csv
   replace;
   run;

/* BY TENURE: HOUSEHOLDS "AFFORDABLE/DESIRED" HOUSING COST BAND VS SUPPLY AT THAT LEVEL */

*all tenures, occupied units;
PROC FREQ DATA = Housing_needs_baseline_2018_22; 
tables tenure*mallcostlevel /nocol nopercent  out=afford_hous_cost_tenure OUTPCT;
weight hhwt;
run;

proc export data=afford_hous_cost_tenure
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\afford_hous_cost_tenure_&date..csv"
   dbms=csv
   replace;
   run;

*renters, occupied units;
PROC FREQ DATA = Housing_needs_baseline_2018_22; 
where tenure = 1;
tables mrentlevel /  out=afford_rent_cost ;
weight hhwt;
run;

proc export data=afford_rent_cost
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\afford_rent_cost_&date..csv"
   dbms=csv
   replace;
   run;

*owners, occupied units;
PROC FREQ DATA = Housing_needs_baseline_2018_22; 
where tenure = 2;
tables mownlevel /  out=afford_own_cost ;
weight hhwt;
run; 


proc export data=afford_own_cost
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\afford_own_cost_&date..csv"
   dbms=csv
   replace;
   run;

/*Cost mismatch/competition for lower cost units: Figure 20 in 2019 report by Housing Cost by Ability to Pay by Tenure*/

*all units split out by tenure;
*rent;
PROC FREQ DATA = all; 
where tenure = 1;
tables paycategory*rentlevel /  out=abil_pay_rent_all_units OUTPCT;
weight hhwt;
run;

proc export data=abil_pay_rent_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\abil_pay_rent_all_units_&date..csv"
   dbms=csv
   replace;
   run;

 *own based on current payment; 
PROC FREQ DATA = all; 
where tenure = 2;
tables paycategory*curownlevel /  out=abil_pay_own_cur_all_units OUTPCT;
weight hhwt;
run;

proc export data=abil_pay_own_cur_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\abil_pay_own_cur_all_units_&date..csv"
   dbms=csv
   replace;
   run;

*own based on first time buyer payment; 
PROC FREQ DATA = all; 
where tenure = 2;
tables paycategory*ownlevel /  out=abil_pay_own_first_all_units OUTPCT;
weight hhwt;
run;

proc export data=abil_pay_own_first_all_units
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\abil_pay_own_first_all_units_&date..csv"
   dbms=csv
   replace;
   run;

/* VACANT BY TYPE */
PROC FREQ DATA = Housing_needs_vacant_2018_22;
	TABLES VACANCY_R /  out=vacancy_by_type;
	Weight hhwt;
RUN;

proc export data=vacancy_by_type
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\vacancy_by_type_&date..csv"
   dbms=csv
   replace;
   run;

/* OTHER VACANT BY TYPE */

PROC FREQ DATA = other_vacant_2018_22;
	TABLES VACANCY/  out=other_vacancy_by_type;
	Weight hhwt;
RUN;

proc export data=other_vacancy_by_type
 	outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\other_vacancy_by_type_&date..csv"
   dbms=csv
   replace;
   run;
