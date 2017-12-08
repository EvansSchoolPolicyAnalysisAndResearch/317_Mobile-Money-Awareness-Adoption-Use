/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Kenya Financial Inclusion Insights Wave 3 data set.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Financial Inclusion Insights Wave 3 data was collected by Intermedia 
*The data were collected over the period of June 2015 – October 2015.
*All the raw data, questionnaires, and basic information documents can be requested from Intermedia by clicking "contact InterMedia" at the following link
*http://finclusion.org/data_fiinder/


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Kenya Financial Inclusion Insights Wave 2 data set.
*After downloading the "FSP_Final_Kenya_W3 (public).xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FSP_Final_Kenya_W3 (public).xlsx", firstrow clear
save "filepath for location where you want to save dta file/Kenya_Wave3_Stata.dta", replace
clear

***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


*******
*Kenya*
*******
use "$input\Kenya_Wave3_Stata.dta"

*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
//Generate dummy variable for Kenya (for when appending to other files) 
gen Kenya=1 

//Wave dummy
gen wave=3

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************

//Location Variables
rename AA1 county
la var county "residential county of respondent"
rename AA7 urban_rural //1=urban, 2=rural
la var urban_rural "settlement size (AA7)"
	label define urban_rural1 1 "Urban" 2 "Rural" 
	label values urban_rural urban_rural1

rename rural_females rural_female
la var rural_female "female living in a rural area"
	label define rural_femalel 0 "Not Rural or Not Female" 1 "Female - rural"
	label values rural_female rural_femalel

//Other characteristics
rename DG1 yearborn
la var yearborn "year of birth (DG1)"

rename DG3 marital_status // created dummy var below
la var marital_status "person's marital status (DG3)"
	label define marital_statusl 1 "Single/never married" 2 "Polygamously married" /*
		*/ 3 "Monogamously married" 4 "Divorced" 5 "Separated" 6 "Widowed" 7 "Living together/cohabiting" /*
		*/ 8 "Other(specify)" 9 "DK/Refused"
	label values marital_status marital_statusl

rename DL1 employment_status //generated dummy var below
la var employment_status "employment status of individual (DL1)"
	label define employment_status1 1 "Full-time for regular salary" 2 "Part-time for regular salary" /*
	*/ 3 "Occassionally, irregular pay" 4 "Per season" 5 "Self-employed" 6 "Not working, looking" /*
	*/ 7 "Housewife" 8 "Full-time student" 9 "Not working retired" 10 "Not working sickness, disability" /*
	*/ 11 "Other" 12 "DK/Refused" 
	label values employment_status employment_status1

rename DL2 primary_job 
la var primary_job "individual's primary job (DL2)"
	label define primary_job1 1 "Farmer owner/farmer" 2 "Farm worker" 3 "Public or health service worker (non-prof)" 4 "Professional (i.e. doctor, teacher, nurse)" /*
		*/ 5 "Clerk" 6 "Carpenter/mason" 7 " Mechanic" 8 "Electrician" 9 "Cleaner/house help" 10 "Waiter/cook" 11 "Driver, including public transport" /* 
		*/ 12 "Tailor" 13 "Secretary" 14 "Manager" 15 "Watchman/security/caretaker" 16 "Messenger" 17 "Policeman/police reserve" 18 "Conductor" 19 "Factory employee" /*
		*/ 20 "Shop owner" 21 "Salesperson in a store" 22 "Street vendor/hawker (groceries, mboga,etc.)" 23 "Business owner (specify below)" 24 "Salonist" /*
		*/ 25 "Money lender" 26 "Landlord/landlady" 27 "Miner (gold, sand, coal, oil, etc.)" 28 "Military" 29 "Occasional worker with no occupation" /*
		*/ 30 "Other (specify in row)" 31 "Refused/prefer not to say"
	label values primary_job primary_job1
	
rename DL3 secondary_job 
la var secondary_job "do you have a secondary job (DL3)"

//Generate employment variable
gen employment=.
replace employment=1 if employment_status==1 | employment_status==2
replace employment=2 if employment_status==3 | employment_status==4 
replace employment=3 if employment_status==5 
replace employment=4 if employment_status==7
replace employment=5 if employment_status==6 | employment_status==8 | employment_status==9 | employment_status==10
	label define employment1 1 "Full or part-time" 2 "Occasional or seasonal" 3 "Self-employed" 4 "Non-wage labor" 5 "Not working"
	label values employment employment1

//Number of persons in the household 
gen n_household=.
replace n_household=(DG8a+DG8b+DG8c)
la var n_household "number of persons in the HH, including adults and children (DG8a - c)"
tab n_household, missing

//Education and literacy
rename DG4 highest_ed 
la var highest_ed "highest level of education  (DG4)"
	label define highest_edl 1 "No formal education" 2 "Primary education not complete" 3 "Primary education complete" /*
		*/ 4 "Some secondary" 5 "Secondary education complete" 6 "Some secondary vocational training/some certificate" /*
		*/ 7 "Secondary vocational training or certificate complete" 8 "Some diploma" 9 "Diploma complete" 10 "Some college/university" /* 
		*/ 11 "Complete university degree" 12 "Post-graduate university degree" 13 "Koranic school" 14 "Other (specify)" 15 "DK/Refused"
	label values highest_ed highest_edl

