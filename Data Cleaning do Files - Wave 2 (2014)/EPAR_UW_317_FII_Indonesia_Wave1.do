/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Indonesia Financial Inclusion Insights Wave 1 data set.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Financial Inclusion Insights Wave 1 data was collected by Intermedia 
*The data were collected over the period of September 2014-December 2014.
*All the raw data, questionnaires, and basic information documents can be requested from Intermedia by clicking "contact InterMedia" at the following link
*http://finclusion.org/data_fiinder/


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Indonesia Financial Inclusion Insights Wave 1 data set.
*After downloading the "FSP_Final_Indonesia_02122015 (public).xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FSP_Final_Indonesia_02122015 (public).xlsx", firstrow
save "filepath for location where you want to save dta file/Indonesia_Wave1_Stata.dta", replace
clear

***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


***********
*Indonesia*
***********
use "$input\Indonesia_Wave1_Stata.dta"


*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
//Generate dummy variable for Bangladesh (for when appending to other files) 
gen indonesia=1 

//Wave dummy
gen wave=2

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************

//Location Variables
rename ïAA2 province
la var province "residential province of respondent"
rename AA3 district
la var district "residential district of respondent"
rename AA7 urban_rural //1=urban, 2=rural
la var urban_rural "settlement size(AA7)"
	label define urban_rurall 1 "Urban" 2 "Rural" 
	label values urban_rural urban_rurall

//no missing ages listed as 999
	
rename rural_females rural_female
la var rural_female "female living in a rural area"
	label define rural_femalel 0 "Not rural or not female" 1 "Female - rural"
	label values rural_female rural_femalel

//Other characteristics
rename DG1 yearborn
la var yearborn "year of birth (DG1)"
rename DG3 marital_status //created dummy var below
la var marital_status "person's marital status (DG3)"
	label define marital_statusl 1 "Single/never married/not married" 2 "Polygamously married" /*
		*/ 3 "Monogamously married" 4 "Divorced" 5 "Separated" 6 "Widowed" 7 "Living together/cohabiting" /*
		*/ 8 "Other(specify)" 9 "DK/Refused"
	label values marital_status marital_statusl

rename DL1 employment_status // generated dummy var below
la var employment_status "employment status of individual (DL1)"
	label define employment_statusl 1 "Working full-time for a regular salary" 2 "Working part-time for a regular salary" 3 "Working occasionally, irregular pay" /*
		*/ 4 "Self-employed, working for yourself" 5 "Not working but looking for a job" 6 "Housewife, doing household chores" 7 "Full-time student" /*
		*/ 8 "Not working because of retirement" 9 "Not working because of sickness, disability, etc." 10 "Other(specify)" 11 "DK/Refused"
	label values employment_status employment_statusl

//Generate employment variable	
gen employment=.
replace employment=1 if employment_status==1 | employment_status==2
replace employment=2 if employment_status==3 
replace employment=3 if employment_status==4 
replace employment=4 if employment_status==6
replace employment=5 if employment_status==5 | employment_status==7 | employment_status==8 | employment_status==9
	label define employment1 1 "Full or part-time" 2 "Occasional or seasonal" 3 "Self-employed" 4 "Non-wage labor" 5 "Not working"
	label values employment employment1

rename DL2 primary_job 
la var primary_job "individual's primary job (see codebook for labels) (DL2)"
destring primary_job, replace 
	label define primary_jobl 1 "Farm owner" 2 "Farm worker" 3 "Government employee" 4 "Professional (i.e. doctor, teacher, nurse)" 5 "Clerk"/*
		*/ 6 "Carpenter/mason" 7 " Mechanic" 8 "Electrician" 9 "Cleaner/house help" 10 "Waiter/cook" 11 "Driver, including public transport" /* 
		*/ 12 "Tailor" 13 "Secretary" 14 "Manager" 15 "Watchman/security/caretaker" 17 "Policeman/police reserve" 18 "Conductor" 19 "Factory employee" /*
		*/ 20 "Shop owner" 21 "Salesperson in a store" 22 "Street vendor/hawker (selling groceries warung)" 23 "Business owner (specify below)" 24 "Salonist" /*
		*/ 25 "Money lender" 26 "Landlord/landlady" 27 "Miner (gold, sand, coal, oil, etc.)" 28 "Military" 29 "Occasional worker with no occupation" /*
		*/ 30 "Other (specify in row)" 31 "Refused/prefer not to say"
	label values primary_job primary_job1

