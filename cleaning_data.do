* CLEANING PROCESS

gen COUNTRY = cond(B_COUNTRY_ALPHA == "USA", 1, ///
               cond(B_COUNTRY_ALPHA == "CAN", 2, ///
               cond(B_COUNTRY_ALPHA == "GBR", 3, ///
               cond(B_COUNTRY_ALPHA == "AUS", 4, ///
               cond(B_COUNTRY_ALPHA == "NZL", 5, .)))))

label define country_label 1 "The USA" 2 "Canada" 3 "The UK" 4 "Australia" 5 "New Zealand"
label values COUNTRY country_label

drop B_COUNTRY_ALPHA

*** Negative codes = missing
foreach var of varlist _all {
    replace `var' = . if `var' < 0  
}

replace Q281 = .  /// Remove other types of occupation
        if Q281 == 11

replace Q283 = .  /// Remove other types of occupation
        if Q283 == 11

recode Q281 /// recode occupations of respondents
(0=10 "10 Never had a job") (1=1 "01 Prof. and tech.") (2=2 "02 Higher admin.") (3=3 "03 Clerical") (4=4 "04 Sales") (5=5 "05 Service") (6=6 "06 Skilled worker") (7=7 "07 Semi-skilled worker") (8=8 "08 Unskilled worker") (9/10=9 "09 Farming"), generate(Q281_recoded) 

recode Q283 /// recode occupations of fathers
(0=10 "10 Never had a job") (1=1 "01 Prof. and tech.") (2=2 "02 Higher admin.") (3=3 "03 Clerical") (4=4 "04 Sales") (5=5 "05 Service") (6=6 "06 Skilled worker") (7=7 "07 Semi-skilled worker") (8=8 "08 Unskilled worker") (9/10=9 "09 Farming"), generate(Q283_recoded)

recode Q288 ///  Recode to 5-level
(1/2=1 "Lower class") (3/4=2 "Working class") (5/6=3 "Lower middle class") (7/8=4 "Upper middle class") (9/10=5 "Upper class"), generate(Q288_recoded) 

recode Q159 /// Recode to 5-level
(9/10=1 "Agree strongly") (7/8=2 "Agree") (5/6=3 "Neither agree nor disagree") (3/4=4 "Disagree") (1/2=5 "Disagree strongly"), generate(Q159_recoded) 

label define Q263_label 1 "native" 2 "immigrant"
label values Q263 Q263_label

generate Q275_Q278 = .
replace Q275_Q278 = 1 if Q275 > Q278
replace Q275_Q278 = 2 if Q275 < Q278
replace Q275_Q278 = 3 if Q275 == Q278
label define Q275_Q278_label 1 "Better off" 2 "Worse off" 3 "About the same"
label values Q275_Q278 Q275_Q278_label

*** equilibrated weights between countries
egen group = group(COUNTRY)
egen obs_per_country = count(COUNTRY), by(group)
gen weights = 1/obs_per_country
tabstat weights, by(COUNTRY) stat(sum) 