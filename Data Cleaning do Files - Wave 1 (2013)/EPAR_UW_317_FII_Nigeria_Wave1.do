/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Nigeria Financial Inclusion Insights Wave 1 data set.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Financial Inclusion Insights Wave 1 data was collected by Intermedia 
*The data were collected over the period October 2013- January 2014.
*All the raw data, questionnaires, and basic information documents can be requested from Intermedia by clicking "contact InterMedia" at the following link
*http://finclusion.org/data_fiinder/


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Nigeria Financial Inclusion Insights Wave 1 data set.
*After downloading the "Final_Nigeria-FII-wave 1-06-28-2014(public).xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/Final_Nigeria-FII-wave 1-06-28-2014(public).xlsx", firstrow
save "filepath for location where you want to save dta file/Nigeria_Wave1_Stata.dta", replace
clear


***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


*********
*NIGERIA*
*********
use "$input\Nigeria_Wave1_Stata.dta"

*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
gen nigeria=1

//Wave dummy
gen wave=1

rename WEIGHT weight
	la var weight "survey weights"
	
***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************
rename IAGE age

//Urban/rural residence
rename AA7 urban_rural 
la var urban_rural "settlement size (AA7)"
	label define urban_rurall 1 "Urban" 2 "Rural" 
	label values urban_rural urban_rurall

**Generate a female variable
gen female=.
replace female=1 if DG2==2
replace female=0 if DG2==1
	la var female "Gender of respondent (DG2)"
	label define femalel 0 "Male" 1 "Female"
	label values female femalel
	
*Generate PPI Cutoff - above variable
rename PPI_CUTOFF ppi_cutoff
	la var ppi_cutoff "PPI Cutoff"
	label define ppi_cutoff1 0 "Above poverty line" 1 "Below poverty line" 
	label values ppi_cutoff ppi_cutoff1	

rename PPI_SCORE ppi_score

//Marital status (if monogomously or polygamously married - does not include widowed, divorced, etc.)
rename DG3 marital_status //generated dummy var below
la var marital_status "person's marital status (DG3)"
	label define marital_statusl 1 "Single/never married" 2 "Polygamously married" /*
		*/ 3 "Monogamously married" 4 "Divorced" 5 "Separated" 6 "Widowed" 7 "Living together/cohabiting" /*
		*/ 8 "Other(specify)" 9 "DK/Refused"
	label values marital_status marital_statusl
	
//Highest level of education 
rename DG4 highest_ed // refer to FII codebook for labels
la var highest_ed "highest level of education (DG4)"
	label define highest_edl 1 "No formal education " 2 "Primary education not complete" 3 "Primary education complete" /*
	*/ 4 "Some secondary education" 5 "Secondary education complete" 6 "Secondary education vocational" /*
	*/ 7 "Secondary vocational training complete" 8 "Some diploma" 9 "Diploma complete" 10 "Some college/university" /*
	*/ 11 "Complete university degree" 12 "Post-graduate university degree" 13 "Koranic school" 14 "Other" /*
	*/ 15 "DK/Refused" 
	label values highest_ed highest_edl
	
//Level of education - variable to be used in regression analysis (standardized across countries)
gen ed_level=.
replace ed_level=1 if highest_ed==1
replace ed_level=2 if highest_ed==2 | highest_ed==3 
replace ed_level=3 if highest_ed==4 | highest_ed==5 | highest_ed==6 | highest_ed==7
replace ed_level=4 if highest_ed==8 | highest_ed==9 | highest_ed==10 | highest_ed==11 | highest_ed==12
	label define ed_level1 1 "No formal education" 2 "Primary education" 3 "Secondary education" 4 "Above secondary"
	label values ed_level ed_level1

	
******************************
** GENERATE DUMMY VARIABLES **
******************************	

//Rural
gen rural=.
replace rural=1 if urban_rural==2
replace rural=0 if urban_rural==1

//Married
gen married=.
replace married=1 if marital_status ==2 | marital_status==3
replace married=0 if marital_status !=2 & marital_status!=3
la var married "person is monogomously or polygomously married (dg3)"

//Literacy
gen literate=.
replace literate=1 if LITERACY==1
replace literate=0 if LITERACY==2
	la var literate "person has basic literacy"
	
//Numeracy
gen numerate=.
replace numerate=1 if NUMERACY==1
replace numerate=0 if NUMERACY==2
	la var numerate "person has basic numeracy"

//Employment - this is a binary in W1 (no employment_status variable; cannot make i.employment outcome)
gen employed=.
replace employed=1 if DL1==1
replace employed=0 if DL1==2
	
