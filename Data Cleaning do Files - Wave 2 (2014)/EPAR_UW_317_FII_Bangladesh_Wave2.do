/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Bangladesh Financial Inclusion Insights Wave 2 data set.
				  
*Author(s)		: Caitlin O'Brien Carrelli, Matthew Fowle, Jack Knauer

*Date			: 5 December 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Financial Inclusion Insights Wave 2 data was collected by Intermedia 
*The data were collected over the period of September 2014-December 2014.
*All the raw data, questionnaires, and basic information documents can be requested from Intermedia by clicking "contact InterMedia" at the following link
*http://finclusion.org/data_fiinder/


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Bangladesh Financial Inclusion Insights Wave 2 data set.
*After downloading the "FSP_Final_Bangladesh_w2_10162014(public).xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FSP_Final_Bangladesh_w2_10162014(public).xlsx", firstrow
save "filepath for location where you want to save dta file/Bangladesh_Wave2_Stata.dta", replace
clear


***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


************
*BANGLADESH*
************
use "$input\Bangladesh_Wave2_Stata.dta"


*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
//Generate dummy variable for Bangladesh (for when appending to other files) 
gen bang=1 

//Wave dummy
gen wave=2

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************

//Location Variables
rename AA1 division
la var division "residential division of respondent"
label define divisionl 1 "Dhaka" 2 "Chittagong" 3 "Khulna" 4 "Rajshahi" 5 "Sylhet" 6 "Barishal" 7 "Rongpur"
label values division divisionl

rename AA2 district
la var district "residential district of respondent"

rename AA7 urban_rural 
la var urban_rural "settlement size (AA7)"
	label define urban_rurall 1 "Urban" 2 "Rural" 
	label values urban_rural urban_rurall
	
rename rural_females rural_female
la var rural_female "female living in a rural area"
	label define rural_femalel 0 "Not rural or not female" 1 "Female - rural"
	label values rural_female rural_femalel

//Weight variable
rename Weight weight

//Other characteristics
rename DG1 yearborn
la var yearborn "year of birth (DG1)"

rename DG3 marital_status //created dummy var below 
la var marital_status "person's marital status(DG3)"   
	label define marital_statusl 1 "Single/never married" 3 "Monogamously married" 4 "Divorced" 5 "Separated" 6 "Widowed" 8 "Other(specify)" 9 "DK/Refused"
	label values marital_status marital_statusl

rename DL1 employment_status //created dummy var below
la var employment_status "employment status of individual (DL1)"
label define employment_statusl 1 "Working full-time for a regular salary" 2 "Working part-time for a regular salary" 3 "Working occasionally, irregular pay" /*
	*/ 4 "Self-employed, working for yourself" 5 "Not working but looking for a job" 6 "Housewife, doing household chores" 7 "Full-time student" /*
	*/ 8 "Not working because of retirement" 9 "Not working because of sickness, disability, etc." 10 "Other(specify)" 11 "DK/Refused"
label values employment_status employment_statusl

//Generate youth in household variable
//rename DL11 household_children
//la var household_children "household members 12-years-old or younger (DL11)"
	//label define household_childrenl 1 "Three or more" 2 "Two" 3 "One" 4 "None"
	//label values household_children household_childrenl

//Generate employment variable
gen employment=.
replace employment=1 if employment_status==1 | employment_status==2
replace employment=2 if employment_status==3 
replace employment=3 if employment_status==4 
replace employment=4 if employment_status==6
replace employment=5 if employment_status==5 | employment_status==7 | employment_status==8 | employment_status==9
	label define employment1 1 "Full or part-time" 2 "Occasional or seasonal" 3 "Self-employed" 4 "Non-wage labor" 5 "Not working"
	label values employment employment1

rename DL2 primary_job // May want to make dummy for farmer
la var primary_job "individual's primary job (DL2)"
label define primary_jobl 1 "Farmer" 2 "Farm worker" 3 "Public or health service worker (non-professional)" 4 "Professional (i.e. doctor, teacher, nurse)" 5 "Clerk"/*
	*/ 6 "Carpenter/mason" 7 " Mechanic" 8 "Electrician" 9 "Cleaner/house help" 10 "Waiter/cook" 11 "Driver" 12 "Tailor" 13 "Secretary" 14 "Manager" /*
	*/ 15 "Watchman" 16 "Messenger" 17 "Policeman" 18 "Conductor" 19 "Factory employee" 20 "Shop owner" 21 "Salesperson in a store" 22 "Street vendor/hawker" /*
	*/ 23 "Business owner (specify below)" 24 "Salonist/barber" 25 "Money lender" 26 "Landlord/landlady" 27 "Retired" 28 "Student" 29 "Housewife" /*
	*/ 30 "Other (specify in row)" 31 "Refused/prefer not to say" 32 "Govt. service" 33 "Non-govt. service" 34 "Manual labor without stable profession"