//Level of education - standardized variable to be used in the regression model	
gen ed_level=.
replace ed_level=1 if highest_ed==1 
replace ed_level=2 if highest_ed==2 | highest_ed==3 
replace ed_level=3 if highest_ed==4 | highest_ed==5 | highest_ed==6 | highest_ed==7
replace ed_level=4 if highest_ed==8 | highest_ed==9 | highest_ed==10 | highest_ed==11 | highest_ed==12
label define ed_level1 1 "No formal" 2 "Primary" 3 "Secondary" 4 "Higher education"
	label values ed_level ed_level1
	
//Completed any education above primary school
//No=no formal education, informal only, primary incomplete, Koranic school, or primary complete
gen above_prim=.
replace above_prim=0 if highest_ed==1 | highest_ed==2 | highest_ed==3 | highest_ed==13
replace above_prim=1 if above_prim!=0 & highest_ed!=14 &highest_ed!=15
la var above_prim "Highest level of edu is primary"
	label define above_prim1 0 "Primary or lower" 1 "Above primary"
	label values above_prim above_prim1

rename Numeracy numerate
la var numerate "person has basic numeracy"
rename Literacy literate
la var literate "person has basic literacy"

//Mobile phone and bank ownership and access
rename MT2 phone_own
la var phone_own "person owns a mobile phone (MT2)"
rename MT7 phone_access
la var phone_access "person uses mobile phone belonging to someone else by borrowing or paying for its use (MT7)"
rename MT10 sim_own
la var sim_own "person owns an active/working sim card (MT10)"
rename MT15 sim_access
la var sim_access "person uses sim card belonging to someone else (MT15)"

rename FF1 bank_own
la var bank_own "person has bank account registered in their name (FF1)"
rename FF3 reason_nobankacct 
la var reason_nobankacct "reason person does not have bank account (FF3)"
	label define reason_nobankacctl 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state-issued/national ID or other req. docs" /*
		*/ 4 "There are no banks close to where I live" 5 "I do not have money" 6 "I do not need one, I do not make any transactions" /*
		*/ 7 "Registration paperwork is too complicated" 8 "Registration fee is too high" 9 "Using a bank account is difficult" 10 "Fees for using a bank account are too high" /*
		*/ 11 "I do not have money to make any transactions with such an account" 12 "No one among my friends or family has such account" /*
		*/ 13 "I do not understand the purpose of such account, i do not know what I can use it for" 14 "A bank has agents but they are not accessible" /*
		*/ 15 "Banks are not reliable" 16 "Banks do not offer the services I need" 17 "Bank staff/agents are unfriendly; they make me feel unwelcome" /*
		*/ 18 "I can't afford the minimum balance" 19 "Bank hours are not convenient for me" 20 "I never thought about using a bank" /*
		*/ 21 "I do not trust banks/that my money is safe in a bank" 22 "I would rather have my money close to me" 23 "I use mobile money" /*
		*/ 24 "I don't have time to go to the bank" 25 "I use somebody else's account" 26 "My husband, family, in-laws do not approve of me having a bank account" /*
		*/ 27 "I will not be able to go to a bank on my own" 28 "It's not approved by my religion" 29 "Other" 30 "DK/Refused"
	label values reason_nobankacct reason_nobankacctl

rename FF4 bank_access
la var bank_access "person uses someone else's bank account (FF4)"

//Digital Financial Services / Mobile Money

*General awareness of concept of mobile money
rename MM1 dfs_aware_gen //1=yes, 2=no
la var dfs_aware_gen "person has heard of Mobile Money (MM1)"

*Reasons for using/not using DFS
rename MM12 dfs_reasonnouse 
la var dfs_reasonnouse "main reason for never having used DFS (MM12)"
destring dfs_reasonnouse, replace
	label define dfs_reasonnousel 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state ID or other req. docs" /*
		*/ 4 "There is no point-of-service/agent close to where I live" 5 "I do not need one, I do not make any transactions" 6 "Registration paperwork is too complicated" /*
		*/ 7 "Registration fee is too high" 8 "Using such account is difficult" 9 "Fees for using this service are too high" /*
		*/ 10 "I never have money to make transactions with this service" 11 "No one among my friends or family use this service" /*
		*/ 12 "I do not understand this service/ I do not know what I can use it for" 13 "I do not have a smartphone" /*
		*/ 14 "I do not trust that my money is safe on mobile money" 15 "My husband/family/in-laws do not approve of me having an m-money account" /*
		*/ 16 "It is against my religion" 17 "I don't use because all agents are men" /*
		*/ 18 "Mobile money does not provide anything better/any advantage over financial systems I currently use" 19 "Other(specify)"
	label values dfs_reasonnouse dfs_reasonnousel

