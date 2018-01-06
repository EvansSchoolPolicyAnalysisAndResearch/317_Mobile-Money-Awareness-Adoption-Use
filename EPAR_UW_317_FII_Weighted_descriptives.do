*********************************
**WEIGHTED DESCRIPTIVES, WAVE 3**
*********************************
*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
*				  for to construct descriptive statistics 
*				  using Financial Inclusion Insights Wave 3 data sets.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer, Andrew Andrew Orlebeke

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/

*TABLE OF CONTENTS
*----------
*1. File description
*2. Appending of individual country wave 3 .dta files
*3. Generating and renaming of variables
*5. Demographics
	//a. Sample subpopulation code
	//b. Descriptives
	//bc. Chi-squared tests
*6. Chi-squared tests of demographics
*7. Weighted descriptives, awareness
	//a. Proportions
	//b. Counts
*8. Weighted descriptives, adoption
	//a. Proportions
	//b. Counts
*9. Weighted descriptives, use
	//a. Proportions
	//b. Counts
*10. Descriptive stastics for females only
	//a. Descriptives
	//b. Chi-squared tests
*11. Weighted frequency of use by country


*Data source
*-----------
*The Financial Inclusion Insights data was collected by Intermedia 
*The data were collected across all aurveyed countries in Wave 3 from June 2015 – October 2015.
	//Tanzania
	//Kenya
	//Uganda
	//Nigeria
	//India
	//Pakistan
	//Indonesia 
	//Bangladesh


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs descriptive stastics and performs chi2 tests for selected sociodemogaphic characteristics from Financial Inclusion Insights Wave 3 data sets.
*This .do file uses the cleaned .dta files for each country and wave prepared in individual country/wave .do files. 
*To run the .do file, update the filepaths below to indicate the locations where you have saved those .dta files. If you have saved them in different folder, it may be most efficient to copy all the cleaned .dta files to the same folder.
*The .do file first loads all relevant data sets and saves a Master aggregated Wave 3 .dta file.
*the .do file then labels relevant variables and creates weighted descriptives statistics for the following sample populations: 
*entire FII Wave 3 sample
*those aware of MM in Wave 3
*those who adopted MM in Wave 3
*those who used MM in the last 90 days in Wave 3
*only women in Wave 3
*The file then creates weighted frequency of use statistics among those who adopted MM 


clear
//Global list for input
global input "filepath for location where you want to save output files" //from the individual country .do files 
//Global path for saving output files (for regression output below)
global output "filepath for location where you want to save Wave 3 analysis"

*********************************************
** APPEND DATASETS TO CREATE ONE .DTA FILE **
*********************************************

//Starting with Tanzania
clear
append using "$input\W3\Tanzania_W3_Clean.dta", force

//Add in Kenya
append using "$input\W3\Kenya_W3_Clean.dta", force

//Add in Uganda
append using "$input\W3\Uganda_W3_Clean.dta", force

//Add in Nigeria
append using "$input\W3\Nigeria_W3_Clean.dta", force

//Add in India
append using "$input\W3\India_W3_Clean.dta", force

//Add in Pakistan
append using "$input\W3\Pakistan_W3_Clean.dta", force
 
//Add in Indonesia
append using "$input\W3\Indonesia_W2_Clean.dta", force

//Add in Bangladesh
append using "$input\W3\Bangladesh_W3_Clean.dta", force

save "$output\W3_Master.dta"

******************
* LOAD WAVE 3 DTA AND GENERATE NEW VARIABLES*
******************

clear
use "$output\W3_Master.dta"

**Create a continent variable and check
gen africa=1 if kenya==1 | tanzania==1 | uganda==1 | nigeria==1
replace africa=0 if bang==1 | india==1 | indonesia==1 | pakistan==1
label define afri_1 0 "Asia" 1 "Africa" 
label values africa afri_1
tab africa country


