/**************************************************************************
 Program:  KidsBedroomsNeeded.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  07/30/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Use ipums data to determine how many kids bedrooms are needed
			   in each household. 

 Modifications:
**************************************************************************/


%macro KidsBedroomsNeeded (indata,outdata);

data pretables2;
	set &indata.;
	if age <18;
	s = put(serial,z7.);
	np = put(pernum,z2.);
	id2 = s||np;
run;

proc sort data = pretables2; by serial age ; run;

/* Transpose so each boy's age is on a row */
proc transpose data = pretables2 (where=(sex=1)) out = boys
	prefix=boy;
	var age;
	by serial;
run;

/* Count how many boys per household */
data boys2;
	set boys;

	array chars(*)  _character_;
	array num(*)  _numeric_;
	count=0;
	do i=1 to dim(chars);
	if missing(chars(i))=0 then count=count+1;
	end;

	do j=1 to dim(num);
	if missing(num(j))=0 then count=count+1;
	end;

	drop i j;

	numboys = count-3;

	if numboys >= 2 then do;
	diffboy2to1=boy2-boy1;
	diffboy3to2=boy3-boy2;
	diffboy4to3=boy4-boy3;
	diffboy5to4=boy5-boy4;
	end;

	if boy2 >= 13 then do;
	if diffboy2to1 > 4 and (diffboy3to2 = . or diffboy3to2 > 4) then boy2flag = 1;
	end;

	if boy3 >= 13 then do;
	if diffboy3to2 > 4 and (diffboy4to3 = . or diffboy4to3 > 4) then boy3flag = 1;
	end;

	if boy3 >= 13 then do;
	if diffboy4to3 > 4 and (diffboy5to4 = . or diffboy5to4 > 4) then boy4flag = 1;
	end;

run;

/* Transpose so each girl's age is on a row */
proc transpose data = pretables2 (where=(sex=2)) out = girls
	prefix=girl;
	var age;
	by serial;
run;

/* Count how many girls per household */
data girls2;
	set girls;

	array chars(*)  _character_;
	array num(*)  _numeric_;
	count=0;
	do i=1 to dim(chars);
	if missing(chars(i))=0 then count=count+1;
	end;

	do j=1 to dim(num);
	if missing(num(j))=0 then count=count+1;
	end;

	drop i j;

	numgirls = count-3;

	if numgirls >= 2 then do;
	diffgirl2to1=girl2-girl1;
	diffgirl3to2=girl3-girl2;
	diffgirl4to3=girl4-girl3;
	diffgirl5to4=girl5-girl4;
	diffgirl6to5=girl6-girl5;
	end;

	if girl2 >= 13 then do;
	if diffgirl2to1 > 4 and (diffgirl3to2 = . or diffgirl3to2 > 4) then girl2flag = 1;
	end;

	if girl3 >= 13 then do;
	if diffgirl3to2 > 4 and (diffgirl4to3 = . or diffgirl4to3 > 4) then girl3flag = 1;
	end;

	if girl3 >= 13 then do;
	if diffgirl4to3 > 4 and (diffgirl5to4 = . or diffgirl5to4 > 4) then girl4flag = 1;
	end;

	if girl3 >= 13 then do;
	if diffgirl5to4 > 4 and (diffgirl6to5 = . or diffgirl6to5 > 4) then girl5flag = 1;
	end;

run;

