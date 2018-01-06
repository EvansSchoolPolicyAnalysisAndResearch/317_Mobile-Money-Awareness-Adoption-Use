
/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: Analysis of mobile money outcomes across countries and waves
				  This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the regression analysis of factors associated with awareness, adoption, and use of Mobile Money 
				  over time in eight countries using data from Financial Inclusion Insights.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer, Andrew Orlebeke

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/

*TABLE OF CONTENTS
*----------
*1. File description
*2. Appending of individual country and wave .dta files
*3. List of variables for analysis
*4. Generating and renaming of variables
*5. Regression anaylsis
	//a. Pooled Countries
	//b. All countries, dummies
	//c. Individual Country- general awareness, specific awareness, adoption, & use
*6. Final awareness, adoption, use (multi-wave)
	//a. All wave regression - specific awareness, general awareness, adoption ,use
	//b. Coutnry specific regressions - awareness, adoption, use
	



*Data source
*-----------
*The Financial Inclusion Insights data were collected by Intermedia.
*At the time of the analysis, three waves of data were available, one for each of the years from 2013-2015, except for Indonesia which only has two waves of data.
	//Tanzania Wave 1 (October 2013 – January 2014)
	//Tanzania Wave 2 (September 2014-December 2014)
	//Tanzania Wave 3 (June 2015 – October 2015)
	//Kenya Wave 1 (October 2013 – January 2014)
	//Kenya Wave 2 (September 2014-December 2014)
	//Kenya Wave 3 (June 2015 – October 2015)
	//Uganda Wave 1 (October 2013 – January 2014)
	//Uganda Wave 2 (September 2014-December 2014)
	//Uganda Wave 3 (June 2015 – October 2015)
	//Nigeria Wave 1 (October 2013 – January 2014)
	//Nigeria Wave 2 (September 2014-December 2014)
	//Nigeria Wave 3 (June 2015 – October 2015)
	//India Wave 1 (October 2013 – January 2014)
	//India Wave 2 (September 2014-December 2014)
	//India Wave 3 (June 2015 – October 2015)
	//Pakistan Wave 1 (October 2013 – January 2014)
	//Pakistan Wave 2 (September 2014-December 2014)
	//Pakistan Wave 3 (June 2015 – October 2015)
	//Indonesia Wave 1 (September 2014-December 2014)
	//Indonesia Wave 2 (June 2015 – October 2015)
	//Bangladesh Wave 1 (October 2013 – January 2014)
	//Bangladesh Wave 2 (September 2014-December 2014)
	//Bangladesh Wave 3 (June 2015 – October 2015)
	
*Summary of Executing the Master do.file
*-----------
*This Master do.file conducts linear and logistic regression analysis using selected sociodemogaphic variables and mobile money outcome variables from Financial Inclusion Insights data sets.
*This .do file uses the cleaned .dta files for each country and wave prepared in individual country/wave .do files. 
*To run the .do file, update the filepaths below to indicate the locations where you have saved those .dta files. If you have saved them in different folder, it may be most efficient to copy all the cleaned .dta files to the same folder.
*The .do file first loads all relevant data sets, recodes variables, and saves a Master aggregated .dta file.
*The .do file then performs regression analyses using various methods, creating tables of regression output when appropriate
*The logistic regressions used in the technical paper associated with this .do file are included at the end of the file in the section labeled: "FINAL AWARENESS, ADOPTION, USE MULTI-WAVE TABLES"

	
**OUTCOME VARIABLES
*dfs_aware_gen: Adults are aware of mobile money 
*dfs_aware_name: Adults are aware of at least one of the mobile money providers (spontaneous & prompted)
**dfs_adopt: Adults who have ever used MM
**dfs_use: Categorical variable indicating last use of MM
**dfs_90: Adults who have used MM within the last 90 days


** Large data set need to increase memory
set maxvar 30000

	
**FIRST TIME ON A COMPUTER: Install program to output results (install first time using this do-file on each computer)	
ssc install estout, replace
	

clear
//Global list for input
global input "filepath for location where you want to save output files" //from the individual country .do files 
//Global path for saving output files (for regression output below)
global output "filepath for location where you want to save final tables"

*********************************************
** APPEND DATASETS TO CREATE ONE .DTA FILE **
*********************************************

//Starting with Tanzania
clear
use "$input\W1\Tanzania_W1_Clean.dta"
append using "$input\W2\Tanzania_W2_Clean.dta", force
append using "$input\W3\Tanzania_W3_Clean.dta", force

//Add in Kenya
append using "$input\W1\Kenya_W1_Clean.dta", force
append using "$input\W2\Kenya_W2_Clean.dta", force
append using "$input\W3\Kenya_W3_Clean.dta", force

//Add in Uganda
append using "$input\W1\Uganda_W1_Clean.dta", force
append using "$input\W2\Uganda_W2_Clean.dta", force
append using "$input\W3\Uganda_W3_Clean.dta", force

//Add in Nigeria
append using "$input\W1\Nigeria_W1_Clean.dta", force
append using "$input\W2\Nigeria_W2_Clean.dta", force
append using "$input\W3\Nigeria_W3_Clean.dta", force

//Add in India
append using "$input\W1\India_W1_Clean.dta", force
append using "$input\W2\India_W2_Clean.dta", force
append using "$input\W3\India_W3_Clean.dta", force

//Add in Pakistan
append using "$input\W1\Pakistan_W1_Clean.dta", force
append using "$input\W2\Pakistan_W2_Clean.dta", force
append using "$input\W3\Pakistan_W3_Clean.dta", force
 
//Add in Indonesia
//Only Wave 1 (concurrent with W2) and 3 for Indonesia
append using "$input\W2\Indonesia_W1_Clean.dta", force
append using "$input\W3\Indonesia_W2_Clean.dta", force

