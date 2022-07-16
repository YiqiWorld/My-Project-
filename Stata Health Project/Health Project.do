/*Health Research Survey Data Project.do*/

clear all
prog drop _all
capture log close
set more off

global datadir "/Users/nugget/Desktop/NYU/Econometrics/Project"
global logdir "/Users/nugget/Desktop/NYU/Econometrics/Project"

log using "$logdir/Health Project.smcl", replace
use "$datadir/hrsdata_mr.dta", clear

/*Dichotomous self reported health for dependent variable*/

generate Healthy = 1
replace Healthy = 1 if shlt==1
replace Healthy = 1 if shlt==2
replace Healthy = 0 if shlt==3
replace Healthy = 0 if shlt==4
replace Healthy = 0 if shlt==5
label define Healthy 0 "0.not healthy" 1 "1.healthy", modify
label values Healthy Healthy


/*hispanic*/ 

replace race = 4 if hispan==1
label define race  1 "1.white non-hispanic" 2 "2.black non-hispanic" 3 "3.other" 4 "4.hispanic", modify
label values race race 

gen White = (race==1)
gen Black = (race==2)
gen Other = (race==3)
gen Hispanic = (race==4)

/*Year dummies*/
gen Year08 = (year==2008)
gen Year10 = (year==2010)
gen Year12 = (year==2012)
gen Year14 = (year==2014)
gen Year16 = (year==2016)

/*gender*/
gen Female = (gender==2)

/*replace missing value with mean*/
gen BMI_im=bmi
egen mean_bmi= mean(bmi)
replace BMI_im= mean_bmi if missing(BMI_im)
gen bmi_mis = (bmi==.)

/*marital status*/
replace mstat = 0 if mstat>1
label define mstat 0 "0.not married" 1 "1.married", modify
label values mstat mstat
gen Married = (mstat==1)

/*education level*/
replace edegrm = 1 if edegrm>4
label define edegrm 0 "no college" 1 "Atleast some college"
label values edegrm edegrm 
gen College = (edegrm==1)

/*Income*/
gen Income = iearn + issdi + iunwc + icap 


label var agey "Age"
label var cenreg "Region"



/*income logged*/
gen LnIncome = log(Income)

/*income squared*/
gen Incomesqr = Income*Income

/*Interactions*/
gen IncEd = iearn*College



reg Healthy Income LnIncome College IncEd year08 year10 year12 year14 year16 Hispanic Black Other ib1.White_nh female mstat psych prpcnt higov hchild 



ssc install outreg2
outreg2 using HealthProject.doc, replace sum(log) keep(Healthy Income College Age Year08 Year10 Year12 Year14 ib1.Year16 BMI_im Hispanic Black Other White Female Married) eqkeep (mean sd min max) sortvar(Healthy Income White Black Hispanic Other) label

reg Healthy Income Year08 Year10 Year12 Year14 Year16
outreg2 using Table2.doc, replace ctitle (Model 1) addtext(Year FE, YES, Regional FE, NO) label

reg Healthy Income Year08 Year10 Year12 Year14 ib1.Year16 Hispanic Black Other ib1.White Female Married
outreg2 using Table2.doc, append ctitle (Model 2) addtext(Year FE, YES, Regional FE, NO) label

reg Healthy Income LnIncome College Year08 Year10 Year12 Year14 ib1.Year16 Hispanic Black Other ib1.White Female Married
outreg2 using Table2.doc, append ctitle (Model 3) addtext(Year FE, YES, Regional FE, NO) label 

xtreg Healthy Income LnIncome Year08 Year10 Year12 Year14 ib1.Year16 College Hispanic Black Other ib1.White Female Married, fe i(cenreg) robust
outreg2 using Table2.doc, append ctitle (Model 4: Fixed Effects) addtext(Year FE, YES, Regional FE, YES) label
