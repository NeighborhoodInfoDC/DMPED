 import excel "C:\Users\Ysu\Downloads\prediction_data.xlsx", sheet("prediction_data") firstrow

replace medianhome_2012_2020 = medianhome_2012_2020/100000
gen distancesquared=distance_to_downtown_miles*distance_to_downtown_miles
 
logistic displacement medianhome_2012_2020 vacancy_2012 distance_to_downtown_miles distancesquared lowinc_job_2012 pct_hcv_2012 pct_black_2012, robust
estimates store model1
 
 *putexcel set "C:\Users\Ysu\Downloads\test.xlsx"
 *putexcel (A1) = etable
 
 *outreg2 using "C:\Users\Ysu\Downloads\test.doc", stats(coef se)replace bdec(2) append label ctitle(Baseline)


*file myodds.xlsx saved
 
 logistic displacement medianhome_2012_2020 distance_to_downtown_miles distancesquared lowinc_job_2012 pct_hcv_2012 pct_black_2012
 estimates store model2
 
  outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_1)

 
 logistic displacement medianhome_2012_2020 vacancy_2012 distance_to_downtown_miles distancesquared lowinc_job_2012 pct_black_2012
 estimates store model3
 
   outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_2)
 
 logistic displacement medianhome_2012_2020 vacancy_2012 distance_to_downtown_miles distancesquared pct_hcv_2012 pct_black_2012
 estimates store model4
   outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_3)
 
 logistic displacement medianhome_2012_2020 distance_to_downtown_miles distancesquared lowinc_job_2012 pct_black_2012
 estimates store model5
   outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_4)
 
 logistic displacement medianhome_2012_2020 vacancy_2012 distance_to_downtown_miles distancesquared pct_black_2012
 estimates store model6
   outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_5)
  
logistic displacement medianhome_2012_2020 distance_to_downtown_miles distancesquared pct_black_2012
 estimates store model7
   outreg2 using "C:\Users\Ysu\Downloads\test.doc", append label ctitle(Alt_6)
 
etable, estimates(model1 model2 model3 model4 model5 model6 model7) showstars showstarsnote title("Table 1. Models for displacement risk") export("C:\Users\Ysu\Downloads\prediction.docx", replace)

outreg2 using "C:\Users\Ysu\Downloads\predictiontable.doc", append label ctitle(Marg. Eff.)

outreg2 using model1, append "C:\Users\Ysu\Downloads\prediction.xlsx"

putexcel set mytable, replace 

putexcel I1="Table 2: Model for BMI"

putexcel I2 = etable

putexcel N2:O2, merge

putexcel save