//Add in Bangladesh
append using "$input\W1\Bangladesh_W1_Clean.dta", force
append using "$input\W2\Bangladesh_W2_Clean.dta", force
append using "$input\W3\Bangladesh_W3_Clean.dta", force

************************************
** LIST OF VARIABLES FOR ANALYSIS **
************************************

**Create a global list with all the variables we want to use 
#d ;
global vars urban_rural rural ppi_score ppi_prob ppi_cutoff rural_female rural_poor literate numerate female yearborn age 
age_group marital_status married edu official_id employment_status employed primary_job rec_support  n_household ed_level
highest_ed dfs_agent_sex wave employment

phone_own phone_access sim_own sim_access bank_own bank_access

dfs_aware_gen dfs_aware_name dfs_aware_spont dfs_aware_prompt 

dfs_adopt 
dfs_use
dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month  dfs_lastuse_90days dfs_lastuse_more90
dfs_regacct 
dfs_agent_same dfs_agentiss_*

dfs_deposit dfs_withdraw dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater
dfs_paytv dfs_paygov dfs_recgov_welfpen dfs_recwage1 dfs_paylarge	dfs_payins	dfs_ins	dfs_loan dfs_savepurchase dfs_savepen	dfs_saveunknown	dfs_invest	
dfs_paystore dfs_transferacct dfs_transferbank dfs_transferother dfs_rent 	dfs_bus_payemp	dfs_bus_paysup  dfs_bus_recpaycust dfs_bus_recpaydist 
dfs_bus_invest dfs_bus_payexp dfs_bus_ag dfs_bus_other dfs_bus_none  

lapsed_registered_mm active_nonreg_mm lapsed_nonreg_mm active_mm registered_MM
rec_remit

kenya tanzania uganda nigeria india pakistan indonesia bang

weight 

;
#d cr

*******************************
** DROP VARIABLES NOT NEEDED **
*******************************
//Only keep the variables we need for analysis (add variables to global list above to include in dataset)
keep $vars

************************
** SET SURVEY WEIGHTS **
************************

svyset [pweight=weight] //This is the default survey weight provided by the FII team - this gets called when running svy: regress - not other regression commands
**Note on svyset: reg outcomevar rhsvars [pweight=weight], cluster(AA2) // This is the suggested code suggested if you want to cluster at the district level at individual regressions. We do not have the PSU variable

************************************************
** GENERATE/LABEL/RENAME ADDITIONAL VARIABLES **
************************************************

//Generating a variable called "country" to use for sorting
gen country=.
replace country=1 if kenya==1
replace country=2 if nigeria==1
replace country=3 if tanzania==1
replace country=4 if uganda==1
replace country=5 if bang==1
replace country=6 if india==1
replace country=7 if indonesia==1
replace country=8 if pakistan==1

	label define country1 1 "Kenya" 2 "Nigeria" 3 "Tanzania" 4 "Uganda" 5 "Bangladesh" 6 "India" 7 "Indonesia" 8 "Pakistan"
	label values country country1

//Fix missing values for highest_ed
replace highest_ed=. if highest_ed==99 | highest_ed==999

//Create own or access SIM variable
gen sim_ownoraccess=.
replace sim_ownoraccess=0 if (sim_access==0 & sim_own==0)
replace sim_ownoraccess=1 if (sim_access==1 | sim_own==1)
label define sim_ownoraccessl 0 "does not own or access a SIM" 1 "owns or accesses a SIM"
label values sim_ownoraccess sim_ownoraccessl

//Label ppi_cutoff
label define ppi_cutoff2 0 "Above poverty line" 1 "Below poverty line" 
label values ppi_cutoff ppi_cutoff2

//Employment
**Note - employment status is not asked in W1; exclude this variable from the analyses

**Create an Africa/Asia dyummy variable
gen africa=.
replace africa=1 if (country==1 | country==2 | country==3 | country==4)
replace africa=0 if (country==5 | country==6 | country==7 | country==8)
la var africa "Region: 0=Asia 1=Africa" 

**DFS_90
//dfs_90 is the binary created from dfs_use (used in the last 90 days)
tab dfs_use
gen dfs_90=.
replace dfs_90=1 if dfs_use==1 | dfs_use==2 | dfs_use==3 | dfs_use==4
replace dfs_90=0 if dfs_use==5
tab dfs_90 
label define dfs_901 0 "Did not use DFS in the last 90 days" 1 "Used DFS in the last 90 days"
	label values dfs_90 dfs_901

**COLLAPSE AVBOVE SECONDARY into "secondary and above" 
**Too few people with higher education in Africa for solid comparisons
tab ed_level
rename ed_level ed_level1
gen ed_level=.
replace ed_level=1 if ed_level1==1
replace ed_level=2 if ed_level1==2
replace ed_level=3 if ed_level1==3 | ed_level1==4
	label define ed_level_ 1 "No formal education" 2 "Primary education" 3 "Secondary education and above"
	label values ed_level ed_level_
	
**Label control variables
la var female "Female"
la var age "Age"
la var rural "Rural"
la var ppi_cutoff "PPI: 0=income above $2.50/day 1=income below $2.50/day"
la var married "Married: 0=not married 1=monog/poly married"
la var literate "Literate"
la var numerate "Numerate"
la var ed_level "Level of Education"
la var employed "Employed"
la var official_id "Person has any official ID"
la var phone_own "Person owns phone"
la var sim_own "Person owns SIM"
la var bank_own "Person has bank account"
la var rural_poor "Rural & Below PPI Cutoff"
	label define rural_poor1 0 "No" 1 "Yes"
	label values rural_poor rural_poor1

