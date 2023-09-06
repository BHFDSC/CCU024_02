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

clear 
odbc load, exec("SELECT * FROM dars_nic_391419_j3w9t_collab.ccu024_01_cohort_deaths") dsn("databricks")
/*deaths from 2018-2020*/
sort PERSON_ID
save "$raw/deaths_2018_2020.dta", replace

clear
odbc load, exec("SELECT * FROM dars_nic_391419_j3w9t_collab.ccu024_01_cohort_hes_ae") dsn("databricks")
/*ae for deaths from 2018-2020*/
/*check and drop dups based on arrival date and time*/
duplicates tag AEKEY, gen(tag1)
duplicates tag PERSON_ID ARRIVALDATE ARRIVALTIME, gen(tag2)
duplicates drop PERSON_ID ARRIVALDATE ARRIVALTIME, force
sort PERSON_ID
drop tag1 tag2
save "$raw/hesAE_deaths_2018_2020.dta", replace

clear
odbc load, exec("SELECT * FROM dars_nic_391419_j3w9t_collab.ccu024_01_skinny_deaths") dsn("databricks")
/*linked in demogs*/
sort PERSON_ID
save"$raw/demogs_deaths_2018_2020.dta", replace


/*prescription data*/
/************/
clear
odbc load, exec("SELECT * FROM dars_nic_391419_j3w9t_collab.ccu024_01_pmeds_deaths_2020") dsn("databricks")
gen BNF=substr(PrescribedBNFCode,1,7)
/*standardise the bnf code for lookup to ATC - not needed*/
/*gen BNF2 = BNF + "0"*/
/*replace BNF2 = usubstr(BNF2, 2, .) if usubstr(BNF2,1,1) == "0"*/
rename BNF bnf
sort PERSON_ID
gen days_btween=REG_DATE_OF_DEATH-ProcessingPeriodDate
codebook PERSON_ID
/*NB precrip processing date is always 1st of month - therefore take at least 120 days (4 months before) to get at least 3 months before*/
gen flag=1 if days_btween>=0 & days_btween<=365
gen flag2=1 if days_btween>=0 & days_btween<=90
gen flag3=1 if days_btween>=120 & days_btween<=365
codebook PERSON_ID if flag==1
keep if flag==1
sort bnf
/*create count of unique medicines*/
egen tag = tag(PERSON_ID bnf)
egen distinct_meds12m= total(tag) if flag==1, by(PERSON_ID)
egen distinct_meds3m= total(tag) if flag2==1, by(PERSON_ID)
egen distinct_meds4to12m= total(tag) if flag3==1, by(PERSON_ID)
drop if PERSON_ID==""
collapse (firstnm) distinct_meds12m distinct_meds3m distinct_meds4to12m, by(PERSON_ID)
save "$raw/pmeds_death_2020_lastyr.dta", replace
/****************************************************************/