**Create a variable for owns a phone and owns a SIM card
gen sim_phone=1 if sim_own==1 & phone_own==1
replace sim_phone=0 if sim_own==0 | phone_own==0
label define sim_phone1 0 "No" 1 "Yes"
label values sim_phone sim_phone1
tab sim_phone

**Create a variable for owns a phone but does not own a SIM card
gen phone_nosim=1 if phone_own==1 & sim_own==0
replace phone_nosim=0 if phone_nosim==.
label define phone_nosim1 0 "Phone & SIM" 1 "Phone but no SIM"
label values phone_nosim phone_nosim1

**Generate a variable for people who own phones but no SIM cards
gen no_sim=1 if sim_own==0
replace no_sim=0 if sim_own==1
gen phone_nosim=1 if phone_own==1 & no_sim==1
replace phone_nosim=0 if phone_own==0 | sim_own==1

**ALTERNATE VARIABLES FOR DESCRIPTIVE STATISTICS

**Generate a male variable
gen male=. 
replace male=1 if female==0
replace male=0 if female==1

**Generate an urban variable 
gen urban=.
replace urban=1 if urban_rural==1
replace urban=0 if urban_rural==2

**Over the ppi cutoff of $2.50/day
gen ppi_above=.
replace ppi_above=1 if ppi_cutoff==0
replace ppi_above=0 if ppi_cutoff==1

**Illiterate
gen illiterate=.
replace illiterate=1 if literate==0
replace illiterate=0 if literate==1

**Innumerate
gen innumerate=.
replace innumerate=1 if numerate==0
replace innumerate=0 if numerate==1

**Unemployed
gen unempl=.
replace unempl=1 if employed==0
replace unempl=0 if employed==1

**Single
gen single=.
replace single=1 if married==0
replace single=0 if married==1

save "$output\W3_Master.dta"

****************
**DEMOGRAPHICS**
****************

svyset [pweight=weight]

**********************
*CHOOSE SUBPOPULATION*
**********************

*FEMALES ONLY
*change "svy:" to "svy, subpop(if female==1):"
*if already subpop command, change "svy, subpop([subpop1]):" where [subpop1] is any subpop to "svy, subpop(if [subpop1==1] & female==1):"

*MALES ONLY
*change "svy:" to "svy, subpop(if female==0):"
*if already subpop command, change "svy, subpop([subpop1]):" where [subpop1] is any subpop to "svy, subpop(if [subpop1==1] & female==0):"


**own phone but no sim and have access to sim
svy, subpop(if phone_nosim==1): proportion sim_access,over(country)

**Run the descriptive stats weighted by country for Wave 3
svy: proportion female, over(country)

**Mean age comparison - not for tables
svy: mean age
svy: mean age, over(africa)

svy: mean age, over(country)
svy: proportion age_group, over(country)

svy: proportion rural, over(country)
svy: proportion ppi_cutoff, over(country)
svy: proportion married, over(country)

svy: proportion employed, over(country)
svy: proportion literate, over(country)
svy: proportion numerate, over(country)

svy: proportion ed_level, over(country)

svy: proportion official_id, over(country)
svy: proportion phone_own, over(country)
svy: proportion sim_own, over(country)

svy: proportion sim_phone, over(country)
svy: proportion bank_own, over(country)

**************
**CHI2 TESTS**
**************
**Test for statistically significant differences in proportion by country
**This is a weighted Pearson's Chi2 test
**Tells you that the percent female differs by country (not due to chance)

svy: tabulate female country
svy: tabulate age_group country

svy: tabulate rural
svy: tabulate ppi_cutoff country
svy: tabulate married country

svy: tabulate employed country
svy: tabulate literate country
svy: tabulate numerate country

svy: tabulate ed_level country

svy: tabulate official_id country
svy: tabulate phone_own country
svy: tabulate sim_own country

svy: tabulate sim_phone country
svy: tabulate bank_own country

**Check that these tests are still correct when stratified by continent