save "$output\Cross_WaveMaster.dta", replace


********************
**USE APPENDED DTA**
********************

use "$output\Cross_WaveMaster.dta", clear

*************************
** REGRESSION ANALYSIS **
*************************

********************
**POOLED COUNTRIES**
********************

global indep_personal female age rural ppi_cutoff married literate numerate employed i.ed_level
global indep_other official_id phone_own bank_own

**1 POOLED LINEAR REGRESSION WITH WAVE DUMMIES - No dummy by region
//All countries pooled no region or country dummies (wave dummies included)
**Dropped out general awareness - no general awareness variable in W1
eststo awarename: svy: reg dfs_aware_name $indep_personal $indep_other i.wave
eststo adopt: svy: reg dfs_adopt $indep_personal $indep_other i.wave
eststo dfs_use: svy: reg dfs_90 $indep_personal $indep_other i.wave
	//Output
	esttab awarename adopt dfs_use using "$output\CW - All Countries Pooled with Wave Dummy - OLS.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave Dummy - OLS}) mtitles("Aware of specific provider" "Adoption" "Use in last 90 days") replace b(3) se(3) r2 ///
	onecell
	
**2 POOLED LINEAR REGRESSION WITH WAVE AS CATEGORICAL - No dummy by region
//All countries pooled no region or country dummies
**Dropped out general awareness - no general awareness variable in W1
eststo awarename: svy: reg dfs_aware_name $indep_personal $indep_other i.wave
eststo adopt: svy: reg dfs_adopt $indep_personal $indep_other i.wave
eststo dfs_use: svy: reg dfs_90 $indep_personal $indep_other i.wave
	//Output
	esttab awarename adopt dfs_use using "$output\CW - All Countries Pooled with Wave Variable - OLS.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave Variable - OLS}) mtitles( "Aware of specific provider" "Adoption" "Use in last 90 days") replace b(3) se(3) r2 ///
	onecell

**3 POOLED COUNTRY LINEAR REGRESSION - Wave and regional dummies
//All countries pooled with dummy for Africa/Asia (Asia is the reference group)
eststo awarename: svy: reg dfs_aware_name $indep_personal $indep_other i.wave africa
eststo adopt: svy: reg dfs_adopt $indep_personal $indep_other i.wave africa
eststo dfs_use: svy: reg dfs_90 $indep_personal $indep_other i.wave africa
	//Output
	esttab awarename adopt dfs_use using "$output\CW - All Countries Pooled with Wave and AA Dummies - OLS.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave and Region Dummies - OLS}) mtitles( "Aware of specific provider" "Adoption" "Use in last 90 days") replace b(3) se(3) r2 ///
	onecell

**4 POOLED COUNTRY LINEAR REGRESSION - Regional dummies and Wave as categorical
//All countries pooled with dummy for Africa/Asia (Asia is the reference group)
eststo awarename: svy: reg dfs_aware_name $indep_personal $indep_other i.wave africa
eststo adopt: svy: reg dfs_adopt $indep_personal $indep_other i.wave africa
eststo dfs_use: svy: reg dfs_90 $indep_personal $indep_other i.wave africa

	//Output
	esttab awarename adopt dfs_use using "$output\CW - All Countries Pooled with Wave & Region Variables - OLS.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave and Region Variables - OLS}) mtitles("Aware of specific provider" "Adoption" "Use in last 90 days") replace b(3) se(3) r2 ///
	onecell

	
**POOLED COUNTRY LOGISTIC REGRESSION - Regression 2
//All countries pooled with dummy for Africa/Asia (Asia is the reference group)
eststo awaregen1: quietly svy: logit dfs_aware_gen $indep_personal $indep_other africa
eststo awaregen_m: margins,dydx ($indep_personal $indep_other africa) post

eststo awarename1: quietly svy: logit dfs_aware_name $indep_personal $indep_other africa
eststo awarename_m: margins,dydx ($indep_personal $indep_other africa) post

eststo adopt1: quietly svy: logit dfs_adopt $indep_personal $indep_other africa
eststo adopt_m: margins,dydx ($indep_personal $indep_other africa) post

eststo dfs_use1: quietly svy: logit dfs_90 $indep_personal $indep_other africa
eststo dfs_use_m: margins,dydx ($indep_personal $indep_other africa) post

	//Output
	esttab awaregen_m awarename_m adopt_m dfs_use_m using "$output\CW - All Countries Pooled with Region Dummy - LogitME.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Region Dummy - Mean Marginal Effects of Logit Model}) mtitles("General Awareness" "Aware of Specific Provider" "Adoption" "Use in Last 90 Days)") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) r2 ///
	onecell
	
**POOLED COUNTRY LOGISTIC REGRESSION - Regression 2
//All countries pooled with dummy for Wave
eststo awaregen1: quietly svy: logit dfs_aware_gen $indep_personal $indep_other i.wave
eststo awaregen_m: margins,dydx ($indep_personal $indep_other i.wave) post

eststo awarename1: quietly svy: logit dfs_aware_name $indep_personal $indep_other i.wave
eststo awarename_m: margins,dydx ($indep_personal $indep_other i.wave) post

eststo adopt1: quietly svy: logit dfs_adopt $indep_personal $indep_other i.wave
eststo adopt_m: margins,dydx ($indep_personal $indep_other i.wave) post

eststo dfs_use1: quietly svy: logit dfs_90 $indep_personal $indep_other i.wave
eststo dfs_use_m: margins,dydx ($indep_personal $indep_other i.wave) post

	//Output
	esttab awaregen_m awarename_m adopt_m dfs_use_m using "$output\CW - All Countries Pooled with Wave Dummy - LogitME.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave Dummy - Mean Marginal Effects of Logit Model}) mtitles("General Awareness" "Aware of Specific Provider" "Adoption" "Use in Last 90 Days)") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) r2 ///
	onecell
	
	