/*person days in hospital in last 3 months of life*/
clear
odbc load, exec("SELECT * FROM dars_nic_391419_j3w9t_collab.ccu024_01_hes_apc_dates_deaths_2019_2020") dsn("databricks")
sort PERSON_ID EPISTART
collapse (firstnm)EPISTART (firstnm)EPIEND (firstnm)REG_DATE_OF_DEATH, by(PERSON_ID SUSSPELLID)
/*<10 with with missing end or start*/
drop if EPIEND==.
drop if EPISTART==.
/*fixing 5 known problems with the data*/
/*1. end date > dod*/
replace EPIEND=REG_DATE_OF_DEATH if EPIEND>REG_DATE_OF_DEATH
/*2. start date > end date - no logical way to preserve these cases so dropping but only effects <0.1% of records*/
drop if EPISTART>EPIEND
/*3. duplicates*/
duplicates drop PERSON_ID EPISTART EPIEND REG_DATE_OF_DEATH, force
/*4.implausible start date*/
/*repeat code until 0 replace - probably a much more elegant way to do this!*/
sort PERSON_ID EPISTART
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): replace EPISTART=EPIEND[_n-1] if (EPISTART<EPIEND[_n-1]) & (PERSON_ID==PERSON_ID[_n-1])
/*5.implausible end date*/
sort PERSON_ID EPISTART
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
bys PERSON_ID (EPISTART): drop if EPIEND<=EPIEND[_n-1] & (PERSON_ID==PERSON_ID[_n-1])
/***/
gen days_btween=REG_DATE_OF_DEATH-EPISTART
gen flag=1 if days_btween>=0 & days_btween<=90
gen days_btween2=REG_DATE_OF_DEATH-EPIEND
gen flag2=1 if days_btween2>=0 & days_btween2<=90
gen flag3=1 if flag==. & flag2==1
keep if flag==1 | flag2==1
/***/
gen hosp_days=EPIEND-EPISTART if flag==1
gen hosp_days2=90-days_btween2 if flag3==1
replace hosp_days=1 if hosp_days==0
replace hosp_days2=1 if hosp_days2==0
replace hosp_days=hosp_days2 if hosp_days==.
/*small n of cases where epi end is before epi start by 1 day - fix this*/
replace hosp_days=1 if hosp_days==-1
/*check no cases with >90*/
bys PERSON_ID: egen total_days=total(hosp_days)
sum total_days, detail 
gen flag_prob=1 if total_days>=91
browse if flag_prob==1
/*small n with 91 not 90 days, feature of rounding up 0 to 1 day earlier - set to 90 for consistency*/
/***/
collapse (sum)hosp_days, by(PERSON_ID)
rename hosp_days hosp_days_last3m
sum hosp_days_last3m, detail
replace hosp_days_last3m=90 if hosp_days_last3m>=91
save "$work\days_in_hosp_last3m_deathsin2019and2020.dta", replace

clear
odbc load, exec("SELECT * FROM dss_corporate.hesf_ethnicity") dsn("databricks")
rename ETHNICITY_CODE ETHNIC
rename ETHNICITY_DESCRIPTION Labelhes
keep ETHNIC Label
save "$raw/hes_ethnicity.dta", replace

clear
odbc load, exec("SELECT * FROM dss_corporate.gdppr_ethnicity") dsn("databricks")
rename Value ETHNIC
rename Label Labelgp
keep ETHNIC Labelgp
save "$raw/gp_ethnicity.dta", replace

clear
insheet using "$raw/IMD_2019_lsoa_lookup.csv"
rename lsoacode2011 LSOA
sort LSOA
save "$raw/IMD_2019_lsoa_lookup.dta", replace

clear
insheet using "$raw/lsoa_STP_lookup.csv"
rename lsoa11cd LSOA
sort LSOA
save "$raw/lsoa_STP_lookup.dta", replace

clear
insheet using "$raw\stp_region_lookup.csv"
sort stp20cd
save "$raw/stp_region_lookup.dta", replace

clear
use "$raw\onspopulation_density_mid2020.dta"
keep lsoacode peoplepersqkm
rename lsoacode LSOA
sort LSOA
save "$raw\onspopulation_density_mid2020.dta", replace


