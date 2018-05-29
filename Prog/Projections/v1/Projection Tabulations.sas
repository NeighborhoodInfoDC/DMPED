/**************************************************************************
 Program:  Projection Tabulations.sas
 Library:  DMPED
 Project:  NeighborhoodInfo DC
 Author:   Graham MacDonald
 Created:  1/24/2014
 Version:  SAS 9.2
 
 Description: Tabulate matrix for impuatation of certain characteristics
				for the population projections.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Ipums )
%DCData_lib( DMPED )

%include "K:\Metro\PTatian\DCData\Libraries\IPUMS\Prog\hud_inc_all.sas";
%include "K:\Metro\PTatian\DCData\Libraries\IPUMS\Prog\hud_inc_2012.sas";

%macro age_cats();
	
	%let i = -1;
	if age = . then agecat = .;
	%do %until (&i. > 80);
		%let i = %eval(&i. + 5);
		%let j = %eval(&i. - 4);
		else if &j. <= age <= &i. then agecat = "&j. - &i.";
	%end;
	else agecat = "85 and older";

%mend age_cats;

filename asciidat "D:\DCData\Libraries\DMPED\Raw\usa_00034.dat";

data 
  DMPED.ACS_2009_12 (label="IPUMS ACS sample, 2009-12")
  ;
length agecat $12. race_ethnicity $29.;

/**** COPY INFILE, INPUT, AND LABEL STATEMENTS FROM DOWNLOADED SAS PROGRAM HERE ****/

infile ASCIIDAT pad missover lrecl=1326;