**Africa
svy: tabulate female country if africa==1
svy: tabulate age_group country if africa==1

svy: tabulate rural if africa==1
svy: tabulate ppi_cutoff country if africa==1
svy: tabulate married country if africa==1

svy: tabulate employed country if africa==1
svy: tabulate literate country if africa==1
svy: tabulate numerate country if africa==1

svy: tabulate ed_level country if africa==1

svy: tabulate official_id country if africa==1
svy: tabulate phone_own country if africa==1
svy: tabulate sim_own country if africa==1

svy: tabulate sim_phone country if africa==1
svy: tabulate bank_own country if africa==1

**Asia
svy: tabulate female country if africa==0
svy: tabulate age_group country if africa==0

svy: tabulate rural if africa==0
svy: tabulate ppi_cutoff country if africa==0
svy: tabulate married country if africa==0

svy: tabulate employed country if africa==0
svy: tabulate literate country if africa==0
svy: tabulate numerate country if africa==0

svy: tabulate ed_level country if africa==0

svy: tabulate official_id country if africa==0
svy: tabulate phone_own country if africa==0
svy: tabulate sim_own country if africa==0

svy: tabulate sim_phone country if africa==0
svy: tabulate bank_own country if africa==0

**Phone and SIM Ownership Decision
svy: proportion phone_own, over (country)
svy: proportion sim_phone, over(country)
svy, subpop(phone_own): proportion sim_own, over(country)


svy, subpop(phone_nosim): proportion sim_access, over(country)
svy: tabulate phone_nosim country


************************************
**WEIGHTED DESCRIPTIVES, AWARENESS**
************************************

****************************
**WEIGHTED AWARENESS OF MM**
****************************

svy: tabulate dfs_aware_name country, count
svy: proportion dfs_aware_name, over (country)

**Gender
svy, subpop(female): proportion dfs_aware_name, over(country)
svy, subpop(male): proportion dfs_aware_name, over(country)

**Age category
svy, subpop(kenya): proportion dfs_aware_name, over(age_group)
svy, subpop(nigeria): proportion dfs_aware_name, over(age_group)
svy, subpop(tanzania): proportion dfs_aware_name, over(age_group)
svy, subpop(uganda): proportion dfs_aware_name, over(age_group)
svy, subpop(bang): proportion dfs_aware_name, over(age_group)
svy, subpop(india): proportion dfs_aware_name, over(age_group)
svy, subpop(indonesia): proportion dfs_aware_name, over(age_group)
svy, subpop(pakistan): proportion dfs_aware_name, over(age_group)

**Rural 
svy, subpop(rural): proportion dfs_aware_name, over(country)
svy, subpop(urban): proportion dfs_aware_name, over(country)

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): proportion dfs_aware_name, over(country)
svy, subpop(ppi_above): proportion dfs_aware_name, over(country)

**Rural Below PPI
svy, subpop(rural_poor): proportion dfs_aware_name, over(country)

**Married
svy, subpop(married): proportion dfs_aware_name, over(country)
svy, subpop(single): proportion dfs_aware_name, over(country)

**Employed
svy, subpop(unempl): proportion dfs_aware_name, over(country)
svy, subpop(employed): proportion dfs_aware_name, over(country)

**Literate
svy, subpop(illiterate): proportion dfs_aware_name, over(country)
svy, subpop(literate): proportion dfs_aware_name, over(country)

**Numerate
svy, subpop(innumerate): proportion dfs_aware_name, over(country)
svy, subpop(numerate): proportion dfs_aware_name, over(country)

**********************
**LEVEL OF EDUCATION**
**********************

