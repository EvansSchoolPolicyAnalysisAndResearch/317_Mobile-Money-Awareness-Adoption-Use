
/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Bangladesh Financial Inclusion Insights Wave 1 data set.
				  
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
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Bangladesh Financial Inclusion Insights Wave 1 data set.
*After downloading the "FII Bangladesh Wave One Data.xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FII Bangladesh Wave One Data.xlsx", firstrow
save "filepath for location where you want to save dta file/Bangladesh_Wave1_Stata.dta", replace
clear


***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 

************
*BANGLADESH*
************
use "$input\Bangladesh_Wave1_Stata.dta"

*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
gen bang=1 

//Wave dummy
gen wave=1

rename WEIGHT weight
	la var weight"survey weights"

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************
rename IAGE age

//Urban/rural residence
rename AA7 urban_rural 
la var urban_rural "settlement size (AA7)"
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
la var ppi_cutoff "PPI Cutoff"
	label define ppi_cutoff1 0 "Above poverty line" 1 "Below poverty line" 
	label values ppi_cutoff ppi_cutoff1	

//Marital status (if monogomously or polygamously married - does not include widowed, divorced, etc.)
rename DG3 marital_status //generated dummy var below
la var marital_status "person's marital status (DG3)"
	label define marital_statusl 1 "Single/never married" /*
		*/ 2 "Monogamously married" 3 "Divorced" 4 "Separated" 5 "Widowed" /*
		*/ 6 "Other(specify)" 7 "DK/Refused"
	label values marital_status marital_statusl
	
//Highest level of education 
rename DG4 highest_ed // refer to FII codebook for labels
la var highest_ed "highest level of education (DG4)"
	label define highest_edl 1 "No formal education" 2 "Primary education not complete" /*
	*/ 3 "Primary education complete"  4 "Junior/Middle school incomplete (SSC Level)" /*
	*/ 5 "Junior/Middle school complete (O'Level)" 6 "Some secondary (HSC level)" 7 "Secondary education complete (A'Level)" /*
	*/ 8 "Some secondary vocational training" 9 "Secondary vocational training complete" 10 "Some diploma" /*
	*/ 11 "Diploma complete" 12 "Some college/university" 13 "Complete university degree"/*
	*/   14 "Post-graduate university degree" 16 "Other" 17 "DK/Refused"  
	label values highest_ed highest_edl
	
//Level of education - variable to be used in regression analysis (standardized across countries)
gen ed_level=.
replace ed_level=1 if highest_ed==1
replace ed_level=2 if highest_ed==2 | highest_ed==3 | highest_ed==4 | highest_ed==5
replace ed_level=3 if  highest_ed==6 | highest_ed==7
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
replace married=1 if marital_status==3
replace married=0 if marital_status!=3
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
	replace employed=0 if employed==2
	
//Official ID (if answered yes to any type of official id; verify if we need to exclude any types)
egen official_id=rowmin(DG5_*)
la var official_id "has any type of official identification (DG5_1 to DG5_8)"

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

***********
*AWARENESS*
***********
*General awareness - does not exist in Wave 1
**Create a general awareness variable for append with all values missing
gen dfs_aware_gen=.

*Specific provider awareness - prompted & spontaneous
**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if MM1_1==1 | MM1_2==1 | MM1_3==1 | MM1_4==1 | MM1_5==1 | MM1_6==1 | MM1_7==1 
replace dfs_aware_spont=0 if (MM1_1==2 & MM1_2==2 & MM1_3==2 & MM1_4==2 & MM1_5==2 & MM1_6==2 & MM1_7==2)
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM1_1-7)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if MM2_1==1 | MM2_2==1 | MM2_3==1 | MM2_4==1 | MM2_5==1 | MM2_6==1 | MM2_7==1 
replace dfs_aware_prompt=0 if (MM2_1==2 & MM2_2==2 & MM2_3==2 & MM2_4==2 & MM2_5==2 & MM2_6==2 & MM2_7==2)
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM2_1-7)"

**AWARENESS OUTCOME VARIABLE
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_prompt==1 | dfs_aware_spont==1
replace dfs_aware_name=0 if dfs_aware_prompt==0 & dfs_aware_spont==0
la var dfs_aware_name "person could recall name of DFS provider spontaneously or when prompted"