*Reasons for not registering for DFS
rename MM13 dfs_reasonnoreg
la var dfs_reasonnoreg "main reason for not signing up for an acct despite using DFS (MM13)"
	label define dfs_reasonnoregl 1 "I do not have a state ID or other req. docs" 2 "There is no point-of-service/agent close to where I live" /*
		*/ 3 "I do not need to, I do not make any transactions" 4 "Using such an account is difficult" 5 "Fees for using such account are too high" /*
		*/ 6 "I never have money to make a transaction with such account" 7 "No one among my friends or family has such account" /*
		*/ 8 "I do not understand the purpose of this account, I don't know what I can use it for" 9 "I can have all the services through an agent, I do not need an account" /*
		*/ 10 "Registration fees are too high" 11 "I prefer that agents perform transactions for me, they will fix the problems if anything happens" /*
		*/ 12 "I do not trust my money is safe on an m-money account" 13 "I prefer to keep money in cash and use m-money only to send/receive money" /*
		*/ 14 "I have heard of fraud on mobile money" 15 "Agent can help me use the service/I do not know how to use it on my own" /*
		*/ 16 "I do not see any additional advantages to registration" 17 "Someone in my family has an account" 18 "Other (specify)"
	label values dfs_reasonnoreg dfs_reasonnoregl

*Reasons for starting to use DFS
rename MM14	dfs_reasonstart 
la var dfs_reasonstart "reason for starting to use DFS (MM14)"
destring dfs_reasonstart, replace
	label define dfs_reasonstartl 1 "I had to send money to another person" 2 "I had to receive money from another person" 3 "Somebody/a person requested I open an account" /*
		*/ 4 "I had to send money to an org/govt. agency: e.g. had to pay a bill" 5 "I had to receive money from an org/govt. agency: e.g. unemployment payment or welfare benefits" /*
		*/ 6 "An organization/govt. agency requested I sign up for an account" 7 "An agent or sales person convinced me" /*
		*/ 8 "I saw posters/billboards/radio/TV advertising that convinced me" 9 "A person I know who uses mobile money, recommended I use it because it is better than other financial..."/*
		*/ 10 "I saw other people using it and wanted to try by myself" 11 "I wanted to start saving money with an m-money account" /*
		*/ 12 "I wanted a safe place to store my money" 13 "I got a discount on airtime" 14 "I got a promotional amount of money to spend if I start using m-money" /*
		*/ 15 "Most of my friends/family members are already using it" 16 "Other (specify)"
	label values dfs_reasonstart dfs_reasonstartl


**Uses of DFS
rename MM15_1 dfs_deposit
la var dfs_deposit "person has used DFS to deposit money (MM15_1)"
rename MM15_2 dfs_withdraw
la var dfs_withdraw "person has used DFS to withdraw money (MM15_2)"
rename MM15_3 dfs_airtime
la var dfs_airtime "person has used DFS to buy airtime top-ups (MM15_3)"
rename MM15_4 dfs_payschool
la var dfs_payschool "person has used DFS to pay school fees (MM15_4)"
rename MM15_5 dfs_paymed
la var dfs_paymed "person has used DFS to pay medical bills (MM15_5)"
rename MM15_6 dfs_payelectric
la var dfs_payelectric "person has used DFS to pay electric bills (MM15_6)"
rename MM15_7 dfs_paywater
la var dfs_paywater "person has used DFS to pay for water access or delivery (MM15_7)"
rename MM15_8 dfs_paysolar
la var dfs_paysolar "person has used DFS to pay for solar lamp/solar home system (MM15_8)"
rename MM15_9 dfs_paytv
la var dfs_paytv "person has used DFS to pay a TV/cable/satellite bill (MM15_9)"
rename MM15_10 dfs_paygov
la var dfs_paygov "person has used DFS to pay a government bill, incl. tax, fine, fee (MM15_10)"
rename MM15_11 dfs_payfam_reg
la var dfs_payfam_reg "person has used DFS to send money to fam/friends for reg support or emergency (MM15_11)"
rename MM15_12 dfs_recfam_reg
la var dfs_recfam_reg "person has used DFS to receive money to fam/friends for reg support or emergency (MM15_12)"
rename MM15_13 dfs_recgov_welfpen
la var dfs_recgov_welfpen "person has used DFS to receive welfare or pension from gov (MM15_13)"
rename MM15_14 dfs_recwage
la var dfs_recwage "person has used DFS to receive wages from primary job (MM15_14)"
rename MM15_15 dfs_paylarge
la var dfs_paylarge "person has used DFS to pay for large acquisitions (MM15_15)"
rename MM15_16 dfs_payins
la var dfs_payins "person has used DFS to make insurance pmts (MM15_16)"
rename MM15_17 dfs_takeloan
la var dfs_takeloan "person has used DFS to take a loan, make payment on loan, give loan (MM15_17)"
rename MM15_18 dfs_savepurchase
la var dfs_savepurchase "person has used DFS to save for future purchases (MM15_18)"
rename MM15_19 dfs_savepen
la var dfs_savepen "person has used DFS to save for pensions (MM15_19)"
rename MM15_20 dfs_saveunknown
la var dfs_saveunknown "person has used DFS to set aside money just in case (MM15_20)"
rename MM15_21 dfs_invest
la var dfs_invest "person has used DFS to invest (MM15_21)"
rename MM15_22 dfs_paystore
la var dfs_paystore "person has used DFS to pay for goods at a store (MM15_22)"
rename MM15_23 dfs_transferacct
la var dfs_transferacct "person has used DFS to transfer btwn MM acts (MM15_23)"
rename MM15_24 dfs_transferbank
la var dfs_transferbank "person has used DFS to transfer btwn bank and MM acts (MM15_24)"
rename MM15_25 dfs_transferother
la var dfs_transferother "person has used DFS to transfer btwen MM act and act at other fin institution (MM15_25)"
rename MM15_26 dfs_savings
la var dfs_transferother "person has used DFS to pay or reveive money from savings/lending group (MM15_26)"
rename MM15_27 dfs_rent
la var dfs_rent "person has used DFS to pay rent (MM15_27)"
rename MM15_28 dfs_maint
la var dfs_maint "person has used DFS for account maintenance (MM15_28)"
rename MM15_29 dfs_other
la var dfs_other "person has used DFS for other (MM15_29)"