**Level of Education
svy, subpop(kenya): proportion dfs_aware_name, over(ed_level)
svy, subpop(nigeria): proportion dfs_aware_name, over(ed_level)
svy, subpop(tanzania): proportion dfs_aware_name, over(ed_level)
svy, subpop(uganda): proportion dfs_aware_name, over(ed_level)
svy, subpop(bang): proportion dfs_aware_name, over(ed_level)
svy, subpop(india): proportion dfs_aware_name, over(ed_level)
svy, subpop(indonesia): proportion dfs_aware_name, over(ed_level)
svy, subpop(pakistan): proportion dfs_aware_name, over(ed_level)


********************
**ACCESS VARIABLES**
********************
**No Official ID
gen no_official_id=.
replace no_official_id=1 if official_id==0
replace no_official_id=0 if official_id==1

**No phone
gen no_phone=.
replace no_phone=1 if phone_own==0
replace no_phone=0 if phone_own==1

**No SIM
gen no_sim=.
replace no_sim=1 if sim_own==0
replace no_sim=0 if sim_own==1

**No bank account
gen no_bank=.
replace no_bank=1 if bank_own==0
replace no_bank=0 if bank_own==1

**Official ID
svy, subpop(official_id): proportion dfs_aware_name, over(country)
svy, subpop(no_official_id): proportion dfs_aware_name, over(country)

**Phone ownership
svy, subpop(phone_own): proportion dfs_aware_name, over(country)
svy, subpop(no_phone): proportion dfs_aware_name, over(country)

**SIM ownership
svy, subpop(sim_own): proportion dfs_aware_name, over(country)
svy, subpop(no_sim): proportion dfs_aware_name, over(country)

**Bank account ownership
svy, subpop(bank_own): proportion dfs_aware_name, over(country)
svy, subpop(no_bank): proportion dfs_aware_name, over(country)

**********
**COUNTS**
**********

**Gender
svy, subpop(female): tabulate dfs_aware_name country, count 
svy, subpop(male): tabulate dfs_aware_name country, count 

**Age category
svy, subpop(kenya): tabulate dfs_aware_name age_group, count
svy, subpop(nigeria): tabulate dfs_aware_name age_group, count
svy, subpop(tanzania): tabulate dfs_aware_name age_group, count
svy, subpop(uganda): tabulate dfs_aware_name age_group, count
svy, subpop(bang): tabulate dfs_aware_name age_group, count
svy, subpop(india): tabulate dfs_aware_name age_group, count
svy, subpop(indonesia): tabulate dfs_aware_name age_group, count
svy, subpop(pakistan): tabulate dfs_aware_name age_group, count

**Rural 
svy, subpop(rural): tabulate dfs_aware_name country, count 
svy, subpop(urban): tabulate dfs_aware_name country, count 

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): tabulate dfs_aware_name country, count 
svy, subpop(ppi_above): tabulate dfs_aware_name country, count 

**Rural Below PPI
svy, subpop(rural_poor): tabulate dfs_aware_name country, count 

**Married
svy, subpop(married): tabulate dfs_aware_name country, count 
svy, subpop(single): tabulate dfs_aware_name country, count 

**Literate
svy, subpop(literate): tabulate dfs_aware_name country, count 
svy, subpop(illiterate): tabulate dfs_aware_name country, count 

**Numerate
svy, subpop(numerate): tabulate dfs_aware_name country, count 
svy, subpop(innumerate): tabulate dfs_aware_name country, count 

**Employed
svy, subpop(employed): tabulate dfs_aware_name country, count 
svy, subpop(unempl): tabulate dfs_aware_name country, count 

**Level of education
svy, subpop(kenya): tabulate dfs_aware_name ed_level, count
svy, subpop(nigeria): tabulate dfs_aware_name ed_level, count
svy, subpop(tanzania): tabulate dfs_aware_name ed_level, count
svy, subpop(uganda): tabulate dfs_aware_name ed_level, count
svy, subpop(bang): tabulate dfs_aware_name ed_level, count
svy, subpop(india): tabulate dfs_aware_name ed_level, count
svy, subpop(indonesia): tabulate dfs_aware_name ed_level, count
svy, subpop(pakistan): tabulate dfs_aware_name ed_level, count