label values primary_job primary_jobl

//Education 
rename DG4 highest_ed 
la var highest_ed "highest level of education (DG4)"
label define highest_edl 1 "No formal education" 2 "Primary education not complete" 3 "Primary education complete" 4 "Junior/Middle school incomplete (SSC level)" /*
	*/ 5 "Junior/Middle school complete (O level)" 6 "Some secondary (HSC level)" 7 "Secondary education complete (A level)" /*
	*/ 8 "Some secondary vocational training/some certificate" 9 "Secondary vocational training complete/certificate complete" 10 "Some diploma" /*
	*/ 11 "Diploma complete" 12 "Some college/university" 13 "Complete university degree" 14 "Post-graduate university degree" 16 "Other" 17 "DK/Refused"
label values highest_ed highest_edl

//Generate ed_level variable 
gen ed_level=.
replace ed_level=1 if highest_ed==1
replace ed_level=2 if highest_ed==2 | highest_ed==3 | highest_ed==4 | highest_ed==5
replace ed_level=3 if highest_ed==6 | highest_ed==7 | highest_ed==8 | highest_ed==9
replace ed_level=4 if highest_ed==10 | highest_ed==11 | highest_ed==12 | highest_ed==13 | highest_ed==14
label define ed_level1 1 "No formal" 2 "Primary" 3 "Secondary" 4 "Higher education"
	label values ed_level ed_level1

//Numeracy and literacy
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
label define reason_nobankacctl 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state-issued/national ID or other req. docs" /*
	*/ 4 "There are no banks close to where I live" 5 "I do not have money" 6 "I do not need one, I do not make any transactions" /*
	*/ 7 "Registration paperwork is too complicated" 8 "Registration fee is too high" 9 "Using a bank account is difficult" 10 "Fees for using a bank account are too high" /*
	*/ 11 "I do not have money to make any transactions with such an account" 12 "No one among my friends or family has such account" /*
	*/ 13 "I do not understand the purpose of such account, I do not know what I can use it for" 14 "A bank has agents but they are not accessible" /*
	*/ 15 "Banks are not reliable" 16 "Banks do not offer the services I need" 17 "Bank staff/agents are unfriendly; they make me feel unwelcome" /*
	*/ 18 "I can't afford the minimum balance" 19 "Bank hours are not convenient for me" 20 "I never thought about using a bank" /*
	*/ 21 "I do not trust banks/that my money is safe in a bank" 22 "I would rather have my money close to me" 23 "I use mobile money" /*
	*/ 24 "I don't have time to go to the bank" 25 "I use somebody else's account" 26 "My husband, family, in-laws do not approve of me having a bank account" /*
	*/ 27 "I will not be able to go to a bank on my own" 28 "It's not approved by my religion" 29 "Other" 30 "DK/Refused"
label values reason_nobankacct reason_nobankacctl

rename FF6 bank_access
la var bank_access "person uses someone else's bank account (FF6)"

//Digital Financial Services / Mobile Money

*General awareness
rename MM1 dfs_aware_gen //1=yes, 2=no
la var dfs_aware_gen "person has heard of Mobile Money (MM1)"

*Reasons for using/not using DFS
rename MM16 dfs_reasonnouse 
la var dfs_reasonnouse "main reason for never having used DFS (MM16)"
label define dfs_reasonnousel 1 "I do not know what it is" 2 "I do not know how to open one" 3 "I do not have a state ID or other req. docs" /*
	*/ 4 "There is no point-of-service/agent close to where I live" 5 "I do not need one, I do not make any transactions" 6 "Registration paperwork is too complicated" /*
	*/ 7 "Registration fee is too high" 8 "Using such account is difficult" 9 "Fees for using this service are too high" /*
	*/ 10 "I never have money to make transactions with this service" 11 "No one among my friends or family use this service" /*
	*/ 12 "I do not understand this service/ I do not know what I can use it for" 13 "I do not have a smartphone" /*
	*/ 14 "I do not trust that my money is safe on a m-money account" 15 "My husband/family/in-laws do not approve of me having an m-money account" /*
	*/ 16 "It is against my religion" 17 "I don't use because all agents are men" /*
	*/ 18 "Mobile money does not provide anything better/any advantage over financial systems I currently use" 19 "Other(specify)"
label values dfs_reasonnouse dfs_reasonnousel