****************************
** ALL COUNTRIES, DUMMIES **
****************************
**Regression running all countries but with country dummies

**5. OLS for all countries with country dummies and Wave as a categorical variable
eststo awaregen_countries: svy: reg dfs_aware_gen $indep_personal $indep_other i.wave i.country
eststo awarename_countries: svy: reg dfs_aware_name $indep_personal $indep_other i.wave i.country
eststo adopt_countries: svy: reg dfs_adopt $indep_personal $indep_other i.wave i.country
eststo use_countries: svy: reg dfs_90 $indep_personal $indep_other i.wave i.country

	//Output
	esttab awaregen_countries awarename_countries adopt_countries use_countries using "$output\CW - All Countries Pooled with Wave Variable & Country Dummy - OLS", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave Variable & Country Dummy - OLS}) mtitles("General Awareness" "Aware of specific provider" "Adoption" "Use in last 90 days") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ar2 ///
	onecell


**6. OLS for all countries with country and Wave dummies
eststo awaregen_countries: svy: reg dfs_aware_gen $indep_personal $indep_other  i.wave i.country
eststo awarename_countries: svy: reg dfs_aware_name $indep_personal $indep_other i.wave i.country
eststo adopt_countries: svy: reg dfs_adopt $indep_personal $indep_other i.wave i.country
eststo use_countries: svy: reg dfs_90 $indep_personal $indep_other i.wave i.country

	//Output
	esttab awaregen_countries awarename_countries adopt_countries use_countries using "$output\CW - All Countries Pooled with Wave & Country Dummies - OLS.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Wave & Country Dummies - OLS}) mtitles("General Awareness" "Aware of specific provider" "Adoption" "Use in last 90 days") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ar2 ///
	onecell

	
**Logistic regression for all countries with country and wave dummies
eststo awarename_countries1: quietly svy: logit dfs_aware_name $indep_personal $indep_other sim_own i.country i.wave
eststo awarename_countries_m: margins,dydx ($indep_personal $indep_other sim_own i.country i.wave) post

eststo adopt_countries1: quietly svy: logit dfs_adopt $indep_personal $indep_other sim_own i.country i.wave
eststo adopt_countries_m: margins,dydx ($indep_personal $indep_other sim_own i.country i.wave) post

eststo use_countries1: quietly svy: logit dfs_90 $indep_personal $indep_other sim_own i.country i.wave
eststo use_countries_m: margins,dydx ($indep_personal $indep_other sim_own i.country i.wave) post

//Output
	esttab awarename_countries_m adopt_countries_m use_countries_m using "$output\CW - All Countries Pooled with Country and Wave Dummies - LogitME.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Aware of Specific Provider" "Adoption" "Use in Last 90 Days") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ar2 ///
	onecell 
	///
	

***********************************
****COUNTRY-LEVEL FINDINGS*********
***********************************

