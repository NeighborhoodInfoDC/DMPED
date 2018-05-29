libname ipums 'F:\DCDATA\Libraries\IPUMS\Data';

options fmtsearch=(ipums); 

proc contents data = ipums.acs_2011_fam_pmsa99; run;

proc contents data = ipums.acs_2011_dc; run;

proc sort data = ipums.acs_2011_fam_pmsa99 out = fam_ahs_2011; by serial; run;

proc sort data = ipums.acs_2011_dc out=acs_2011_dc; by serial; run;

proc format;
value yes_no
1='Yes'
2='No';
value income
0='Above Extremely Low Income'
1='Extremely Low Income'
2='Less than half of ELI';
value family_risk
0='No young children or older parents'
1='Children under 7 and parents under 25'
2='Children under 3 and parents under 23';
value total_risk
0='Minimal Risk'
1-4='Moderate Risk'
5-10='High Risk';
value hh_size
1 = '1 person'
2 = '2 person'
3 = '3 person'
4 = '4 person'
5-25 = '5 or more people';
run; 

/* Merging DC and family household datasets*/

data ipums_merge;
merge fam_ahs_2011 (in=a where=(statefip = 11)) acs_2011_dc (in=b where=(statefip=11));
if a and b;
by serial;
if gq in (1,2); *excludes households in group quarters;
run;

/* Finding Young parents with young children */


proc sort data = ipums_merge;
by SERIAL pernum;
run;

proc transpose data = ipums_merge prefix=mom_pernum out=mom_key; 
by serial;
id pernum;
var momloc;
run;

proc transpose data = ipums_merge prefix=dad_pernum out=dad_key; 
by serial;
id pernum;
var poploc;
run;


data family_values;
merge mom_key dad_key;
by serial;
run;

data bare_min;
set ipums_merge;
keep serial pernum age sex yngch;
run;

proc sort data = bare_min; by serial; run;

proc sort data = family_values; by serial; run;

data dc_parents;
merge bare_min family_values;
by serial;
run;

data dc_parents2;
set dc_parents;
array mom_num(10) mom_pernum1-mom_pernum10;
array dad_num {10} dad_pernum1-dad_pernum10;
do i = 1 to dim(mom_num);
if mom_num(i)=pernum then is_mom =1;*if record matches any records mom locator value then is_mom;
*else if mom_num(i)gt 0 then is_relchild = 1;
end;
do i = 1 to dim(dad_num);
if dad_num(i)=pernum then is_dad =1;
*else if dad_num(i)gt 0 then is_relchild = 1;
end;
dad_age = age*is_dad;
mom_age=age*is_mom;
*kid_age =age*is_relchild;
run;

data young_child;
set dc_parents2;
if yngch ge 0 and yngch lt 7;
run;

proc sort data = young_child;
by serial;
run;

proc means data = young_child noprint;
by serial;
output out = family_risk min(yngch)=yng_child min(dad_age)=yng_dad min(mom_age)=yng_mom;
run;

data fam_risk_calc;
set family_risk;
if yng_mom ne . and yng_dad ne . then do;
if yng_mom gt 24 or yng_dad gt 24 then fam_risk = 0;
else if yng_mom le 22 and yng_dad le 22 and yng_child le 2 then fam_risk =2;
else fam_risk = 1;
end;
if yng_dad = . then do;
if yng_mom gt 24 then fam_risk = 0;
else if yng_mom le 22 and yng_child le 2 then fam_risk = 2;
else fam_risk = 1;
end;
if yng_mom = . then do;
if yng_dad gt 24 then fam_risk = 0;
else if yng_dad le 22 and yng_child le 2 then fam_risk = 2;
else fam_risk = 1;
end;
run;

data fam_risk_only;
set fam_risk_calc;
keep serial fam_risk;
run;

proc sort data = fam_risk_only; by serial; run;

proc sort data = ipums_merge; by serial; run;