rename MM17 dfs_reasonnoreg 
la var dfs_reasonnoreg "main reason for not signing up for an acct despite using DFS (MM17)"
label define dfs_reasonnoregl 1 "I do not have a state ID or other req. docs" 2 "There is no point-of-service/agent close to where I live" /*
	*/ 3 "I do not need to, I do not make any transactions" 4 "Using such an account is difficult" 5 "Fees for using such account are too high" /*
	*/ 6 "I never have money to make a transaction with such account" 7 "No one among my friends or family has such account" /*
	*/ 8 "I do not understand the purpose of this account, I don't know what I can use it for" 9 "I can have all the services through an agent, I do not need an account" /*
	*/ 10 "Registration fees are too high" 11 "I prefer that agents perform transactions for me, they will fix the problems if anything happens" /*
	*/ 12 "I do not trust my money is safe on an m-money account" 13 "I prefer to keep money in cash and use m-money only to send/receive money" /*
	*/ 14 "I have heard of fraud on mobile money" 15 "Agent can help me use the service/I do not know how to use it on my own" /*
	*/ 16 "I do not see any additional advantages to registration" 17 "Other (specify)"
label values dfs_reasonnoreg dfs_reasonnoregl

rename MM18	dfs_reasonstart 
la var dfs_reasonstart "reason for starting to use DFS (MM18)"
label define dfs_reasonstartl 1 "I had to send money to another person" 2 "I had to receive money from another person" 3 "Somebody/a person requested I open an account" /*
	*/ 4 "I had to send money to an org/govt. agency: e.g. had to pay a bill" 5 "I had to receive money from an org/govt. agency: e.g. pension unemployment payment..." /*
	*/ 6 "An organization/govt. agency requested I sign up for an account" 7 "An agent or sales person convinced me" /*
	*/ 8 "I saw posters/billboards/radio/TV advertising that convinced me" 9 "A person I know who uses mobile money, recommended I use it because it is better than..."/*
	*/ 10 "I saw other people using it and wanted to try by myself" 11 "I wanted to start saving money with an m-money account" /*
	*/ 12 "I wanted a safe place to store my money" 13 "I got a discount on airtime" 14 "I got a promotional amount of money to spend if I start using m-money" /*
	*/ 15 "Most of my friends/family members are already using it" 16 "Other (specify)"
label values dfs_reasonstart dfs_reasonstartl

**Uses of DFS
//Question: Have you ever used a mobile money account to do the following?

rename MM19_1 dfs_deposit
la var dfs_deposit "person has used DFS to deposit money (MM19_1)"
rename MM19_2 dfs_withdraw
la var dfs_withdraw "person has used DFS to withdraw money (MM19_2)"
rename MM19_3 dfs_airtime
la var dfs_airtime "person has used DFS to buy airtime top-ups (MM19_3)"
rename MM19_4 dfs_payschool
la var dfs_payschool "person has used DFS to pay school fees (MM19_4)"
rename MM19_5 dfs_paymed
la var dfs_paymed "person has used DFS to pay medical bills (MM19_5)"
rename MM19_6 dfs_payelectric
la var dfs_payelectric "person has used DFS to pay electric bills (MM19_6)"
rename MM19_7 dfs_paywater
la var dfs_paywater "person has used DFS to pay for water access or delivery (MM19_7)"
rename MM19_8 dfs_paysolar
la var dfs_paysolar "person has used DFS to pay for solar lamp/solar home system (MM19_8)"
rename MM19_9 dfs_paytv
la var dfs_paytv "person has used DFS to pay a TV/cable/satellite bill (MM19_9)"
rename MM19_10 dfs_paygov
la var dfs_paygov "person has used DFS to pay a government bill, incl. tax, fine, fee (MM19_10)"
rename MM19_11 dfs_payfam_reg
la var dfs_payfam_reg "person has used DFS to send money to fam/friends for reg support or emergency (MM19_11)"
rename MM19_12 dfs_payfam_noreg
la var dfs_payfam_noreg "person has used DFS to send money to fam/friends for other reason or no reason (MM19_12)"
rename MM19_13 dfs_recfam_reg
la var dfs_recfam_reg "person has used DFS to receive money to fam/friends for reg support or emergency (MM19_13)"
rename MM19_14 dfs_recfam_noreg
la var dfs_recfam_noreg "person has used DFS to receive money to fam/friends for other reason or no reason (MM19_14)"
rename MM19_15 dfs_recgov_welfpen
la var dfs_recgov_welfpen "person has used DFS to receive welfare or pension from gov (MM19_15)"
rename MM19_16 dfs_recgov_otherben
la var dfs_recgov_otherben "person has used DFS to receive other gov benefit (MM19_16)"
rename MM19_17 dfs_recwage1
la var dfs_recwage1 "person has used DFS to receive wages from primary job (MM19_17)"
rename MM19_18 dfs_recwage2
la var dfs_recwage2 "person has used DFS to receive wages from secondary job (MM19_18)"
rename MM19_19 dfs_paylarge
la var dfs_paylarge "person has used DFS to pay for large acquisitions (MM19_19)"
rename MM19_20 dfs_payins
la var dfs_payins "person has used DFS to make insurance pmts (MM19_20)"
rename MM19_21 dfs_recins
la var dfs_recins "person has used DFS to receive insurance pmts (MM19_21)"
rename MM19_22 dfs_takeloan
la var dfs_takeloan "person has used DFS to take a loan, make payment on loan (MM19_22)"
rename MM19_23 dfs_giveloan
la var dfs_giveloan "person has used DFS to give a loan, rec payment on loan (MM19_23)"
rename MM19_24 dfs_savepurchase
la var dfs_savepurchase "person has used DFS to save for future purchases (MM19_24)"
rename MM19_25 dfs_savepen
la var dfs_savepen "person has used DFS to save for pensions (MM19_25)"
rename MM19_26 dfs_saveunknown
la var dfs_saveunknown "person has used DFS to set aside money just in case (MM19_26)"
rename MM19_27 dfs_invest
la var dfs_invest "person has used DFS to invest (MM19_27)"
rename MM19_28 dfs_paystore
la var dfs_paystore "person has used DFS to pay for goods at a store (MM19_28)"