//Official ID (if answered yes to any type of official id; verify if we need to exclude any types)
gen official_id=.
replace official_id=1 if DG5A==1 | DG5B==1 | DG5C==1 | DG5D==1 | DG5E==1 | DG5F==1 | DG5G==1 | DG5H==1 | DG5I==1
replace official_id=0 if DG5A!=1 & DG5B!=1 & DG5C!=1 & DG5D!=1 & DG5E!=1 & DG5F!=1 & DG5G!=1 & DG5H!=1 & DG5I!=1
la var official_id "has any type of official identification (DG5A to DG5I)"

//Mobile phone and bank ownership and access
rename MT1 phone_own //1=yes, 2=no
la var phone_own "person owns a mobile phone (MT1)" 
rename MT2 phone_access //1=yes, 2=no
la var phone_access "person uses mobile phone belonging to someone else by borrowing or paying for its use (MT2)"
rename MT5 sim_own //1=yes, 2=no
la var sim_own "person owns an active/working sim card (MT5)"
rename MT8 sim_access //1=yes, 2=no
la var sim_access "person uses sim card belonging to someone else (MT8)"
rename FFI1 bank_own //1=yes, 2=no
la var bank_own "person has bank account registered in their name (FFI1)"

recode literate numerate employed official_id phone_own sim_own sim_access bank_own (2=0)

*******************
*OUTCOME VARIABLES*
*******************

*General awareness - does not exist in Wave 1
**Create a general awareness variable for append with all values missing
gen dfs_aware_gen=.

***********
*AWARENESS*
***********

*Specific provider awareness - prompted & spontaneous
**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=. // Though not documented on the questionnaire, MM1M seems to indicate "none of the above" instead of a 13th MM provider
replace dfs_aware_spont=1 if (MM1A==1 | MM1B==1 | MM1C==1 | MM1D==1 | MM1E==1 | MM1F==1 | MM1G==1 | MM1H==1 | MM1I==1 | MM1J==1 | MM1K==1 | MM1L==1)
replace dfs_aware_spont=0 if (MM1A==0 & MM1B==0 & MM1C==0 & MM1D==0 & MM1E==0 & MM1F==0 & MM1G==0 & MM1H==0 & MM1I==0 & MM1J==0 & MM1K==0 & MM1L==0)
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM1A - MM1L)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if (MM2A==1 | MM2B==1 | MM2C==1 | MM2D==1 | MM2E==1 | MM2F==1 | MM2G==1 | MM2H==1 | MM2I==1 | MM2J==1 | MM2K==1)  
replace dfs_aware_prompt=0 if (MM2A==0 & MM2B==0 & MM2C==0 & MM2D==0 & MM2E==0 & MM2F==0 & MM2G==0 & MM2H==0 & MM2I==0 & MM2J==0 & MM2K==0)
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM2A - MM2L)"

**AWARENESS OUTCOME VARIABLE
**Aware of any specific provider, spontaneous or prompted
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_prompt==1 | dfs_aware_spont==1
replace dfs_aware_name=0 if dfs_aware_prompt==0 & dfs_aware_spont==0
la var dfs_aware_name "person could recall name of DFS provider spontaneously or when prompted"

**********
*ADOPTION*
**********
gen dfs_adopt=.  // Though not documented on the questionnaire, MM6M seems to indicates "none of the above", instead of a 13th MM provider
replace dfs_adopt=1 if MM6A==1 | MM6B==1 | MM6C==1 | MM6D==1 | MM6E==1 | MM6F==1 | MM6G==1 | MM6H==1 | MM6I==1 | MM6J==1 | MM6K==1 | MM6L==1
replace dfs_adopt=0 if MM6M==1
replace dfs_adopt=. if dfs_aware_name!=1
la var dfs_adopt "person has ever used DFS for any financial activity (MM6A-L)"

*****
*USE*
*****
gen dfs_lastuse_yest=.
replace dfs_lastuse_yest=1 if (MM7_1==1 | MM7_2==1 | MM7_3==1 | MM7_4==1 | MM7_5==1 | MM7_6==1 | MM7_7==1 | MM7_8==1 | MM7_9==1 | MM7_10==1 | MM7_11==1 | MM7_12==1) 
replace dfs_lastuse_yest=0 if (MM7_1!=1 & MM7_2!=1 & MM7_3!=1 & MM7_4!=1 & MM7_5!=1 & MM7_6!=1 & MM7_7!=1 & MM7_8!=1 & MM7_9!=1 & MM7_10!=1 & MM7_11!=1 & MM7_12!=1)
replace dfs_lastuse_yest=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. & MM7_8==. & MM7_9==. & MM7_10==. & MM7_11==. & MM7_12==.)
la var dfs_lastuse_yest "person used DFS yesterday (MM7_1-12)"