/******************************************************/
/*merge the files*/
clear
use "$raw/deaths_2018_2020.dta"
merge 1:1 PERSON_ID using "$raw/demogs_deaths_2018_2020.dta"
drop _merge
/*drop out the other lsoa vars to simplify*/
label var LSOA lsoa_most_recent_todeath
drop LSOAR _date_LSOA - _tie_LSOA
/*deaths data contains deaths registered in Wales and some in Scotland - but the link to lsoa using HES/GP only draws on english HES/GP -> most with missing LSOA will be Welsh deaths but NB REG_DISTRICT_CODE is the place the death was registered, not necessarily the home of the deceased*/
/*so first keep only the deaths from people living in england (i.e. LSOA in ENG), then drop out if REG_DISTRICT_CODE>"799" & LSOA=.*/
/*REG_DISTRICT_CODE>"799" seems to correspond to welsh REG_DISTRICT_NAME, apart from no name for 812 and no lookup available to check what this code is but reasonable assumption this is welsh*/
gen country=""
replace country="E" if substr(LSOA, 1, 1) == "E"
replace country="W" if substr(LSOA, 1, 1) == "W"
replace country="S" if substr(LSOA, 1, 1) == "S"
replace country="missing" if substr(LSOA, 1, 1) == ""
tab country, mi
drop if country=="S" | country=="W"
tab country if REG_DISTRICT_CODE>"799", mi
drop if REG_DISTRICT_CODE>"799" & country!="E"
tab country, missing
sort LSOA
merge m:1 LSOA using "$raw/IMD_2019_lsoa_lookup.dta"
/*some LSOAs with no deaths fyi*/
sort LSOA
drop _merge
merge m:1 LSOA using "$raw/lsoa_STP_lookup.dta"
drop _merge
drop if PERSON_ID==""
sort PERSON_ID
sort stp20cd
merge m:1 stp20cd using "$raw/stp_region_lookup.dta"
drop _merge
sort ETHNIC
merge m:1 ETHNIC using "$raw/hes_ethnicity.dta"
drop _merge
sort ETHNIC
merge m:1 ETHNIC using "$raw/gp_ethnicity.dta"
drop _merge
merge 1:m PERSON_ID using "$raw/hesAE_deaths_2018_2020.dta"
/*some not matched from using - most are ae lsoas that are welsh - so these are people that we have dropped out earlier becuase their lsoa was not english - in the small number of cases where this ae lsoa is english it must be because a more recent non-english lsoa was available - so still right to drop out these ones. I have checked that all with available ae lsoa have non-missing lsoa in demog link file. */
drop if _merge==2
drop _merge
/*keep only the 2019 & 2020 deaths*/
di date("01012019", "DMY")
di date("31122020", "DMY")
drop if REG_DATE_OF_DEATH<21550
drop if REG_DATE_OF_DEATH>22280
/*merge in count of meds*/
sort PERSON_ID
merge m:1 PERSON_ID using "$raw/pmeds_death_2020_lastyr.dta"
drop if _merge==2
drop _merge
/*merge in hosp days in last 3 months*/
sort PERSON_ID
merge m:1 PERSON_ID using "$work\days_in_hosp_last3m_deathsin2019and2020.dta"
drop if _merge==2
drop _merge
/*merge in the population density*/
sort LSOA
merge m:1 LSOA using "$raw\onspopulation_density_mid2020.dta"
drop if _merge==2
save "$work\merged death_ae_geog_2019_2020.dta", replace

/***************************************************************/
/*prep the data*/
clear
use "$work\merged death_ae_geog_2019_2020.dta"
browse *date* *DATE*

/*create a unique count of deaths for use later*/
sort PERSON_ID
gen death=.
replace death=1 if PERSON_ID!=PERSON_ID[_n-1]

/*code pod*/
codebook POD_CODE
codebook POD_NHS_ESTABLISHMENT
codebook POD_ESTABLISHMENT_TYPE
destring POD_NHS_ESTABLISHMENT, replace
destring POD_ESTABLISHMENT_TYPE, replace