//Education
rename DG4 highest_ed
la var highest_ed "highest level of education (DG4)"
	label define highest_edl 1 "No formal education" 2 "Primary education not complete" 3 "Primary education complete" /*
		*/ 4 "Some junior high school" 5 "Junior high school complete" 6 "Some senior high school" 7 "Senior high school complete" /*
		*/ 8 "Some secondary vocational training/some certificate" 9 "Secondary vocational training complete/certificate complete" /* 
		*/ 10 "Some diploma" 11 "Diploma complete" 12 "Some college/university" 13 "Complete university degree" 14 "Post-graduate university degree" /*
		*/ 15 "Informal education" 16 "Other (specify)" 17 "DK/Refused"
	label values highest_ed highest_edl

gen ed_level=.
replace ed_level=1 if highest_ed==1 | highest_ed==15
replace ed_level=2 if highest_ed==2 | highest_ed==3 | highest_ed==4 | highest_ed==5
replace ed_level=3 if highest_ed==6 | highest_ed==7 | highest_ed==8 | highest_ed==9
replace ed_level=4 if highest_ed==10 | highest_ed==11 | highest_ed==12 | highest_ed==13 | highest_ed==14
label define ed_level1 1 "No formal" 2 "Primary" 3 "Secondary" 4 "Higher education"
	label values ed_level ed_level1

//Completed any education above primary school
//No=no formal education, informal only, primary incomplete, or primary complete
gen above_prim=.
replace above_prim=0 if highest_ed==1 | highest_ed==2 | highest_ed==3 | highest_ed==15 
replace above_prim=1 if above_prim!=0 & highest_ed!=16 &highest_ed!=17
la var above_prim "Highest level of edu is primary"
	label define above_prim1 0 "Primary or lower" 1 "Above primary"
	label values above_prim above_prim1	

//Number of persons in the household not coded (different than in Wave 2)
	
//Literacy/Numeracy
rename Numeracy numerate
la var numerate "person has basic numeracy"
rename Literacy literate
la var literate "person has basic literacy"

//Mobile phone and bank ownership and access
rename MT1 phone_own
la var phone_own "person owns a mobile phone (MT1)"
rename MT3 phone_access
la var phone_access "person uses mobile phone belonging to someone else by borrowing or paying for its use (MT3)"
rename MT7 sim_own
la var sim_own "person owns an active/working sim card (MT7)"
rename MT9 sim_access
la var sim_access "person uses sim card belonging to someone else (MT9)"
rename FF1 bank_own
la var bank_own "person has bank account registered in their name (FF1)"
rename FF5 reason_nobankacct 
la var reason_nobankacct "reason person does not have bank account (FF5)"
destring reason_nobankacct, replace
	label define reason_nobankacctl 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state-issued/national ID or other req. docs" /*
		*/ 4 "There are no banks close to where I live" 5 "I do not have money" 6 "I do not need one, I do not make any transactions" /*
		*/ 7 "Registration paperwork is too complicated" 8 "Registration fee is too high" 9 "Using a bank account is difficult" 10 "Fees for using a bank account are too high" /*
		*/ 11 "I do not have money to make any transactions with such an account" 12 "No one among my friends or family has such account" /*
		*/ 13 "I do not understand the purpose of such account, i do not know what I can use it for" 14 "A bank has agents but they are not accessible" /*
		*/ 15 "Banks are not reliable" 16 "Banks do not offer the services I need" 17 "Bank staff/agents are unfriendly; they make me feel unwelcome" /*
		*/ 18 "I can't afford the minimum balance" 19 "Bank hours are not convenient for me" 20 "I never thought about using a bank" /*
		*/ 21 "I do not trust banks/that my money is safe in a bank" 22 "I would rather have my money close to me" 23 "I use mobile money/uang ponsel" /*
		*/ 24 "I don't have time to go to the bank" 25 "I use somebody else's account" 26 "My husband, family, in-laws do not approve of me having a bank account" /*
		*/ 27 "I will not be able to go to a bank on my own" 28 "It's not approved by my religion" 29 "Transportation to the bank is costly for me" /*
		*/ 30 "I don't like the monthly charges applied to my account" 31 "Other(specify)" 32 "DK/Refused"
	label values reason_nobankacct reason_nobankacctl