rename MM22_1 dfs_bus_none
la var dfs_bus_none "person does not use DFS for business transactions (MM22_1)"
rename MM22_2 dfs_bus_payemp
la var dfs_bus_payemp "person has used DFS to pay employees (MM22_2)"
rename MM22_3 dfs_bus_paysup
la var dfs_bus_paysup "person has used DFS to pay suppliers (MM22_3)"
rename MM22_4 dfs_bus_recpaycust
la var dfs_bus_recpaycust "person has used DFS to receive pmts from customers (MM22_4)"
rename MM22_5 dfs_bus_recpaydist
la var dfs_bus_recpaydist "person has used DFS to receive pmts from distributors (MM22_5)"
rename MM22_6 dfs_bus_invest
la var dfs_bus_invest "person has used DFS to invest in business (MM22_6)"
rename MM22_7 dfs_bus_payexp
la var dfs_bus_payexp "person has used DFS to pay other bus related expenses (i.e.rent) (MM22_7)"
rename MM22_8 dfs_bus_ag
la var dfs_bus_ag "person has used DFS to pay for ag inputs (MM22_8)"
rename MM22_9 dfs_bus_other
la var dfs_bus_other "person has used DFS for other business pmts/transactions(MM22_9)"


**Agent used
rename MM33 dfs_agent_same
la var dfs_agent_same "person tends to use same MM agent most of the time (MM33)"

rename MM34 dfs_agentsame_reason 
la var dfs_agentsame_reason "reason person uses same MM agent regularly (MM34)"
	label define dfs_agentsame_reasonl 1 "Out of courtesy" 2 "The agent is fast" 3 "I trust this agent" 4 "Reliability: the agent is always present during work hours" /*
		*/ 5 "Reliability: the agent always has e-float and/or cash to help with my transaction" 6 "Proximity to where I live" /*
		*/ 7 "Proximity to places where I go to school, retail store, my job, etc." 8 " Agent is knowledgeable/helpful" 9 "Agent is friendly & engaged" /*
		*/ 10 "This agent is my personal friend, family member, or relative" 11 "My family members, friends or workmates use this agent" /*
		*/ 12 "Out of habit" 13 "Other (specify)" 14 "Because the agent is a female" 15 "Because the agent is a male" /*
		*/ 16 "Agent was recommended to me" 17 "Agent's place is safe/secure" 18 "No particular reason"
	label values dfs_agentsame_reason dfs_agentsame_reasonl

**Transport to agent - questions eliminated in W3

**Have you ever experienced any of the following issues with an agent?
rename MM38_1 dfs_agentiss_absent
la var dfs_agentiss_absent "agent issue: agent was absent (MM38_1)"
rename MM38_2 dfs_agentiss_rude
la var dfs_agentiss_rude "agent issue: agent was rude (MM38_2)"
rename MM38_3 dfs_agentiss_nocash
la var dfs_agentiss_nocash "agent issue: agent didn't have enough cash or e-float (MM38_3)"
rename MM38_4 dfs_agentiss_refuse
la var dfs_agentiss_refuse "agent issue: agent refused to perform transaction (MM38_4)"
rename MM38_5 dfs_agentiss_noknow
la var dfs_agentiss_noknow "agent issue: agent didn't know how to perform trans (MM38_5)"
rename MM38_6 dfs_agentiss_overcharge
la var dfs_agentiss_overcharge "agent issue: agent overchareged or asked for deposit (MM38_6)"
rename MM38_7 dfs_agentiss_wrongcash
la var dfs_agentiss_wrongcash "agent issue: agent didn't give all cash owed (MM38_7)"
rename MM38_8 dfs_agentiss_netdown
la var dfs_agentiss_netdown "agent issue: mobile network down (MM38_8)"
rename MM38_9 dfs_agentiss_agsysdown
la var dfs_agentiss_agsysdown "agent issue: agent system down (MM38_9)"
rename MM38_10 dfs_agentiss_notime
la var dfs_agentiss_notime "agent issue: transaction too time consuming (MM38_10)"
rename MM38_11 dfs_agentiss_noreceipt
la var dfs_agentiss_noreceipt "agent issue: didn't get receipt (MM38_11)"
rename MM38_12 dfs_agentiss_chargedep
la var dfs_agentiss_chargedep "agent issue: agent charged for depositing money (MM38_12)"
rename MM38_13 dfs_agentiss_pin
la var dfs_agentiss_pin "agent issue: agent asked for PIN (MM38_13)"
rename MM38_14 dfs_agentiss_women
la var dfs_agentiss_women "agent issue: agent dismissive of women (MM38_14)"
rename MM38_15 dfs_agentiss_fraud
la var dfs_agentiss_fraud "agent issue: agent committed fraud (MM38_15)"
rename MM38_16 dfs_agentiss_insecure
la var dfs_agentiss_insecure "agent issue: place not secure, suspicious people (MM38_16)"
rename MM38_17 dfs_agentiss_shareinfo
la var dfs_agentiss_shareinfo "agent issue: agent shared info with other people (MM38_17)"
rename MM38_18 dfs_agentiss_scam
la var dfs_agentiss_scam "agent issue: agent assisted others in defrauding or scamming (MM38_18)"
rename MM38_19 dfs_agentiss_id
la var dfs_agentiss_id "agent issue: agent assisted others in defrauding or scamming (MM38_19)"
rename MM38_20 dfs_agentiss_other
la var dfs_agentiss_other "agent issue: other(MM38_20)"