input
  RECTYPE     $ 1-1
  YEAR          2-5
  DATANUM       6-7
  SERIAL        8-15
  NUMPREC       16-17
  SUBSAMP       18-19
  HHWT          20-29 .2
  HHTYPE        30-30
  REPWT         31-31
  CLUSTER       32-44
  ADJUST        45-51 .6
  CPI99         52-56 .3
  REGION        57-58
  STATEICP      59-60
  STATEFIP      61-62
  COUNTY        63-66
  METRO         67-67
  METAREA       68-70
  METAREAD      71-74
  CITY          75-78
  CITYPOP       79-83
  PUMA          84-88
  PUMARES2MIG   89-93
  STRATA        94-105
  PUMASUPR      106-110
  CONSPUMA      111-113
  APPAL         114-114
  APPALD        115-116
  HOMELAND      117-117
  CNTRY         118-120
  GQ            121-121
  GQTYPE        122-122
  GQTYPED       123-125
  FARM          126-126
  OWNERSHP      127-127
  OWNERSHPD     128-129
  MORTGAGE      130-130
  MORTGAG2      131-131
  COMMUSE       132-132
  FARMPROD      133-133
  ACREHOUS      134-134
  MORTAMT1      135-139
  MORTAMT2      140-143
  TAXINCL       144-144
  INSINCL       145-145
  PROPINSR      146-149
  PROPTX99      150-151
  OWNCOST       152-156
  RENT          157-160
  RENTGRS       161-164
  RENTMEAL      165-165
  CONDOFEE      166-169
  MOBLHOME      170-173
  COSTELEC      174-177
  COSTGAS       178-181
  COSTWATR      182-185
  COSTFUEL      186-189
  HHINCOME      190-196
  FOODSTMP      197-197
  VALUEH        198-204
  LINGISOL      205-205
  VACANCY       206-206
  KITCHEN       207-207
  FRIDGE        208-208
  SINK          209-209
  STOVE         210-210
  ROOMS         211-212
  PLUMBING      213-214
  HOTWATER      215-215
  SHOWER        216-216
  TOILET        217-217
  BUILTYR2      218-219
  UNITSSTR      220-221
  BEDROOMS      222-223
  PHONE         224-224
  FUELHEAT      225-225
  VEHICLES      226-226
  NFAMS         227-228
  NSUBFAM       229-229
  NCOUPLES      230-230
  NMOTHERS      231-231
  NFATHERS      232-232
  MULTGEN       233-233
  MULTGEND      234-235
  CBNSUBFAM     236-236
  REPWT1        237-240
  REPWT2        241-244
  REPWT3        245-248
  REPWT4        249-252
  REPWT5        253-256
  REPWT6        257-260
  REPWT7        261-264
  REPWT8        265-268
  REPWT9        269-272
  REPWT10       273-276
  REPWT11       277-280
  REPWT12       281-284
  REPWT13       285-288
  REPWT14       289-292
  REPWT15       293-296
  REPWT16       297-300
  REPWT17       301-304
  REPWT18       305-308
  REPWT19       309-312
  REPWT20       313-316
  REPWT21       317-320
  REPWT22       321-324
  REPWT23       325-328
  REPWT24       329-332
  REPWT25       333-336
  REPWT26       337-340
  REPWT27       341-344
  REPWT28       345-348
  REPWT29       349-352
  REPWT30       353-356
  REPWT31       357-360
  REPWT32       361-364
  REPWT33       365-368
  REPWT34       369-372
  REPWT35       373-376
  REPWT36       377-380
  REPWT37       381-384
  REPWT38       385-388
  REPWT39       389-392
  REPWT40       393-396
  REPWT41       397-400
  REPWT42       401-404
  REPWT43       405-408
  REPWT44       409-412
  REPWT45       413-416
  REPWT46       417-420
  REPWT47       421-424
  REPWT48       425-428
  REPWT49       429-432
  REPWT50       433-436
  REPWT51       437-440
  REPWT52       441-444
  REPWT53       445-448
  REPWT54       449-452
  REPWT55       453-456
  REPWT56       457-460
  REPWT57       461-464
  REPWT58       465-468
  REPWT59       469-472
  REPWT60       473-476
  REPWT61       477-480
  REPWT62       481-484
  REPWT63       485-488
  REPWT64       489-492
  REPWT65       493-496
  REPWT66       497-500
  REPWT67       501-504
  REPWT68       505-508
  REPWT69       509-512
  REPWT70       513-516
  REPWT71       517-520
  REPWT72       521-524
  REPWT73       525-528
  REPWT74       529-532
  REPWT75       533-536
  REPWT76       537-540
  REPWT77       541-544
  REPWT78       545-548
  REPWT79       549-552
  REPWT80       553-556
  RESPMODE      557-557
  PERNUM        558-561
  PERWT         562-571 .2
  SLWT          572-581 .2
  REPWTP        582-582
  MOMLOC        583-584
  STEPMOM       585-585
  MOMRULE       586-586
  POPLOC        587-588
  STEPPOP       589-589
  POPRULE       590-590
  SPLOC         591-592
  SPRULE        593-593
  FAMSIZE       594-595
  NCHILD        596-596
  NCHLT5        597-597
  FAMUNIT       598-599
  ELDCH         600-601
  YNGCH         602-603
  NSIBS         604-604
  SUBFAM        605-605
  SFTYPE        606-606
  SFRELATE      607-607
  CBSUBFAM      608-608
  CBSFTYPE      609-609
  CBSFRELATE    610-610
  RELATE        611-612
  RELATED       613-616
  AGE           617-619
  SEX           620-620
  MARST         621-621
  BIRTHQTR      622-622
  BIRTHYR       623-626
  MARRNO        627-627
  MARRINYR      628-628
  YRMARR        629-632
  WIDINYR       633-633
  DIVINYR       634-634
  FERTYR        635-635
  RACE          636-636
  RACED         637-639
  BPL           640-642
  BPLD          643-647
  ANCESTR1      648-650
  ANCESTR1D     651-654
  ANCESTR2      655-657
  ANCESTR2D     658-661
  CITIZEN       662-662
  YRNATUR       663-666
  YRIMMIG       667-670
  YRSUSA1       671-672
  YRSUSA2       673-673
  LANGUAGE      674-675
  LANGUAGED     676-679
  SPEAKENG      680-680
  HISPAN        681-681
  HISPAND       682-684
  TRIBE         685-688
  TRIBED        689-694
  RACESING      695-695
  RACESINGD     696-697
  RACAMIND      698-698
  RACASIAN      699-699
  RACBLK        700-700
  RACPACIS      701-701
  RACWHT        702-702
  RACOTHER      703-703
  RACNUM        704-704
  HCOVANY       705-705
  HCOVPRIV      706-706
  HINSEMP       707-707
  HINSPUR       708-708
  HINSTRI       709-709
  HCOVPUB       710-710
  HINSCAID      711-711
  HINSCARE      712-712
  HINSVA        713-713
  HINSIHS       714-714
  SCHOOL        715-715
  HIUFPGBASE    716-720
  HIUFPGINC     721-724
  HIURULE       725-725
  HIUID         726-734
  HIUNPERS      735-736
  EDUC          737-738
  EDUCD         739-741
  GRADEATT      742-742
  GRADEATTD     743-744
  SCHLTYPE      745-745
  DEGFIELD      746-747
  DEGFIELDD     748-751
  DEGFIELD2     752-753
  DEGFIELD2D    754-757
  EMPSTAT       758-758
  EMPSTATD      759-760
  LABFORCE      761-761
  OCC           762-765
  OCC1950       766-768
  OCC1990       769-771
  IND           772-775
  IND1950       776-778
  IND1990       779-781
  CLASSWKR      782-782
  CLASSWKRD     783-784
  OCCSOC      $ 785-790
  INDNAICS    $ 791-798
  WKSWORK2      799-799
  UHRSWORK      800-801
  ABSENT        802-802
  LOOKING       803-803
  AVAILBLE      804-804
  WRKRECAL      805-805
  WORKEDYR      806-806
  INCTOT        807-813
  FTOTINC       814-820
  INCWAGE       821-826
  INCBUS00      827-832
  INCSS         833-837
  INCWELFR      838-842
  INCINVST      843-848
  INCRETIR      849-854
  INCSUPP       855-859
  INCOTHER      860-864
  INCEARN       865-871
  POVERTY       872-874
  OCCSCORE      875-876
  SEI           877-878
  HWSEI         879-882 .2
  PRESGL        883-885 .1
  PRENT         886-888 .1
  ERSCOR50      889-892 .1
  ERSCOR90      893-896 .1
  EDSCOR50      897-900 .1
  EDSCOR90      901-904 .1
  NPBOSS50      905-908 .1
  NPBOSS90      909-912 .1
  MIGRATE1      913-913
  MIGRATE1D     914-915
  MIGPLAC1      916-918
  MIGMET1       919-922
  MIGTYPE1      923-923
  MIGCITY1      924-927
  MIGPUMS1      928-930
  MIGPUMA1      931-933
  MOVEDIN       934-934
  VETDISAB      935-935
  DIFFREM       936-936
  DIFFPHYS      937-937
  DIFFMOB       938-938
  DIFFCARE      939-939
  DIFFSENS      940-940
  DIFFEYE       941-941
  DIFFHEAR      942-942
  VETSTAT       943-943
  VETSTATD      944-945
  VET01LTR      946-946
  VET90X01      947-947
  VET80X90      948-948
  VET75X80      949-949
  VETVIETN      950-950
  VET55X64      951-951
  VETKOREA      952-952
  VET47X50      953-953
  VETWWII       954-954
  VETOTHER      955-955
  PWSTATE2      956-957
  PWMETRO       958-961
  PWCITY        962-965
  PWTYPE        966-966
  PWPUMA00      967-970
  PWPUMAS       971-973
  TRANWORK      974-975
  CARPOOL       976-976
  RIDERS        977-977
  TRANTIME      978-980
  DEPARTS       981-984
  ARRIVES       985-988
  GCHOUSE       989-989
  GCMONTHS      990-990
  GCRESPON      991-991
  PROBAI        992-994
  PROBAPI       995-997
  PROBBLK       998-1000
  PROBOTH       1001-1003
  PROBWHT       1004-1006
  REPWTP1       1007-1010
  REPWTP2       1011-1014
  REPWTP3       1015-1018
  REPWTP4       1019-1022
  REPWTP5       1023-1026
  REPWTP6       1027-1030
  REPWTP7       1031-1034
  REPWTP8       1035-1038
  REPWTP9       1039-1042
  REPWTP10      1043-1046
  REPWTP11      1047-1050
  REPWTP12      1051-1054
  REPWTP13      1055-1058
  REPWTP14      1059-1062
  REPWTP15      1063-1066
  REPWTP16      1067-1070
  REPWTP17      1071-1074
  REPWTP18      1075-1078
  REPWTP19      1079-1082
  REPWTP20      1083-1086
  REPWTP21      1087-1090
  REPWTP22      1091-1094
  REPWTP23      1095-1098
  REPWTP24      1099-1102
  REPWTP25      1103-1106
  REPWTP26      1107-1110
  REPWTP27      1111-1114
  REPWTP28      1115-1118
  REPWTP29      1119-1122
  REPWTP30      1123-1126
  REPWTP31      1127-1130
  REPWTP32      1131-1134
  REPWTP33      1135-1138
  REPWTP34      1139-1142
  REPWTP35      1143-1146
  REPWTP36      1147-1150
  REPWTP37      1151-1154
  REPWTP38      1155-1158
  REPWTP39      1159-1162
  REPWTP40      1163-1166
  REPWTP41      1167-1170
  REPWTP42      1171-1174
  REPWTP43      1175-1178
  REPWTP44      1179-1182
  REPWTP45      1183-1186
  REPWTP46      1187-1190
  REPWTP47      1191-1194
  REPWTP48      1195-1198
  REPWTP49      1199-1202
  REPWTP50      1203-1206
  REPWTP51      1207-1210
  REPWTP52      1211-1214
  REPWTP53      1215-1218
  REPWTP54      1219-1222
  REPWTP55      1223-1226
  REPWTP56      1227-1230
  REPWTP57      1231-1234
  REPWTP58      1235-1238
  REPWTP59      1239-1242
  REPWTP60      1243-1246
  REPWTP61      1247-1250
  REPWTP62      1251-1254
  REPWTP63      1255-1258
  REPWTP64      1259-1262
  REPWTP65      1263-1266
  REPWTP66      1267-1270
  REPWTP67      1271-1274
  REPWTP68      1275-1278
  REPWTP69      1279-1282
  REPWTP70      1283-1286
  REPWTP71      1287-1290
  REPWTP72      1291-1294
  REPWTP73      1295-1298
  REPWTP74      1299-1302
  REPWTP75      1303-1306
  REPWTP76      1307-1310
  REPWTP77      1311-1314
  REPWTP78      1315-1318
  REPWTP79      1319-1322
  REPWTP80      1323-1326
