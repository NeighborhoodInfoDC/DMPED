import delimited "C:\Users\Ysu\Documents\regression.csv"

gen distancesquared=distanc*distance

regress changeinblack distancesquared vacancy changerent black
estimates store modelblack
 outreg2 using "C:\Users\Ysu\Documents\blackmodel.doc", append label ctitle(Black Population)
   