rename FF6 bank_access
la var bank_access "person uses someone else's bank account (FF6)"

//Digital Financial Services / Mobile Money

*General awareness of concept of mobile money
rename MM1 dfs_aware_gen //1=yes, 2=no
la var dfs_aware_gen "person has heard of Mobile Money (MM1)"

*Reasons for using/not using DFS
rename MM16 dfs_reasonnouse 
la var dfs_reasonnouse "main reason for never having used DFS (MM16)"
destring dfs_reasonnouse, replace
	label define dfs_reasonnousel 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state ID or other req. docs" /*
		*/ 4 "There is no point-of-service/agent close to where I live" 5 "I do not need one, I do not make any transactions" 6 "Registration paperwork is too complicated" /*
		*/ 7 "Registration fee is too high" 8 "Using such account is difficult" 9 "Fees for using this service are too high" /*
		*/ 10 "I never have money to make transactions with this service" 11 "No one among my friends or family use this service" /*
		*/ 12 "I do not understand this service/ I do not know what I can use it for" 13 "I do not have a smartphone" /*
		*/ 14 "I do not trust that my money is safe on mobile money /uang ponsel" 15 "My husband/family/in-laws do not approve of me having an m-money account" /*
		*/ 16 "It is against my religion" 17 "I don't use because all agents are men" /*
		*/ 18 "Mobile money/uang ponsel does not provide anything better/any advantage over financial systems I currently use" 19 "Other(specify)"
	label values dfs_reasonnouse dfs_reasonnousel

*Reasons for not registering for DFS
rename MM17 dfs_reasonnoreg
la var dfs_reasonnoreg "main reason for not signing up for an acct despite using DFS (MM17)"
destring dfs_reasonnoreg, replace
	label define dfs_reasonnoregl 1 "I do not have a state ID or other req. docs" 2 "There is no point-of-service/agent close to where I live" /*
		*/ 3 "I do not need to, I do not make any transactions" 4 "Using such an account is difficult" 5 "Fees for using such account are too high" /*
		*/ 6 "I never have money to make a transaction with such account" 7 "No one among my friends or family has such account" /*
		*/ 8 "I do not understand the purpose of this account, I don't know what I can use it for" 9 "I can have all the services through an agent, I do not need an account" /*
		*/ 10 "Registration fees are too high" 11 "I prefer that agents perform transactions for me, they will fix the problems if anything happens" /*
		*/ 12 "I do not trust my money is safe on an m-money account" 13 "I prefer to keep money in cash and use m-money only to send/receive money" /*
		*/ 14 "I have heard of fraud on mobile money" 15 "Agent can help me use the service/I do not know how to use it on my own" /*
		*/ 16 "I do not see any additional advantages to registration" 17 "Other (specify)"
	label values dfs_reasonnoreg dfs_reasonnoregl

*Reasons for starting to use DFS
rename MM18	dfs_reasonstart 
la var dfs_reasonstart "reason for starting to use DFS (MM18)"
destring dfs_reasonstart, replace
	label define dfs_reasonstartl 1 "I had to send money to another person" 2 "I had to receive money from another person" 3 "Somebody/a person requested I open an account" /*
		*/ 4 "I had to send money to an org/govt. agency: e.g. had to pay a bill" 5 "I had to receive money from an org/govt. agency: e.g. unemployment payment or welfare benefits" /*
		*/ 6 "An organization/govt. agency requested I sign up for an account" 7 "An agent or sales person convinced me" /*
		*/ 8 "I saw posters/billboards/radio/TV advertising that convinced me" 9 "A person I know who uses mobile money, recommended I use it because it is better than other financial..."/*
		*/ 10 "I saw other people using it and wanted to try by myself" 11 "I wanted to start saving money with an m-money account" /*
		*/ 12 "I wanted a safe place to store my money" 13 "I got a discount on airtime" 14 "I got a promotional amount of money to spend if I start using m-money" /*
		*/ 15 "Most of my friends/family members are already using it" 16 "Other (specify)"
	label values dfs_reasonstart dfs_reasonstartl


//MLL: Skipping the following sections because only four people have used DFS:
**Uses of DFS
**Agent used
**Transport to agent
**Have you ever experienced any of the following issues with an agent?
**LAST USED DFS
**HOW DO YOU ACCESS DFS