rename MM41 dfs_prob_who
la var dfs_prob_who "when an MM transaction goes wrong, who do you go to to help you resolve it? (MM41)"

//recode renamed dummy variables to be 0=no and 1=yes

recode phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw /*
*/dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paytv /*
*/dfs_paygov dfs_payfam_reg dfs_recfam_reg dfs_recgov_welfpen secondary_job /*
*/dfs_recwage dfs_paylarge dfs_payins dfs_takeloan dfs_savepurchase dfs_savepen /*
*/dfs_saveunknown dfs_invest dfs_paystore dfs_transferacct dfs_transferbank dfs_transferother dfs_rent /*
*/dfs_bus_payemp dfs_bus_paysup dfs_bus_recpaycust dfs_bus_recpaydist dfs_bus_invest dfs_bus_payexp dfs_bus_ag dfs_bus_other /*
*/dfs_bus_none dfs_agent_same dfs_agentiss_absent dfs_agentiss_rude dfs_agentiss_nocash dfs_agentiss_refuse /*
*/dfs_agentiss_noknow dfs_agentiss_overcharge dfs_agentiss_wrongcash dfs_agentiss_netdown dfs_agentiss_agsysdown dfs_agentiss_notime /*
*/dfs_agentiss_noreceipt dfs_agentiss_chargedep dfs_agentiss_pin dfs_agentiss_women dfs_agentiss_fraud dfs_agentiss_insecure /*
*/dfs_agentiss_shareinfo dfs_agentiss_scam dfs_agentiss_id dfs_agentiss_other (2=0)

#d ;
local yesnorename phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw 
	dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paysolar dfs_paytv 
	dfs_paygov dfs_payfam_reg dfs_recfam_reg dfs_recgov_welfpen secondary_job
	dfs_recwage dfs_paylarge dfs_payins dfs_takeloan dfs_savepurchase dfs_savepen
	dfs_saveunknown dfs_invest dfs_paystore dfs_transferacct dfs_transferbank dfs_transferother dfs_rent 
	dfs_bus_payemp dfs_bus_paysup dfs_bus_recpaycust dfs_bus_recpaydist dfs_bus_invest dfs_bus_payexp dfs_bus_ag dfs_bus_other 
	dfs_bus_none dfs_agent_same dfs_agentiss_absent dfs_agentiss_rude dfs_agentiss_nocash dfs_agentiss_refuse 
	dfs_agentiss_noknow dfs_agentiss_overcharge dfs_agentiss_wrongcash dfs_agentiss_netdown dfs_agentiss_agsysdown dfs_agentiss_notime 
	dfs_agentiss_noreceipt dfs_agentiss_chargedep dfs_agentiss_pin dfs_agentiss_women dfs_agentiss_fraud dfs_agentiss_insecure 
	dfs_agentiss_shareinfo dfs_agentiss_scam dfs_agentiss_other
;
#d cr

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

**OTC AGENT SEX //Is your regular agent a male or a female?
gen dfs_agent_sex=.
replace dfs_agent_sex=1 if MM35==2
replace dfs_agent_sex=0 if MM35==1
la var dfs_agent_sex "sex of OTC agent (MM35)"

**RURAL
gen rural=.
replace rural=1 if urban_rural==2
replace rural=0 if urban_rural==1
la var rural "person lives in a rural area (AA7)"

**MARRIED (if monogomously or polygomously married - does not include widowed, divorced, etc.)
gen married=.
replace married=1 if marital_status==2 | marital_status==3
replace married=0 if marital_status!=2 & marital_status!=3
la var married "person is monogomously or polygomously married (DG3)"

**OFFICIAL ID (if answered yes to any type of official id; verify if we need to exclude any types)
gen official_id=.
replace official_id=1 if DG5_1 ==1 | DG5_2==1 | DG5_3==1 | DG5_4==1 | DG5_5==1 | DG5_6==1 | DG5_7==1 | DG5_8==1 | DG5_9==1 | DG5_10==1 
replace official_id=0 if DG5_1==2 & DG5_2==2 & DG5_3==2 & DG5_4==2 & DG5_5==2 & DG5_6==2 & DG5_7==2 & DG5_8==2 & DG5_9==2 & DG5_10==2 
la var official_id "has any type of official identification (DG5_1 to DG5_10)"

