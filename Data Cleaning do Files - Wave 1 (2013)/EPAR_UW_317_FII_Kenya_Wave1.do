/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Kenya Financial Inclusion Insights Wave 1 data set.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Financial Inclusion Insights Wave 1 data were collected by Intermedia.
*The data were collected over the period October 2013- January 2014.
*All the raw data, questionnaires, and basic information documents can be requested from Intermedia by clicking "contact InterMedia" at the following link
*http://finclusion.org/data_fiinder/


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Kenya Financial Inclusion Insights Wave 1 data set.
*After downloading the "FII Kenya Wave One Data_v1.xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FII Kenya Wave One Data_v1.xlsx", firstrow
save "filepath for location where you want to save dta file/Kenya_Wave1_Stata.dta", replace
clear

***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


*******
*KENYA*
*******
use "$input\Kenya_Wave1_Stata.dta"

*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
gen kenya=1 

//Wave dummy
gen wave=1

rename WEIGHT weight
	la var weight"survey weights"

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************

rename IAGE age

//Urban/rural residence
rename AA8 urban_rural 
la var urban_rural "settlement size (AA8)"
	label define urban_rurall 1 "Urban" 2 "Rural" 
	label values urban_rural urban_rurall

//Generate a female variable
gen female=.
replace female=1 if DG2==2
replace female=0 if DG2==1
	la var female "Gender of respondent (DG2)"
	label define femalel 0 "Male" 1 "Female"
	label values female femalel

//PPI Cutoff
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
	*/ 11 "Complete university degree" 12 "Post-graduate university degree" 13 "Koranic school" 14 "Other/specify" /*
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
rename Literacy literate 
	la var literate "person has basic literacy"
	
//Numeracy
rename Numeracy numerate 
	la var numerate "person has basic numeracy"

//Employment - this is a binary in W1 (no employment_status variable; cannot make i.employment outcome)
rename DL1 employed
	la var employed "do you have a job that earns you income?"

	
//Official ID (if answered yes to any type of official id; verify if we need to exclude any types)
egen official_id=rowmin(DG5_*)
replace official_id=0 if official_id==2
la var official_id "has any type of official identification (DG5_1 to DG5_9)"

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

*General awareness - question does not exist in Wave 1
**Create a general awareness variable for append with all values missing
gen dfs_aware_gen=.

***********
*AWARENESS*
***********
*Specific provider awareness - prompted & spontaneous
**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if (MM1A==1 | MM1B==1 | MM1C==1 | MM1D==1)
replace dfs_aware_spont=0 if (MM1A==0 & MM1B==0 & MM1C==0 & MM1D==0)
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM1A-D)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if (MM2A==1 | MM2B==1 | MM2C==1 | MM2D==1)  
replace dfs_aware_prompt=0 if (MM2A==0 & MM2B==0 & MM2C==0 & MM2D==0)
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM2A-D)"

**AWARENESS OUTCOME VARIABLE
**No general awareness in W1, so this has to be the outcome
**Aware of any specific provider, spontaneous or prompted
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_prompt==1 | dfs_aware_spont==1
replace dfs_aware_name=0 if dfs_aware_prompt==0 & dfs_aware_spont==0
la var dfs_aware_name "person could recall name of DFS provider spontaneously or when prompted"

**********
*ADOPTION*
**********
gen dfs_adopt=.
replace dfs_adopt=1 if dfs_aware_name==1 & (MM6A==1 | MM6B==1 | MM6C==1 | MM6D==1)
**Use 'never used DFS' (MM6E) to code this variable
replace dfs_adopt=0 if MM6E==1 
la var dfs_adopt "person has ever used DFS for any financial activity (MM6A-D)"

*****
*USE*
*****
gen dfs_lastuse_yest=.
replace dfs_lastuse_yest=1 if (MM7_1==1 | MM7_2==1 | MM7_3==1 | MM7_4==1) 
replace dfs_lastuse_yest=0 if (MM7_1!=1 & MM7_2!=1 & MM7_3!=1 & MM7_4!=1)
replace dfs_lastuse_yest=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==.)
la var dfs_lastuse_yest "person used DFS yesterday (MM7_1-4)"

gen dfs_lastuse_week=.
replace dfs_lastuse_week=1 if (MM7_1==2 | MM7_2==2 | MM7_3==2 | MM7_4==2)
replace dfs_lastuse_week=0 if (MM7_1!=2 & MM7_2!=2 & MM7_3!=2 & MM7_4!=2) | dfs_lastuse_yest==1
replace dfs_lastuse_week=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==.)
la var dfs_lastuse_week "person used DFS in the past 7 days (MM7_1-4)"

gen dfs_lastuse_month=.
replace dfs_lastuse_month=1 if (MM7_1==3 | MM7_2==3 | MM7_3==3 | MM7_4==3)
replace dfs_lastuse_month=0 if (MM7_1!=3 & MM7_2!=3 & MM7_3!=3 & MM7_4!=3) | dfs_lastuse_yest==1 | dfs_lastuse_week==1
replace dfs_lastuse_month=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==.)
la var dfs_lastuse_month "person used DFS in the past 30 days (MM7_1-4)"

gen dfs_lastuse_90days=.
replace dfs_lastuse_90days=1 if (MM7_1==4 | MM7_2==4 | MM7_3==4 | MM7_4==4)
replace dfs_lastuse_90days=0 if (MM7_1!=4 & MM7_2!=4 & MM7_3!=4 & MM7_4!=4) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1
replace dfs_lastuse_90days=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==.)
la var dfs_lastuse_90days "person used DFS in the past 90 days (MM7_1-4)"

gen dfs_lastuse_more90=.
replace dfs_lastuse_more90=1 if (MM7_1==5 | MM7_2==5 | MM7_3==5 | MM7_4==5)
replace dfs_lastuse_more90=0 if (MM7_1!=5 | MM7_2!=5 | MM7_3!=5 | MM7_4!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if (MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==.)
la var dfs_lastuse_more90 "person used DFS over 90 days ago (MM7_1-4)"

//Generating dfs_use categorical variable
egen dfs_use=rowmin(MM7_*)
replace dfs_use=. if dfs_adopt!=1
tab dfs_use
la var dfs_use "When did you last use MM?"
label define dfs_use1 1 "Yesterday" 2 "Less than a Week" 3 "Less than a Month" 4 "Less than 90 Days" 5 "More than 90 Days"
label values dfs_use dfs_use1


//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married literate numerate employed official_id
phone_own phone_access sim_own sim_access bank_own 
dfs_aware_name dfs_aware_spont dfs_aware_prompt dfs_adopt
dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_week dfs_lastuse_month 
dfs_lastuse_90days dfs_lastuse_more90
;
	#d cr

//Label generated variable values 0=no; 1=yes
	label define yesnovars 0 "No" 1 "Yes"
foreach var of local yesnogen {
	label values `var' yesnovars
}


save "$output\Kenya_W1_Clean.dta", replace