//MM19_29 doesn't exist in the Bangladesh data set.
//rename MM19_29 dfs_transferacct
//la var dfs_transferacct "person has used DFS to transfer btwn MM acts (MM19_29)"
rename MM19_30 dfs_transferbank
la var dfs_transferbank "person has used DFS to transfer btwn bank and MM acts (MM19_30)"
rename MM19_31 dfs_transferother
la var dfs_transferother "person has used DFS to transfer btwen MM act and act at other fin institution (MM19_31)"
rename MM19_32 dfs_rent
la var dfs_rent "person has used DFS to spay rent (MM19_32)"
rename MM21_1 dfs_bus_payemp
la var dfs_bus_payemp "person has used DFS to pay employees (MM21_1)"
rename MM21_2 dfs_bus_paysup
la var dfs_bus_paysup "person has used DFS to pay suppliers (MM21_2)"
rename MM21_3 dfs_bus_recpaycust
la var dfs_bus_recpaycust "person has used DFS to receive pmts from customers (MM21_3)"
rename MM21_4 dfs_bus_recpaydist
la var dfs_bus_recpaydist "person has used DFS to receive pmts from distributors (MM21_4)"
rename MM21_5 dfs_bus_invest
la var dfs_bus_invest "person has used DFS to invest in business (MM21_5)"
rename MM21_6 dfs_bus_payexp
la var dfs_bus_payexp "person has used DFS to pay other bus related expenses (i.e.rent) (MM21_6)"
rename MM21_7 dfs_bus_ag
la var dfs_bus_ag "person has used DFS to pay for ag inputs (MM21_7)"
rename MM21_8 dfs_bus_other
la var dfs_bus_other "person has used DFS for other business pmts/transactions(MM21_8)"
rename MM21_9 dfs_bus_none
la var dfs_bus_none "person does not use DFS for business transactions (MM21_9)"

**Agent used
rename MM23 dfs_agent_same
la var dfs_agent_same "person tends to use same MM agent most of the time (MM23)"
rename MM24 dfs_agentsame_reason
la var dfs_agentsame_reason "reason person uses same MM agent regularly (MM24)"
	label define dfs_agentsame_reasonl 1 "Out of courtesy" 2 "The agent is fast" 3 "I trust this agent" 4 "Reliability: the agent is always present during work hours" /*
		*/ 5 "Reliability: the agent always has e-float and/or cash to help with my transaction" 6 "Proximity to where I live" /*
		*/ 7 "Proximity to places where I go to school, retail store, my job, etc." 8 " Agent is knowledgeable/helpful" 9 "Agent is friendly & engaged" /*
		*/ 10 "This agent is my personal friend, family member, or relative" 11 "My family members, friends or workmates use this agent" /*
		*/ 12 "Out of habit" 13 "Other (specify)" 14 "Because the agent is a female" 15 "Because the agent is a male" /*
		*/ 16 "Agent was recommended to me" 17 "No particular reason"
	label values dfs_agentsame_reason dfs_agentsame_reasonl

**Transport to agent
rename MM25 dfs_agent_dist 
la var dfs_agent_dist "distance (km) of closest MM agent from where they live (MM25)"
label define dfs_agent_distl 1 "0.5 km or less" 2 "More than .5 km to 1 km" 3 "More than 1 km to 5 km" 4 "More than 5 km to 10 km" /*
	*/5 "More than 10 km to 15 km" 6 "More than 15 km" 