*****************
**ACCESS COUNTS**
*****************

**Official ID
svy, subpop(official_id): tabulate dfs_aware_name country, count 
svy, subpop(no_official_id): tabulate dfs_aware_name country, count 

**Phone ownership
svy, subpop(phone_own): tabulate dfs_aware_name country, count 
svy, subpop(no_phone): tabulate dfs_aware_name country, count 

**SIM ownership
svy, subpop(sim_own): tabulate dfs_aware_name country, count 
svy, subpop(no_sim): tabulate dfs_aware_name country, count 

**Bank account ownershup
svy, subpop(bank_own): tabulate dfs_aware_name country, count 
svy, subpop(no_bank): tabulate dfs_aware_name country, count 




************************************
**WEIGHTED DESCRIPTIVES, ADOPTION**
************************************

use "$output\W3_Master.dta", clear

****************************
**WEIGHTED ADOPTION OF MM**
****************************
svy: tabulate dfs_adopt country, count 
svy: proportion dfs_adopt, over(country)

**Gender
svy, subpop(female): proportion dfs_adopt, over(country)
svy, subpop(male): proportion dfs_adopt, over(country)

**Age category
svy, subpop(kenya): proportion dfs_adopt, over(age_group)
svy, subpop(nigeria): proportion dfs_adopt, over(age_group)
svy, subpop(tanzania): proportion dfs_adopt, over(age_group)
svy, subpop(uganda): proportion dfs_adopt, over(age_group)

svy, subpop(bang): proportion dfs_adopt, over(age_group)
svy, subpop(india): proportion dfs_adopt, over(age_group)
svy, subpop(indonesia): proportion dfs_adopt, over(age_group)
svy, subpop(pakistan): proportion dfs_adopt, over(age_group)

**Rural 
svy, subpop(rural): proportion dfs_adopt, over(country)
svy, subpop(urban): proportion dfs_adopt, over(country)

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): proportion dfs_adopt, over(country)
svy, subpop(ppi_above): proportion dfs_adopt, over(country)

**Rural Below PPI
svy, subpop(rural_poor): proportion dfs_adopt, over(country)

**Married
svy, subpop(married): proportion dfs_adopt, over(country)
svy, subpop(single): proportion dfs_adopt, over(country)

**Employed
svy, subpop(unempl): proportion dfs_adopt, over(country)
svy, subpop(employed): proportion dfs_adopt, over(country)

**Literate
svy, subpop(illiterate): proportion dfs_adopt, over(country)
svy, subpop(literate): proportion dfs_adopt, over(country)

**Numerate
svy, subpop(innumerate): proportion dfs_adopt, over(country)
svy, subpop(numerate): proportion dfs_adopt, over(country)

**********************
**LEVEL OF EDUCATION**
**********************

**Level of Education
svy, subpop(kenya): proportion dfs_adopt, over(ed_level)
svy, subpop(nigeria): proportion dfs_adopt, over(ed_level)
svy, subpop(tanzania): proportion dfs_adopt, over(ed_level)
svy, subpop(uganda): proportion dfs_adopt, over(ed_level)

svy, subpop(bang): proportion dfs_adopt, over(ed_level)
svy, subpop(india): proportion dfs_adopt, over(ed_level)
svy, subpop(indonesia): proportion dfs_adopt, over(ed_level)
svy, subpop(pakistan): proportion dfs_adopt, over(ed_level)


********************
**ACCESS VARIABLES**
********************
**Official ID
svy, subpop(no_official_id): proportion dfs_adopt, over(country)
svy, subpop(official_id): proportion dfs_adopt, over(country)

**Phone ownership
svy, subpop(no_phone): proportion dfs_adopt, over(country)
svy, subpop(phone_own): proportion dfs_adopt, over(country)

**SIM ownership
svy, subpop(no_sim): proportion dfs_adopt, over(country)
svy, subpop(sim_own): proportion dfs_adopt, over(country)