gen dfs_lastuse_week=.
replace dfs_lastuse_week=1 if (MM7_1==2 | MM7_2==2 | MM7_3==2 | MM7_4==2 | MM7_5==2 | MM7_6==2 | MM7_7==2 | MM7_8==2 | MM7_9==2 | MM7_10==2 | MM7_11==2 | MM7_12==2)
replace dfs_lastuse_week=0 if (MM7_1!=2 & MM7_2!=2 & MM7_3!=2 & MM7_4!=2 & MM7_5!=2 & MM7_6!=2 & MM7_7!=2 & MM7_8!=2 & MM7_9!=2 & MM7_10!=2 & MM7_11!=2 & MM7_12!=2) | dfs_lastuse_yest==1
replace dfs_lastuse_week=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. & MM7_8==. & MM7_9==. & MM7_10==. & MM7_11==. & MM7_12==.)
la var dfs_lastuse_week "person used DFS in the past 7 days (MM7_1-12)"

gen dfs_lastuse_month=.
replace dfs_lastuse_month=1 if (MM7_1==3 | MM7_2==3 | MM7_3==3 | MM7_4==3 | MM7_5==3 | MM7_6==3 | MM7_7==3 | MM7_8==3 | MM7_9==3 | MM7_10==3 | MM7_11==3 | MM7_12==3)
replace dfs_lastuse_month=0 if (MM7_1!=3 & MM7_2!=3 & MM7_3!=3 & MM7_4!=3 & MM7_5!=3 & MM7_6!=3 & MM7_7!=3 & MM7_8!=3 & MM7_9!=3 & MM7_10!=3 & MM7_11!=3 & MM7_12!=3) | dfs_lastuse_yest==1 | dfs_lastuse_week==1
replace dfs_lastuse_month=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. & MM7_8==. & MM7_9==. & MM7_10==. & MM7_11==. & MM7_12==.)
la var dfs_lastuse_month "person used DFS in the past 30 days (MM7_1-12)"

gen dfs_lastuse_90days=.
replace dfs_lastuse_90days=1 if (MM7_1==4 | MM7_2==4 | MM7_3==4 | MM7_4==4 | MM7_5==4 | MM7_6==4 | MM7_7==4 | MM7_8==4 | MM7_9==4 | MM7_10==4 | MM7_11==4 | MM7_12==4)
replace dfs_lastuse_90days=0 if (MM7_1!=4 & MM7_2!=4 & MM7_3!=4 & MM7_4!=4 & MM7_5!=4 & MM7_6!=4 & MM7_7!=4 & MM7_8!=4 & MM7_9!=4 & MM7_10!=4 & MM7_11!=4 & MM7_12!=4) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1
replace dfs_lastuse_90days=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. & MM7_8==. & MM7_9==. & MM7_10==. & MM7_11==. & MM7_12==.)
la var dfs_lastuse_90days "person used DFS in the past 90 days (MM7_1-12)"

gen dfs_lastuse_more90=.
replace dfs_lastuse_more90=1 if (MM7_1==5 | MM7_2==5 | MM7_3==5 | MM7_4==5 | MM7_5==5 | MM7_6==5 | MM7_7==5 | MM7_8==5 | MM7_9==5 | MM7_10==5 | MM7_11==5 | MM7_12==5)
replace dfs_lastuse_more90=0 if (MM7_1!=5 & MM7_2!=5 & MM7_3!=5 & MM7_4!=5 & MM7_5 !=5 & MM7_6!=5 & MM7_7!=5 & MM7_8!=5 & MM7_9!=5 & MM7_10!=5 & MM7_11!=5 & MM7_12!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. & MM7_8==. & MM7_9==. & MM7_10==. & MM7_11==. & MM7_12==.)
la var dfs_lastuse_more90 "person used DFS over 90 days ago (MM7-15)"

//Generating dfs_use categorical variable
**There are 8 people in Nigeria who answered "DK/Refused," so n=10 (n for dfs_adopt is 18)
**In this case, choice 6 says "never" on the survey but these people answered 'yes' to adopt, coded as missing
egen dfs_use=rowmin(MM7_*)
replace dfs_use=. if dfs_use==6
tab dfs_use
la var dfs_use "When did you last use MM?"
label define dfs_use1 1 "Yesterday" 2 "Less than a Week" 3 "Less than a Month" 4 "Less than 90 Days" 5 "More than 90 Days" 
label values dfs_use dfs_use1


//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married literate numerate employed official_id
phone_own phone_access sim_own sim_access bank_own 
dfs_aware_name dfs_aware_spont dfs_aware_prompt dfs_adopt 
dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month dfs_lastuse_90days dfs_lastuse_more90
dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_week dfs_lastuse_month
dfs_lastuse_90days dfs_lastuse_more90


;
	#d cr

//Label generated variable values 0=no; 1=yes
	label define yesnovars 0 "No" 1 "Yes"
foreach var of local yesnogen {
	label values `var' yesnovars
}



save "$output\Nigeria_W1_Clean.dta", replace