label values dfs_agent_dist dfs_agent_distl

rename MM27 dfs_agent_transway
la var dfs_agent_transway "method of transport to get to nearest MM agent (MM27)"
rename MM28 dfs_agent_transtime
la var dfs_agent_transtime "length of time to get to nearest MM agent (MM28)"

**Have you ever experienced any of the following issues with an agent?

rename MM30_1 dfs_agentiss_absent
la var dfs_agentiss_absent "agent issue: agent was absent (MM30_1)"

rename MM30_2 dfs_agentiss_rude
la var dfs_agentiss_rude "agent issue: agent was rude (MM30_2)"

rename MM30_3 dfs_agentiss_nocash
la var dfs_agentiss_nocash "agent issue: agent didn't have enough cash or e-float (MM30_3)"

rename MM30_4 dfs_agentiss_refuse
la var dfs_agentiss_refuse "agent issue: agent refused to perform transaction (MM30_4)"

rename MM30_5 dfs_agentiss_noknow
la var dfs_agentiss_noknow "agent issue: agent didn't know how to perform trans (MM30_5)"

rename MM30_6 dfs_agentiss_overcharge
la var dfs_agentiss_overcharge "agent issue: agent overchareged or asked for deposit (MM30_6)"

rename MM30_7 dfs_agentiss_wrongcash
la var dfs_agentiss_wrongcash "agent issue: agent didn't give all cash owed (MM30_7)"

rename MM30_8 dfs_agentiss_netdown
la var dfs_agentiss_netdown "agent issue: mobile network down (MM30_8)"

rename MM30_9 dfs_agentiss_agsysdown
la var dfs_agentiss_agsysdown "agent issue: agent system down (MM30_9)"

rename MM30_10 dfs_agentiss_notime
la var dfs_agentiss_notime "agent issue: transaction too time consuming (MM30_10)"

rename MM30_11 dfs_agentiss_noreceipt
la var dfs_agentiss_noreceipt "agent issue: didn't get receipt (MM30_11)"

rename MM30_12 dfs_agentiss_chargedep
la var dfs_agentiss_chargedep "agent issue: agent charged for depositing money (MM30_12)"

rename MM30_13 dfs_agentiss_pin
la var dfs_agentiss_pin "agent issue: agent asked for PIN (MM30_13)"

rename MM30_14 dfs_agentiss_women
la var dfs_agentiss_women "agent issue: agent dismissive of women (MM30_14)"

rename MM30_15 dfs_agentiss_fraud
la var dfs_agentiss_fraud "agent issue: agent committed fraud (MM30_15)"

rename MM30_16 dfs_agentiss_insecure
la var dfs_agentiss_insecure "agent issue: place not secure, suspicious people (MM30_16)"

rename MM30_17 dfs_agentiss_shareinfo
la var dfs_agentiss_shareinfo "agent issue: agent shared info with other people (MM30_17)"

rename MM30_18 dfs_agentiss_scam
la var dfs_agentiss_scam "agent issue: agent assisted others in defrauding or scamming (MM30_18)"

rename MM30_19 dfs_agentiss_other
la var dfs_agentiss_other "agent issue: other(MM30_19)"

rename MM43 dfs_prob_who
la var dfs_prob_who "when an MM transaction goes wrong, who do you go to to help you resolve it? (MM43)"


**Level of satisfaction with financial options before and after having bank account/ using DFS

rename SFC1 sat_bankacct_before
la var sat_bankacct_before "rate 1-10 rate choice of financial options available before having bank acct"

rename SFC2 sat_bankacct_after
la var sat_bankacct_after "rate 1-10 rate choice of financial options available after you have bank acct"

rename SFC3 sat_dfs_before
la var sat_dfs_before "rate 1-10 rate choice of financial options available before you started using DFS"

rename SFC4 sat_dfs_after
la var sat_dfs_after "rate 1-10 rate choice of financial options available after you started using DFS"