**Bank account ownership
svy, subpop(no_bank): proportion dfs_adopt, over(country)
svy, subpop(bank_own): proportion dfs_adopt, over(country)


**********
**COUNTS**
**********

**Gender
svy: tabulate dfs_adopt country, count 
svy, subpop(female): tabulate dfs_adopt country, count 
svy, subpop(male): tabulate dfs_adopt country, count 

**Age category
svy, subpop(kenya): tabulate dfs_adopt age_group, count
svy, subpop(nigeria): tabulate dfs_adopt age_group, count
svy, subpop(tanzania): tabulate dfs_adopt age_group, count
svy, subpop(uganda): tabulate dfs_adopt age_group, count

svy, subpop(bang): tabulate dfs_adopt age_group, count
svy, subpop(india): tabulate dfs_adopt age_group, count
svy, subpop(indonesia): tabulate dfs_adopt age_group, count
svy, subpop(pakistan): tabulate dfs_adopt age_group, count

**Rural 
svy, subpop(rural): tabulate dfs_adopt country, count 
svy, subpop(urban): tabulate dfs_adopt country, count 

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): tabulate dfs_adopt country, count 
svy, subpop(ppi_above): tabulate dfs_adopt country, count 

**Rural Below PPI
svy, subpop(rural_poor): tabulate dfs_adopt country, count 

**Married
svy, subpop(married): tabulate dfs_adopt country, count 
svy, subpop(single): tabulate dfs_adopt country, count 

**Literate
svy, subpop(literate): tabulate dfs_adopt country, count 
svy, subpop(illiterate): tabulate dfs_adopt country, count 

**Numerate
svy, subpop(numerate): tabulate dfs_adopt country, count 
svy, subpop(innumerate): tabulate dfs_adopt country, count 

**Employed
svy, subpop(employed): tabulate dfs_adopt country, count 
svy, subpop(unempl): tabulate dfs_adopt country, count 

********************
**LEVEL OF EDUCATION COUNTS**
********************

**Level of Education
svy, subpop(kenya): tabulate dfs_adopt ed_level, count
svy, subpop(nigeria): tabulate dfs_adopt ed_level, count
svy, subpop(tanzania): tabulate dfs_adopt ed_level, count
svy, subpop(uganda): tabulate dfs_adopt ed_level, count
svy, subpop(bang): tabulate dfs_adopt ed_level, count
svy, subpop(india): tabulate dfs_adopt ed_level, count
svy, subpop(indonesia): tabulate dfs_adopt ed_level, count
svy, subpop(pakistan): tabulate dfs_adopt ed_level, count

*****************
**ACCESS COUNTS**
*****************

**Official ID
svy, subpop(official_id): tabulate dfs_aware_name country, count 
svy, subpop(no_official_id): tabulate dfs_aware_name country, count 

**Phone ownership
svy, subpop(phone_own): tabulate dfs_aware_name country, count 
svy, subpop(no_phone): tabulate dfs_aware_name country, count 

**SIM ownership
svy, subpop(sim_own): tabulate dfs_aware_name country, count 
svy, subpop(no_sim): tabulate dfs_aware_name country, count 

**Bank account ownership
svy, subpop(bank_own): tabulate dfs_aware_name country, count 
svy, subpop(no_bank): tabulate dfs_aware_name country, count 



************************************
*****WEIGHTED DESCRIPTIVES, USE*****
************************************
/*clear
use "R:\Project\EPAR\Working Files\317 - Gender and DFS Adoption\Output\Wave 3\W3_Master.dta" */

****************************
*****WEIGHTED USE OF MM*****
****************************
svy: mean age, over(country)
svy: proportion dfs_90, over(country)

**Gender
svy, subpop(female): proportion dfs_90, over(country)
svy, subpop(male): proportion dfs_90, over(country)