data ipums_merge_wfam_risk;
merge ipums_merge (in=a) fam_risk_only (in=b);
by serial;
if a;
if fam_risk = . then fam_risk = 0;
run;

proc freq data = ipums_merge_wfam_risk;
weight hhwt;
table fam_risk;
where pernum = 1;
run;

/* Income Risk */

data other_risks;
set ipums_merge_wfam_risk;
*Income risk;
	if hhincome in ( 9999999, .n ) then inc_risk = .n;
  		else do;

    		if numprec =1 then do;
				  if hhincome <= 12325 then inc_risk = 2;
				  else if 12325 < hhincome <= 24650 then inc_risk = 1;
      		      else if 24650 < hhincome then inc_risk = 0;
        end;
     else if numprec =2 then do;
          if hhincome <= 14075 then inc_risk = 2;
          else if 14075 < hhincome <= 28150 then inc_risk = 1;
          else if 28150 < hhincome then inc_risk = 0;
        end;
     else if numprec =3 then do;
          if hhincome <= 15850 then inc_risk = 2;
          else if 15850 < hhincome <= 31700 then inc_risk = 1;
          else if 31700 < hhincome then inc_risk = 0;
        end;
      else if numprec =4 then do;
        if hhincome <= 17600 then inc_risk = 2;
          else if 17600< hhincome <= 35200 then inc_risk = 1;
          else if 35200 < hhincome then inc_risk = 0;
        end;
      else if numprec =5 then do;
        if hhincome <= 19000 then inc_risk = 2;
          else if 19000< hhincome <= 38000 then inc_risk = 1;
          else if 38000< hhincome then inc_risk = 0;
        end;
      else if numprec =6 then do;
        if hhincome <= 20425 then inc_risk = 2;
          else if 20425< hhincome <= 40850 then inc_risk = 1;
          else if 40850< hhincome then inc_risk = 0;
        end;
      else if numprec =7 then do;
        if hhincome <= 21825 then inc_risk = 2;
          else if 21825< hhincome <= 43650 then inc_risk = 1;
          else if 43650< hhincome then inc_risk = 0;
        end;
		else if numprec ge 8 then do;
        if hhincome <= 23225 then inc_risk = 2;
          else if 23225< hhincome <= 46450 then inc_risk = 1;
          else if 46450< hhincome then inc_risk = 0;
        end;
    end;
	*Rent Burden;
	if hhincome in ( 9999999, .n ) or rentgrs = .n then rent_burden = .n;
            else do;
                  if rentgrs = 0 or rentgrs = 1 then rent_burden = 0;
                  else if hhincome <= 0 then rent_burden = 1;
                  else do;
                        if rentgrs * 12 / hhincome <= 0.3 then rent_burden = 0;
                        else if rentgrs * 12 / hhincome <= 0.5 then rent_burden = 0;
                        else if rentgrs * 12 / hhincome > 0.5 then rent_burden = 1;
                  end;
            end;

	*Welfare risk factor;
	if 0 < incwelfr < 20000 then welfare =1;
	else welfare = 0;
	*Unemployment risk factor;
	if relate in (1,2) and empstat = 2 then unemployed = 1;
	else unemployed = 0;
	* Severe overcrowding (more than 1.5 people per room);
	if rooms gt 0 then do;
	ppr = numprec/rooms;
	if ppr gt 1.5 then crowd_risk = 1;
	else crowd_risk = 0;
	end;
	else if rooms = 1 then crowd_risk = .n;
	* mobility risk ;
	if migrate1 in (0,9) then mobility = .n;
	else if migrate1 in (2,3,4) then mobility= 1;
	else if migrate1 = 1 then mobility = 0;
	* High school grad;
	if educ le 5 then hs_grad = 0;
	else if educ gt 5 then hs_grad = 1;
run;

proc sort data = other_risks; by serial; run;