//recode renamed dummy variables to be 0=no and 1=yes 
recode phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw dfs_deposit /*
	*/ dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paysolar dfs_paytv /*
	*/dfs_paygov dfs_payfam_reg dfs_payfam_noreg dfs_recfam_reg dfs_recfam_noreg dfs_recgov_welfpen /*
	*/dfs_recgov_otherben dfs_recwage1 dfs_recwage2 dfs_paylarge dfs_payins dfs_recins dfs_takeloan dfs_giveloan dfs_savepurchase /*
	*/dfs_savepen dfs_saveunknown dfs_invest dfs_paystore dfs_transferbank dfs_transferother dfs_rent /*
	*/dfs_bus_payemp dfs_bus_paysup dfs_bus_recpaycust dfs_bus_recpaydist dfs_bus_invest dfs_bus_payexp dfs_bus_ag dfs_bus_other /*
	*/dfs_bus_none dfs_agent_same dfs_agentiss_absent dfs_agentiss_rude dfs_agentiss_nocash dfs_agentiss_refuse /*
	*/dfs_agentiss_noknow dfs_agentiss_overcharge dfs_agentiss_wrongcash dfs_agentiss_netdown dfs_agentiss_agsysdown dfs_agentiss_notime /*
	*/dfs_agentiss_noreceipt dfs_agentiss_chargedep dfs_agentiss_pin dfs_agentiss_women dfs_agentiss_fraud dfs_agentiss_insecure /*
	*/dfs_agentiss_shareinfo dfs_agentiss_scam dfs_agentiss_other (2=0)


//Label variable values 0=no; 1=yes
#d ;
local yesnorename phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw dfs_deposit
	dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paysolar dfs_paytv
	dfs_paygov dfs_payfam_reg dfs_payfam_noreg dfs_recfam_reg dfs_recfam_noreg dfs_recgov_welfpen
	dfs_recgov_otherben dfs_recwage1 dfs_recwage2 dfs_paylarge dfs_payins dfs_recins dfs_takeloan dfs_giveloan dfs_savepurchase
	dfs_savepen dfs_saveunknown dfs_invest dfs_paystore dfs_transferbank dfs_transferother dfs_rent
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

**RURAL
gen rural=.
replace rural=1 if urban_rural==2
replace rural=0 if urban_rural==1
la var rural "person lives in a rural area (AA7)"

**MARRIED (if monogamously married - does not include widowed, divorced, etc.) - polygamously married not an option as an answer
gen married=.
replace married=1 if marital_status==3
replace married=0 if marital_status!=3
la var married "person is monogomously married (DG3)"

**OFFICIAL ID (if answered yes to any type of official id; verify if we need to exclude any types)
gen official_id=.
replace official_id=1 if DG5_1 ==1 | DG5_2==1 | DG5_3==1 | DG5_4==1 | DG5_5==1 | DG5_6==1 | DG5_7==1 | DG5_8==1 | DG5_9==1 | DG5_10==1 
replace official_id=0 if DG5_1 ==2 & DG5_2==2 & DG5_3==2 & DG5_4==2 & DG5_5==2 & DG5_6==2 & DG5_7==2 & DG5_8==2 & DG5_9==2 & DG5_10==2 
la var official_id "has any type of official identification (DG5_1 to DG5_10)"

**EMPLOYED (if working full or part time for a regular salary, self-employed, or working occasionally, irregular pay) 
gen employed=. 
replace employed=1 if employment_status <=4 
replace employed=0 if employment_status>4
la var employed "person works full-time, part-time, irregularly, or is self-employed (DL1)"

**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if MM2_1==1 | MM2_2==1 | MM2_3==1 | MM2_4==1 | MM2_5==1 | MM2_6==1 | MM2_7==1
replace dfs_aware_spont=0 if MM2_1==2 & MM2_2==2 & MM2_3==2 & MM2_4==2 & MM2_5==2 & MM2_6==2 & MM2_7==2
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (MM2_1-7)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if MM3_1==1 | MM3_2==1 | MM3_3==1 | MM3_4==1 | MM3_5==1 | MM3_6==1 | MM3_7==1
replace dfs_aware_prompt=0 if MM3_1==2 & MM3_2==2 & MM3_3==2 & MM3_4==2 & MM3_5==2 & MM3_6==2 & MM3_7==2
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(MM3_1-7)"