**Age category
svy, subpop(kenya): proportion dfs_90, over(age_group)
svy, subpop(nigeria): proportion dfs_90, over(age_group)
svy, subpop(tanzania): proportion dfs_90, over(age_group)
svy, subpop(uganda): proportion dfs_90, over(age_group)
svy, subpop(bang): proportion dfs_90, over(age_group)
svy, subpop(india): proportion dfs_90, over(age_group)
svy, subpop(indonesia): proportion dfs_90, over(age_group)
svy, subpop(pakistan): proportion dfs_90, over(age_group)

**Rural 
svy, subpop(rural): proportion dfs_90, over(country)
svy, subpop(urban): proportion dfs_90, over(country)

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): proportion dfs_90, over(country)
svy, subpop(ppi_above): proportion dfs_90, over(country)

**Rural Below PPI
svy, subpop(rural_poor): proportion dfs_90, over(country)

**Married
svy, subpop(married): proportion dfs_90, over(country)
svy, subpop(single): proportion dfs_90, over(country)

**Literate
svy, subpop(literate): proportion dfs_90, over(country)
svy, subpop(illiterate): proportion dfs_90, over(country)

**Numerate
svy, subpop(numerate): proportion dfs_90, over(country)
svy, subpop(innumerate): proportion dfs_90, over(country)

**Employed
svy, subpop(employed): proportion dfs_90, over(country)
svy, subpop(unempl): proportion dfs_90, over(country)

********************
**LEVEL OF EDUCATION**
********************

**Level of Education
svy, subpop(kenya): proportion dfs_90, over(ed_level)
svy, subpop(nigeria): proportion dfs_90, over(ed_level)
svy, subpop(tanzania): proportion dfs_90, over(ed_level)
svy, subpop(uganda): proportion dfs_90, over(ed_level)
svy, subpop(bang): proportion dfs_90, over(ed_level)
svy, subpop(india): proportion dfs_90, over(ed_level)
svy, subpop(indonesia): proportion dfs_90, over(ed_level)
svy, subpop(pakistan): proportion dfs_90, over(ed_level)


********************
**ACCESS VARIABLES**
********************

**Official ID
svy, subpop(official_id): proportion dfs_90, over(country)
svy, subpop(no_official_id): proportion dfs_90, over(country)

**Phone ownership
svy, subpop(phone_own): proportion dfs_90, over(country)
svy, subpop(no_phone): proportion dfs_90, over(country)

**SIM ownership
svy, subpop(sim_own): proportion dfs_90, over(country)
svy, subpop(no_sim): proportion dfs_90, over(country)

**Bank account ownershup
svy, subpop(bank_own): proportion dfs_90, over(country)
svy, subpop(no_bank): proportion dfs_90, over(country)


**********
**COUNTS**
**********
svy: tabulate dfs_90 country, count
svy: proportion dfs_90, over (country)

**Gender
svy, subpop(female): tabulate dfs_90 country, count 
svy, subpop(male): tabulate dfs_90 country, count 

**Age category
svy, subpop(kenya): tabulate dfs_90 age_group, count
svy, subpop(nigeria): tabulate dfs_90 age_group, count
svy, subpop(tanzania): tabulate dfs_90 age_group, count
svy, subpop(uganda): tabulate dfs_90 age_group, count
svy, subpop(bang): tabulate dfs_90 age_group, count
svy, subpop(india): tabulate dfs_90 age_group, count
svy, subpop(indonesia): tabulate dfs_90 age_group, count
svy, subpop(pakistan): tabulate dfs_90 age_group, count

**Rural 
svy, subpop(rural): tabulate dfs_90 country, count 
svy, subpop(urban): tabulate dfs_90 country, count 

**PPI Cutoff of $2.50/day
svy, subpop(ppi_cutoff): tabulate dfs_90 country, count 
svy, subpop(ppi_above): tabulate dfs_90 country, count 