**********
*ADOPTION*
**********

**Generate DFS use variable (if they've ever used a DFS service)
gen dfs_adopt=.
replace dfs_adopt=1 if MM6_1==1 | MM6_2==1 | MM6_3==1 | MM6_4==1 | MM6_5==1 | MM6_6==1 | MM6_7==1
replace dfs_adopt=0 if MM6_1!=1 & MM6_2!=1 & MM6_3!=1 & MM6_4!=1 & MM6_5!=1 & MM6_6!=1 & MM6_7!=1
replace dfs_adopt=. if MM6_1==. & MM6_2==. & MM6_3==. & MM6_4==. & MM6_5==. & MM6_6==. & MM6_7==.
la var dfs_adopt "person has ever used DFS for any financial activity (MM6_1-7)"

**These are exclusive categories
gen dfs_lastuse_yest=.
replace dfs_lastuse_yest=1 if MM7_1==1 | MM7_2==1 | MM7_3==1 | MM7_4==1 | MM7_5==1 | MM7_6==1 | MM7_7==1 
replace dfs_lastuse_yest=0 if MM7_1!=1 & MM7_2!=1 & MM7_3!=1 & MM7_4!=1 & MM7_5!=1 & MM7_6!=1 & MM7_7!=1 
replace dfs_lastuse_yest=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. 
la var dfs_lastuse_yest "person used DFS yesterday (MM7_1-7)"

gen dfs_lastuse_week=.
replace dfs_lastuse_week=1 if MM7_1==2 | MM7_2==2 | MM7_3==2 | MM7_4==2 | MM7_5==2 | MM7_6==2 | MM7_7==2  
replace dfs_lastuse_week=0 if (MM7_1!=2 & MM7_2!=2 & MM7_3!=2 & MM7_4!=2 & MM7_5!=2 & MM7_6!=2 & MM7_7!=2) | dfs_lastuse_yest==1
replace dfs_lastuse_week=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. 
la var dfs_lastuse_week "person used DFS in the past 7 days (MM7_1-7)"

gen dfs_lastuse_month=.
replace dfs_lastuse_month=1 if MM7_1==3 | MM7_2==3 | MM7_3==3 | MM7_4==3 | MM7_5==3 | MM7_6==3 | MM7_7==3 
replace dfs_lastuse_month=0 if (MM7_1!=3 & MM7_2!=3 & MM7_3!=3 & MM7_4!=3 & MM7_5!=3 & MM7_6!=3 & MM7_7!=3) | dfs_lastuse_yest==1 | dfs_lastuse_week==1
replace dfs_lastuse_month=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. 
la var dfs_lastuse_month "person used DFS in the past 30 days (MM7_1-7)"

gen dfs_lastuse_90days=.
replace dfs_lastuse_90days=1 if MM7_1==4 | MM7_2==4 | MM7_3==4 | MM7_4==4 | MM7_5==4 | MM7_6==4 | MM7_7==4 
replace dfs_lastuse_90days=0 if (MM7_1!=4 & MM7_2!=4 & MM7_3!=4 & MM7_4!=4 & MM7_5!=4 & MM7_6!=4 & MM7_7!=4) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1
replace dfs_lastuse_90days=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. 
la var dfs_lastuse_90days "person used DFS in the past 90 days (MM7_1-7)"

gen dfs_lastuse_more90=.
replace dfs_lastuse_more90=1 if MM7_1==5 | MM7_2==5 | MM7_3==5 | MM7_4==5 | MM7_5==5 | MM7_6==5 | MM7_7==5
replace dfs_lastuse_more90=0 if (MM7_1!=5 & MM7_2!=5 & MM7_3!=5 & MM7_4!=5 & MM7_5 !=5 & MM7_6!=5 & MM7_7!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==. 
la var dfs_lastuse_more90 "person used DFS over 90 days ago (MM7-1-7)"


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
dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month dfs_lastuse_90days 
dfs_lastuse_more90

;
	#d cr

//Label generated variable values 0=no; 1=yes
	label define yesnovars 0 "No" 1 "Yes"
foreach var of local yesnogen {
	label values `var' yesnovars
}


save "$output\Bangladesh_W1_Clean.dta", replace