;

label
  RECTYPE     = "Record type"
  YEAR        = "Census year"
  DATANUM     = "Data set number"
  SERIAL      = "Household serial number"
  NUMPREC     = "Number of person records following"
  SUBSAMP     = "Subsample number"
  HHWT        = "Household weight"
  HHTYPE      = "Household Type"
  REPWT       = "Household replicate weights"
  CLUSTER     = "Household cluster for variance estimation"
  ADJUST      = "Adjustment factor, ACS/PRCS"
  CPI99       = "CPI-U adjustment factor to 1999 dollars"
  REGION      = "Census region and division"
  STATEICP    = "State (ICPSR code)"
  STATEFIP    = "State (FIPS code)"
  COUNTY      = "County"
  METRO       = "Metropolitan status"
  METAREA     = "Metropolitan area [general version]"
  METAREAD    = "Metropolitan area [detailed version]"
  CITY        = "City"
  CITYPOP     = "City population"
  PUMA        = "Public Use Microdata Area"
  PUMARES2MIG = "Public Use Microdata Area matching MIGPUMA"
  STRATA      = "Household strata for variance estimation"
  PUMASUPR    = "Super Public Use Microdata Area"
  CONSPUMA    = "Consistent Public Use Microdata Area"
  APPAL       = "Appalachian region [general version]"
  APPALD      = "Appalachian region [detailed version]"
  HOMELAND    = "American Indian, Alaska Native, or Native Hawaiian homeland area"
  CNTRY       = "Country"
  GQ          = "Group quarters status"
  GQTYPE      = "Group quarters type [general version]"
  GQTYPED     = "Group quarters type [detailed version]"
  FARM        = "Farm status"
  OWNERSHP    = "Ownership of dwelling (tenure) [general version]"
  OWNERSHPD   = "Ownership of dwelling (tenure) [detailed version]"
  MORTGAGE    = "Mortgage status"
  MORTGAG2    = "Second mortgage status"
  COMMUSE     = "Commercial use"
  FARMPROD    = "Sales of farm products"
  ACREHOUS    = "House acreage"
  MORTAMT1    = "First mortgage monthly payment"
  MORTAMT2    = "Second mortgage monthly payment"
  TAXINCL     = "Mortgage payment includes property taxes"
  INSINCL     = "Mortgage payment includes property insurance"
  PROPINSR    = "Annual property insurance cost"
  PROPTX99    = "Annual property taxes, 1990"
  OWNCOST     = "Selected monthly owner costs"
  RENT        = "Monthly contract rent"
  RENTGRS     = "Monthly gross rent"
  RENTMEAL    = "Meals included in rent"
  CONDOFEE    = "Monthly condominium fee"
  MOBLHOME    = "Annual mobile home costs"
  COSTELEC    = "Annual electricity cost"
  COSTGAS     = "Annual gas cost"
  COSTWATR    = "Annual water cost"
  COSTFUEL    = "Annual home heating fuel cost"
  HHINCOME    = "Total household income"
  FOODSTMP    = "Food stamp recipiency"
  VALUEH      = "House value"
  LINGISOL    = "Linguistic isolation"
  VACANCY     = "Vacancy status"
  KITCHEN     = "Kitchen or cooking facilities"
  FRIDGE      = "Refrigerator"
  SINK        = "Sink with faucet"
  STOVE       = "Stove or range"
  ROOMS       = "Number of rooms"
  PLUMBING    = "Plumbing facilities"
  HOTWATER    = "Hot and cold piped water"
  SHOWER      = "Bathtub or shower"
  TOILET      = "Flush toilet"
  BUILTYR2    = "Age of structure, decade"
  UNITSSTR    = "Units in structure"
  BEDROOMS    = "Number of bedrooms"
  PHONE       = "Telephone availability"
  FUELHEAT    = "Home heating fuel"
  VEHICLES    = "Vehicles available"
  NFAMS       = "Number of families in household"
  NSUBFAM     = "Number of subfamilies in household"
  NCOUPLES    = "Number of married couples in household"
  NMOTHERS    = "Number of mothers in household"
  NFATHERS    = "Number of fathers in household"
  MULTGEN     = "Multigenerational household [general version]"
  MULTGEND    = "Multigenerational household [detailed version]"
  CBNSUBFAM   = "Number of subfamilies in household (original Census Bureau classification)"
  REPWT1      = "Household replicate weight 1"
  REPWT2      = "Household replicate weight 2"
  REPWT3      = "Household replicate weight 3"
  REPWT4      = "Household replicate weight 4"
  REPWT5      = "Household replicate weight 5"
  REPWT6      = "Household replicate weight 6"
  REPWT7      = "Household replicate weight 7"
  REPWT8      = "Household replicate weight 8"
  REPWT9      = "Household replicate weight 9"
  REPWT10     = "Household replicate weight 10"
  REPWT11     = "Household replicate weight 11"
  REPWT12     = "Household replicate weight 12"
  REPWT13     = "Household replicate weight 13"
  REPWT14     = "Household replicate weight 14"
  REPWT15     = "Household replicate weight 15"
  REPWT16     = "Household replicate weight 16"
  REPWT17     = "Household replicate weight 17"
  REPWT18     = "Household replicate weight 18"
  REPWT19     = "Household replicate weight 19"
  REPWT20     = "Household replicate weight 20"
  REPWT21     = "Household replicate weight 21"
  REPWT22     = "Household replicate weight 22"
  REPWT23     = "Household replicate weight 23"
  REPWT24     = "Household replicate weight 24"
  REPWT25     = "Household replicate weight 25"
  REPWT26     = "Household replicate weight 26"
  REPWT27     = "Household replicate weight 27"
  REPWT28     = "Household replicate weight 28"
  REPWT29     = "Household replicate weight 29"
  REPWT30     = "Household replicate weight 30"
  REPWT31     = "Household replicate weight 31"
  REPWT32     = "Household replicate weight 32"
  REPWT33     = "Household replicate weight 33"
  REPWT34     = "Household replicate weight 34"
  REPWT35     = "Household replicate weight 35"
  REPWT36     = "Household replicate weight 36"
  REPWT37     = "Household replicate weight 37"
  REPWT38     = "Household replicate weight 38"
  REPWT39     = "Household replicate weight 39"
  REPWT40     = "Household replicate weight 40"
  REPWT41     = "Household replicate weight 41"
  REPWT42     = "Household replicate weight 42"
  REPWT43     = "Household replicate weight 43"
  REPWT44     = "Household replicate weight 44"
  REPWT45     = "Household replicate weight 45"
  REPWT46     = "Household replicate weight 46"
  REPWT47     = "Household replicate weight 47"
  REPWT48     = "Household replicate weight 48"
  REPWT49     = "Household replicate weight 49"
  REPWT50     = "Household replicate weight 50"
  REPWT51     = "Household replicate weight 51"
  REPWT52     = "Household replicate weight 52"
  REPWT53     = "Household replicate weight 53"
  REPWT54     = "Household replicate weight 54"
  REPWT55     = "Household replicate weight 55"
  REPWT56     = "Household replicate weight 56"
  REPWT57     = "Household replicate weight 57"
  REPWT58     = "Household replicate weight 58"
  REPWT59     = "Household replicate weight 59"
  REPWT60     = "Household replicate weight 60"
  REPWT61     = "Household replicate weight 61"
  REPWT62     = "Household replicate weight 62"
  REPWT63     = "Household replicate weight 63"
  REPWT64     = "Household replicate weight 64"
  REPWT65     = "Household replicate weight 65"
  REPWT66     = "Household replicate weight 66"
  REPWT67     = "Household replicate weight 67"
  REPWT68     = "Household replicate weight 68"
  REPWT69     = "Household replicate weight 69"
  REPWT70     = "Household replicate weight 70"
  REPWT71     = "Household replicate weight 71"
  REPWT72     = "Household replicate weight 72"
  REPWT73     = "Household replicate weight 73"
  REPWT74     = "Household replicate weight 74"
  REPWT75     = "Household replicate weight 75"
  REPWT76     = "Household replicate weight 76"
  REPWT77     = "Household replicate weight 77"
  REPWT78     = "Household replicate weight 78"
  REPWT79     = "Household replicate weight 79"
  REPWT80     = "Household replicate weight 80"
  RESPMODE    = "Response mode"
  PERNUM      = "Person number in sample unit"
  PERWT       = "Person weight"
  SLWT        = "Sample-line weight"
  REPWTP      = "Person replicate weights"
  MOMLOC      = "Mother's location in the household"
  STEPMOM     = "Probable step/adopted mother"
  MOMRULE     = "Rule for linking mother"
  POPLOC      = "Father's location in the household"
  STEPPOP     = "Probable step/adopted father"
  POPRULE     = "Rule for linking father"
  SPLOC       = "Spouse's location in household"
  SPRULE      = "Rule for linking spouse"
  FAMSIZE     = "Number of own family members in household"
  NCHILD      = "Number of own children in the household"
  NCHLT5      = "Number of own children under age 5 in household"
  FAMUNIT     = "Family unit membership"
  ELDCH       = "Age of eldest own child in household"
  YNGCH       = "Age of youngest own child in household"
  NSIBS       = "Number of own siblings in household"
  SUBFAM      = "Subfamily membership"
  SFTYPE      = "Subfamily type"
  SFRELATE    = "Relationship within subfamily"
  CBSUBFAM    = "Subfamily number (original Census Bureau classification)"
  CBSFTYPE    = "Subfamily type (original Census Bureau classification)"
  CBSFRELATE  = "Subfamily relationship (original Census Bureau classification)"
  RELATE      = "Relationship to household head [general version]"
  RELATED     = "Relationship to household head [detailed version]"
  AGE         = "Age"
  SEX         = "Sex"
  MARST       = "Marital status"
  BIRTHQTR    = "Quarter of birth"
  BIRTHYR     = "Year of birth"
  MARRNO      = "Times married"
  MARRINYR    = "Married within the past year"
  YRMARR      = "Year married"
  WIDINYR     = "Widowed in the past year"
  DIVINYR     = "Divorced in the past year"
  FERTYR      = "Children born within the last year"
  RACE        = "Race [general version]"
  RACED       = "Race [detailed version]"
  BPL         = "Birthplace [general version]"
  BPLD        = "Birthplace [detailed version]"
  ANCESTR1    = "Ancestry, first response [general version]"
  ANCESTR1D   = "Ancestry, first response [detailed version]"
  ANCESTR2    = "Ancestry, second response [general version]"
  ANCESTR2D   = "Ancestry, second response [detailed version]"
  CITIZEN     = "Citizenship status"
  YRNATUR     = "Year naturalized"
  YRIMMIG     = "Year of immigration"
  YRSUSA1     = "Years in the United States"
  YRSUSA2     = "Years in the United States, intervalled"
  LANGUAGE    = "Language spoken [general version]"
  LANGUAGED   = "Language spoken [detailed version]"
  SPEAKENG    = "Speaks English"
  HISPAN      = "Hispanic origin [general version]"
  HISPAND     = "Hispanic origin [detailed version]"
  TRIBE       = "Tribe [general version]"
  TRIBED      = "Tribe [detailed version]"
  RACESING    = "Race: Single race identification [general version]"
  RACESINGD   = "Race: Single race identification [detailed version]"
  RACAMIND    = "Race: American Indian or Alaska Native"
  RACASIAN    = "Race: Asian"
  RACBLK      = "Race: black or African American"
  RACPACIS    = "Race: Pacific Islander"
  RACWHT      = "Race: white"
  RACOTHER    = "Race: some other race"
  RACNUM      = "Number of major race groups"
  HCOVANY     = "Any health insurance coverage"
  HCOVPRIV    = "Private health insurance coverage"
  HINSEMP     = "Health insurance through employer/union"
  HINSPUR     = "Health insurance purchased directly"
  HINSTRI     = "Health insurance through TRICARE"
  HCOVPUB     = "Public health insurance coverage"
  HINSCAID    = "Health insurance through Medicaid"
  HINSCARE    = "Health insurance through Medicare"
  HINSVA      = "Health insurance through VA"
  HINSIHS     = "Health insurance through Indian Health Services"
  SCHOOL      = "School attendance"
  HIUFPGBASE  = "Federal poverty guidelines (base)"
  HIUFPGINC   = "Federal poverty guidelines (increment)"
  HIURULE     = "HIU pointer rule"
  HIUID       = "HIU identification"
  HIUNPERS    = "HIU number of persons"
  EDUC        = "Educational attainment [general version]"
  EDUCD       = "Educational attainment [detailed version]"
  GRADEATT    = "Grade level attending [general version]"
  GRADEATTD   = "Grade level attending [detailed version]"
  SCHLTYPE    = "Public or private school"
  DEGFIELD    = "Field of degree [general version]"
  DEGFIELDD   = "Field of degree [detailed version]"
  DEGFIELD2   = "Field of degree (2) [general version]"
  DEGFIELD2D  = "Field of degree (2) [detailed version]"
  EMPSTAT     = "Employment status [general version]"
  EMPSTATD    = "Employment status [detailed version]"
  LABFORCE    = "Labor force status"
  OCC         = "Occupation"
  OCC1950     = "Occupation, 1950 basis"
  OCC1990     = "Occupation, 1990 basis"
  IND         = "Industry"
  IND1950     = "Industry, 1950 basis"
  IND1990     = "Industry, 1990 basis"
  CLASSWKR    = "Class of worker [general version]"
  CLASSWKRD   = "Class of worker [detailed version]"
  OCCSOC      = "Occupation, SOC classification"
  INDNAICS    = "Industry, NAICS classification"
  WKSWORK2    = "Weeks worked last year, intervalled"
  UHRSWORK    = "Usual hours worked per week"
  ABSENT      = "Absent from work last week"
  LOOKING     = "Looking for work"
  AVAILBLE    = "Available for work"
  WRKRECAL    = "Informed of work recall"
  WORKEDYR    = "Worked last year"
  INCTOT      = "Total personal income"
  FTOTINC     = "Total family income"
  INCWAGE     = "Wage and salary income"
  INCBUS00    = "Business and farm income, 2000"
  INCSS       = "Social Security income"
  INCWELFR    = "Welfare (public assistance) income"
  INCINVST    = "Interest, dividend, and rental income"
  INCRETIR    = "Retirement income"
  INCSUPP     = "Supplementary Security Income"
  INCOTHER    = "Other income"
  INCEARN     = "Total personal earned income"
  POVERTY     = "Poverty status"
  OCCSCORE    = "Occupational income score"
  SEI         = "Duncan Socioeconomic Index"
  HWSEI       = "Socioeconomic Index, Hauser and Warren"
  PRESGL      = "Occupational prestige score, Siegel"
  PRENT       = "Occupational prestige score, Nakao and Treas"
  ERSCOR50    = "Occupational earnings score, 1950 basis"
  ERSCOR90    = "Occupational earnings score, 1990 basis"
  EDSCOR50    = "Occupational education score, 1950 basis"
  EDSCOR90    = "Occupational education score, 1990 basis"
  NPBOSS50    = "Nam-Powers-Boyd occupational status score, 1950 basis"
  NPBOSS90    = "Nam-Powers-Boyd occupational status score, 1990 basis"
  MIGRATE1    = "Migration status, 1 year [general version]"
  MIGRATE1D   = "Migration status, 1 year [detailed version]"
  MIGPLAC1    = "State or country of residence 1 year ago"
  MIGMET1     = "Metropolitan area of residence 1 year ago"
  MIGTYPE1    = "Metropolitan status 1 year ago"
  MIGCITY1    = "City of residence 1 year ago"
  MIGPUMS1    = "Super-PUMA of residence 1 year ago"
  MIGPUMA1    = "PUMA of residence 1 year ago"
  MOVEDIN     = "When occupant moved into residence"
  VETDISAB    = "VA service-connected disability rating"
  DIFFREM     = "Cognitive difficulty"
  DIFFPHYS    = "Ambulatory difficulty"
  DIFFMOB     = "Independent living difficulty"
  DIFFCARE    = "Self-care difficulty"
  DIFFSENS    = "Vision or hearing difficulty"
  DIFFEYE     = "Vision difficulty"
  DIFFHEAR    = "Hearing difficulty"
  VETSTAT     = "Veteran status [general version]"
  VETSTATD    = "Veteran status [detailed version]"
  VET01LTR    = "Veteran, served 2001 or later"
  VET90X01    = "Veteran, served 1990-2001"
  VET80X90    = "Veteran, served 1980 to 1990"
  VET75X80    = "Veteran, served 1975 to 1980"
  VETVIETN    = "Veteran, served during Vietnam era"
  VET55X64    = "Veteran, served 1955 to 1964"
  VETKOREA    = "Veteran, served during Korean conflict era"
  VET47X50    = "Veteran, served 1947-1950"
  VETWWII     = "Veteran, served during WWII era"
  VETOTHER    = "Veteran of other period"
  PWSTATE2    = "Place of work: state, 1980 onward"
  PWMETRO     = "Place of work: metropolitan area"
  PWCITY      = "Place of work: city"
  PWTYPE      = "Place of work: metropolitan status"
  PWPUMA00    = "Place of work: PUMA, 2000 onward"
  PWPUMAS     = "Super-PUMA of work"
  TRANWORK    = "Means of transportation to work"
  CARPOOL     = "Carpooling"
  RIDERS      = "Vehicle occupancy"
  TRANTIME    = "Travel time to work"
  DEPARTS     = "Time of departure for work"
  ARRIVES     = "Time of arrival at work"
  GCHOUSE     = "Own grandchildren living in household"
  GCMONTHS    = "Months responsible for grandchildren"
  GCRESPON    = "Responsible for grandchildren"
  PROBAI      = "Probability of American Indian race response"
  PROBAPI     = "Probability of Asian/Pacific Islander race response"
  PROBBLK     = "Probability of black race response"
  PROBOTH     = "Probability of 'other race' race response"
  PROBWHT     = "Probability of white race response"
  REPWTP1     = "Person replicate weight 1"
  REPWTP2     = "Person replicate weight 2"
  REPWTP3     = "Person replicate weight 3"
  REPWTP4     = "Person replicate weight 4"
  REPWTP5     = "Person replicate weight 5"
  REPWTP6     = "Person replicate weight 6"
  REPWTP7     = "Person replicate weight 7"
  REPWTP8     = "Person replicate weight 8"
  REPWTP9     = "Person replicate weight 9"
  REPWTP10    = "Person replicate weight 10"
  REPWTP11    = "Person replicate weight 11"
  REPWTP12    = "Person replicate weight 12"
  REPWTP13    = "Person replicate weight 13"
  REPWTP14    = "Person replicate weight 14"
  REPWTP15    = "Person replicate weight 15"
  REPWTP16    = "Person replicate weight 16"
  REPWTP17    = "Person replicate weight 17"
  REPWTP18    = "Person replicate weight 18"
  REPWTP19    = "Person replicate weight 19"
  REPWTP20    = "Person replicate weight 20"
  REPWTP21    = "Person replicate weight 21"
  REPWTP22    = "Person replicate weight 22"
  REPWTP23    = "Person replicate weight 23"
  REPWTP24    = "Person replicate weight 24"
  REPWTP25    = "Person replicate weight 25"
  REPWTP26    = "Person replicate weight 26"
  REPWTP27    = "Person replicate weight 27"
  REPWTP28    = "Person replicate weight 28"
  REPWTP29    = "Person replicate weight 29"
  REPWTP30    = "Person replicate weight 30"
  REPWTP31    = "Person replicate weight 31"
  REPWTP32    = "Person replicate weight 32"
  REPWTP33    = "Person replicate weight 33"
  REPWTP34    = "Person replicate weight 34"
  REPWTP35    = "Person replicate weight 35"
  REPWTP36    = "Person replicate weight 36"
  REPWTP37    = "Person replicate weight 37"
  REPWTP38    = "Person replicate weight 38"
  REPWTP39    = "Person replicate weight 39"
  REPWTP40    = "Person replicate weight 40"
  REPWTP41    = "Person replicate weight 41"
  REPWTP42    = "Person replicate weight 42"
  REPWTP43    = "Person replicate weight 43"
  REPWTP44    = "Person replicate weight 44"
  REPWTP45    = "Person replicate weight 45"
  REPWTP46    = "Person replicate weight 46"
  REPWTP47    = "Person replicate weight 47"
  REPWTP48    = "Person replicate weight 48"
  REPWTP49    = "Person replicate weight 49"
  REPWTP50    = "Person replicate weight 50"
  REPWTP51    = "Person replicate weight 51"
  REPWTP52    = "Person replicate weight 52"
  REPWTP53    = "Person replicate weight 53"
  REPWTP54    = "Person replicate weight 54"
  REPWTP55    = "Person replicate weight 55"
  REPWTP56    = "Person replicate weight 56"
  REPWTP57    = "Person replicate weight 57"
  REPWTP58    = "Person replicate weight 58"
  REPWTP59    = "Person replicate weight 59"
  REPWTP60    = "Person replicate weight 60"
  REPWTP61    = "Person replicate weight 61"
  REPWTP62    = "Person replicate weight 62"
  REPWTP63    = "Person replicate weight 63"
  REPWTP64    = "Person replicate weight 64"
  REPWTP65    = "Person replicate weight 65"
  REPWTP66    = "Person replicate weight 66"
  REPWTP67    = "Person replicate weight 67"
  REPWTP68    = "Person replicate weight 68"
  REPWTP69    = "Person replicate weight 69"
  REPWTP70    = "Person replicate weight 70"
  REPWTP71    = "Person replicate weight 71"
  REPWTP72    = "Person replicate weight 72"
  REPWTP73    = "Person replicate weight 73"
  REPWTP74    = "Person replicate weight 74"
  REPWTP75    = "Person replicate weight 75"
  REPWTP76    = "Person replicate weight 76"
  REPWTP77    = "Person replicate weight 77"
  REPWTP78    = "Person replicate weight 78"
  REPWTP79    = "Person replicate weight 79"
  REPWTP80    = "Person replicate weight 80"