**EMPLOYED (if working full or part time for a regular salary, self-employed, or working occasionally, irregular pay)
gen employed=.
replace employed=1 if employment_status <=5 
replace employed=0 if employment_status >=6
la var employed "person works full-time, part-time, irregularly, or is self-employed (DL1)"

**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if MM2_1==1 | MM2_2==1 | MM2_3==1 | MM2_4==1 | MM2_5==1 | MM2_6==1 | MM2_7==1 | MM2_8==1
replace dfs_aware_spont=0 if  MM2_1!=1 & MM2_2!=1 & MM2_3!=1 & MM2_4!=1 & MM2_5!=1 & MM2_6!=1 & MM2_7!=1 & MM2_8!=1
replace dfs_aware_spont=. if dfs_aware_gen==0
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM2_1-8)"

**PROMPTED RECALL of DFS providers - only asked for providers not spontaneously recalled
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if MM3_1==1 | MM3_2==1 | MM3_3==1 | MM3_4==1 | MM3_5==1 | MM3_6==1 | MM3_7==1
replace dfs_aware_prompt=0 if MM3_1==2 & MM3_2==2 & MM3_3==2 & MM3_4==2 & MM3_5==2 & MM3_6==2 & MM3_7==2
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM3_1-7)"

**Was able to spontaneously or prompted recall a MM provider
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_spont==1 | dfs_aware_prompt==1
replace dfs_aware_name=0 if dfs_aware_name!=1

**SOURCE OF INFORMATION FROM WHICH THEY LEARNED ABOUT DFS - section eliminated in W3

**EVER USED DFS
**Question: Have you ever used this mobile money service for any financial activity? (one question for each DFS provider, combining them to find out if they have ever used any DFS service)
//Note: this code differs from other countries because of missing data (people who had not used the service and were aware of it were not always coded as "No")
gen dfs_adopt=.
replace dfs_adopt=1 if MM4_1==1 | MM4_2==1 | MM4_3==1 | MM4_4==1 | MM4_5==1 | MM4_6==1 | MM4_7==1 | MM4_8==1
replace dfs_adopt=0 if dfs_adopt!=1 & dfs_aware_name==1
replace dfs_adopt=. if dfs_aware_name==0
la var dfs_adopt "person has ever used DFS for any financial activity (MM4_1-8)"

**LAST USED DFS
//Question: Apart from today, when was the last time you conducted any financial activity with this mobile money service?
//One question for each DFS provider, so we are combining them to find out the last time individual used any of the DFS services
//Only including most recent use for each person

gen dfs_lastuse_yest=.
replace dfs_lastuse_yest=1 if MM8_1==1 | MM8_2==1 | MM8_3==1 | MM8_4==1 | MM8_5==1 | MM8_6==1 | MM8_7==1 
replace dfs_lastuse_yest=0 if MM8_1!=1 & MM8_2!=1 & MM8_3!=1 & MM8_4!=1 & MM8_5!=1 & MM8_6!=1 & MM8_7!=1 
replace dfs_lastuse_yest=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. & MM8_7==. 
la var dfs_lastuse_yest "person used DFS yesterday (MM8_1-7)"

gen dfs_lastuse_week=.
replace dfs_lastuse_week=1 if MM8_1==2 | MM8_2==2 | MM8_3==2 | MM8_4==2 | MM8_5==2 | MM8_6==2 | MM8_7==2 
replace dfs_lastuse_week=0 if (MM8_1!=2 & MM8_2!=2 & MM8_3!=2 & MM8_4!=2 & MM8_5!=2 & MM8_6!=2 & MM8_7!=2) | dfs_lastuse_yest==1
replace dfs_lastuse_week=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. 
la var dfs_lastuse_week "person used DFS in the past 7 days (MM8_1-7)"

gen dfs_lastuse_month=.
replace dfs_lastuse_month=1 if MM8_1==3 | MM8_2==3 | MM8_3==3 | MM8_4==3 | MM8_5==3 | MM8_6==3 | MM8_7==3 
replace dfs_lastuse_month=0 if (MM8_1!=3 & MM8_2!=3 & MM8_3!=3 & MM8_4!=3 & MM8_5!=3 & MM8_6!=3 & MM8_7!=3) | dfs_lastuse_yest==1 | dfs_lastuse_week==1
replace dfs_lastuse_month=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. & MM8_7==.
la var dfs_lastuse_month "person used DFS in the past 30 days (MM8_1-7)"

gen dfs_lastuse_90days=.
replace dfs_lastuse_90days=1 if MM8_1==4 | MM8_2==4 | MM8_3==4 | MM8_4==4 | MM8_5==4 | MM8_6==4 | MM8_7==4 
replace dfs_lastuse_90days=0 if (MM8_1!=4 & MM8_2!=4 & MM8_3!=4 & MM8_4!=4 & MM8_5!=4 & MM8_6!=4 & MM8_7!=4) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1
replace dfs_lastuse_90days=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. & MM8_7==.
la var dfs_lastuse_90days "person used DFS in the past 90 days (MM8_1-7)"