/*check the below against: https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/831853/Classification_Place_Death_report.pdf*/
gen placeofdeath=2 if POD_NHS_ESTABLISHMENT==1 & (POD_ESTABLISHMENT_TYPE==1 | POD_ESTABLISHMENT_TYPE==3 | POD_ESTABLISHMENT_TYPE==18 | POD_ESTABLISHMENT_TYPE==99)
replace placeofdeath=2 if POD_NHS_ESTABLISHMENT==2 & (POD_ESTABLISHMENT_TYPE==1 | POD_ESTABLISHMENT_TYPE==18 | POD_ESTABLISHMENT_TYPE==19)
replace placeofdeath=3 if POD_NHS_ESTABLISHMENT==1 & (POD_ESTABLISHMENT_TYPE==2 | POD_ESTABLISHMENT_TYPE==4 | POD_ESTABLISHMENT_TYPE==7 | POD_ESTABLISHMENT_TYPE==10 | POD_ESTABLISHMENT_TYPE==21)
replace placeofdeath=3 if POD_NHS_ESTABLISHMENT==2 & (POD_ESTABLISHMENT_TYPE==3 | POD_ESTABLISHMENT_TYPE==4 | POD_ESTABLISHMENT_TYPE==7 | POD_ESTABLISHMENT_TYPE==10 | POD_ESTABLISHMENT_TYPE==14 | POD_ESTABLISHMENT_TYPE==20 | POD_ESTABLISHMENT_TYPE==22 | POD_ESTABLISHMENT_TYPE==32 | POD_ESTABLISHMENT_TYPE==33 | POD_ESTABLISHMENT_TYPE==99)
replace placeofdeath=4 if POD_ESTABLISHMENT_TYPE==83
replace placeofdeath=5 if POD_NHS_ESTABLISHMENT==1 & (POD_ESTABLISHMENT_TYPE==5 | POD_ESTABLISHMENT_TYPE==6 | POD_ESTABLISHMENT_TYPE==8 | POD_ESTABLISHMENT_TYPE==9 | POD_ESTABLISHMENT_TYPE==11)
replace placeofdeath=5 if POD_NHS_ESTABLISHMENT==2 & (POD_ESTABLISHMENT_TYPE==5 | POD_ESTABLISHMENT_TYPE==8 | POD_ESTABLISHMENT_TYPE==9 | POD_ESTABLISHMENT_TYPE==11 | POD_ESTABLISHMENT_TYPE==12 | POD_ESTABLISHMENT_TYPE==13 | POD_ESTABLISHMENT_TYPE==15 | POD_ESTABLISHMENT_TYPE==16 | POD_ESTABLISHMENT_TYPE==17)
replace placeofdeath=5 if POD_NHS_ESTABLISHMENT==2 & (POD_ESTABLISHMENT_TYPE>=23 & POD_ESTABLISHMENT_TYPE<=31)
replace placeofdeath=5 if POD_NHS_ESTABLISHMENT==2 & (POD_ESTABLISHMENT_TYPE>=34 & POD_ESTABLISHMENT_TYPE<=82)

label define placeofdeathlab 1"Home" 2"Hospital" 3"Care home" 4"Hospice" 5"Other", replace
label values placeofdeath placeofdeathlab
tab placeofdeath, miss 
tab POD_CODE if placeofdeath==. 
replace placeofdeath=1 if POD_CODE=="H"
replace placeofdeath=5 if POD_CODE=="E" & placeofdeath==.
tab placeofdeath, miss 

/*gen age at death*/
gen byte age_atdeath=(REG_DATE_OF_DEATH-DOB)/365
format age_atdeath %3.0f
/*age cats*/
tab age_atdeath
sum age_atdeath, detail
recode age_atdeath (0/64=1) (65/84=2) (85/120=3), gen(age_cats)
label define age_cats 1 "<65" 2 "65-84" 3 "85+"
label values age_cats age_cats
tab age_cats, mi
/*10 year age bands - max age at death is 100 so group at 101*/
egen age_cat10=cut(age_atdeath), at(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 101)
/*gen age binary*/
gen agebin = .
replace agebin=0 if age_cats==1 | age_cats==2
replace agebin=1 if age_cats==3
label define agebin 0 "<85" 1 "85+"
label values agebin agebin
tab age_cats agebin, mi

/*sex*/
bys SEX: sum age_atdeath
/* 1 = men*/
encode SEX, gen(sex2)
tab sex2
label list sex2
recode sex2 (4=1)
label define sex 1 other 2 men 3 women
label values sex2 sex 

/*ethnicity*/
gen ethnicity=Labelgp
replace ethnicity=Labelhes if Labelgp==""
encode ethnicity, gen(ethnicity2)
label list ethnicity2
recode ethnicity2 (12 = 1) (9 1 = 2) (10 13 = 3) (8 = 4) (20 = 5) (15 = 6) (23 24 25 6 = 7) (14 = 8) (4 16 22 21 = 9) (2 3 5 11 7 = 10) (17 18 19 = .), gen(ethnicity3)
label define ethnicity 1 "white british" 2 "black african" 3 "black caribbean" 4 "bangladeshi" 5 "pakistani" 6 "indian" 7 "mixed" 8 "chinese" 9 "white other" 10 "other"
label values ethnicity3 ethnicity
tab ethnicity3, mi
tab ethnicity2 ethnicity3, mi