;

format
 year yearx_f.
 /***LONG FORMAT NAME ***  numprec numprec_f.***/
 numprec numprecf.
 /***LONG FORMAT NAME ***   subsamp subsamp_f.***/
 subsamp subsampf.
 hhtype hhtype_f.
 region region_f.
 /***LONG FORMAT NAME *** stateicp stateicp_f.***/
 stateicp stateicp.
 /***LONG FORMAT NAME ***  statefip statefip_f.***/
 statefip statefip.
 metro metro_f.
 /***LONG FORMAT NAME ***   metarea metarea_f.***/
 metarea metareaf.
  /***LONG FORMAT NAME ***   metaread metaread_f.***/
 metaread metaread.
 city city_f.
  /***LONG FORMAT NAME ***  homeland homeland_f.***/
 homeland homeland.
 cntry cntry_f.
 gq gq_f.
 gqtype gqtype_f.
 /***LONG FORMAT NAME ***   gqtyped gqtyped_f.***/
 gqtyped gqtypedf.
 farm farm_f.
 /***LONG FORMAT NAME ***   ownershp ownershp_f.***/
 ownershp ownershp.
 /***LONG FORMAT NAME ***   ownershpd ownershpd_f.***/
 ownershpd ownrshpd.
 /***LONG FORMAT NAME ***   mortgage mortgage_f.***/
 mortgage mortgage.
 /***LONG FORMAT NAME ***   mortgag2 mortgag2_f.***/
 mortgag2 mrtgag2f.
 /***LONG FORMAT NAME ***   commuse commuse_f.***/
 commuse commusef.
 /***LONG FORMAT NAME ***   acrehous acrehous_f.***/
 acrehous acrehous.
 /***LONG FORMAT NAME ***   taxincl taxincl_f.***/
 taxincl taxinclf.
 /***LONG FORMAT NAME ***   insincl insincl_f.***/
 insincl insinclf.
 /***LONG FORMAT NAME ***   proptx99 proptx99_f.***/
 proptx99 prptx99f.
 /***LONG FORMAT NAME ***   rentmeal rentmeal_f.***/
 rentmeal rentmeal.
 /***LONG FORMAT NAME ***   foodstmp foodstmp_f.***/
 foodstmp foodstmp.
 /***LONG FORMAT NAME ***   lingisol lingisol_f.***/
 lingisol lingisol.
 /***LONG FORMAT NAME ***   vacancy vacancy_f.***/
 vacancy vacancyf.
 /***LONG FORMAT NAME ***   kitchen kitchen_f.***/
 kitchen kitchenf.
 rooms rooms_f.
 /***LONG FORMAT NAME ***   plumbing plumbing_f.***/
 plumbing plumbing.
 /***LONG FORMAT NAME ***   builtyr2 builtyr2_f.***/
 builtyr2 builty2f.
 /***LONG FORMAT NAME ***   unitsstr unitsstr_f.***/
 unitsstr unitsstr.
 /***LONG FORMAT NAME ***   bedrooms bedrooms_f.***/
 bedrooms bedrooms.
 phone phone_f.
 /***LONG FORMAT NAME ***   fuelheat fuelheat_f.***/
 fuelheat fuelheat.
 /***LONG FORMAT NAME ***   vehicles vehicles_f.***/
 vehicles vehicles.
 nfams nfams_f.
 /***LONG FORMAT NAME ***   nsubfam nsubfam_f.***/
 nsubfam nsubfamf.
 /***LONG FORMAT NAME ***   ncouples ncouples_f.***/
 ncouples ncouples.
 /***LONG FORMAT NAME ***   nmothers nmothers_f.***/
 nmothers nmothers.
 /***LONG FORMAT NAME ***   nfathers nfathers_f.***/
 nfathers nfathers.
 /***LONG FORMAT NAME ***   multgen multgen_f.***/
 multgen multgenf.
 /***LONG FORMAT NAME ***   multgend multgend_f.***/
 multgend multgend.
 /***LONG FORMAT NAME ***   respmode respmode_f.***/
 respmode respmode.
 /***LONG FORMAT NAME ***   stepmom stepmom_f.***/
 stepmom stepmomf.
 /***LONG FORMAT NAME ***   momrule momrule_f.***/
 momrule momrulef.
 /***LONG FORMAT NAME ***   steppop steppop_f.***/
 steppop steppopf.
 /***LONG FORMAT NAME ***   poprule poprule_f.***/
 poprule poprulef.
 sprule sprule_f.
 /***LONG FORMAT NAME ***   famsize famsize_f.***/
 famsize famsizef.
 nchild nchild_f.
 nchlt5 nchlt5_f.
 /***LONG FORMAT NAME ***   famunit famunit_f.***/
 famunit famunitf.
 eldch eldch_f.
 yngch yngch_f.
 nsibs nsibs_f.
 subfam subfam_f.
 sftype sftype_f.
 /***LONG FORMAT NAME ***   sfrelate sfrelate_f***/
 sfrelate sfrelate.
 relate relate_f.
 /***LONG FORMAT NAME ***   related related_f.***/
 related relatedf.
 age age_f.
 sex sex_f.
 marst marst_f.
 /***LONG FORMAT NAME ***   birthqtr birthqtr_f.***/
 birthqtr birthqtr.
 fertyr fertyr_f.
 race race_f.
 raced raced_f.
 bpl bpl_f.
 bpld bpld_f.
 /***LONG FORMAT NAME ***   ancestr1 ancestr1_f.***/
 ancestr1 ancstr1f.
 /***LONG FORMAT NAME ***   ancestr1d ancestr1d_f.***/
 ancestr1d ancstr1d.
 /***LONG FORMAT NAME ***   ancestr2 ancestr2_f.***/
 ancestr2 ancstr2f.
 /***LONG FORMAT NAME ***   ancestr2d ancestr2d_f.***/
 ancestr2d ancstr2d.
 /***LONG FORMAT NAME ***   citizen citizen_f.***/
 citizen citizenf.
 /***LONG FORMAT NAME ***   yrsusa2 yrsusa2_f.***/
 yrsusa2 yrsusa2f.
 /***LONG FORMAT NAME ***   language language_f.***/
 language language.
 /***LONG FORMAT NAME ***   languaged languaged_f.***/
 languaged lnguaged.
 /***LONG FORMAT NAME ***   speakeng speakeng_f.***/
 speakeng speakeng.
 hispan hispan_f.
 /***LONG FORMAT NAME ***   hispand hispand_f.***/
 hispand hispandf.
 tribe tribe_f.
 tribed tribed_f.
 /***LONG FORMAT NAME ***   racesing racesing_f.***/
 racesing racesing.
 /***LONG FORMAT NAME ***  racesingd racesingd. ***/
 racesingd racesind.
 school school_f.
 educ educ_f.
 educd educd_f.
 /***LONG FORMAT NAME ***   gradeatt gradeatt_f.***/
 gradeatt gradeatt.
 /***LONG FORMAT NAME ***   gradeatt gradeatt_f.***/
 gradeattd grdeattd.
 /***LONG FORMAT NAME ***   schltype schltype_f.***/
 schltype schltype.
 /***LONG FORMAT NAME ***   empstat empstat_f.***/
 empstat empstatf.
 /***LONG FORMAT NAME ***   empstatd empstatd_f.***/
 empstatd empstatd.
 /***LONG FORMAT NAME ***   labforce labforce_f.***/
 labforce labforce.
 /***LONG FORMAT NAME ***   occ1950 occ1950_f.***/
 occ1950 occ1950f.
 /***LONG FORMAT NAME ***   occ1990 occ1990_f.***/
 occ1990 occ1990f.
 /***LONG FORMAT NAME ***   ind1950 ind1950_f.***/
 ind1950 ind1950f.
 /***LONG FORMAT NAME ***   ind1990 ind1990_f.***/
 ind1990 ind1990f.
 /***LONG FORMAT NAME ***   classwkr classwkr_f.***/
 classwkr classwkr.
 /***LONG FORMAT NAME ***   classwkrd classwkrd_f.***/
 classwkrd clsswkrd.
 /***LONG FORMAT NAME ***   wkswork2 wkswork2_f.***/
 wkswork2 wkswrk2f.
 absent absent_f.
 /***LONG FORMAT NAME ***   looking looking_f***/
 looking lookingf.
 /***LONG FORMAT NAME ***   availble availble_f.***/
 availble availble.
 /***LONG FORMAT NAME ***   wrkrecal wrkrecal_f.***/
 wrkrecal wrkrecal.
 /***LONG FORMAT NAME ***   workedyr workedyr_f.***/
 workedyr workedyr.
 /***LONG FORMAT NAME ***   migrate1 migrate1_f.***/
 migrate1 migrat1f.
 /***LONG FORMAT NAME ***   migrate1d migrate1d_f.***/
 migrate1d migrat1d.
 /***LONG FORMAT NAME ***   migplac1 migplac1_f.***/
 migplac1 migplc1f.
 /***LONG FORMAT NAME ***   migmet1 migmet1_f.***/
 migmet1 migmet1f.
 /***LONG FORMAT NAME ***   migtype1 migtype1_f.***/
 migtype1 migtyp1f.
 /***LONG FORMAT NAME ***   migcity1 migcity1_f.***/
 migcity1 migcty1f.
 /***LONG FORMAT NAME ***   diffrem diffrem_f.***/
 diffrem diffremf.
 /***LONG FORMAT NAME ***   diffphys diffphys_f.***/
 diffphys diffphys.
 /***LONG FORMAT NAME ***   diffmob diffmob_f.***/
 diffmob diffmobf.
 /***LONG FORMAT NAME ***   diffcare diffcare_f.***/
 diffcare diffcare.
 /***LONG FORMAT NAME ***   diffsens diffsens_f.***/
 diffsens diffsens.
 /***LONG FORMAT NAME ***   vetstat vetstat_f.***/
 vetstat vetstatf.
 /***LONG FORMAT NAME ***   vetstatd vetstatd_f.***/
 vetstatd vetstatd.
 /***LONG FORMAT NAME ***   vet01ltr vet01ltr_f.***/
 vet01ltr vet01ltr.
 /***LONG FORMAT NAME ***   vet90x01 vet90x01_f.***/
 vet90x01 vt90x01f.
 /***LONG FORMAT NAME ***   vet80x90 vet80x90_f.***/
 vet80x90 vt80x90f.
 /***LONG FORMAT NAME ***   vet75x80 vet75x80_f.***/
 vet75x80 vt75x80f.
 /***LONG FORMAT NAME ***   vetvietn vetvietn_f.***/
 vetvietn vetvietn.
 /***LONG FORMAT NAME ***   vet55x64 vet55x64_f.***/
 vet55x64 vt55x64f.
 /***LONG FORMAT NAME ***   vetkorea vetkorea_f.***/
 vetkorea vetkorea.
 /***LONG FORMAT NAME ***   vet47x50 vet47x50_f.***/
 vet47x50 vt47x50f.
 /***LONG FORMAT NAME ***   vetwwii vetwwii_f.***/
 vetwwii vetwwiif.
 /***LONG FORMAT NAME ***   vetother vetother_f.***/
 vetother vetother.
 /***LONG FORMAT NAME ***   pwstate2 pwstate2_f.***/
 pwstate2 pw_st2f.
 /***LONG FORMAT NAME ***   pwmetro pwmetro_f.***/
 pwmetro pwmetrof.
 pwcity pwcity_f.
 pwtype pwtype_f.
 /***LONG FORMAT NAME ***   tranwork tranwork_f.***/
 tranwork tranwork.
 /***LONG FORMAT NAME ***   carpool carpool_f.***/
 carpool carpoolf.
 riders riders_f.
 /***LONG FORMAT NAME ***   gchouse gchouse_f.***/
 gchouse gchousef.
 /***LONG FORMAT NAME ***   gcmonths gcmonths_f.***/
 gcmonths gcmonths.
 /***LONG FORMAT NAME ***   gcrespon gcrespon_f.***/
 gcrespon gcrespon.
 
 /******** Formats added 6/25/10 ****************/
 /***LONG FORMAT NAME *** removed _f from all ***/
 hcovany hcovany.
 hcovpriv hcovpriv.
 hinsemp hinsemp.
 hinspur hinspur.
 hinstri hinstri.
 hcovpub hcovpub.
 hinscaid hinscaid.
 hinscare hinscare.
 hinsva hinsva.
 hinsihs hinsihs.
 diffeye diffeye.
 diffhear diffhear.
 divinyr divinyr.
 fridge fridge.
 hotwater hotwater.
 marrinyr marrinyr.
 marrno marrno.
 shower shower.
 sink sink.
 stove stove.
 toilet toilet.
 vetdisab vetdisab.
 widinyr widinyr.

 /*** UI-created format for race Yes/No vars. ***/
 racamind racasian racblk racother racpacis racwht uracyn.