/* Use counts and ages to determine bedrooms needed */
data bg (drop=count _label_ _name_);
	merge boys2 girls2;
	by serial;

	numkids = sum(of numboys numgirls);

	extra13boy = sum(of boy2flag boy3flag boy4flag );
		if extra13boy = . then extra13boy = 0;

	extra13girl = sum(of girl2flag girl3flag girl4flag girl5flag);
		if extra13girl = . then extra13girl = 0;

	
	if numkids = 1 then kidrooms = 1; 

	else if numkids = 2 then do;
		if boy1 <= 5 and girl1 <= 5 then kidrooms = 1;
		else if numboys=2 then kidrooms = 1 + extra13boy;
		else if numgirls=2 then kidrooms = 1 + extra13girl;
		else kidrooms = 2;
	end;

	else if numkids = 3 then do;
		if boy1 <= 5 and girl1 <= 5 then kidrooms = 2;
		else if numboys=3 then kidrooms = 2 + extra13boy;
		else if numgirls=3 then kidrooms = 2 + extra13girl;
		else if numboys=2 then kidrooms = 2 + extra13boy;
		else if numgirls=2 then kidrooms = 2 + extra13girl;
	end;

	else if numkids = 4 then do;
		if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 then kidrooms = 2;
		else if boy1 <= 5 and girl1 <= 5 and numboys=2 then kidrooms = 3;
		else if boy1 <= 5 and girl1 <= 5 and numboys=3 then kidrooms = 2 + extra13boy;
		else if numboys=4 then kidrooms = 2 + extra13boy;
		else if numgirls=4 then kidrooms = 2 + extra13girl;
		else if numboys=3 then kidrooms = 3 + extra13boy;
		else if numgirls=3 then kidrooms = 3 + extra13girl;
		else if numboys=2 then kidrooms = 2 + extra13boy + extra13girl;
	end;

	else if numkids = 5 then do; 
		if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 then kidrooms = 3;
		else if boy1 <= 5 and girl1 <= 5 and numboys<=3 then kidrooms = 3 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and numgirls<=3 then kidrooms = 3 + extra13girl;
		else if numboys=5 then kidrooms = 3 + extra13boy;
		else if numgirls=5 then kidrooms = 3 + extra13girl;
		else if numboys=4 then kidrooms = 3 + extra13boy;
		else if numgirls=4 then kidrooms = 3 + extra13girl;
		else if numboys=3 then kidrooms = 3 + extra13boy + extra13girl;
		else if numgirls=3 then kidrooms = 3 + extra13boy + extra13girl;
	end;

	else if numkids = 6 then do; 
		if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and boy3 <= 5 and girl3 <= 5 then kidrooms = 3;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numboys<=3 then kidrooms = 3 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numgirls<=3 then kidrooms = 3 + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and numboys = 5 then kidrooms = 3 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and numgirls = 5 then kidrooms = 3 + extra13girl; 
		else if numboys=6 then kidrooms = 3 + extra13boy;
		else if numgirls=6 then kidrooms = 3 + extra13girl;
		else if numboys=5 then kidrooms = 4 + extra13boy;
		else if numgirls=5 then kidrooms = 4 + extra13girl;
		else if numboys=4 then kidrooms = 3 + extra13boy + extra13girl;
		else if numgirls=4 then kidrooms = 3 + extra13boy + extra13girl;
		else if numboys=3 then kidrooms = 4 + extra13boy + extra13girl;
	end;

	
	else if numkids = 7 then do; 
		if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and boy3 <= 5 and girl3 <= 5 then kidrooms = 4;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numboys<=5 then kidrooms = 4 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numgirls<=5 then kidrooms = 4 + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and numboys = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and numgirls = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if numboys = 7 then kidrooms = 4 + extra13boy;
		else if numgirls = 7 then kidrooms = 4 + extra13girl; 
		else if numboys = 6 then kidrooms = 4 + extra13boy;
		else if numgirls = 6 then kidrooms = 4 + extra13girl; 
		else if numboys = 5 then kidrooms = 4 + extra13boy + extra13girl;
		else if numgirls = 5 then kidrooms = 4 + extra13boy + extra13girl;
		else if numboys = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if numgirls = 4 then kidrooms = 4 + extra13boy + extra13girl;
	end;

	else if numkids = 8 then do; 
		if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and boy3 <= 5 and girl3 <= 5 and boy4 <= 5 and girl4 <= 5 then kidrooms = 4;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and boy3 <= 5 and girl3 <= 5 and numboys<=5 then kidrooms = 4 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and boy3 <= 5 and girl3 <= 5 and numgirls<=5 then kidrooms = 4 + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numboys<=5 then kidrooms = 4 + extra13boy;
		else if boy1 <= 5 and girl1 <= 5 and boy2 <= 5 and girl2 <= 5 and numgirls<=5 then kidrooms = 4 + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and numboys = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if boy1 <= 5 and girl1 <= 5 and numgirls = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if numboys = 8 then kidrooms = 4 + extra13boy;
		else if numgirls = 8 then kidrooms = 4 + extra13girl;
		else if numboys = 7 then kidrooms = 4 + extra13boy;
		else if numgirls = 7 then kidrooms = 4 + extra13girl; 
		else if numboys = 6 then kidrooms = 4 + extra13boy;
		else if numgirls = 6 then kidrooms = 4 + extra13girl; 
		else if numboys = 5 then kidrooms = 4 + extra13boy + extra13girl;
		else if numgirls = 5 then kidrooms = 4 + extra13boy + extra13girl;
		else if numboys = 4 then kidrooms = 4 + extra13boy + extra13girl;
		else if numgirls = 4 then kidrooms = 4 + extra13boy + extra13girl;
	end;


run;

proc freq data = bg;
	tables kidrooms*numkids;
run;

data &outdata.;
	set bg;
	keep serial kidrooms;
run;

%mend KidsBedroomsNeeded;

/* End of Macro */
