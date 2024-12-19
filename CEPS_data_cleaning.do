***Database Merging***
use cepsw1studenten.dta, clear	// Open T1 student survey database file
merge 1:1 ids using cepsw2studenten.dta	// Merge T2 student survey database using Student ID 'ids'
drop if _merge == 1 | _merge == 2	// Delete data in T2 student database that cannot match with T1 `ids`
drop _merge

merge 1:1 ids using cepsw1parenten.dta	// Merge T1 parent survey database using Student ID 'ids'
drop if _merge == 1 | _merge == 2	// Delete data in T1 parent database that cannot match with T1 `ids`
drop _merge

merge 1:1 ids using cepsw2parenten.dta	// Merge T2 parent survey database using Student ID 'ids'
drop if _merge == 1 | _merge == 2	// Delete data in T2 parent database that cannot match with T1 `ids`

summarize ids

***Data Cleaning***
*Educational aspiration
recode c22 (10=.), gen(educational_aspiration)	// Recode dependent variable 'Educational aspiration'
tabulate educational_aspiration, nol

*Risk factors coding
recode a10 (1=1) (2/3=0), gen(t1_physical_risk)	// Recode 'T1 serious illness'

gen t2_physical_risk = 0 if !missing(w2c0701a, w2c0702a, w2c0703a, w2c0704a, w2c0705a, w2c0706a) // Recode 'T2 serious illness'
replace t2_physical_risk = 1 if w2c0701a == 3 | w2c0702a == 3 | w2c0703a == 3 | w2c0704a == 3 | w2c0705a == 3 | w2c0706a == 3

gen t1_psychological_risk = 0 if !missing(a1801, a1802, a1803, a1804, a1805) // Recode 'T1 excessive negative emotions'
replace t1_psychological_risk = 1 if a1801 >= 4 | a1802 >= 4 | a1803 >= 4 | a1804 >= 4 | a1805 >= 4

gen t2_psychological_risk = 0 if !missing(w2c2501, w2c2502, w2c2503, w2c2504, w2c2506) // Recode 'T2 excessive negative emotions'
replace t2_psychological_risk = 1 if w2c2501 >= 4 | w2c2502 >= 4 | w2c2503 >= 4 | w2c2504 >= 4 | w2c2506 >= 4

recode steco_5c (1/2=1) (3/5=0), gen(t1_family_poverty_risk)	// Recode 'T1 family poverty'

recode w2a09 (1/2=1) (3/5=0), gen(t2_family_poverty_risk)	// Recode 'T2 family poverty'

recode be22 (1=1) (2=0), gen(t1_family_illness_risk)	// Recode 'T1 serious illness of a family member'

recode w2be26 (1=1) (2=0), gen(t2_family_illness_risk)	// Recode 'T2 serious illness of a family member'

*School support factors coding
recode c1704 (3/4=1) (1/2=0), gen(t1_teacher)	// Recode 'T1 My teacher and I have a good relationship'

recode w2b0603 (3/4=1) (1/2=0), gen(t2_teacher)	// Recode 'T2 My teacher and I have a good relationship'

recode c1706 (3/4=1) (1/2=0), gen(t1_peer)	// Recode 'T1 My classmates are very nice to me'

recode w2b0605 (3/4=1) (1/2=0), gen(t2_peer)	// Recode 'T2 My classmates are very nice to me'

recode c1708 (3/4=1) (1/2=0), gen(t1_class)	// Recode 'T1 The class atmosphere is good'

recode w2b0606 (3/4=1) (1/2=0), gen(t2_class)	// Recode 'T2 The class atmosphere is good'

recode c1710 (3/4=1) (1/2=0), gen(t1_school)	// Recode 'T1 The school atmosphere is good'

recode w2b0608 (3/4=1) (1/2=0), gen(t2_school)	// Recode 'T2 The school atmosphere is good'

*Grouping variables
gen hukou = sthktype	// Recode 'current Hukou'(1=rural Hukou)
gen gender = stsex	// Recode 'Gender'(1=male)

gen total_score = tr_chn + tr_mat + tr_eng  // Recode 'performance' (1=good performance)
egen score_standard = std(total_score)
recode score_standard (1/max=1) (min/-1=0) (else=.), gen(academic_performance) 

summarize t1_physical_risk t2_physical_risk t1_psychological_risk t2_psychological_risk t1_family_poverty_risk ///
	t2_family_poverty_risk t1_family_illness_risk t2_family_illness_risk t1_teacher t2_teacher ///
	t1_peer t2_peer t1_class t2_class t1_school t2_school ///
	hukou gender academic_performance
	 
save mergedata.dta, replace