**SPONTANEOUS OR PROMPTED RECALL of DFS providers
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_spont==1 | dfs_aware_prompt==1
replace dfs_aware_name=0 if dfs_aware_spont==0 & dfs_aware_prompt==0


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
**Question: Have you ever used this mobile money service for any financial activity? (one question for each DFS provider,
//combining them to find out if they have ever used any DFS service)
gen dfs_adopt=.
replace dfs_adopt=1 if MM5_1==1 | MM5_2==1 | MM5_3==1 | MM5_4==1 | MM5_5==1 | MM5_6==1 | MM5_7==1
replace dfs_adopt=0 if MM5_1!=1 & MM5_2!=1 & MM5_3!=1 & MM5_4!=1 & MM5_5!=1 & MM5_6!=1 & MM5_7!=1
replace dfs_adopt=. if MM5_1==. & MM5_2==. & MM5_3==. & MM5_4==. & MM5_5==. & MM5_6==. & MM5_7==.
la var dfs_adopt "person has ever used DFS for any financial activity (MM5_2-7)"


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
gen dfs_regacct=.
replace dfs_regacct=1 if MM8_1==1 | MM8_2==1 | MM8_3==1 | MM8_4==1 | MM8_5==1 | MM8_6==1 | MM8_7==1
replace dfs_regacct=0 if MM8_1!=1 & MM8_2!=1 & MM8_3!=1 & MM8_4!=1 & MM8_5!=1 & MM8_6!=1 & MM8_7!=1
replace dfs_regacct=. if MM8_1==. & MM8_2==. & MM8_3==. & MM8_4==. & MM8_5==. & MM8_6==. & MM8_7==.
la var dfs_regacct "person has a registered account with any DFS provider (MM8_1-7)"


**HOW DO YOU ACCESS DFS
//How do you usually access this mobile money service?
//One question for each DFS provider, so we are combining them 

//Over the counter or by using an agent’s account
gen dfs_access_otc=.
replace dfs_access_otc=1 if MM15_1==1 | MM15_2==1 | MM15_3==1 | MM15_4==1 | MM15_5==1 | MM15_6==1 | MM15_7==1
replace dfs_access_otc=0 if MM15_1!=1 & MM15_2!=1 & MM15_3!=1 & MM15_4!=1 & MM15_5!=1 & MM15_6!=1 & MM15_7!=1
replace dfs_access_otc=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_otc "person usually accesses DFS over the counter (MM15_1-7)"

//Account of a family member in this household
gen dfs_access_fam=.
replace dfs_access_fam=1 if MM15_1==2 | MM15_2==2 | MM15_3==2 | MM15_4==2 | MM15_5==2 | MM15_6==2 | MM15_7==2
replace dfs_access_fam=0 if MM15_1!=2 & MM15_2!=2 & MM15_3!=2 & MM15_4!=2 & MM15_5!=2 & MM15_6!=2 & MM15_7!=2
replace dfs_access_fam=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_fam "person usually accesses DFS from a family member's acct in the hh (MM15_1-7)"

//Account of a family member in another household, other relative, friend or a neighbor
gen dfs_access_nonhh=.
replace dfs_access_nonhh=1 if MM15_1==3 | MM15_2==3 | MM15_3==3 | MM15_4==3 | MM15_5==3 | MM15_6==3 | MM15_7==3
replace dfs_access_nonhh=0 if MM15_1!=3 & MM15_2!=3 & MM15_3!=3 & MM15_4!=3 & MM15_5!=3 & MM15_6!=3 & MM15_7!=3
replace dfs_access_nonhh=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_nonhh "person usually accesses DFS from a family member in another hh, friend, or neib (MM15_1-7)"

//Account of a workmate or a business partner
gen dfs_access_work=.
replace dfs_access_work=1 if MM15_1==4 | MM15_2==4 | MM15_3==4 | MM15_4==4 | MM15_5==4 | MM15_6==4 | MM15_7==4
replace dfs_access_work=0 if MM15_1!=4 & MM15_2!=4 & MM15_3!=4 & MM15_4!=4 & MM15_5!=4 & MM15_6!=4 & MM15_7!=4
replace dfs_access_work=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_work "person usually accesses DFS from a workmate or business partner (MM15_1-7)"

//Their own account
gen dfs_access_ownacct=.
replace dfs_access_ownacct=1 if MM15_1==5 | MM15_2==5 | MM15_3==5 | MM15_4==5 | MM15_5==5 | MM15_6==5 | MM15_7==5
replace dfs_access_ownacct=0 if MM15_1!=5 & MM15_2!=5 & MM15_3!=5 & MM15_4!=5 & MM15_5!=5 & MM15_6!=5 & MM15_7!=5
replace dfs_access_ownacct=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_ownacct "person usually accesses DFS from their own account (MM15_1-7)"

//Other
gen dfs_access_other=.
replace dfs_access_other=1 if MM15_1==6 | MM15_2==6 | MM15_3==6 | MM15_4==6 | MM15_5==6 | MM15_6==6 | MM15_7==6
replace dfs_access_other=0 if MM15_1!=6 & MM15_2!=6 & MM15_3!=6 & MM15_4!=6 & MM15_5!=6 & MM15_6!=6 & MM15_7!=6
replace dfs_access_other=. if MM15_1==. & MM15_2==. & MM15_3==. & MM15_4==. & MM15_5==. & MM15_6==. & MM15_7==.
la var dfs_access_other "person usually accesses DFS in an other way (MM15_1-7)"

*REMITTANCES

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

count if rec_remit==. //only 1 obs missing

sum rec_remit //4.5% of obs report receiving remittances


**COMFORT/SKILL WITH MOBILE TECHNOLOGY

//Basic Use - person can make phone calls
gen mobileskills_call=.
replace mobileskills_call=1 if TDL2_1==3 | TDL2_1==4  //if person can make phone calls somewhat or very well
replace mobileskills_call=0 if TDL2_1==0 | TDL2_1==1 | TDL2_1==2 //if person never does this or does it very or somewhat poorly
la var mobileskills_call "person can dial numbers on their phone somewhat or very well (TDL2_1)"

//Texting - person can either send or respond to text messages
gen mobileskills_text=.
replace mobileskills_text=1 if TDL2_4==3 | TDL2_4==4 | TDL2_5==3 | TDL2_5==4 //if person can either send or respond to text messages somewhat or very well
replace mobileskills_text=0	if (TDL2_4==0 | TDL2_4==1 | TDL2_4==2) & (TDL2_5==0 | TDL2_5==1 | TDL2_5==2) //if person can NEITHER send NOR respond to text messages somewhat or very well
la var mobileskills_text "person can send and/or respond to text messages somewhat or very well (DL2_4, DL2_5)"

count if (TDL2_4==3 | TDL2_4==4) & TDL2_5<3 //352 people can send text messages but cannot respond to text messages from other people -- these people still have a 1 for mobileskills_text

//Internet use
*MLL: combining the activities that would require internet access, because there isn't a specific variable for accessing internet
*includes Using social networks like Facebook or  Twitter; Posting pictures online, using Instagram; Watching video you downloaded on a phone; Listening to audio you download on a phone; Using a chatting apps such Whatsapp or Viber

gen mobileskills_internet=.
replace mobileskills_internet=1 if TDL2_8>=3 | TDL2_9>=3 | TDL2_10>=3 | TDL2_11>=3 | TDL2_13>=3
replace mobileskills_internet=0	if TDL2_8<3 & TDL2_9<3 & TDL2_10<3 & TDL2_11<3 & TDL2_13<3 
replace mobileskills_internet=. if TDL2_8==. & TDL2_9==. & TDL2_10==. & TDL2_11==. & TDL2_13==. 
la var mobileskills_internet "person can use their phone to access internet somewhat or very well (TDL2_8,9,10,11,13"


/*
//Advanced Use - person can do ANY of the following somewhat or very well: compose and send picture messages, forward a text message, use social networks, post pictures online, watch video downloaded on phone, 
//listen to audio they downloaded, tune in to radio station, use chatting apps, follow text menu, follow interactive voice menu 
gen mobileskills_advanced=.
replace mobileskills_advanced=1 if TDL2_6>=3 | TDL2_7>=3 | TDL2_8>=3 | TDL2_9>=3 | TDL2_10>=3 | TDL2_11>=3 | TDL2_12>=3 | TDL2_13>=3 | TDL2_14>=3 | TDL2_15>=3 
replace mobileskills_advanced=0 if TDL2_6<3 & TDL2_7<3 & TDL2_8<3 & TDL2_9<3 & TDL2_10<3 & TDL2_11<3 & TDL2_11<3 & TDL2_12<3 & TDL2_13<3 & TDL2_14<3 & TDL2_15<3 
replace mobileskills_advanced=. if TDL2_6==. & TDL2_7==. & TDL2_8==. & TDL2_9==. & TDL2_10==. & TDL2_11==. & TDL2_11==. & TDL2_12==. & TDL2_13==. & TDL2_14==. & TDL2_15==.
la var mobileskills_advanced "person can perform advanced (i.e. access internet, take pictures) functions on phone somewhat or very well (TDL2_*)"
*/



//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married official_id employed dfs_aware_spont dfs_aware_prompt dfs_aware_radio dfs_aware_tv
	dfs_aware_billboard dfs_aware_newspaper dfs_aware_household dfs_aware_otherfam dfs_aware_friend 
	dfs_aware_workmate dfs_aware_cust dfs_aware_admin dfs_aware_bankemp dfs_aware_fingroup dfs_aware_agent 
	dfs_aware_fieldagent dfs_aware_sms dfs_aware_event dfs_aware_other dfs_adopt dfs_lastuse_yest dfs_lastuse_week
	dfs_lastuse_month dfs_lastuse_90days dfs_lastuse_more90 dfs_regacct dfs_access_otc dfs_access_fam 
	dfs_access_nonhh dfs_access_work dfs_access_ownacct dfs_access_other mobileskills_call mobileskills_text mobileskills_internet rec_remit
	ppi_cutoff literate numerate dfs_aware_name 
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

save "R:\Project\EPAR\Working Files\317 - Gender and DFS Adoption\DTAs\W2\Bangladesh_W2_Clean.dta", replace