/*gen year of death*/
gen death_year=year(REG_DATE_OF_DEATH)

/*time between death and admission*/
gen days_da=ARRIVALDATE-REG_DATE_OF_DEATH
label var days_da "days between death and admission"
gen flag=1 if days_da>0 & days_da!=.
tab flag, mi
/*<0.5% of admissions have a date of death before the admission date - set these days_da to missing so they are dropped from the analysis later*/
replace days_da=. if flag==1
drop flag
/*flag admissions in last 3 months and last 12 months*/
gen last_3m=.
replace last_3m = 1 if days_da>=-90 & days_da!=.
gen last_12m=.
replace last_12m=1 if days_da>=-360 & days_da!=.
/*gen months between death and admission*/
gen months_da=.
label var months_da "month before death"
replace months_da=1 if (days_da<=0 & days_da>=-30) & days_da!=.
replace months_da=2 if (days_da<=-31 & days_da>=-60) & days_da!=.
replace months_da=3 if (days_da<=-61 & days_da>=-90) & days_da!=.
replace months_da=4 if (days_da<=-91 & days_da>=-120) & days_da!=.
replace months_da=5 if (days_da<=-121 & days_da>=-150) & days_da!=.
replace months_da=6 if (days_da<=-151 & days_da>=-180) & days_da!=.
replace months_da=7 if (days_da<=-181 & days_da>=-210) & days_da!=.
replace months_da=8 if (days_da<=-211 & days_da>=-240) & days_da!=.
replace months_da=9 if (days_da<=-241 & days_da>=-270) & days_da!=.
replace months_da=10 if (days_da<=-271 & days_da>=-300) & days_da!=.
replace months_da=11 if (days_da<=-301 & days_da>=-330) & days_da!=.
replace months_da=12 if (days_da<=-331 & days_da>=-360) & days_da!=.

/*OOH flag*/
/*flag time between 18:00-08:00*/
gen double arrival_time2 = clock(ARRIVALTIME, "hm")
format arrival_time2 %tc_HH:MM
gen OOH=0
replace OOH=1 if arrival_time2 >= tc(18:00) & arrival_time2!=.
replace OOH=1 if arrival_time2 < tc(8:00) & arrival_time2!=.
/*flag weekends*/
gen week_day = dow(ARRIVALDATE)
replace OOH=1 if week_day==0 | week_day==6
/*flag bank hols*/
replace OOH=1 if ARRIVALDATE==d(01jan2019)
replace OOH=1 if ARRIVALDATE==d(19apr2019)
replace OOH=1 if ARRIVALDATE==d(22apr2019)
replace OOH=1 if ARRIVALDATE==d(06may2019)
replace OOH=1 if ARRIVALDATE==d(27may2019)
replace OOH=1 if ARRIVALDATE==d(26aug2019)
replace OOH=1 if ARRIVALDATE==d(25dec2019)
replace OOH=1 if ARRIVALDATE==d(26dec2019)
/**/
replace OOH=1 if ARRIVALDATE==d(01jan2020)
replace OOH=1 if ARRIVALDATE==d(10apr2020)
replace OOH=1 if ARRIVALDATE==d(13apr2020)
replace OOH=1 if ARRIVALDATE==d(08may2020)
replace OOH=1 if ARRIVALDATE==d(25may2020)
replace OOH=1 if ARRIVALDATE==d(31aug2020)
replace OOH=1 if ARRIVALDATE==d(25dec2020)
replace OOH=1 if ARRIVALDATE==d(28dec2020)
/*gen in hours flag*/
gen IOED=0
replace IOED=1 if OOH==0

/*cause of death*/
/*MCoD*/
codebook S_UNDERLYING_COD_ICD10 /*<1% missing*/
icd10cm check S_UNDERLYING_COD_ICD10, generate(invalid)
tab S_UNDERLYING_COD_ICD10 if invalid==99
icd10cm clean S_UNDERLYING_COD_ICD10, gen (Main_cause_clean)
icd10cm generate Main_causeR =  Main_cause_clean, description
icd10cm generate Main_causeR1 =  Main_cause_clean, categor

