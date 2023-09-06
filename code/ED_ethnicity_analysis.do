clear
set more off
capture log close

log using "D:\PhotonUser\My Files\Home Folder\stata", replace
cd "D:\PhotonUser\My Files\Home Folder"
sysdir set PERSONAL "D:\PhotonUser\My Files\Home Folder\ado\personal"

global stata "stata"
global raw "stata\raw"
global work "stata\work"
global output "stata\output\intersectionality"


/*outcome descriptives*/
clear
use "$work/ED_cleaned_2020_ptlevel.dta"
sum last_3m, detail
sum last_12m, detail
tab last_12m

/*% of visits by deprivation - visit level data*/
clear
use "$work/ED_cleaned_2020_ptlevel.dta"
keep if last_3m==1
tab imd_quints, mi

/*TABLE 1*/
/*2020 only*/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
gen age25=age_atdeath
gen age75=age_atdeath
collapse  (median)age_atdeath (p25)age25 (p75)age75
save "$work/age.dta", replace
/**/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
foreach var of varlist sex2 ethnicity3 imd_quints ucod_nonsud meds12_quarts peoplepersqkm_quarts {
preserve
replace `var'=99 if `var'==.
collapse (sum)death (sum)last_3m last3m_OOH last3m_IH, by(`var')
gen overall_rate = last_3m/death
gen OOH_rate = last3m_OOH/death
gen IH_rate = last3m_IH/death
order `var' death last_3m last3m_OOH last3m_IH overall_rate OOH_rate IH_rate
replace death = 5 * ceil(death/5)
replace last_3m = 5 * ceil(last_3m/5)
replace last3m_OOH = 5 * ceil(last3m_OOH/5)
replace last3m_IH = 5 * ceil(last3m_IH/5)
save "$work/`var'.dta", replace
restore
}
clear
use "$work\age.dta"
append using "$work\sex2.dta"
append using "$work\ethnicity3.dta"
append using "$work\ucod_nonsud.dta"
append using "$work\meds12_quarts.dta"
append using "$work\imd_quints.dta"
append using "$work\peoplepersqkm_quarts.dta"
order age* sex2 ethnicity ucod_nonsud meds12_quarts imd_quints peoplepersqkm_quarts
foreach var of varlist sex2 ethnicity ucod_nonsud {
    decode `var', gen(`var'2)
	drop `var'
}
tostring imd_quints, force replace
tostring meds12_quarts, force replace
tostring peoplepersqkm_quarts, force replace
gen var=sex22
replace var=ethnicity32 if var==""
replace var=ucod_nonsud2 if var==""
replace var=imd_quints if var=="" | var=="."
replace var=meds12_quarts if var=="" | var=="."
replace var=peoplepersqkm_quarts if var=="" | var=="." 
order var age*
drop imd_quints sex22 ethnicity32 ucod_nonsud2 meds12_quarts peoplepersqkm_quarts
replace var="missing" if var=="" | var=="."
replace var="age" if _n==1
gen var1=""
order var1
replace var1 = "sex" if _n==2
replace var1 = "ethnicity" if _n==6
replace var1 = "underlying cause of death" if _n==17
replace var1 = "count of medicines*" if _n==28
replace var1 = "imd (1 is most deprived)" if _n==32
replace var1 = "population density" if _n==38

label var age_atdeath "median age"
label var death "n of deaths"
label var last_3m "n of ED visits in last 3 months of life"
label var last3m_OOH "n of OOH ED visits in last 3 months of life"
label var last3m_IH "n of IH ED visits in last 3 months of life"
export excel using "$output\table1.xls", firstrow(varlabel) sheet(2020_only) sheetreplace
save "$output\table1_2020.dta", replace
/*******************************************/

/*2019 only*/
clear 
use "$work/ED_cleaned_2019_ptlevel.dta"
gen age25=age_atdeath
gen age75=age_atdeath
collapse  (median)age_atdeath (p25)age25 (p75)age75
save "$work/age.dta", replace
/**/
clear 
use "$work/ED_cleaned_2019_ptlevel.dta"
foreach var of varlist sex2 ethnicity3 {
preserve
replace `var'=99 if `var'==.
collapse (sum)death (sum)last_3m last3m_OOH last3m_IH, by(`var')
gen overall_rate = last_3m/death
gen OOH_rate = last3m_OOH/death
gen IH_rate = last3m_IH/death
order `var' death last_3m last3m_OOH last3m_IH overall_rate OOH_rate IH_rate
replace death = 5 * ceil(death/5)
replace last_3m = 5 * ceil(last_3m/5)
replace last3m_OOH = 5 * ceil(last3m_OOH/5)
replace last3m_IH = 5 * ceil(last3m_IH/5)
save "$work/`var'.dta", replace
restore
}
clear
use "$work\age.dta"
append using "$work\sex2.dta"
append using "$work\ethnicity3.dta"
order age* sex2 ethnicity
foreach var of varlist sex2 ethnicity {
    decode `var', gen(`var'2)
	drop `var'
}
replace sex22=ethnicity32 if sex22==""
order sex22 age*
drop ethnicity32
replace sex22="missing" if sex22=="" | sex22=="."
replace sex22="age" if _n==1
gen var1=""
order var1
replace var1 = "sex" if _n==2
replace var1 = "ethnicity" if _n==6

label var age_atdeath "median age"
label var death "n of deaths"
label var last_3m "n of ED visits in last 3 months of life"
label var last3m_OOH "n of OOH ED visits in last 3 months of life"
label var last3m_IH "n of IH ED visits in last 3 months of life"
export excel using "$output\table1.xls", firstrow(varlabel) sheet(2019) sheetreplace
save "$output\table1_2019.dta", replace
/***************************************************/

/*table 1 for 2020 by ethnicity*/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
gen age25=age_atdeath
gen age75=age_atdeath
collapse  (median)age_atdeath (p25)age25 (p75)age75, by(ethnicity3)
save "$work/age_byethnicity.dta", replace
/**/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
replace ethnicity3=99 if ethnicity3==.
replace imd_quints=99 if imd_quints==.
keep death sex2 imd_quints ucod_nonsud meds12_quarts peoplepersqkm_quarts ethnicity3
foreach var of varlist sex2 imd_quints ucod_nonsud meds12_quarts peoplepersqkm_quarts {
preserve
keep `var' death ethnicity3
replace `var'=99 if `var'==.
collapse (sum)death, by(`var' ethnicity3)
order `var' death
replace death = 5 * ceil(death/5)
/**/
reshape wide death, i(`var') j(ethnicity3)
rename death1 white_british
rename death2 black_african 
rename death3 black_caribbean
rename death4 bangladeshi
rename death5 pakistani
rename death6 indian
rename death7 mixed
rename death8 chinese 
rename death9 white_other
rename death10 other
rename death99 missing
/**/
save "$work/`var'.dta", replace
restore
}
clear
use "$work\age.dta"
append using "$work\sex2.dta"
append using "$work\ucod_nonsud.dta"
append using "$work\meds12_quarts.dta"
append using "$work\imd_quints.dta"
append using "$work\peoplepersqkm_quarts.dta"
order age* sex2 ucod_nonsud meds12_quarts imd_quints peoplepersqkm_quarts
foreach var of varlist sex2 ucod_nonsud {
    decode `var', gen(`var'2)
	drop `var'
}
tostring imd_quints, force replace
tostring meds12_quarts, force replace
tostring peoplepersqkm_quarts, force replace
gen var=sex22
replace var=ucod_nonsud2 if var==""
replace var=imd_quints if var=="" | var=="."
replace var=meds12_quarts if var=="" | var=="."
replace var=peoplepersqkm_quarts if var=="" | var=="." 
order var age*
drop imd_quints sex22 ucod_nonsud2 meds12_quarts peoplepersqkm_quarts
replace var="missing" if var=="" | var=="."
replace var="age" if _n==1
gen var1=""
order var1
replace var1 = "sex" if _n==2
replace var1 = "underlying cause of death" if _n==6
replace var1 = "count of medicines*" if _n==17
replace var1 = "imd (1 is most deprived)" if _n==21
replace var1 = "population density" if _n==27
label var age_atdeath "median age"
export excel using "$output\table1.xls", firstrow(varlabel) sheet(by_ethnicity) sheetreplace
save "$output\table1_2020_byethnicity.dta", replace


/***************************************************/

/*HEATMAPS*/
/*data for the descriptive heat map of rates for ethnicity x deprivation, by sex*/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
replace ethnicity3=99 if ethnicity3==.
replace imd_quints=99 if imd_quints==.
drop if sex2==1
collapse (sum)death (sum)last_3m, by(imd_quints ethnicity sex2)
gen rate = last_3m/death
drop if imd_quints==99
drop if ethnicity==99
sort sex2 ethnicity3 imd_quints
replace death = 5 * ceil(death/5)
replace last_3m = 5 * ceil(last_3m/5)
save "$output\heatmap_descriptives.dta", replace

/*age adjusted/predicted rates - for heatmaps*/
/*men*/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
drop if sex==1
keep if sex==2
replace ethnicity=99 if ethnicity==.
nbreg last_3m age_atdeath i.ethnicity##i.imd_quints, irr robust
tempfile tmp
margins ethnicity##imd_quints, atmeans saving("`tmp'")
use "`tmp'", clear
keep _margin _ci_lb _ci_ub _m1 _m2
rename _m1 ethnicity
rename _m2 imd
rename _margin predicted_mean
rename _ci_lb lci
rename _ci_ub uci
drop if imd==.
drop if ethnicity==.
order ethnicity imd
reshape wide predicted_mean lci uci, i(ethnicity) j(imd) 
export excel using "$output\heatmap_margins.xls", firstrow(var) sheet(men) sheetreplace
save "$output\heatmap_men.dta", replace
/*women*/
clear 
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
drop if sex==1
keep if sex==3
replace ethnicity=99 if ethnicity==.
nbreg last_3m age_atdeath i.ethnicity##i.imd_quints, irr robust
tempfile tmp
margins ethnicity##imd_quints, atmeans saving("`tmp'")
use "`tmp'", clear
keep _margin _ci_lb _ci_ub _m1 _m2
rename _m1 ethnicity
rename _m2 imd
rename _margin predicted_mean
rename _ci_lb lci
rename _ci_ub uci
drop if imd==.
drop if ethnicity==.
order ethnicity imd
reshape wide predicted_mean lci uci, i(ethnicity) j(imd) 
export excel using "$output\heatmap_margins.xls", firstrow(var) sheet(women) sheetreplace
save "$output\heatmap_women.dta", replace


/*MODELLING*/
/********************************************************/
clear
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
/*testing some assumptions before running the models*/
/*first - testing for intragroup correlations - nb estat icc not available after menbreg*/
mixed last3m_OOH age sex || la_name_2019:
estat icc
mixed last3m_OOH i.ethnicity age sex peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m || la_name_2019:
estat icc
/*icc small but significant - preferred model is vce(cluster) - NB vce(cluster) also addresses hereoskadasicity, relaxing the same assumptions that vce(robust) does - so use vce(robust) for model 1 and vce(cluster) for models 2, 3 & 4*/
/*************************************************************/

/*MODELS*/
/*INTERSECTIONALITY ANALYSIS - FULL POP*/
/*IH MEN*/
/*cd "D:\PhotonUser\My Files\Home Folder\stata"*/
clear
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
/*1*/ nbreg last3m_IH i.ethnicity age if sex==2, irr vce(robust)
regsave using "$output/1", ci rtable replace
/*2*/ nbreg last3m_IH i.ethnicity age peoplepersqkm if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/2", ci rtable replace
/*3*/ nbreg last3m_IH i.ethnicity age peoplepersqkm i.imd_quints if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/3", ci rtable replace
/*4*/ nbreg last3m_IH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/4", ci rtable replace
cd "D:\PhotonUser\My Files\Home Folder\stata\output\intersectionality"
local myfilelist 1 2 3 4
foreach filename of local myfilelist{
use `filename'.dta, clear
keep if _n>=2 & _n<=10
keep var coef ci_lower ci_upper
gen sex="men"
order sex
rename coef irr`filename'
rename ci_lower lci`filename'
rename ci_upper uci`filename'
rename var ethnicity
gen n = _n
sort n
save new`filename'.dta, replace
}
use new1.dta, clear
merge 1:1 n ethnicity sex using new2.dta
drop _merge
merge 1:1 n ethnicity sex using new3.dta
drop _merge
merge 1:1 n ethnicity sex using new4.dta
drop _merge
label define ethnicity2 1 "black african" 2 "black caribbean" 3 "bangladeshi" 4 "pakistani" 5 "indian" 6 "mixed" 7 "chinese" 8 "white other" 9 "other"
label values n ethnicity2
drop ethnicity
rename n ethnicity
order sex ethnicity
save ih_men.dta, replace
/*IH WOMEN*/
clear
cd "D:\PhotonUser\My Files\Home Folder"
global work "stata\work"
global output "stata\output\intersectionality"
use "$work\ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
/*1*/ nbreg last3m_IH i.ethnicity age if sex==3, irr vce(robust)
regsave using "$output/1", ci rtable replace
/*2*/ nbreg last3m_IH i.ethnicity age peoplepersqkm if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/2", ci rtable replace
/*3*/ nbreg last3m_IH i.ethnicity age peoplepersqkm i.imd_quints if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/3", ci rtable replace
/*4*/ nbreg last3m_IH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/4", ci rtable replace
cd "$output"
local myfilelist 1 2 3 4
foreach filename of local myfilelist{
use `filename'.dta, clear
keep if _n>=2 & _n<=10
keep var coef ci_lower ci_upper
gen sex="women"
order sex
rename coef irr`filename'
rename ci_lower lci`filename'
rename ci_upper uci`filename'
rename var ethnicity
gen n = _n
sort n
save new`filename'.dta, replace
}
use new1.dta, clear
merge 1:1 n ethnicity sex using new2.dta
drop _merge
merge 1:1 n ethnicity sex using new3.dta
drop _merge
merge 1:1 n ethnicity sex using new4.dta
drop _merge
label define ethnicity2 1 "black african" 2 "black caribbean" 3 "bangladeshi" 4 "pakistani" 5 "indian" 6 "mixed" 7 "chinese" 8 "white other" 9 "other"
label values n ethnicity2
drop ethnicity
rename n ethnicity
order sex ethnicity
save ih_women.dta, replace
append using ih_men.dta
save ih.dta, replace
export excel using "models_nbreg.xls", firstrow(var) sheet("ih", replace)
/*BAR GRAPH*/
reshape long irr lci uci, i(ethnicity sex) j(model)
label define model 1 "+age" 2 "+geography" 3 "+deprivation" 4 "+health"
label values model model
/*reorder ethnicity var to run from larger irr to smaller - consistent accross graphs*/
gen ethnicity2 = .
replace ethnicity2=1 if ethnicity==3
replace ethnicity2=2 if ethnicity==4
replace ethnicity2=3 if ethnicity==5
replace ethnicity2=4 if ethnicity==9
replace ethnicity2=5 if ethnicity==2
replace ethnicity2=6 if ethnicity==1
replace ethnicity2=7 if ethnicity==8
replace ethnicity2=8 if ethnicity==7
replace ethnicity2=9 if ethnicity==6
label define ethnicity3 1 "bangladeshi" 2 "pakistani" 3 "indian" 4 "other" 5 "black caribbean" 6 "black african" 7 "white other" 8 "chinese" 9 "mixed"
label values ethnicity2 ethnicity3
drop ethnicity
order ethnicity
gen eth_mod = model if ethnicity==9
replace eth_mod = model+5 if ethnicity==8
replace eth_mod = model+10 if ethnicity==7
replace eth_mod = model+15 if ethnicity==6
replace eth_mod = model+20 if ethnicity==5
replace eth_mod = model+25 if ethnicity==4
replace eth_mod = model+30 if ethnicity==3
replace eth_mod = model+35 if ethnicity==2
replace eth_mod = model+40 if ethnicity==1
sort eth_mod eth_mod ethnicity model
twoway  (bar irr eth_mod if model==1, base(1) horizontal) ///
		(bar irr eth_mod if model==2, base(1) horizontal) ///
		(bar irr eth_mod if model==3, base(1) horizontal) ///
		(bar irr eth_mod if model==4, base(1) horizontal) ///
		(rcap lci uci eth_mod, horizontal lcolor(black)), ///
		legend(row(1) order(1 "+age" 2 "+geography" 3 "+deprivation" 4 "+health")) ///
		ylabel(2.5 "mixed" 7.5 "chinese" 12.5 "white other" 17.5 "black african" 22.5 "black caribbean" 27.5 "other" 32.5 "indian" 37.5 "pakistani" 42.5 "bangladeshi", noticks angle(horizontal)) ///
		ytitle("") xtitle("incidence rate ratio (irr)") xline(1, lwidth(thin) lcolor(black) lpattern(solid)) graphregion(color(white)) title("") ///
		by(sex, note("") title("Rate of in-hours ED visits in last 3m of life, compared to White British", size(*0.8)) graphregion(color(white)))
graph save "ih_fullpop", replace

/**************************/
/*OOH MEN*/
clear
cd "D:\PhotonUser\My Files\Home Folder"
global work "stata\work"
global output "stata\output\intersectionality"
use "$work\ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
/*1*/ nbreg last3m_OOH i.ethnicity age if sex==2, irr vce(robust)
regsave using "$output/1", ci rtable replace
/*2*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/2", ci rtable replace
/*3*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/3", ci rtable replace
/*4*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/4", ci rtable replace
cd "$output"
local myfilelist 1 2 3 4
foreach filename of local myfilelist{
use `filename'.dta, clear
keep if _n>=2 & _n<=10
keep var coef ci_lower ci_upper
gen sex="men"
order sex
rename coef irr`filename'
rename ci_lower lci`filename'
rename ci_upper uci`filename'
rename var ethnicity
gen n = _n
sort n
save new`filename'.dta, replace
}
use new1.dta, clear
merge 1:1 n ethnicity sex using new2.dta
drop _merge
merge 1:1 n ethnicity sex using new3.dta
drop _merge
merge 1:1 n ethnicity sex using new4.dta
drop _merge
label define ethnicity2 1 "black african" 2 "black caribbean" 3 "bangladeshi" 4 "pakistani" 5 "indian" 6 "mixed" 7 "chinese" 8 "white other" 9 "other"
label values n ethnicity2
drop ethnicity
rename n ethnicity
order sex ethnicity
save ooh_men.dta, replace
/*OOH WOMEN*/
clear
cd "D:\PhotonUser\My Files\Home Folder"
global work "stata\work"
global output "stata\output\intersectionality"
use "$work\ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
/*1*/ nbreg last3m_OOH i.ethnicity age if sex==3, irr vce(robust)
regsave using "$output/1", ci rtable replace
/*2*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/2", ci rtable replace
/*3*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/3", ci rtable replace
/*4*/ nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/4", ci rtable replace
cd "$output"
local myfilelist 1 2 3 4
foreach filename of local myfilelist{
use `filename'.dta, clear
keep if _n>=2 & _n<=10
keep var coef ci_lower ci_upper
gen sex="women"
order sex
rename coef irr`filename'
rename ci_lower lci`filename'
rename ci_upper uci`filename'
rename var ethnicity
gen n = _n
sort n
save new`filename'.dta, replace
}
use new1.dta, clear
merge 1:1 n ethnicity sex using new2.dta
drop _merge
merge 1:1 n ethnicity sex using new3.dta
drop _merge
merge 1:1 n ethnicity sex using new4.dta
drop _merge
label define ethnicity2 1 "black african" 2 "black caribbean" 3 "bangladeshi" 4 "pakistani" 5 "indian" 6 "mixed" 7 "chinese" 8 "white other" 9 "other"
label values n ethnicity2
drop ethnicity
rename n ethnicity
order sex ethnicity
save ooh_women.dta, replace
append using ooh_men.dta
save ooh.dta, replace
export excel using "models_nbreg.xls", firstrow(var) sheet("ooh", replace)
/*BAR GRAPH*/
reshape long irr lci uci, i(ethnicity sex) j(model)
label define model 1 "+age" 2 "+geography" 3 "+deprivation" 4 "+health"
label values model model
/*reorder ethnicity var to run from larger irr to smaller - consistent accross graphs*/
gen ethnicity2 = .
replace ethnicity2=1 if ethnicity==3
replace ethnicity2=2 if ethnicity==4
replace ethnicity2=3 if ethnicity==5
replace ethnicity2=4 if ethnicity==9
replace ethnicity2=5 if ethnicity==2
replace ethnicity2=6 if ethnicity==1
replace ethnicity2=7 if ethnicity==8
replace ethnicity2=8 if ethnicity==7
replace ethnicity2=9 if ethnicity==6
label define ethnicity3 1 "bangladeshi" 2 "pakistani" 3 "indian" 4 "other" 5 "black caribbean" 6 "black african" 7 "white other" 8 "chinese" 9 "mixed"
label values ethnicity2 ethnicity3
drop ethnicity
order ethnicity
gen eth_mod = model if ethnicity==9
replace eth_mod = model+5 if ethnicity==8
replace eth_mod = model+10 if ethnicity==7
replace eth_mod = model+15 if ethnicity==6
replace eth_mod = model+20 if ethnicity==5
replace eth_mod = model+25 if ethnicity==4
replace eth_mod = model+30 if ethnicity==3
replace eth_mod = model+35 if ethnicity==2
replace eth_mod = model+40 if ethnicity==1
sort eth_mod eth_mod ethnicity model
twoway  (bar irr eth_mod if model==1, base(1) horizontal) ///
		(bar irr eth_mod if model==2, base(1) horizontal) ///
		(bar irr eth_mod if model==3, base(1) horizontal) ///
		(bar irr eth_mod if model==4, base(1) horizontal) ///
		(rcap lci uci eth_mod, horizontal lcolor(black)), ///
		legend(row(1) order(1 "+age" 2 "+geography" 3 "+deprivation" 4 "+health")) ///
		ylabel(2.5 "mixed" 7.5 "chinese" 12.5 "white other" 17.5 "black african" 22.5 "black caribbean" 27.5 "other" 32.5 "indian" 37.5 "pakistani" 42.5 "bangladeshi", noticks angle(horizontal)) ///
		ytitle("") xtitle("incidence rate ratio (irr)") xline(1, lwidth(thin) lcolor(black) lpattern(solid)) graphregion(color(white)) title("") ///
		by(sex, note("") title("Rate of out-of-hours ED visits in last 3m of life, compared to White British", size(*0.8)) graphregion(color(white)))
graph save "ooh_fullpop", replace
/****************************/
/*combine graphs*/
/*title: "Rate of emergency department visits in last 3 months of life, compared to White British*/
grc1leg2 ih_fullpop.gph ooh_fullpop.gph, row(1) ycommon ///
title("all deaths in England in 2020", size(9pt)) graphregion(color(white)) 
graph save "fullpop", replace
/************************************/

/*LINE GRAPH 2019 V 2020 - last 12m - probably drop*/
clear 
use "$work/ED_cleaned_2019_2020.dta"
keep if death_year==2020 | death_year==2019
collapse (sum)last_12m (sum)death, by(months_da death_year)
bys death_year: egen alldeaths = sum(death)
drop if months_da==.
drop death
reshape wide last_12m alldeaths, i(months_da) j(death_year)
gen rate2019=last_12m2019/alldeaths2019*1000
gen rate2020=last_12m2020/alldeaths2020*1000
label var rate2019 "2019"
label var rate2020 "2020"
twoway line rate2019 rate2020 months_da, xscale(reverse) xlabel(1(1)12) title("Rate of ED visits per 1,000 deaths in 2019  and 2020", size(*0.7)) graphregion(color(white))
graph save "$output\rate per 1000 2019 v 2020", replace 
export excel using "$output\England OOH 2020.xls", firstrow(varlabel) sheet("19v20", replace)
replace last_12m2019 = 5 * ceil(last_12m2019/5)
replace alldeaths2019 = 5 * ceil(alldeaths2019/5)
replace last_12m2020 = 5 * ceil(last_12m2020/5)
replace alldeaths2020 = 5 * ceil(alldeaths2020/5)
export excel using "$output\line_ed_rate_2019and2020.xls", firstrow(varlabel) sheet("line", replace)

/*INTERACTION - ETHNICITY & YEAR*/
clear
use "$work/ED_cleaned_july_dec_2019_2020_ptlevel.dta"
drop if sex==1
drop if hosp_days_last3m==90
nbreg last3m_OOH age_atdeath i.sex2 i.ethnicity##i.death_year, irr robust
regsave using "$output/ethnicity_year_interaction", ci rtable replace
tempfile tmp
margins ethnicity##death_year, atmeans saving("`tmp'")
use "`tmp'", clear
keep _margin _ci_lb _ci_ub _m1 _m2
rename _m1 ethnicity
rename _m2 year
rename _margin predicted_mean
rename _ci_lb lci
rename _ci_ub uci
order ethnicity year
save "$output/margins_ethnicity_year.dta", replace
export excel using "$output\margins_ethnicity_year.xls", firstrow(varlabel) sheet("margins", replace)
clear
use "$output/ethnicity_year_interaction"
replace N = 5 * ceil(N/5)
rename coef IRR
save "$output/ethnicity_year_interaction.dta", replace
export excel using "$output\ethnicity_year_interaction.xls", firstrow(var) replace
/*also get the simple effects - difference between each ethnic group in 2019 v 2020*/
clear
use "$work/ED_cleaned_july_dec_2019_2020_ptlevel.dta"
drop if sex==1
drop if hosp_days_last3m==90
nbreg last3m_OOH age_atdeath i.sex2 i.ethnicity##i.death_year, irr robust
tempfile tmp
margins ethnicity, atmeans dydx(death_year) saving("`tmp'")
use "`tmp'", clear
keep _margin _ci_lb _ci_ub _m1 
rename _m1 ethnicity
rename _margin simpleeffects2020minus2019
rename _ci_lb lci
rename _ci_ub uci
order ethnicity
save "$output/simple_effects_2020minus2019.dta", replace
export excel using "$output\simple_effects_2020minus2019.xls", firstrow(varlabel) sheet("margins", replace)

/*e-values*/
cd "D:\Users\joannamariedavies\Desktop\CovPall CCUO24\Joanna Davies"
clear
use "$work/ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
drop if ethnicity==.
label list ethnicity
/*create dummy vars*/
gen eth2=0 
replace eth2=1 if ethnicity3==2
gen eth3=0 
replace eth3=1 if ethnicity3==3
gen eth4=0 
replace eth4=1 if ethnicity3==4 
gen eth5=0 
replace eth5=1 if ethnicity3==5 
gen eth6=0 
replace eth6=1 if ethnicity3==6 
gen eth7=0 
replace eth7=1 if ethnicity3==7 
gen eth8=0 
replace eth8=1 if ethnicity3==8 
gen eth9=0 
replace eth9=1 if ethnicity3==9 
gen eth10=0 
replace eth10=1 if ethnicity3==10 
/*men*/
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.la_name_2019 i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(robust)
evalue_estat eth4 
evalue_estat eth5
/*women*/
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.la_name_2019 i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(robust)
evalue_estat eth4 
evalue_estat eth5
evalue_estat eth6
/***********************************/

/*SENSITIVITY - just ooh, just model 4*/
/*EXCLUDING SUDDEN CAUSES*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel_exclsudd.dta"
drop if hosp_days_last3m==90
keep if death_year==2020
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/sensitivity_exclsudd_men", ci rtable replace
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/sensitivity_exclsudd_women", ci rtable replace
clear
use "$output/sensitivity_exclsudd_men"
keep if _n<11
gen sex="men"
replace N = 5 * ceil(N/5)
rename coef IRR
save "$output/sensitivity_exclsudd_men.dta", replace
clear
use "$output/sensitivity_exclsudd_women"
keep if _n<11
gen sex="women"
replace N = 5 * ceil(N/5)
rename coef IRR
append using "$output/sensitivity_exclsudd_men.dta"
save "$output/sensitivity_exclsudd.dta", replace
 
/*EXCLUDING SUDDEN CAUSES AND CARE HOME*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel_exclsudd_exclcarehome.dta"
drop if hosp_days_last3m==90
keep if death_year==2020
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/sensitivity_exclsudd_andCH_men", ci rtable replace
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/sensitivity_exclsudd_andCH_women", ci rtable replace
clear
use "$output/sensitivity_exclsudd_andCH_men"
keep if _n<11
gen sex="men"
replace N = 5 * ceil(N/5)
rename coef IRR
save "$output/sensitivity_exclsudd_andCH_men", replace
clear
use "$output/sensitivity_exclsudd_andCH_women"
keep if _n<11
gen sex="women"
replace N = 5 * ceil(N/5)
rename coef IRR
append using "$output/sensitivity_exclsudd_andCH_men"
save "$output/sensitivity_exclsudd_andCH", replace

/*SAVE FULL FINAL MODEL 4 FOR SUPPLEMENTARY*/
clear
use "$work\ED_cleaned_2020_ptlevel.dta"
drop if hosp_days_last3m==90
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==2, irr vce(cluster la_name_2019)
regsave using "$output/full_model4_men", ci rtable replace
nbreg last3m_OOH i.ethnicity age peoplepersqkm i.imd_quints i.ucod_nonsud distinct_meds4to12m if sex==3, irr vce(cluster la_name_2019)
regsave using "$output/full_model4_women", ci rtable replace
clear
use "$output/full_model4_men"
gen sex="men"
replace N = 5 * ceil(N/5)
rename coef IRR
save "$output/full_model4_men", replace
clear
use "$output/full_model4_women"
gen sex="women"
replace N = 5 * ceil(N/5)
rename coef IRR
append using "$output/full_model4_men"
save "$output/full_model4", replace