**Rural Below PPI
svy, subpop(rural_poor): tabulate dfs_90 country, count 

**Married
svy, subpop(married): tabulate dfs_90 country, count 
svy, subpop(single): tabulate dfs_90 country, count 

**Literate
svy, subpop(literate): tabulate dfs_90 country, count 
svy, subpop(illiterate): tabulate dfs_90 country, count 

**Numerate
svy, subpop(numerate): tabulate dfs_90 country, count 
svy, subpop(innumerate): tabulate dfs_90 country, count 

**Employed
svy, subpop(employed): tabulate dfs_90 country, count 
svy, subpop(unempl): tabulate dfs_90 country, count 

********************
**LEVEL OF EDUCATION**
********************

**Level of Education
svy, subpop(kenya): tabulate dfs_90 ed_level, count
svy, subpop(nigeria): tabulate dfs_90 ed_level, count
svy, subpop(tanzania): tabulate dfs_90 ed_level, count
svy, subpop(uganda): tabulate dfs_90 ed_level, count
svy, subpop(bang): tabulate dfs_90 ed_level, count
svy, subpop(india): tabulate dfs_90 ed_level, count
svy, subpop(indonesia): tabulate dfs_90 ed_level, count
svy, subpop(pakistan): tabulate dfs_90 ed_level, count

*****************
**ACCESS COUNTS**
*****************

**Official ID
svy, subpop(official_id): tabulate dfs_90 country, count 
svy, subpop(no_official_id): tabulate dfs_90 country, count 

**Phone ownership
svy, subpop(phone_own): tabulate dfs_90 country, count 
svy, subpop(no_phone): tabulate dfs_90 country, count 

**SIM ownership
svy, subpop(sim_own): tabulate dfs_90 country, count 
svy, subpop(no_sim): tabulate dfs_90 country, count 

**Bank account ownershup
svy, subpop(bank_own): tabulate dfs_90 country, count 
svy, subpop(no_bank): tabulate dfs_90 country, count 




*********************************
**DESCRIPTIVES FOR FEMALES ONLY**
*********************************

**Run the same descriptives but ONLY on the female population
**This code drops males from the data, so should be run after other descriptives

*****************************
**FEMALES ONLY DEMOGRAPHICS**
*****************************

**Drop out males to calculate females only
keep if female==1

svy: tab country, count

svy: mean age, over(country)
svy: proportion age_group, over(country)

svy: proportion rural, over(country)
svy: proportion ppi_cutoff, over(country)
svy: proportion married, over(country)

svy: proportion employed, over(country)
svy: proportion literate, over(country)
svy: proportion numerate, over(country)

svy: proportion ed_level, over(country)

svy: proportion official_id, over(country)
svy: proportion phone_own, over(country)
svy: proportion sim_own, over(country)

svy: proportion sim_phone, over(country)
svy: proportion bank_own, over(country)


**Run Pearson's Chi2 tests again for only women
svy: tabulate age_group country

svy: tabulate rural
svy: tabulate ppi_cutoff country
svy: tabulate married country

svy: tabulate employed country
svy: tabulate literate country
svy: tabulate numerate country

svy: tabulate ed_level country

svy: tabulate official_id country
svy: tabulate phone_own country
svy: tabulate sim_own country

svy: tabulate sim_phone country
svy: tabulate phone_nosim country
svy: tabulate bank_own country


*************************************
*****WEIGHTED FREQUENCY OF USE OF MM*
*************************************

svy: tabulate dfs_freq country, count

svy, subpop(kenya): proportion dfs_freq
svy, subpop(nigeria): proportion dfs_freq
svy, subpop(tanzania): proportion dfs_freq
svy, subpop(uganda): proportion dfs_freq


svy, subpop(bang): proportion dfs_freq
svy, subpop(india): proportion dfs_freq
svy, subpop(pakistan): proportion dfs_freq
svy, subpop(indonesia): proportion dfs_freq
