*generate covid death from underlying cause of death
gen covid_death=.
replace covid_death=1 if Main_cause_clean=="U07.1" | Main_cause_clean=="U07.2"
replace covid_death=0 if covid_death!=1
tab covid_death, m

*Main causes of deaths - broad cats*/
gen COD_cat=.
replace COD_cat=1 if Main_cause_clean>="C00" & Main_cause_clean<="D49"
replace COD_cat=2 if Main_cause_clean>="F00" & Main_cause_clean<="F03" | Main_cause_clean>="G30" & Main_cause_clean<"G31"
replace COD_cat=3 if Main_cause_clean>="I00" & Main_cause_clean<="I99"
replace COD_cat=4 if Main_cause_clean>="J00" & Main_cause_clean<="J99"
replace COD_cat=5 if COD_cat==. & Main_cause_clean!=""

lab def COD_cat 1"cancer" 2"dementia" 3"cardiovascular" 4"respiratory" 5"other"
lab val COD_cat COD_cat
tab COD_cat, mi

/*non-sudden causes - following Etkind/Murtagh method*/
gen Main_cause_clean3 = substr(Main_cause_clean, 1, 3)
gen ucod_nonsud = .
replace  ucod_nonsud = 1 if Main_cause_clean3>="C00" & Main_cause_clean3<="C97"
replace ucod_nonsud = 2 if (Main_cause_clean3>="I00" & Main_cause_clean3<="I52") & Main_cause_clean3!="I12" & Main_cause_clean3!="I13"
replace ucod_nonsud = 3 if (Main_cause_clean3>="J40" & Main_cause_clean3<="J47") | Main_cause_clean3=="J96"
replace ucod_nonsud = 4 if Main_cause_clean3=="I12" | Main_cause_clean3=="I13" | Main_cause_clean3=="N17" | Main_cause_clean3=="N18" | Main_cause_clean3=="N28"
replace ucod_nonsud = 5 if Main_cause_clean3>="K70" & Main_cause_clean3<="K77"
replace ucod_nonsud = 6 if Main_cause_clean3=="F01" | Main_cause_clean3=="F03" | Main_cause_clean3=="G30" | Main_cause_clean3=="R54"
replace ucod_nonsud = 7 if Main_cause_clean3=="G10" | Main_cause_clean=="G12.2" | Main_cause_clean3=="G20" | Main_cause_clean=="G23.1" | Main_cause_clean3=="G35" | Main_cause_clean=="G90.3" 
replace ucod_nonsud = 8 if Main_cause_clean3>="I60" & Main_cause_clean3<="I69"
replace ucod_nonsud = 9 if Main_cause_clean3>="B20" & Main_cause_clean3<="B24"
replace ucod_nonsud = 10 if ucod_nonsud==. & Main_cause_clean3!=""
label define ucod_nonsud 1 "cancer_malignant" 2 "heart_disease/failure" 3 "respiratory_disease/failure" 4 "reno-vascular_disease/renal_failure" 5 "liver_disease" 6 "dementia/Alzheimers/senility" 7 "neurodegenerative" 8 "stroke" 9 "HIV" 10 "sudden_cause"
label values ucod_nonsud ucod_nonsud
tab ucod_nonsud, mi
tab ucod_nonsud COD_cat, mi

/*imd quintiles*/
tab indexofmultipledeprivationimddec, mi
recode indexofmultipledeprivationimddec (1/2=1) (3/4=2) (5/6=3) (7/8=4) (9/10=5), gen(imd_quints)
tab indexofmultipledeprivationimddec imd_quints, mi
/*check imd against age - more deprived die younger*/
bys imd_quints: sum age_atdeath

/*ICS/STP*/
codebook stp20nm
encode stp20nm, gen(stp)

