/**************************************************************************
 Program:  PotentialOwnerUnits.sas
 Library:  DMPED
 Project:  DMPED Housing Forecast
 Author:   L. Hendey
 Created:  06/20/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  
**/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DMPED )
%DCData_lib( REALPROP )
%DCData_lib( MAR )

option spool; 
*max owner units;
data maxunits;
	set realpr_r.num_units_city;

	keep city units_owner: units_coop:;

	run;

*look at owner point files going back in time. */;
%let real=2002_05 2003_07 2004_07 2005_06 2006_07 2007_05 2008_06 2009_06 2010_07 2011_06 2012_06 2013_03 2014_01 2016_04 
		  2017_02 /*2018_05*/ 2019_09 2020_05 2021_01 2022_06 2023_05 2024_05;

%let year=2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2016 2017 /*2018*/ 2019 2020 2021 2022 2023 2024;

%macro getdata;

	%do i=1 %to 21; 

	%let r=%scan(&real.,&i.," "); 
	%let y=%scan(&year.,&i.," ");


	data ownerpt_&y. except_&y.;
	set RealPr_r.ownerpt_&r. (where=(ui_proptype in ('10','11','12','13')));
		year=&y.;
		count=1; 

		%if &y.=2016 %then %do; 
			rename CITYSTZIP=address3;
		%end; 

		if ((ssl="0131    2127" and address2="STATE DEPARTMENT")| (PREMISEADD= "WATKINS ALLEY SE WASHINGTON DC 00000")) then output except_&y.;
		else output ownerpt_&y.; 


	run;

	%create_own_occ(inds=ownerpt_&y.,outds=ownerpt_&y.a );
	
	proc freq data=ownerpt_&y.a;
	tables owner_occ_sale*ui_proptype/missprint;
	where ui_proptype in("10" "11");
	title "owner-occupied sales for single family and condo &y."; 
	run;

	
	proc freq data=ownerpt_&y.a;
	tables owner_occ_sale*ui_proptype/missprint;
	where ui_proptype in("13");
	title "owner-occupied sales for multifamily &y."; 
	run;


		data all_&y.;
			set except_&y. (in=a) ownerpt_&y.a;
			if a then owner_occ_sale=0; 

			*assuming that owner_occ_sale unknown are not owner occupants for our purposes;
			if owner_occ_sale=.u then owner_occ_sale=0; 

			run; 

		proc sort data=all_&y.;
		by ui_proptype owner_occ_sale;

		proc summary data= all_&y.;
		where ui_proptype in("10" "11" "13");
		by ui_proptype owner_occ_sale;

		var count; 
		id year;
		output out=sum_&y. sum= ;
		run; 

		proc transpose data=sum_&y. out=sum_&y._res;
		var count;
		by ui_proptype;
		id owner_occ_sale;

		run;
		 
		data coop_&y.;

			set all_&y. (drop=count);
			where ui_proptype="12";


			Yes=NO_OWNOCCT;
			No=(NO_units - NO_OWNOCCT);
			 
			run; 

		proc summary data=coop_&y.;
		var yes no; 
		output out=coop_sum_&y. sum= ;
		run; 

		data sum_all_&y.;
			set sum_&y._res (drop=_name_) coop_sum_&y. (in=a keep= yes no);

			if a then ui_proptype="12"; 

			pct_ownerocc=yes/(yes+no)*100; 
			total_units=yes + no; 
			year=&y.;

			run;

			%if &y.=2002 %then %do; 
				data allyears ;
					set sum_all_&y. ;
					
					run;

				%end; 

			%else %do;

					data allyears ;
					set allyears sum_all_&y. ;

					
					run;
			%end; 
			/*
			proc datasets nolist library=work memtype=(data);
  			delete _ownerpt_2003 _sales_owner_dc _premise_geo _owneraddress_geo;
  			quit;*/


		%end; 

%mend;

%getdata;
/*fix number of units for 2021 coops (only zeros reported in 2021, replacing with 2022 values);
not using this - too in the weeds for time available 
 -on ownerpt files in 2019, 2020 the NO_OWNOCCT var doesn't look like it was read in correctly. ; 
proc sort data=coop_2021;
by ssl;
proc sort data=coop_2022;
by ssl;
data fixcoop2021;
merge coop_2021 (in=a drop=yes no no_units NO_OWNOCCT) coop_2022 (keep=ssl  no_units NO_OWNOCCT);
by Ssl;
if a;
	Yes=NO_OWNOCCT;
	No=(NO_units - NO_OWNOCCT);

run;
proc summary data=fixcoop2021;
		var yes no; 
		output out=coop_sum_2021f sum= ;
		run; 
proc contents data=ownerpt_2002;
run;
proc print data=coop_2020;
var ssl premiseadd NO_OWNOCCT no_units;run;
proc freq data=coop_2021;
tables no_units;
run;*/
proc sort data=allyears;
by ui_proptype;
proc export data=allyears 
outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\owneroccupied_properties.csv"
dbms=csv
replace;
run;


data maxunits;
	set realpr_r.num_units_city;

	keep city units_owner: units_coop: units_sf: units_condo:;

	run;

proc export data=maxunits 
outfile="&_dcdata_default_path\DMPED\Prog\Housing Forecast\maxunits.csv"
dbms=csv
replace;
run;