gen dfs_lastuse_more90=.
replace dfs_lastuse_more90=1 if MM8_1==5 | MM8_2==5 | MM8_3==5 | MM8_4==5 | MM8_5==5 | MM8_6==5 | MM8_7==5
replace dfs_lastuse_more90=0 if (MM8_1!=5 & MM8_2!=5 & MM8_3!=5 & MM8_4!=5 & MM8_5!=5 & MM8_6!=5 & MM8_7!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. & MM8_7==.
la var dfs_lastuse_more90 "person last used DFS more than 90 days ago (MM8_1-7)"

//Removed dfs_lastuse-never bc respondent # is lower than for dfs_adopt (larger sample, same question)

//Generating dfs_use categorical variable
egen dfs_use=rowmin(MM5_*)
replace dfs_use=. if dfs_adopt!=1
tab dfs_use
la var dfs_use "When did you last use MM?"
label define dfs_use1 1 "Yesterday" 2 "Less than a Week" 3 "Less than a Month" 4 "Less than 90 Days" 5 "More than 90 Days"
label values dfs_use dfs_use1

//FREQUENCY OF DFS USE
egen dfs_freq=rowmin(MM17_*)
replace dfs_freq=. if dfs_adopt!=1
tab dfs_freq
la var dfs_freq "How often do you use mobile money?"
label define dfs_freq1 1 "Daily" 2 "Weekly" 3 "Once every 15 days" 4 "Monthly" 5 "Once every 3 months" 6 "Once every 6 months" 7 "Once a year" 8 "Almost never"
label values dfs_freq dfs_freq1

**REGISTERED ACCOUNT
//Question: Do you have a registered account (account registered in your name) with this mobile money service?
//One question for each DFS provider, so we are combining them 
gen dfs_regacct=.
replace dfs_regacct=1 if MM6_1==1 | MM6_2==1 | MM6_3==1 | MM6_4==1 | MM6_5==1 | MM6_6==1 | MM6_7==1
replace dfs_regacct=0 if MM6_1!=1 & MM6_2!=1 & MM6_3!=1 & MM6_4!=1 & MM6_5!=1 & MM6_6!=1 & MM6_7!=1
replace dfs_regacct=. if MM6_1==. & MM6_2==. & MM6_3==. & MM6_4==. & MM6_5==. & MM6_6==.
la var dfs_regacct "person has a registered account with any DFS provider (MM6_1-7)"

**HOW DO YOU ACCESS DFS
//How do you usually access this mobile money service?
//One question for each DFS provider, so we are combining them 

//ADD ATM TO THIS

//Over the counter or by using an agent’s account
gen dfs_access_otc=.
replace dfs_access_otc=1 if MM11_1_1==1 | MM11_2_1==1 | MM11_3_1==1 | MM11_4_1==1 | MM11_5_1==1 | MM11_6_1==1 | MM11_7_1==1 | MM11_8_1==1
replace dfs_access_otc=0 if MM11_1_1!=1 & MM11_2_1!=1 & MM11_3_1!=1 & MM11_4_1!=1 & MM11_5_1!=1 & MM11_6_1!=1 & MM11_7_1!=1 & MM11_8_1!=1
replace dfs_access_otc=. if MM11_1_1==. & MM11_2_1==. & MM11_3_1==. & MM11_4_1==. & MM11_5_1==. & MM11_6_1==. & MM11_7_1==. & MM11_8_1==.
la var dfs_access_otc "person usually accesses DFS over the counter (MM11_1_1 to 15_8_1)"

//Account of a family member in this household
gen dfs_access_fam=.
replace dfs_access_fam=1 if MM11_1_2==1 | MM11_2_2==1 | MM11_3_2==1 | MM11_4_2==1 | MM11_5_2==1 | MM11_6_2==1 | MM11_7_2==1 | MM11_8_2==1
replace dfs_access_fam=0 if MM11_1_2!=1 & MM11_2_2!=1 & MM11_3_2!=1 & MM11_4_2!=1 & MM11_5_2!=1 & MM11_6_2!=1 & MM11_7_2!=1 & MM11_8_2!=1
replace dfs_access_fam=. if MM11_1_2==. & MM11_2_2==. & MM11_3_2==. & MM11_4_2==. & MM11_5_2==. & MM11_6_2==. & MM11_7_2==. & MM11_8_2==.
la var dfs_access_fam "person usually accesses DFS from a family member's acct in the hh (MM11_1_2 to 15_8_2)"

//Account of a family member in another household, other relative, friend or a neighbor
gen dfs_access_nonhh=.
replace dfs_access_nonhh=1 if MM11_1_3==1 | MM11_2_3==1 | MM11_3_3==1 | MM11_4_3==1 | MM11_5_3==1 | MM11_6_3==1 | MM11_7_3==1 | MM11_8_3==1
replace dfs_access_nonhh=0 if MM11_1_3!=1 & MM11_2_3!=1 & MM11_3_3!=1 & MM11_4_3!=1 & MM11_5_3!=1 & MM11_6_3!=1 & MM11_7_3!=1 & MM11_8_3!=1
replace dfs_access_nonhh=. if MM11_1_3==. & MM11_2_3==. & MM11_3_3==. & MM11_4_3==. & MM11_5_3==. & MM11_6_3==. & MM11_7_3==. & MM11_8_3==.
la var dfs_access_nonhh "person usually accesses DFS from a family member in another hh, friend, or neib (MM11_1_3 to 15_8_3)"

//Account of a workmate or a business partner 
gen dfs_access_work=.
replace dfs_access_work=1 if MM11_1_4==1 | MM11_2_4==1 | MM11_3_4==1 | MM11_4_4==1 | MM11_5_4==1 | MM11_6_4==1 | MM11_7_4==1 | MM11_8_4==1
replace dfs_access_work=0 if MM11_1_4!=1 & MM11_2_4!=1 & MM11_3_4!=1 & MM11_4_4!=1 & MM11_5_4!=1 & MM11_6_4!=1 & MM11_7_4!=1 & MM11_8_4!=1
replace dfs_access_work=. if MM11_1_4==. & MM11_2_4==. & MM11_3_4==. & MM11_4_4==. & MM11_5_4==. & MM11_6_4==. & MM11_7_4==. & MM11_8_4==.
la var dfs_access_work "person usually accesses DFS from a workmate or business partner (MM11_1_4 to 15_8_4)" 

//Their own account
gen dfs_access_ownacct=.
replace dfs_access_ownacct=1 if MM11_1_5==1 | MM11_2_5==1 | MM11_3_5==1 | MM11_4_5==1 | MM11_5_5==1 | MM11_6_5==1 | MM11_7_5==1 | MM11_8_5==1
replace dfs_access_ownacct=0 if MM11_1_5!=1 & MM11_2_5!=1 & MM11_3_5!=1 & MM11_4_5!=1 & MM11_5_5!=1 & MM11_6_5!=1 & MM11_7_5!=1 & MM11_8_5!=1
replace dfs_access_ownacct=. if MM11_1_5==. & MM11_2_5==. & MM11_3_5==. & MM11_4_5==. & MM11_5_5==. & MM11_6_5==. & MM11_7_5==. & MM11_8_5==.
la var dfs_access_ownacct "person usually accesses DFS from their own account (MM11_1_5 to 15_8_5)"

//ATM
gen dfs_access_atm=.
replace dfs_access_atm=1 if MM11_1_6==1 | MM11_2_6==1 | MM11_3_6==1 | MM11_4_6==1 | MM11_5_6==1 | MM11_6_6==1 | MM11_7_6==1 | MM11_8_6==1
replace dfs_access_atm=0 if MM11_1_6!=1 & MM11_2_6!=1 & MM11_3_6!=1 & MM11_4_6!=1 & MM11_5_6!=1 & MM11_6_6!=1 & MM11_7_6!=1 & MM11_8_6!=1
replace dfs_access_atm=. if MM11_1_6==. & MM11_2_6==. & MM11_3_6==. & MM11_4_6==. & MM11_5_6==. & MM11_6_6==. & MM11_7_6==. & MM11_8_6==.
la var dfs_access_atm "person usually accesses DFS via atm (MM11_1_6 to 15_8_6)"

//Other
gen dfs_access_other=.
replace dfs_access_other=1 if MM11_1_7==1 | MM11_2_7==1 | MM11_3_7==1 | MM11_4_7==1 | MM11_5_7==1 | MM11_6_7==1 | MM11_7_7==1 | MM11_8_7==1
replace dfs_access_other=0 if MM11_1_7!=1 & MM11_2_7!=1 & MM11_3_7!=1 & MM11_4_7!=1 & MM11_5_7!=1 & MM11_6_7!=1 & MM11_7_7!=1 & MM11_8_7!=1
replace dfs_access_other=. if MM11_1_7==. & MM11_2_7==. & MM11_3_7==. & MM11_4_7==. & MM11_5_7==. & MM11_6_7==. & MM11_7_7==. & MM11_8_7==.
la var dfs_access_other "person usually accesses DFS in an other way (MM11_1_7 to 15_8_7)"


//Remittances
count if DL4_5==1 //Which of the following ways did you get money in the past 12 mos.? 5=Money from fam, friends for regular support or emergencies.
count if DL5==5 //Which of these brought you the most money in the past 12 mos.?

gen rec_remit=.
replace rec_remit=1 if DL4_5==1 
replace rec_remit=0 if DL4_5==2 
la var rec_remit "person receives remittances (DL4_5)"
tab rec_remit //% of population that receives remittances

gen remit_main=.
replace remit_main=1 if DL5==5
replace remit_main=0 if DL5!=5 & DL5!=.
tab remit_main

**COMFORT/SKILL WITH MOBILE TECHNOLOGY - Section eliminated in W3

//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married official_id employed dfs_aware_spont dfs_aware_prompt dfs_aware_name
	dfs_adopt dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month dfs_lastuse_90days 
	dfs_lastuse_more90 dfs_regacct dfs_access_otc dfs_access_fam dfs_access_nonhh dfs_access_work 
	dfs_access_ownacct dfs_access_other rec_remit remit_main ppi_cutoff literate numerate
;
	#d cr

//Label generated variable values 0=no; 1=yes
foreach var of local yesnogen {
	label values `var' yesnovarsl
}

//Renaming female as 1="female" 0="male" 
label define femalel 0 "Male" 1 "Female"
label values female femalel

//Renaming dfs_agent_sex as 1="female" 0="male" 
label define dfs_agent_sexl 0 "Male" 1 "Female"
label values dfs_agent_sex dfs_agent_sexl

*********************************
** SAVE WITH RENAMED VARIABLES**
*********************************
save "$output\Kenya_W3_Clean.dta", replace


