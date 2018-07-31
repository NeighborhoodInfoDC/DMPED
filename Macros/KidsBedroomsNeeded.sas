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


data pretables2;
	set ipums.Acs_2012_16_dc;
	*set pretables;
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
	diffgirll2to1=girl2-girl1;
	diffgirl3to2=girl3-girl2;
	diffgirl4to3=girl4-girl3;
	diffgirl5to4=girl5-girl4;
	diffgirl6to5=girl6-girl5;
	end;

run;

/* Use counts and ages to determine bedrooms needed */
data bg (drop=count _label_ _name_);
	merge boys2 girls2;
	by serial;

	numkids = sum(of numboys numgirls);

	
	if numkids = 1 then kidrooms = 1; 

	else if numkids = 2 then do;
		if boy1 <= 5 and girl1 <= 5 then kidrooms = 1;
		else if ( 0 <= boy1 < 13 and 0 <= boy2 < 13 ) or ( 0 <= girl1 < 13 and 0 <= girl2 < 13) then kidsrooms=1;
	    else if (numboys=2 and diffboy2to1 < 5) or (numgirls = 2 and diffgirl2to1 < 5) then kidrooms = 1; 
		else kidrooms = 2;
	end;

	else if numkids = 3 then kidrooms = 2;

	else if numkids = 4 then do;
		if numboys = 4 or numgirls = 4 then kidrooms = 2;
		else if numboys = 2 and numgirls = 2 then kidrooms = 2;
		else if numboys = 3 and boy1 <=5 and girl1 <=5 then kidrooms = 2;
		else if numgirls = 3 and boy1 <=5 and girl1 <=5 then kidrooms = 2;
		else kidrooms = 3;
	end;

	else if numkids = 5 then kidrooms = 3;

	else if numkids = 6 then do;
		if numboys = 6 or numgirls = 6 then kidrooms = 3;
		else if numboys = 5 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else if numgirls = 5 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else if numboys = 4 then kidrooms = 3;
		else if numgirls = 4 then kidrooms = 3;
		else if numboys = 3 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else kidrooms = 4;
	end;

	else if numkids = 7 then kidrooms = 4;

	else if numkids = 8 then do;
		if numboys = 8 or numgirls = 8 then kidrooms = 4;
		else if numboys = 7 and boy1 <=5 and girl1 <=5 then kidrooms = 4;
		else if numgirls = 7 and boy1 <=5 and girl1 <=5 then kidrooms = 4;
		else if numboys = 6 then kidrooms = 3;
		else if numgirls = 6 then kidrooms = 3;
		else if numboys = 5 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else if numgirls = 5 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else if numboys = 4 then kidrooms = 3;
		else if numgirls = 4 then kidrooms = 3;
		else if numboys = 3 and boy1 <=5 and girl1 <=5 then kidrooms = 3;
		else kidrooms = 4;
	end;


run;


proc freq data = bg;
	tables kidrooms;
run;