global indep_personal female age rural ppi_cutoff married literate numerate employed i.ed_level 
global indep_other official_id phone_own bank_own i.wave

	*****************************
	** General awareness of MM **
	*****************************

	**OLS AFRICAN COUNTRIES 
	//One table with regression results for dfs_aware_gen for African countries
	eststo kenya_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if kenya==1
	eststo nigeria_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if nigeria==1
	eststo tanz_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if tanzania==1
	eststo uganda_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if uganda==1

	//Output
	esttab kenya_awaregen nigeria_awaregen tanz_awaregen uganda_awaregen using "$output\CW - General Awareness by African Country - OLS.rtf", ///
	label title({\b Cross-Wave - General Awareness of Mobile Money by African Country - OLS}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC AFRICAN COUNTRIES
	//One table with logistic regression results for dfs_aware_gen for African countries
	eststo kenya_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if kenya==1
	eststo kenya_awaregen_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo nigeria_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if nigeria==1
	eststo nigeria_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	eststo tanz_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if tanzania==1
	eststo tanz_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	eststo uganda_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if uganda==1
	eststo uganda_awaregen_m: margins,dydx ($indep_personal $indep_other) post
	
	//Output
	esttab kenya_awaregen_m nigeria_awaregen_m tanz_awaregen_m uganda_awaregen_m using "$output\CW - General Awareness by African Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Awareness of Specific MM Provider by Country - Mean Marginal Effects of Logit Model}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell

	
	**OLS S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_aware_gen for S/SE Asian countries
	eststo bang_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other sim_own if bang==1
	eststo india_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other sim_own if india==1
	eststo indo_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if indonesia==1
	eststo pak_awaregen: svy: reg dfs_aware_gen $indep_personal $indep_other if pakistan==1

	//Output
	esttab bang_awaregen india_awaregen indo_awaregen pak_awaregen using "$output\CW - General Awareness by Asian Country - OLS.rtf", ///
	label title({\b Cross-Wave - General Awareness of Mobile Money by Asian Country - OLS}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC S/SE ASIAN COUNTRIES
	//One table with logistic regression results for dfs_aware_gen for S/SE Asian countries
	eststo bang_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other sim_own if bang==1
	eststo bang_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	eststo india_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other sim_own if india==1
	eststo india_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	eststo indo_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if indonesia==1
	eststo indo_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	eststo pak_awaregen1: svy: logit dfs_aware_gen $indep_personal $indep_other if pakistan==1
	eststo pak_awaregen_m: margins,dydx ($indep_personal $indep_other) post

	//Output
	esttab bang_awaregen_m india_awaregen_m indo_awaregen_m pak_awaregen_m using "$output\CW - General Awareness by Asian Country - LogitME.rtf", ///
	label title({\b Cross-Wave - General Awareness of Mobile Money by Asian Country - Mean Marginal Effects of Logit Model}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	

	*******************************
	** Awareness of DFS providers **
	*******************************
	
global indep_personal female age rural ppi_cutoff married literate numerate employed i.ed_level 
global indep_other official_id phone_own bank_own i.wave

	**OLS AFRICAN COUNTRIES
	//One table with regression results for dfs_aware_name for African countries
	eststo kenya_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if kenya==1
	eststo nigeria_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if nigeria==1
	eststo tanz_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if tanzania==1
	eststo uganda_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if uganda==1

	//Output
	esttab kenya_awarename nigeria_awarename tanz_awarename uganda_awarename using "$output\CW - Specific Awareness by African Country - OLS.rtf", ///
	label title({\b Cross-Wave - Awareness of Specific MM Provider by African Country - OLS}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC AFRICAN COUNTRIES
	//One table with logistic regression results for dfs_aware_name for African countries
	eststo kenya_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if kenya==1
	eststo kenya_awarename_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo nigeria_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if nigeria==1
	eststo nigeria_awarename_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo tanz_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if tanzania==1
	eststo tanz_awarename_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo uganda_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if uganda==1
	eststo uganda_awarename_m: margins,dydx ($indep_personal $indep_other) post

	//Output
	esttab kenya_awarename_m nigeria_awarename_m tanz_awarename_m uganda_awarename_m using "$output\CW - Specific Awareness by African Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Awareness of Specific MM Provider by African Country - Mean Marginal Effects of Logit Model}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	

	**OLS S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_aware_name for S/SE Asian countries
	eststo bang_awarename: svy: reg dfs_aware_name $indep_personal $indep_other sim_own if bang==1
	eststo india_awarename: svy: reg dfs_aware_name $indep_personal $indep_other sim_own if india==1
	eststo indo_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if indonesia==1
	eststo pak_awarename: svy: reg dfs_aware_name $indep_personal $indep_other if pakistan==1

	//Output
	esttab bang_awarename india_awarename indo_awarename pak_awarename using "$output\CW - Specific Awareness by Asian Country - OLS.rtf", ///
	label title({\b Cross-Wave - Awareness of Specific MM Provider by Asian Country - OLS}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_aware_name for S/SE Asian countries
	eststo bang_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other sim_own if bang==1
	eststo bang_awarename_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo india_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other sim_own if india==1
	eststo india_awarename_m: margins,dydx ($indep_personal $indep_other) post

	eststo indo_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if indonesia==1
	eststo indo_awarename_m: margins,dydx ($indep_personal $indep_other) post

	eststo pak_awarename1: svy: logit dfs_aware_name $indep_personal $indep_other if pakistan==1
	eststo pak_awarename_m: margins,dydx ($indep_personal $indep_other) post

	//Output
	esttab bang_awarename_m india_awarename_m indo_awarename_m pak_awarename_m using "$output\CW - Specific Awareness by Asian Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Awareness of Specific MM Provider by Asian Country - Mean Marginal Effects of Logit Model}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	
	
	**************
	** Adoption **
	**************
	**People who have ever used MM (of the population of people who are aware of MM)
	
	**OLS AFRICAN COUNTRIES
	//One table with regression results for dfs_use for African countries
	eststo kenya_adopt: svy: reg dfs_adopt $indep_personal $indep_other if kenya==1
	eststo nigeria_adopt: svy: reg dfs_adopt $indep_personal $indep_other if nigeria==1
	eststo tanz_adopt: svy: reg dfs_adopt $indep_personal $indep_other if tanzania==1
	eststo uganda_adopt: svy: reg dfs_adopt $indep_personal $indep_other if uganda==1

	//Output
	esttab kenya_adopt nigeria_adopt tanz_adopt uganda_adopt using "$output\CW - Adoption of MM by African Country - OLS.rtf", ///
	label title({\b Cross-Wave - Adoption of MM by African Country - OLS}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC AFRICAN COUNTRIES
	//One table with regression results for dfs_adopt for African countries
	eststo kenya_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if kenya==1
	eststo kenya_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo nigeria_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if nigeria==1
	eststo nigeria_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo tanz_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if tanzania==1
	eststo tanz_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo uganda_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if uganda==1
	eststo uganda_adopt_m: margins,dydx ($indep_personal $indep_other) post

	//Output
	esttab kenya_adopt_m nigeria_adopt_m tanz_adopt_m uganda_adopt_m using "$output\CW - Adoption of MM by African Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Adoption of MM by African Country - Mean Marginal Effects of Logit Model}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	
	**OLS S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_use for S/SE Asian countries
	eststo bang_adopt: svy: reg dfs_adopt $indep_personal $indep_other sim_own if bang==1
	eststo india_adopt: svy: reg dfs_adopt $indep_personal $indep_other sim_own if india==1
	eststo indo_adopt: svy: reg dfs_adopt $indep_personal $indep_other if indonesia==1
	eststo pak_adopt: svy: reg dfs_adopt $indep_personal $indep_other if pakistan==1

	//Output
	esttab bang_adopt india_adopt indo_adopt pak_adopt using "$output\CW - Adoption of MM by Asian Country - OLS.rtf", ///
	label title({\b Cross-Wave - Adoption of MM by Asian Country - OLS}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_aware_name for S/SE Asian countries
	eststo bang_adopt1: svy: logit dfs_adopt $indep_personal $indep_other sim_own if bang==1
	eststo bang_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo india_adopt1: svy: logit dfs_adopt $indep_personal $indep_other sim_own if india==1
	eststo india_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo indo_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if indonesia==1
	eststo indo_adopt_m: margins,dydx ($indep_personal $indep_other) post

	eststo pak_adopt1: svy: logit dfs_adopt $indep_personal $indep_other if pakistan==1
	eststo pak_adopt_m: margins,dydx ($indep_personal $indep_other) post

	//Output
	esttab bang_adopt_m india_adopt_m indo_adopt_m pak_adopt_m using "$output\CW - Adoption of MM by Asian Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Adoption of MM by Asian Country - Mean Marginal Effects of Logit Model}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	
	**************
	**USE OF DFS**
	**************
	**People who have used MM in the last 90 days (of those who have ever used MM)
	
	**OLS AFRICAN COUNTRIES
	//One table with regression results for dfs_use for African countries
	eststo kenya_use: svy: reg dfs_90 $indep_personal $indep_other if kenya==1
	eststo nigeria_use: svy: reg dfs_90 $indep_personal $indep_other if nigeria==1
	eststo tanz_use: svy: reg dfs_90 $indep_personal $indep_other if tanzania==1
	eststo uganda_use: svy: reg dfs_90 $indep_personal $indep_other if uganda==1

	//Output
	esttab kenya_use nigeria_use tanz_use uganda_use using "$output\CW - Use of MM  in last 90 days by African Country - OLS.rtf", ///
	label title({\b Cross-Wave - Use of MM by African Country - OLS}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC AFRICAN COUNTRIES
	//One table with regression results for dfs_use for African countries
	eststo kenya_use1: svy: logit dfs_90 $indep_personal $indep_other if kenya==1
	eststo kenya_use_m: margins,dydx ($indep_personal $indep_other) post

	eststo nigeria_use1: svy: logit dfs_90 $indep_personal $indep_other if nigeria==1
	eststo nigeria_use_m: margins,dydx ($indep_personal $indep_other) post
		
	eststo tanz_use1: svy: logit dfs_90 $indep_personal $indep_other if tanzania==1
	eststo tanz_use_m: margins,dydx ($indep_personal $indep_other) post
	
	eststo uganda_use1: svy: logit dfs_90 $indep_personal $indep_other if uganda==1
	eststo uganda_use_m: margins,dydx ($indep_personal $indep_other) post
	
	//Output
	esttab kenya_use_m nigeria_use_m tanz_use_m uganda_use_m using "$output\CW - Use of MM in last 90 days by African Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Use of MM by African Country - Mean Marginal Effects of Logit Model}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell
	
	
	**OLS S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_use for S/SE Asian countries
	eststo bang_use: svy: reg dfs_90 $indep_personal $indep_other sim_own if bang==1
	eststo india_use: svy: reg dfs_90 $indep_personal $indep_other sim_own if india==1
	eststo indo_use: svy: reg dfs_90 $indep_personal $indep_other if indonesia==1
	eststo pak_use: svy: reg dfs_90 $indep_personal $indep_other if pakistan==1

	//Output
	esttab bang_use india_use indo_use pak_use using "$output\CW - Use of MM in last 90 days by Asian Country - OLS.rtf", ///
	label title({\b Cross-Wave - Use of MM by Asian Country - OLS}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	**LOGISTIC S/SE ASIAN COUNTRIES
	//One table with regression results for dfs_aware_name for S/SE Asian countries
	eststo bang_use1: svy: logit dfs_90 $indep_personal $indep_other sim_own if bang==1
	eststo bang_use_m: margins,dydx ($indep_personal $indep_other) post

	eststo india_use1: svy: logit dfs_90 $indep_personal $indep_other sim_own if india==1
	eststo india_use_m: margins,dydx ($indep_personal $indep_other) post

	eststo pak_use1: svy: logit dfs_90 $indep_personal $indep_other if pakistan==1
	eststo pak_use_m: margins,dydx ($indep_personal $indep_other) post

**Indonesia excluded from dfs_90: only 15 people had used it in the last 90 days

	//Output
	esttab bang_use_m india_use_m pak_use_m using "$output\CW - Use of MM in last 90 days by Asian Country - LogitME.rtf", ///
	label title({\b Cross-Wave - Use of MM by Asian Country - Mean Marginal Effects of Logit Model}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace b(3) se(3) r2 ///
	onecell
	
	
	

****************************************************
**FINAL AWARENESS, ADOPTION, USE MULTI-WAVE TABLES**
****************************************************

//USE CWFinal and save
use "$output\Cross_WaveMaster.dta", clear

**********************
*CHOOSE SUBPOPULATION*
**********************

***************
* FEMALES ONLY*
***************
*keep if female==1

*************
* MALES ONLY*
*************
*keep if female==0



**Sample code for the primary model we use 

global indep_personal female age rural ppi_cutoff married literate numerate i.ed_level
global indep_other official_id phone_own bank_own

**Logistic regression for all countries with country and wave dummies
eststo awarename_countries1: quietly svy: logit dfs_aware_name $indep_personal $indep_other employed i.country if wave==1
eststo awarename_countries_m1: margins,dydx ($indep_personal $indep_other employed i.country) post

eststo awarename_countries2: quietly svy: logit dfs_adopt $indep_personal $indep_other i.employment i.country if wave==2
eststo awarename_countries_m2: margins,dydx ($indep_personal $indep_other i.employment i.country) post

eststo awarename_countries3: quietly svy: logit dfs_90 $indep_personal $indep_other i.employment i.country if wave==3
eststo use_countries_m3: margins,dydx ($indep_personal $indep_other i.employment i.country i.wave) post

//Output
	esttab awarename_countries_m1 awarename_countries_m2 awarename_countries_m3 using "$output\CW - All Countries Pooled with Country and Wave Dummies - LogitME.rtf", ///
	label title({\b Cross-Wave - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Aware of Specific Provider" "Adoption" "Use in Last 90 Days") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ar2 ///
	onecell 
	///



*******************************
**ALL WAVES REGRESSION MODELS**
*******************************
**Main models for the Awareness, Adoption, Use sections

************************************
**CONTROL VARIABLES FOR ALL MODELS**
************************************
**indep_employed is the new model that includes "employed" (binary), the variable present in all Waves
global indep_employed female age rural ppi_cutoff married literate numerate employed i.ed_level official_id phone_own bank_own

**********************
**SPECIFIC AWARENESS**
**********************

**Logistic regression of SPECIFIC AWARENESS for all countries for each wave and cross-wave
eststo awarename_countries1: svy: logit dfs_aware_name $indep_employed i.country if wave==1
eststo awarename_countries_m1: margins,dydx ($indep_employed i.country) post

eststo awarename_countries2: quietly svy: logit dfs_aware_name $indep_employed i.country if wave==2
eststo awarename_countries_m2: margins,dydx ($indep_employed i.country) post

eststo awarename_countries3: quietly svy: logit dfs_aware_name $indep_employed i.country if wave==3
eststo awarename_countries_m3: margins,dydx ($indep_employed i.country) post

eststo cw_awarename_countries: quietly svy: logit dfs_aware_name $indep_employed i.country i.wave
eststo cw_awarename_countries_m: margins,dydx ($indep_employed i.country i.wave) post

//Output
	esttab awarename_countries_m1 awarename_countries_m2 awarename_countries_m3 cw_awarename_countries_m using "$output\Specific Awareness - All Waves w Country - LogitME.rtf", ///
	label title({\b Specific Awareness - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Wave 1" "Wave 2" "Wave 3" "Cross-Wave") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///


**********************
**GENERAL AWARENESS**
**********************
**Remember: there is NO general awareness variable in Wave 1 (no general MM awareness question)
**Logistic regression of GENERAL AWARENESS for all countries for each wave and cross-wave
**This is used primarily as a robustness check

eststo awaregen_countries2: quietly svy: logit dfs_aware_gen $indep_employed i.country if wave==2
eststo awaregen_countries_m2: margins,dydx ($indep_employed i.country) post

eststo awaregen_countries3: quietly svy: logit dfs_aware_gen $indep_employed i.country if wave==3
eststo awaregen_countries_m3: margins,dydx ($indep_employed i.country) post

eststo cw_awaregen_countries: quietly svy: logit dfs_aware_gen $indep_employed  i.country i.wave
eststo cw_awaregen_countries_m: margins,dydx ($indep_employed i.country i.wave ) post

//Output
	esttab awaregen_countries_m2 awaregen_countries_m3 cw_awaregen_countries_m using "$output\Gen Awareness - All Waves with CountryD - LogitME.rtf", ///
	label title({\b General Awareness - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Wave 1" "Wave 2" "Wave 3" "Cross-Wave") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	/// 

	
************
**ADOPTION**
************

**Logistic regression of ADOPTION for all countries for each wave and cross-wave
eststo adopt_countries1: quietly svy: logit dfs_adopt $indep_employed i.country if wave==1
eststo adopt_countries_m1: margins,dydx ($indep_employed i.country) post

eststo adopt_countries2: quietly svy: logit dfs_adopt $indep_employed i.country if wave==2
eststo adopt_countries_m2: margins,dydx ($indep_employed i.country) post

eststo adopt_countries3: quietly svy: logit dfs_adopt $indep_employed i.country if wave==3
eststo adopt_countries_m3: margins,dydx ($indep_employed i.country) post

eststo cw_adopt_countries: quietly svy: logit dfs_adopt $indep_employed i.country i.wave
eststo cw_adopt_countries_m: margins,dydx ($indep_employed i.country i.wave) post

//Output
	esttab adopt_countries_m1 adopt_countries_m2 adopt_countries_m3 cw_adopt_countries_m using "$output\Adoption - All Waves with CountryD - LogitME.rtf", ///
	label title({\b Adoption - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Wave 1" "Wave 2" "Wave 3" "Cross-Wave") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///
	
	
*******
**USE**
*******
**In use, we are dropping out countries in which less than 100 people were asked the question
**Indonesia (n=26.97) and Nigeria (n=52.38) are removed from the analysis 

//Generate a new country dummy that includes only the six countries in the regression
//In country, nigeria==2 and indonesia==7
gen country1=.
replace country1=1 if country==1 
replace country1=2 if country==3
replace country1=3 if country==4 
replace country1=4 if country==5
replace country1=5 if country==6
replace country1=6 if country==8
label define country_new 1 "Kenya" 2 "Tanzania" 3 "Uganda" 4 "Bangladesh" 5 "India" 6 "Pakistan"
	label values country1 country_new

**Logistic regression of USE for all countries for each wave and cross-wave
eststo use_countries1: quietly svy: logit dfs_90 $indep_employed i.country1 if wave==1
eststo use_countries_m1: margins,dydx ($indep_employed i.country1) post

eststo use_countries2: quietly svy: logit dfs_90 $indep_employed i.country1 if wave==2
eststo use_countries_m2: margins,dydx ($indep_employed i.country1) post

eststo use_countries3: quietly svy: logit dfs_90 $indep_employed i.country1 if wave==3
eststo use_countries_m3: margins,dydx ($indep_employed i.country1) post

eststo cw_use_countries: quietly svy: logit dfs_90 $indep_employed i.country1 i.wave
eststo cw_use_countries_m: margins,dydx ($indep_employed i.country1 i.wave) post

//Output
	esttab use_countries_m1 use_countries_m2 use_countries_m3 cw_use_countries_m using "$output\Use - All Waves with CountryD - LogitME.rtf", ///
	label title({\b Used in last 90 days - All Countries Pooled with Country Dummy - Mean Marginal Effects of Logit Models}) mtitles("Wave 1" "Wave 2" "Wave 3" "Cross-Wave") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///
	
	

********************************
**COUNTRY-SPECIFIC REGRESSIONS**
********************************
**Cross-wave regressions (dummy controlling for Wave) in each individual country
**Use these to determine which countries are driving the results of the pooled regressions

*************************************
**AWARENESS IN INDIVIDUAL COUNTRIES**
*************************************

**AFRICA AWARENESS
eststo cw_awarename_kenya: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==1
eststo cw_awarename_kenya_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_nigeria: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==2
eststo cw_awarename_nigeria_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_tanzania: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==3
eststo cw_awarename_tanzania_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_uganda: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==4
eststo cw_awarename_uganda_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_awarename_kenya_m cw_awarename_nigeria_m cw_awarename_tanzania_m cw_awarename_uganda_m using "$output\Specific Awareness - African Countries - LogitME.rtf", ///
	label title({\b Specific Awareness - African Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///
	
	
**ASIA AWARENESS
eststo cw_awarename_bang: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==5
eststo cw_awarename_bang_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_india: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==6
eststo cw_awarename_india_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_indonesia: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==7
eststo cw_awarename_indonesia_m: margins,dydx ($indep_employed i.wave) post

eststo cw_awarename_paki: quietly svy: logit dfs_aware_name $indep_employed i.wave if country==8
eststo cw_awarename_paki_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_awarename_bang_m cw_awarename_india_m cw_awarename_indonesia_m cw_awarename_paki_m using "$output\Specific Awareness - Asian Countries - LogitME.rtf", ///
	label title({\b Specific Awareness - Asian Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///

*************************************
**ADOPTION IN INDIVIDUAL COUNTRIES**
*************************************

**AFRICA ADOPTION
eststo cw_adopt_kenya: quietly svy: logit dfs_adopt $indep_employed i.wave if country==1
eststo cw_adopt_kenya_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_nigeria: quietly svy: logit dfs_adopt $indep_employed i.wave if country==2
eststo cw_adopt_nigeria_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_tanzania: quietly svy: logit dfs_adopt $indep_employed i.wave if country==3
eststo cw_adopt_tanzania_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_uganda: quietly svy: logit dfs_adopt $indep_employed i.wave if country==4
eststo cw_adopt_uganda_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_adopt_kenya_m cw_adopt_nigeria_m cw_adopt_tanzania_m cw_adopt_uganda_m using "$output\Adoption - African Countries - LogitME.rtf", ///
	label title({\b Adoption - African Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Kenya" "Nigeria" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell 
	///
	
	
**ASIA ADOPTION
eststo cw_adopt_bang: quietly svy: logit dfs_adopt $indep_employed i.wave if country==5
eststo cw_adopt_bang_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_india: quietly svy: logit dfs_adopt $indep_employed i.wave if country==6
eststo cw_adopt_india_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_indonesia: quietly svy: logit dfs_adopt $indep_employed i.wave if country==7
eststo cw_adopt_indonesia_m: margins,dydx ($indep_employed i.wave) post

eststo cw_adopt_paki: quietly svy: logit dfs_adopt $indep_employed i.wave if country==8
eststo cw_adopt_paki_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_adopt_bang_m cw_adopt_india_m cw_adopt_indonesia_m cw_adopt_paki_m using "$output\Adoption - Asian Countries - LogitME.rtf", ///
	label title({\b Adoption - Asian Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Bangladesh" "India" "Indonesia" "Pakistan") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///

*******************************
**USE IN INDIVIDUAL COUNTRIES**
*******************************

**AFRICA USE
eststo cw_90_kenya: quietly svy: logit dfs_90 $indep_employed i.wave if country==1
eststo cw_90_kenya_m: margins,dydx ($indep_employed i.wave) post

**No Nigeria because n is too small

eststo cw_90_tanzania: quietly svy: logit dfs_90 $indep_employed i.wave if country==3
eststo cw_90_tanzania_m: margins,dydx ($indep_employed i.wave) post

eststo cw_90_uganda: quietly svy: logit dfs_90 $indep_employed i.wave if country==4
eststo cw_90_uganda_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_90_kenya_m cw_90_tanzania_m cw_90_uganda_m using "$output\Use - African Countries - LogitME.rtf", ///
	label title({\b Use - African Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Kenya" "Tanzania" "Uganda") replace b(3) se(3) r2 ///
	onecell 
	///
	
	
**ASIA USE
eststo cw_90_bang: quietly svy: logit dfs_90 $indep_employed i.wave if country==5
eststo cw_90_bang_m: margins,dydx ($indep_employed i.wave) post

eststo cw_90_india: quietly svy: logit dfs_90 $indep_employed i.wave if country==6
eststo cw_90_india_m: margins,dydx ($indep_employed i.wave) post

**No Indonesia because n is too small

eststo cw_90_paki: quietly svy: logit dfs_90 $indep_employed i.wave if country==8
eststo cw_90_paki_m: margins,dydx ($indep_employed i.wave) post

//Output
	esttab cw_90_bang_m cw_90_india_m cw_90_paki_m using "$output\Use - Asian Countries - LogitME.rtf", ///
	label title({\b Use - Asian Countries w Wave Dummy - Mean Marginal Effects of Logit Models}) mtitles("Bangladesh" "India" "Pakistan") replace cells(b(fmt(3) star) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01) ///
	onecell 
	///
	