;

  ** Create unique PUMA ID **;

  %upuma() 
  
  ** Recode n/a values **;
  
  array inca{*}  incwage incbus00 incretir incinvst  ;

  do i = 1 to dim( inca );
    if inca{i} = 999999 then inca{i} = .n;
  end;

  array incb{*} incss incwelfr incsupp incother owncost;

  do i = 1 to dim( incb );
    if incb{i} = 99999 then incb{i} = .n;
  end;

  array incc{*} ftotinc hhincome inctot valueh;

  do i = 1 to dim( incc );
    if incc{i} = 9999999 then incc{i} = .n;
  end;

  ** Utility cost codes 9993-9998 indicate no charge, not used, or costs included in rent/condo fee **;

  array incd{*} costelec costgas costfuel costwatr;
  
  do i = 1 to dim( incd );
    if incd{i} >= 9992 then incd{i} = .n;
  end;
  
  ** 2-digit N/A codes **;
  
  array ince{*} eldch yngch;
  
  do i = 1 to dim( ince );
    if ince{i} = 99 then ince{i} = .n;
  end;
  
  ** yrnatur **;
  
  array incf{*} yrnatur;
  
  do i = 1 to dim( incf );
    if incf{i} >= 9997 then incf{i} = .n;
  end;
  
  ** Earnings, education, and occupational status scores **;
  
  array incg{*} erscor50 erscor90 edscor50 edscor90 npboss50 npboss90;
  
  do i = 1 to dim( incg );
    if incg{i} = 999.9 then incg{i} = .n;
  end;
  
  ** HUD income categories **;
  
  %hud_inc_all()
  
  ** Remove extraneous format associations **;
  
  format 
    datanum serial rooms nfams ncouples nmothers nfathers pernum 
    hhwt perwt slwt momloc poploc sploc famsize nchild nchlt5 
    eldch yngch numprec nsibs age occ occscore ind indnaics occsoc sei
    puma pumasupr conspuma farmprod mortamt1 mortamt2 propinsr rent
    rentgrs condofee moblhome cost: ftotinc hhincome 
    valueh pernum slwt q: uhrswork inc: poverty
    migmet1 migpums1 migpuma1 movedin pwpuma00 pwpumas
    trantime departs arrives yrsusa1 yrimmig
  ;  
  
  format ind indac05f.;
  format occ occac05f.;

  /* Create age categories */

  %age_cats();

  /* Adjust HHIncome for Inflation */

  if year = 2009 then hhincome_adj = hhincome * (229.594 / 214.537);
  else if year = 2010 then hhincome_adj = hhincome * (229.594 / 218.056);
  else if year = 2011 then hhincome_adj = hhincome * (229.594 / 224.939);
  else if year = 2012 then hhincome_adj = hhincome;

  /* Classify races - not reported ethnicity assumed to be non-hispanic */

  if hispan ~= 0 and hispan ~= 9 then race_ethnicity = "Hispanic/Latino";
  else if racesing = 1 then race_ethnicity = "White";
  else if racesing = 2 then race_ethnicity = "Black";
  else if racesing = 4 then race_ethnicity = "Asian and/or Pacific Islander";
  else if racesing = 3 or racesing = 5 then race_ethnicity = "Other";
  
  drop i;

  if GQ in (1,2) then numprec_new = numprec;
  else numprec_new = 0;

  label numprec_new = "Number of person records in the household";

  total = 1;