proc means data = other_risks noprint;
by serial;
output out = hh_risks max(mobility)=mobility_risk max(hs_grad) = graduated_yn max(unemployed)=unemp_risk
max(welfare)=welfare_risk; 
run;

data final_hh_risks;
set hh_risks;
if graduated_yn = 1 then dropout_risk = 0; *if no one in the household has high school degree then dropout risk;
else dropout_risk = 1;
run;

proc sort data = final_hh_risks; by serial; run;

proc sort data = other_risks; by serial; run;

data final_risk_dataset;
merge other_risks (in=a) final_hh_risks (in=b);
by serial;
if a and b;
composite_risk_1 = sum(dropout_risk,unemp_risk,welfare_risk,fam_risk,inc_risk,rent_burden,crowd_risk);
if composite_risk_1 gt 0 then composite_risk = sum(mobility_risk,composite_risk_1);
else composite_risk = composite_risk_1;
composite_risk_2 = sum(dropout_risk,unemp_risk,fam_risk,inc_risk,rent_burden,crowd_risk);
if composite_risk_2 gt 0 then composite_risk_alt = sum(mobility_risk,composite_risk_1);
else composite_risk_alt = composite_risk_2;
run;

proc print data = final_risk_dataset (obs=150);
var serial pernum composite_risk;
run; 



ods pdf file = 'F:\DCDATA\Libraries\IPUMS\Data\Homeless risk.pdf';

proc freq data = final_risk_dataset;
weight hhwt;
tables composite_risk*puma composite_risk*numprec;
format composite_risk total_risk. numprec hh_size.;
title 'Homeless risk by puma and hh size';
where pernum = 1;
run;


proc freq data = final_risk_dataset;
weight hhwt;
table puma*mobility_risk;
where pernum = 1 and composite_risk_1 ge 1;
title 'Households that have moved in the last year';
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*dropout_risk;
where pernum = 1;
title 'Households with no high school graduates';
format dropout_risk yes_no.;
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*unemp_risk;
where pernum = 1;
title 'Households with unemployed head of household or spouse';
format unemp_risk yes_no.;
run;


proc freq data = final_risk_dataset;
weight hhwt;
table puma*welfare_risk;
where pernum = 1;
title 'Households receiving welfare income';
format welfare_risk yes_no.;
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*fam_risk;
where pernum = 1;
title 'Households with young parents and young children';
format fam_risk family_risk.;
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*inc_risk;
where pernum = 1;
title 'Extremely low income households';
format inc_risk income.;
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*rent_burden;
where pernum = 1;
title 'Extremely rent burdened households';
run;

proc freq data = final_risk_dataset;
weight hhwt;
table puma*crowd_risk;
where pernum = 1;
title 'Severely over-crowded households';
format crowd_risk yes_no.;
run;


ods pdf close;

ods pdf file = 'F:\DCDATA\Libraries\IPUMS\Data\Welfare and Homeless risk.pdf';

proc freq data = final_risk_dataset;
weight hhwt;
tables welfare_risk*composite_risk welfare_risk*composite_risk_alt;
title 'Homeless risk by welfare receipt';
format composite_risk composite_risk_alt total_risk.;
where pernum =1;
run;

proc freq data = final_risk_dataset;
weight hhwt;
tables composite_risk_alt*welfare_risk;
title 'Welfare receipt among high risk households';
format composite_risk_alt total_risk.;
where pernum=1;
run;

proc freq data = final_risk_dataset;
weight hhwt;
tables welfare_risk*dropout_risk welfare_risk*unemp_risk welfare_risk*fam_risk welfare_risk*inc_risk welfare_risk*rent_burden welfare_risk*crowd_risk;
title 'homeless risk factors by welfare receipt';
where pernum=1;
run;


proc sort data = final_risk_dataset; by welfare_risk numprec; run; 

proc means data = final_risk_dataset median;
by welfare_risk numprec;
var hhincome;
title 'HH Income by HH Size and Receipt of Welfare';
where pernum=1;
run;

ods pdf close;