/*region*/
codebook nhser20nm
encode nhser20nm, gen(region)
label define region2 1 East 2 London 3 Midlands 4 "N'East/Y'shire'" 5 "N'West" 6 "S'East" 7 "S'West"
label values region region2

/*drop under 18*/
drop if age_atdeath<18 

save "$work/ED_cleaned_2019_2020.dta", replace


/*******************************************************************/
/*gen person level dataset for analysis*/
clear
use "$work/ED_cleaned_2019_2020.dta"
gen last3m_OOH=0
replace last3m_OOH=last_3m if OOH==1
gen last3m_IH=0
replace last3m_IH=last_3m if OOH==0
collapse (firstnm) REG_DATE_OF_DEATH death_year age_atdeath sex2 ethnicity3 indexofmultipledeprivationimdran indexofmultipledeprivationimddec imd_quints S_UNDERLYING_COD_ICD10 COD_cat ucod_nonsud distinct_meds12m distinct_meds3m distinct_meds4to12m region localauthoritydistrictname2019 stp placeofdeath hosp_days_last3m peoplepersqkm (sum)last_3m last_12m last3m_OOH last3m_IH, by(PERSON_ID)
replace hosp_days_last3m=0 if hosp_days_last3m==.
label values placeofdeath placeofdeathlab
label values sex2 sex 
label values ethnicity3 ethnicity
label values region region2
lab val COD_cat COD_cat
label values ucod_nonsud ucod_nonsud
destring indexofmultipledeprivationimdran, replace ignore(",")
rename indexofmultipledeprivationimdran imd_rank
rename indexofmultipledeprivationimddec imd_dec
encode localauthoritydistrictname2019, gen(la_name_2019)
gen death=1
save "$work/ED_cleaned_2019_2020_ptlevel.dta", replace 
drop if ucod_nonsud==10
save "$work/ED_cleaned_2019_2020_ptlevel_exclsudd.dta", replace
drop if placeofdeath==3
save "$work/ED_cleaned_2019_2020_ptlevel_exclsudd_exclcarehome.dta", replace
/*******************************************************************/

/*gen dataset 1st July to 31st december 2019 and 2020 for covid comparison*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel.dta"
di date("01072019", "DMY") 
di date("31122019", "DMY") 
di date("01072020", "DMY") 
di date("31122020", "DMY") 
keep if (REG_DATE_OF_DEATH>=21731 & REG_DATE_OF_DEATH<=21914) | (REG_DATE_OF_DEATH>=22097 & REG_DATE_OF_DEATH<=22280)
save "$work/ED_cleaned_july_dec_2019_2020_ptlevel.dta", replace 
/**/

/*gen dataset just for 2020 and here gen the meds quarts for any descriptives - count will be used in modelling*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel.dta"
keep if death_year==2020
replace distinct_meds12m=0 if distinct_meds12m==.
xtile meds12_quarts = distinct_meds12m, nq(4)
replace distinct_meds3m=0 if distinct_meds3m==.
xtile meds3_quarts = distinct_meds3m, nq(4)
replace distinct_meds4to12m=0 if distinct_meds4to12m==.
xtile meds4to12_quarts = distinct_meds4to12m, nq(4)
xtile peoplepersqkm_quarts = peoplepersqkm, nq(4)
save "$work/ED_cleaned_2020_ptlevel.dta", replace

/*2019 dataset for a supplem table 1*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel.dta"
keep if death_year==2019
xtile peoplepersqkm_quarts = peoplepersqkm, nq(4)
save "$work/ED_cleaned_2019_ptlevel.dta", replace

/*cod check*/
clear
use "$work/ED_cleaned_2019_2020_ptlevel.dta"
tab S_UNDERLYING_COD_ICD10 if COD_cat==2, mi
tab S_UNDERLYING_COD_ICD10 if ucod_nonsud==6, mi
tab COD_cat ucod_nonsud, mi
/*cardio and resp*/
tab S_UNDERLYING_COD_ICD10 if COD_cat==3 & ucod_nonsud==., mi
tab S_UNDERLYING_COD_ICD10 if COD_cat==4 & ucod_nonsud==., mi

/**************************************************************************/
/***END OF SYNTAX***/