run;

/* Get age of household head */

data households;
	set DMPED.ACS_2009_12;
	where relate = 1;
	agecat_hhead = agecat;
	keep relate agecat_hhead agecat serial year;
run;

proc sort data = DMPED.ACS_2009_12; by year SERIAL; run;

proc sort data = households (keep = agecat_hhead serial year) out = households_out; by year SERIAL; run;

/* People in group quarters with no household head are given their own age as age of household head */

data to_analyze;
	merge DMPED.ACS_2009_12 households_out;
	by year SERIAL;
	if agecat_hhead = '' then agecat_hhead = agecat;
run;

proc tabulate data=to_analyze format=comma10.0 noseps missing out=DMPED.Imputations_Table;
	class agecat;
	class sex;
	class race_ethnicity;
	class hud_inc;
	class numprec_new;
	class agecat_hhead;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' '
	  ,
	  /** Columns (do not change) **/
	  hud_inc = ' ' * numprec_new = ' ' * agecat_hhead = ' ' * (total = ' ' * sum=' ')
	  / condense
	;
	format hud_inc hudinc. sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2009-12";
run;

proc tabulate data=to_analyze format=comma10.0 noseps missing out=DMPED.Imputations_Totals;
	class agecat;
	class sex;
	class race_ethnicity;
	var total;
	weight PERWT;
	table 
	  /** Pages (do not change) **/
	  all='Total'
	,
	  /** Rows **/
	  agecat = ' ' * sex = ' ' * race_ethnicity = ' '
	  ,
	  /** Columns (do not change) **/
	  total = ' ' * sum=' '
	  / condense
	;
	format hud_inc hudinc. sex sex_f.;
	title2 "Total People not in group quarters";
	title3 "Universe: All People in DC not in group quarters";
	footnote1 "Source: ACS IPUMS data, 2009-12";
run;

proc sort data = DMPED.Imputations_Table (drop = _TYPE_ _PAGE_ _TABLE_ rename=(total_Sum = total)) out = Imputations_Table; by agecat sex race_ethnicity;
proc sort data = DMPED.Imputations_Totals (drop = _TYPE_ _PAGE_ _TABLE_) out = Imputations_Totals; by agecat sex race_ethnicity; run;

data DMPED.Imputations_Final;
	merge Imputations_Table Imputations_Totals;
	by agecat sex race_ethnicity;
	odds = total / total_Sum;
run;

proc export data = DMPED.Imputations_Final outfile = "D:\DCData\Libraries\DMPED\Data\Imputations_final.csv" dbms = csv replace; run;