**Level of satisfaction with financial options before and after having bank account/ using DFS
destring SFC*, replace

rename SFC1 sat_bankacct_before
la var sat_bankacct_before "rate 1-10 rate choice of financial options available before having bank acct"

rename SFC2 sat_bankacct_after
la var sat_bankacct_after "rate 1-10 rate choice of financial options available after you have bank acct"

rename SFC3 sat_dfs_before
la var sat_dfs_before "rate 1-10 rate choice of financial options available before you started using DFS"

rename SFC4 sat_dfs_after
la var sat_dfs_after "rate 1-10 rate choice of financial options available after you started using DFS"


//recode renamed dummy variables to be 0=no and 1=yes
destring phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen, replace
recode phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen (2=0)
local yesnorename phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen

//Setting the value labels for the loop
label define yesnovarsl 0 "No" 1 "Yes"

foreach var of local yesnorename {
	label values `var' yesnovarsl
}

******************************
** GENERATE DUMMY VARIABLES **
******************************

**FEMALE
gen female=.
replace female=1 if DG2==2
replace female=0 if DG2==1

**RURAL
gen rural=.
replace rural=1 if urban_rural==2
replace rural=0 if urban_rural==1
la var rural "person lives in a rural area (AA7)"

**MARRIED (if monogamously or polygamously married- does not include widowed, divorced, etc.) 
gen married=.
replace married=1 if marital_status==3 | marital_status==2
replace married=0 if marital_status!=3
la var married "person is monogomously or polygamously married (DG3)"

**OFFICIAL ID (if answered yes to any type of official id; verify if we need to exclude any types)
recode DG5_* (2=0)
egen official_id = rowmax (DG5_*) 
la var official_id "has any type of official identification (DG5_1 to DG5_17)"

**EMPLOYED (if working full or part time for a regular salary, self-employed, or working occasionally, irregular pay)
gen employed=.
replace employed=1 if employment_status <=4 
replace employed=0 if employment_status>4
la var employed "person works full-time, part-time, irregularly, or is self-employed (DL1)"

**DESTRING ALL OF THE VARIABLES SOMEONE MESSED UP
destring MM2_*, replace
destring MM3_*, replace
destring MM4_*, replace
destring MM7_*, replace

**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if MM2_1==1| MM2_2==1 | MM2_3==1 | MM2_4==1 | MM2_5==1 | MM2_6==1 | MM2_7==1 
replace dfs_aware_spont=0 if MM2_1==2 & MM2_2==2 & MM2_3==2 & MM2_4==2 & MM2_5==2 & MM2_6==2 & MM2_7==2 
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM2_1-7)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if MM3_1==1 | MM3_2==1 | MM3_3==1 | MM3_4==1 | MM3_5==1 | MM3_6==1 | MM3_7==1
replace dfs_aware_prompt=0 if MM3_1==2 & MM3_2==2 & MM3_3==2 & MM3_4==2 & MM3_5==2 & MM3_6==2 & MM3_7==2
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM3_1-8)"

**SPONTANEOUS OR PROMPTED RECALL of DFS providers
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_spont==1 | dfs_aware_prompt==1
replace dfs_aware_name=0 if dfs_aware_name!=1

**SOURCE OF INFORMATION FROM WHICH THEY LEARNED ABOUT DFS
//Question: From which source of information did you first learn about this mobile money service?
//each question asks where they learned about a specific provider so combining to learn how they learned about any provider

gen dfs_aware_radio=.
replace dfs_aware_radio=1 if MM4_1==1 | MM4_2==1 | MM4_3==1 | MM4_4==1 | MM4_5==1 | MM4_6==1 | MM4_7==1
replace dfs_aware_radio=0 if MM4_1!=1 & MM4_2!=1 & MM4_3!=1 & MM4_4!=1 & MM4_5!=1 & MM4_6!=1 & MM4_7!=1
replace dfs_aware_radio=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_radio "person first learned about any DFS provider from radio (MM4_1-7)"

gen dfs_aware_tv=.
replace dfs_aware_tv=1 if MM4_1==2 | MM4_2==2 | MM4_3==2 | MM4_4==2 | MM4_5==2 | MM4_6==2 | MM4_7==2
replace dfs_aware_tv=0 if MM4_1!=2 & MM4_2!=2 & MM4_3!=2 & MM4_4!=2 & MM4_5!=2 & MM4_6!=2 & MM4_7!=2
replace dfs_aware_tv=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_tv "person first learned about any DFS provider from television (MM4_1-7)"

gen dfs_aware_billboard=.
replace dfs_aware_billboard=1 if MM4_1==3 | MM4_2==3 | MM4_3==3 | MM4_4==3 | MM4_5==3 | MM4_6==3 | MM4_7==3
replace dfs_aware_billboard=0 if MM4_1!=3 & MM4_2!=3 & MM4_3!=3 & MM4_4!=3 & MM4_5!=3 & MM4_6!=3 & MM4_7!=3
replace dfs_aware_billboard=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_billboard "person first learned about any DFS provider from a billboard/poster (MM4_1-7)"

gen dfs_aware_newspaper=.
replace dfs_aware_newspaper=1 if MM4_1==4 | MM4_2==4 | MM4_3==4 | MM4_4==4 | MM4_5==4 | MM4_6==4 | MM4_7==4
replace dfs_aware_newspaper=0 if MM4_1!=4 & MM4_2!=4 & MM4_3!=4 & MM4_4!=4 & MM4_5!=4 & MM4_6!=4 & MM4_7!=4
replace dfs_aware_newspaper=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_newspaper "person first learned about any DFS provider from a newspaper/magazine (MM4_1-7)"

gen dfs_aware_household=. 
replace dfs_aware_household=1 if MM4_1==5 | MM4_2==5 | MM4_3==5 | MM4_4==5 | MM4_5==5 | MM4_6==5 | MM4_7==5
replace dfs_aware_household=0 if MM4_1!=5 & MM4_2!=5 & MM4_3!=5 & MM4_4!=5 & MM4_5!=5 & MM4_6!=5 & MM4_7!=5
replace dfs_aware_household=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_household "person first learned about any DFS provider from a fam member in their household (MM4_1-7)"

gen dfs_aware_otherfam=.
replace dfs_aware_otherfam=1 if MM4_1==6 | MM4_2==6 | MM4_3==6 | MM4_4==6 | MM4_5==5 | MM4_6==6 | MM4_7==6
replace dfs_aware_otherfam=0 if MM4_1!=6 & MM4_2!=6 & MM4_3!=6 & MM4_4!=6 & MM4_5!=5 & MM4_6!=6 & MM4_7!=6
replace dfs_aware_otherfam=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_otherfam "person first learned about any DFS provider from a fam member in another household (MM4_1-7)"

gen dfs_aware_friend=.
replace dfs_aware_friend=1 if MM4_1==7 | MM4_2==7 | MM4_3==7 | MM4_4==7 | MM4_5==7 | MM4_6==7 | MM4_7==7
replace dfs_aware_friend=0 if MM4_1!=7 & MM4_2!=7 & MM4_3!=7 & MM4_4!=7 & MM4_5!=7 & MM4_6!=7 & MM4_7!=7
replace dfs_aware_friend=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_friend "person first learned about any DFS provider from a friend, neighbor, or other relative (MM4_1-7)"

gen dfs_aware_workmate=.
replace dfs_aware_workmate=1 if MM4_1==8 | MM4_2==8 | MM4_3==8 | MM4_4==8 | MM4_5==8 | MM4_6==8 | MM4_7==8
replace dfs_aware_workmate=0 if MM4_1!=8 & MM4_2!=8 & MM4_3!=8 & MM4_4!=8 & MM4_5!=8 & MM4_6!=8 & MM4_7!=8
replace dfs_aware_workmate=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_workmate "person first learned about any DFS provider from a workmate or business partner (MM4_1-7)"

gen dfs_aware_cust=.
replace dfs_aware_cust=1 if MM4_1==9 | MM4_2==9 | MM4_3==9 | MM4_4==9 | MM4_5==9 | MM4_6==9 | MM4_7==9
replace dfs_aware_cust=0 if MM4_1!=9 & MM4_2!=9 & MM4_3!=9 & MM4_4!=9 & MM4_5!=9 & MM4_6!=9 & MM4_7!=9
replace dfs_aware_cust=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_cust "person first learned about any DFS provider from a customer of their business (MM4_1-7)"

gen dfs_aware_admin=.
replace dfs_aware_admin=1 if MM4_1==10 | MM4_2==10 | MM4_3==10 | MM4_4==10 | MM4_5==10 | MM4_6==10 | MM4_7==10
replace dfs_aware_admin=0 if MM4_1!=10 & MM4_2!=10 & MM4_3!=10 & MM4_4!=10 & MM4_5!=10 & MM4_6!=10 & MM4_7!=10
replace dfs_aware_admin=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_admin "person first learned about any DFS provider from elected/administrative officials (MM4_1-7)"

gen dfs_aware_bankemp=.
replace  dfs_aware_bankemp=1 if MM4_1==11 | MM4_2==11 | MM4_3==11 | MM4_4==11 | MM4_5==11 | MM4_6==11 | MM4_7==11
replace  dfs_aware_bankemp=0 if MM4_1!=11 & MM4_2!=11 & MM4_3!=11 & MM4_4!=11 & MM4_5!=11 & MM4_6!=11 & MM4_7!=11
replace  dfs_aware_bankemp=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var  dfs_aware_bankemp "person first learned about any DFS provider from a bank/MFI employee (MM4_1-7)"

gen dfs_aware_fingroup=.
replace dfs_aware_fingroup=1 if MM4_1==12 | MM4_2==12 | MM4_3==12 | MM4_4==12 | MM4_5==12 | MM4_6==12 | MM4_7==12
replace dfs_aware_fingroup=0 if MM4_1!=12 & MM4_2!=12 & MM4_3!=12 & MM4_4!=12 & MM4_5!=12 & MM4_6!=12 & MM4_7!=12
replace dfs_aware_fingroup=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_fingroup "person first learned about any DFS provider from informal financial group (MM4_1-7)"

gen dfs_aware_agent=.
replace dfs_aware_agent=1 if MM4_1==13 | MM4_2==13 | MM4_3==13 | MM4_4==13 | MM4_5==13 | MM4_6==13 | MM4_7==13
replace dfs_aware_agent=0 if MM4_1!=13 & MM4_2!=13 & MM4_3!=13 & MM4_4!=13 & MM4_5!=13 & MM4_6!=13 & MM4_7!=13
replace dfs_aware_agent=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_agent "person first learned about any DFS provider from transactional DFS agent (MM4_1-7)"

gen dfs_aware_fieldagent=.
replace dfs_aware_fieldagent=1 if MM4_1==14 | MM4_2==14 | MM4_3==14 | MM4_4==14 | MM4_5==14 | MM4_6==14 | MM4_7==14
replace dfs_aware_fieldagent=0 if MM4_1!=14 & MM4_2!=14 & MM4_3!=14 & MM4_4!=14 & MM4_5!=14 & MM4_6!=14 & MM4_7!=14
replace dfs_aware_fieldagent=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_fieldagent "person first learned about any DFS provider from a DFS field agent/promoter(MM4_1-7)"

gen dfs_aware_sms=.
replace dfs_aware_sms=1 if MM4_1==15 | MM4_2==15 | MM4_3==15 | MM4_4==15 | MM4_5==15 | MM4_6==15 | MM4_7==15
replace dfs_aware_sms=0 if MM4_1!=15 & MM4_2!=15 & MM4_3!=15 & MM4_4!=15 & MM4_5!=15 & MM4_6!=15 & MM4_7!=15
replace dfs_aware_sms=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_sms "person first learned about any DFS provider from a SMS alert from provider (MM4_1-7)"

gen dfs_aware_event=.
replace dfs_aware_event=1 if MM4_1==16 | MM4_2==16 | MM4_3==16 | MM4_4==16 | MM4_5==16 | MM4_6==16 | MM4_7==16
replace dfs_aware_event=0 if MM4_1!=16 & MM4_2!=16 & MM4_3!=16 & MM4_4!=16 & MM4_5!=16 & MM4_6!=16 & MM4_7!=16
replace dfs_aware_event=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_event "person first learned about any DFS provider from street event, bus, announcer (MM4_1-7)"

gen dfs_aware_other=.
replace dfs_aware_other=1 if MM4_1==17 | MM4_2==17 | MM4_3==17 | MM4_4==17 | MM4_5==17 | MM4_6==17 | MM4_7==17
replace dfs_aware_other=0 if MM4_1!=17 & MM4_2!=17 & MM4_3!=17 & MM4_4!=17 & MM4_5!=17 & MM4_6!=17 & MM4_7!=17
replace dfs_aware_other=. if MM4_1==. & MM4_2==. & MM4_3==. & MM4_4==. & MM4_5==. & MM4_6==. & MM4_7!=.
la var dfs_aware_other "person first learned about any DFS provider from other source (MM4_1-7)"

**EVER USED DFS
**Question: Have you ever used this mobile money service for any financial activity? (one question for each DFS provider, combining them to find out if they have ever used any DFS service)

destring MM5_*, replace
recode MM5_* (2=0)
egen dfs_adopt = rowmax (MM5_*)
la var dfs_adopt "person has ever used DFS for any financial activity (MM5_1-7)"

count if dfs_adopt==1 //4

**LAST USED DFS
//Question: Apart from today, when was the last time you conducted any financial activity with this mobile money service?
//One question for each DFS provider, so we are combining them to find out the last time individual used any of the DFS services
//Only including most recent use for each person

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
replace dfs_lastuse_more90=0 if (MM7_1!=5 & MM7_2!=5 & MM7_3!=5 & MM7_4!=5 & MM7_5!=5 & MM7_6!=5 & MM7_7!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if MM7_1==. & MM7_2==. & MM7_3==. & MM7_4==. & MM7_5==. & MM7_6==. & MM7_7==.
la var dfs_lastuse_more90 "person last used DFS more than 90 days ago (MM7_1-7)"

//Generating dfs_use categorical variable
egen dfs_use=rowmin(MM7_*)
replace dfs_use=. if dfs_adopt!=1
tab dfs_use
la var dfs_use "When did you last use MM?"
label define dfs_use1 1 "Yesterday" 2 "Less than a Week" 3 "Less than a Month" 4 "Less than 90 Days" 5 "More than 90 Days"
label values dfs_use dfs_use1


**REGISTERED ACCOUNT
//Question: Do you have a registered account (account registered in your name) with this mobile money service?
//One question for each DFS provider, so we are combining them 

destring MM8_*, replace
recode MM8_* (2=0)
egen dfs_regacct = rowmax (MM8_*)
la var dfs_regacct "person has a registered account with any DFS provider (MM8_1-7)"

*REMITTANCES
destring DL4_7 DL5 DL6_7, replace

count if DL4_7==1 //Do you supplement your income by any of the following? Remittances/monetary or other help from other family members (siblings, cousins, etc.), relatives or friends [1032 missing for all DL4_* questions].
count if DL5==7 //You said you did not have a regular job/were not working in the past 12 months. What is your main source of money for daily expenses? 7= remittances/monetary or other help from other family members]
count if DL6_7==1 //What are your other/secondary sources of money? Remittances/monetary or other help from other family members (siblings, cousins, etc.), relatives or friends [1973 missing for all secondary source questions]

count if DL6_7==.
count if DL4_7==.
count if DL6_7==. & DL4_7==.

gen rec_remit=.
replace rec_remit=0 if DL4_7==2 | DL6_7==2 //0 if answered "no" to DL4_7 or DL6_7, not considering response to DL5 b/c it only asks if remittances are *main* source of money
replace rec_remit=1 if DL4_7==1 | DL5==7 | DL6_7==1 //if answered "yes" to any question asking about receipt of remittances 
la var rec_remit "person receives remittances (DL4_7, DL6_7, DL5)"

count if rec_remit==. //26 obs missing

sum rec_remit //6.6% of obs report receiving remittances



**COMFORT/SKILL WITH MOBILE TECHNOLOGY
destring TDL2_*, replace


//Basic Use - person can dial numbers on a phone
gen mobileskills_call=.
replace mobileskills_call=1 if TDL2_1==3 | TDL2_1==4  //if person can dial numbers somewhat or very well
replace mobileskills_call=0 if TDL2_1==0 | TDL2_1==1 | TDL2_1==2 //if person never does this or does it very or somewhat poorly
la var mobileskills_call "person can dial numbers on their phone somewhat or very well (TDL2_1)"

//Texting - person can either send or respond to text messages
//gen mobileskills_text=.
//replace mobileskills_text=1 if TDL2_4==3 | TDL2_4==4 | TDL2_5==3 | TDL2_5==4 //if person can either send or respond to text messages somewhat or very well
//replace mobileskills_text=0	if (TDL2_4==0 | TDL2_4==1 | TDL2_4==2) & (TDL2_5==0 | TDL2_5==1 | TDL2_5==2) //if person can NEITHER send NOR respond to text messages somewhat or very well
//la var mobileskills_text "person can send and/or respond to text messages somewhat or very well (DL2_4, DL2_5)"

//count if (TDL2_4==3 | TDL2_4==4) & TDL2_5<3 //159 people can send text messages but cannot respond to text messages from other people -- these people still have a 1 for mobileskills_text

//Internet use
*MLL: combining the activities that would require internet access, because there isn't a specific variable for accessing internet
*includes Using social networks like Facebook or  Twitter; Posting pictures online, using Instagram; Watching video you downloaded on a phone; Listening to audio you download on a phone; Using a chatting apps such Whatsapp or Viber
//gen mobileskills_internet=.
//replace mobileskills_internet=1 if TDL2_8>=3 | TDL2_9>=3 | TDL2_10>=3 | TDL2_11>=3 | TDL2_13>=3
//replace mobileskills_internet=0	if TDL2_8<3 & TDL2_9<3 & TDL2_10<3 & TDL2_11<3 & TDL2_13<3 
//replace mobileskills_internet=. if TDL2_8==. & TDL2_9==. & TDL2_10==. & TDL2_11==. & TDL2_13==. 
//la var mobileskills_internet "person can use their phone to access internet somewhat or very well (TDL2_8,9,10,11,13"


/*
//Advanced Use - person can do ANY of the following somewhat or very well: compose and send picture messages, forward a text message, use social networks, post pictures online, watch video downloaded on phone, 
//listen to audio they downloaded, tune in to radio station, use chatting apps, follow text menu, follow interactive voice menu 
gen mobileskills_advanced=.
replace mobileskills_advanced=1 if TDL2_6>=3 | TDL2_7>=3 | TDL2_8>=3 | TDL2_9>=3 | TDL2_10>=3 | TDL2_11>=3 | TDL2_12>=3 | TDL2_13>=3 | TDL2_14>=3 | TDL2_15>=3 
replace mobileskills_advanced=0 if TDL2_6<3 & TDL2_7<3 & TDL2_8<3 & TDL2_9<3 & TDL2_10<3 & TDL2_11<3 & TDL2_11<3 & TDL2_12<3 & TDL2_13<3 & TDL2_14<3 & TDL2_15<3 
replace mobileskills_advanced=. if TDL2_6==. & TDL2_7==. & TDL2_8==. & TDL2_9==. & TDL2_10==. & TDL2_11==. & TDL2_11==. & TDL2_12==. & TDL2_13==. & TDL2_14==. & TDL2_15==.
la var mobileskills_advanced "person can perform advanced (i.e. access internet, take pictures) functions on phone somewhat or very well (TDL2_*)"

//This is a little weird - some people answered a 3 or 4 for an advanced skill but say they do not make phone calls and/or text....
count if (mobileskills_call==0 | mobileskills_text==0) & mobileskills_advanced==1 //49
*/


//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married official_id employed dfs_aware_spont dfs_aware_prompt dfs_aware_radio dfs_aware_tv 
	dfs_aware_billboard dfs_aware_newspaper dfs_aware_household dfs_aware_otherfam dfs_aware_friend dfs_aware_workmate 
	dfs_aware_cust dfs_aware_admin dfs_aware_bankemp dfs_aware_fingroup dfs_aware_agent dfs_aware_fieldagent dfs_aware_sms 
	dfs_aware_event dfs_aware_other dfs_adopt dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month dfs_lastuse_90days 
	dfs_lastuse_more90 dfs_regacct rec_remit ppi_cutoff literate numerate dfs_aware_name
;
#d cr

//Label generated variable values 0=no; 1=yes
foreach var of local yesnogen {
	label values `var' yesnovarsl
}

//Renaming female as 1="female" 0="male" 
label define femalel 0 "Male" 1 "Female"
label values female femalel

*********************************
** SAVE WITH RENAMED VARIABLES**
*********************************

save "R:\Project\EPAR\Working Files\317 - Gender and DFS Adoption\DTAs\W2\Indonesia_W1_Clean.dta", replace

