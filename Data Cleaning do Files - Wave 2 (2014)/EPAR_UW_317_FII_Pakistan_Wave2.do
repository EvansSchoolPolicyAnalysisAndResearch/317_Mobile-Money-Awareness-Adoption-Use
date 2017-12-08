/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of awareness, adoption, and use of Mobile Money 
				  using the Pakistan Financial Inclusion Insights Wave 2 data set.
				  
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
*This Master do.file constructs selected sociodemogaphic and mobile money uptake outcome variables from the Pakistan Financial Inclusion Insights Wave 2 data set.
*After downloading the "FSP_Final_Pakistan_W2_01072015(public).xlsx" data file from Intermedia, we convert it to Stata .dta format for analysis. 
*The do.file first creates sociodemogaphic variables and then outcome variables related to mobile money uptake.
*We then save a clean .dta file at the end, which we merge with other .dta files from other FII countries and waves for analysis in a separate .do file.


set excelxlsxlargefile on
import excel using "filepath for location where you downloaded raw data/FSP_Final_Pakistan_W2_01072015(public).xlsx", firstrow
save "filepath for location where you want to save dta file/Pakistan_Wave2_Stata.dta", replace
clear

***Update the below global macros with the appropriate filepaths
clear
global input "filepath for location where you want to save dta file" //from the previous line above when convert the Excel file to .dta format
global output "filepath for location where you want to save output files" 


**********
*Pakistan*
**********
use "$input\Pakistan_Wave2_Stata.dta"

*********************************************
** RENAME VARIABLES TO BE USED IN ANALYSIS **
*********************************************
//Generate dummy variable for Pakistan (for when appending to other files) 
gen Pakistan=1 

//Wave dummy
gen wave=2

***********************************
*SOCIO-DEMOGRAPHIC CHARACTERISTICS*
***********************************

//Location Variables
rename aa1 zone
la var zone "residential zone of respondent (AA1)"
rename aa2 district
la var district "residential district of respondent (AA2)"
rename UR urban_rural //1=urban, 2=rural
la var urban_rural "settlement size (1=urban 2=rural)"

//Weight variable
rename Weight weight

//Other characteristics
rename dg1 yearborn
la var yearborn "year of birth (DG1)"
rename dg3 marital_status //refer to codebook (R:\Project\EPAR\FII Datasets\Tanzania Wave 2 Excel) for labels, created dummy var below
la var marital_status "person's marital status (see codebook for labels) (DG3)"
rename dl1 employment_status //generated dummy var below.
la var employment_status "employment status of individual (see codebook for labels) (DL1)"
	label define employment_statusl 1 "Working full-time for a regular salary" 2 "Working part-time for a regular salary" 3 "Working occasionally, irregular pay" /*
		*/ 4 "Self-employed, working for yourself" 5 "Not working but looking for a job" 6 "Housewife, doing household chores" 7 "Full-time student" /*
		*/ 8 "Not working because of retirement" 9 "Not working because of sickness, disability, etc." 10 "Other(specify)" 11 "DK/Refused"
	label values employment_status employment_statusl
	
//Generate employment variable//
gen employment=.
replace employment=1 if employment_status==1 | employment_status==2
replace employment=2 if employment_status==3 
replace employment=3 if employment_status==4 
replace employment=4 if employment_status==6
replace employment=5 if employment_status==5 | employment_status==7 | employment_status==8 | employment_status==9
	label define employment1 1 "Full or part-time" 2 "Occasional or seasonal" 3 "Self-employed" 4 "Non-wage labor" 5 "Not working"
	label values employment employment1

rename dl2 primary_job // refer to FII codebook for labels -- may want to make dummy for farmer 
la var primary_job "individual's primary job (see codebook for labels) (DL2)"

rename dl26_1 n_household
la var n_household "number of members in household, incl. adults and children (DL26_1)" //DL12 is # of children under age of 13

//Education and literacy
rename dg4 highest_ed // refer to FII codebook for labels
la var highest_ed "highest level of education (see codebook for labels) (DG4)"
rename Numeracy numerate
la var numerate "person has basic numeracy"
rename Literacy literate
la var literate "person has basic literacy"

//Create ed_level categorical variable for regressions
tab highest_ed
gen ed_level=.
replace ed_level=1 if highest_ed==1 | highest_ed==2
replace ed_level=2 if highest_ed==3 | highest_ed==4
replace ed_level=3 if highest_ed==5 | highest_ed==6 | highest_ed==7 | highest_ed==8
replace ed_level=4 if  highest_ed==9 | highest_ed==10 | highest_ed==11 | highest_ed==12 | highest_ed==13
label define ed_level1 1 "No formal" 2 "Primary" 3 "Secondary" 4 "Higher education"
	label values ed_level ed_level1

//Mobile phone and bank ownership and access
rename mt1 phone_own
la var phone_own "person owns a mobile phone (MT1)"
rename mt3 phone_access
la var phone_access "person uses mobile phone belonging to someone else by borrowing or paying for its use (MT3)"
rename mt7 sim_own
la var sim_own "person owns an active/working sim card (MT7)"
rename mt9 sim_access
la var sim_access "person uses sim card belonging to someone else (MT9)"
rename ff1 bank_own
la var bank_own "person has bank account registered in their name (FF1)"
rename ff5 reason_nobankacct // refer to codebook for labels
la var reason_nobankacct "reason person does not have bank account (see codebook for labels) (FF5)"
rename ff6 bank_access
la var bank_access "person uses someone else's bank account (FF6)"
rename ff14 bank_lastuse
la var bank_lastuse "apart from today, last time used bank acct (see codebook for labels) (FF14)" 


//Digital Financial Services / Mobile Money

*General awareness of concept of mobile money
rename mm1 dfs_aware_gen 
la var dfs_aware_gen "person has heard of Mobile Money (MM1)"

*Reasons for using/not using DFS
rename mm16 dfs_reasonnouse //refer to FII codebook for labels
la var dfs_reasonnouse "reason person has never used DFS (see codebook for labels) (MM16)"
rename mm17 dfs_reasonnoreg //refer to FII codebook for labels
la var dfs_reasonnoreg "reason person has not registered, despite using DFS (see codebook for labels) (MM17)"
rename mm18	dfs_reasonstart //refer to FII codebook for labels
la var dfs_reasonstart "reason person started using DFS (see codebook for labels) (MM18)"

**Uses of DFS
rename mm19_1 dfs_deposit
la var dfs_deposit "person has used DFS to deposit money (mm19_1)"
rename mm19_2 dfs_withdraw
la var dfs_withdraw "person has used DFS to withdraw money (mm19_2)"
rename mm19_3 dfs_airtime
la var dfs_airtime "person has used DFS to buy airtime top-ups (mm19_3)"
rename mm19_4 dfs_payschool
la var dfs_payschool "person has used DFS to pay school fees (mm19_4)"
rename mm19_5 dfs_paymed
la var dfs_paymed "person has used DFS to pay medical bills (mm19_5)"
rename mm19_6 dfs_payelectric
la var dfs_payelectric "person has used DFS to pay electric bills (mm19_6)"
rename mm19_7 dfs_paywater
la var dfs_paywater "person has used DFS to pay for water access or delivery (mm19_7)"
rename mm19_8 dfs_paynatgas //Note that in other countries, this variable asks if they use DFS to pay for solar lamps
la var dfs_paynatgas "person has used DFS to pay for natural gas bill (mm19_8)"
rename mm19_9 dfs_paytv
la var dfs_paytv "person has used DFS to pay a TV/cable/satellite bill (mm19_9)"
rename mm19_10 dfs_paygov
la var dfs_paygov "person has used DFS to pay a government bill, incl. tax, fine, fee (mm19_10)"
rename mm19_11 dfs_payfam_reg
la var dfs_payfam_reg "person has used DFS to send money to fam/friends for reg support or emergency (mm19_11)"
rename mm19_12 dfs_payfam_noreg
la var dfs_payfam_noreg "person has used DFS to send money to fam/friends for other reason or no reason (mm19_12)"
rename mm19_13 dfs_recfam_reg
la var dfs_recfam_reg "person has used DFS to receive money to fam/friends for reg support or emergency (mm19_13)"
rename mm19_14 dfs_recfam_noreg
la var dfs_recfam_noreg "person has used DFS to receive money to fam/friends for other reason or no reason (mm19_14)"
rename mm19_15 dfs_recgov_welfpen
la var dfs_recgov_welfpen "person has used DFS to receive welfare or pension from gov (mm19_15)"
rename mm19_16 dfs_recgov_otherben
la var dfs_recgov_otherben "person has used DFS to receive other gov benefit (mm19_16)"
rename mm19_17 dfs_recwage1
la var dfs_recwage1 "person has used DFS to receive wages from primary job (mm19_17)"
rename mm19_18 dfs_recwage2
la var dfs_recwage2 "person has used DFS to receive wages from secondary job (mm19_18)"
rename mm19_19 dfs_paylarge
la var dfs_paylarge "person has used DFS to pay for large acquisitions (mm19_19)"
rename mm19_20 dfs_payins
la var dfs_payins "person has used DFS to make insurance pmts (mm19_20)"
rename mm19_21 dfs_recins
la var dfs_recins "person has used DFS to receive insurance pmts (mm19_21)"
rename mm19_22 dfs_takeloan
la var dfs_takeloan "person has used DFS to take a loan, make payment on loan (mm19_22)"
rename mm19_23 dfs_giveloan
la var dfs_giveloan "person has used DFS to give a loan, rec payment on loan (mm19_23)"
rename mm19_24 dfs_savepurchase
la var dfs_savepurchase "person has used DFS to save for future purchases (mm19_24)"
rename mm19_25 dfs_savepen
la var dfs_savepen "person has used DFS to save for pensions (mm19_25)"
rename mm19_26 dfs_saveunknown
la var dfs_saveunknown "person has used DFS to set aside money just in case (mm19_26)"
rename mm19_27 dfs_invest
la var dfs_invest "person has used DFS to invest (mm19_27)"
rename mm19_28 dfs_paystore
la var dfs_paystore "person has used DFS to pay for goods at a store (mm19_28)"
rename mm19_29 dfs_transferacct
la var dfs_transferacct "person has used DFS to transfer btwn mm acts (mm19_29)"
rename mm19_30 dfs_transferbank
la var dfs_transferbank "person has used DFS to transfer btwn bank and mm acts (mm19_30)"
rename mm19_31 dfs_transferother
la var dfs_transferother "person has used DFS to transfer btwen mm act and act at other fin institution (mm19_31)"
rename mm19_32 dfs_rent
la var dfs_rent "person has used DFS to spay rent (mm19_32)"
rename mm21_1 dfs_bus_payemp
la var dfs_bus_payemp "person has used DFS to pay employees (mm21_1)"
rename mm21_2 dfs_bus_paysup
la var dfs_bus_paysup "person has used DFS to pay suppliers (mm21_2)"
rename mm21_3 dfs_bus_recpaycust
la var dfs_bus_recpaycust "person has used DFS to receive pmts from customers (mm21_3)"
rename mm21_4 dfs_bus_recpaydist
la var dfs_bus_recpaydist "person has used DFS to receive pmts from distributors (mm21_4)"
rename mm21_5 dfs_bus_invest
la var dfs_bus_invest "person has used DFS to invest in business (mm21_5)"
rename mm21_6 dfs_bus_payexp
la var dfs_bus_payexp "person has used DFS to pay other bus related expenses (i.e.rent) (mm21_6)"
rename mm21_7 dfs_bus_ag
la var dfs_bus_ag "person has used DFS to pay for ag inputs (mm21_7)"
rename mm21_8 dfs_bus_other
la var dfs_bus_other "person has used DFS for other business pmts/transactions(mm21_8)"
rename mm21_9 dfs_bus_none
la var dfs_bus_none "person does not use DFS for business transactions (mm21_9)"

**Agent used
rename mm23 dfs_agent_same
la var dfs_agent_same "person tends to use same mm agent most of the time (mm23)"
rename mm24 dfs_agentsame_reason // see FII codebook for labels
la var dfs_agentsame_reason "reason person uses same mm agent regularly (see codebook for labels) (mm24)"

**Transport to agent
rename mm25 dfs_agent_dist
la var dfs_agent_dist "distance of closest mm agent from where they live (mm25)"
rename mm27 dfs_agent_transway
la var dfs_agent_transway "method of transport to get to nearest mm agent (mm27)"
rename mm28 dfs_agent_transtime
la var dfs_agent_transtime "length of time to get to nearest mm agent (mm28)"

**Have you ever experienced any of the following issues with an agent?
rename mm30_1 dfs_agentiss_absent
la var dfs_agentiss_absent "agent issue: agent was absent (mm30_1)"
rename mm30_2 dfs_agentiss_rude
la var dfs_agentiss_rude "agent issue: agent was rude (mm30_2)"
rename mm30_3 dfs_agentiss_nocash
la var dfs_agentiss_nocash "agent issue: agent didn't have enough cash or e-float (mm30_3)"
rename mm30_4 dfs_agentiss_refuse
la var dfs_agentiss_refuse "agent issue: agent refused to perform transaction (mm30_4)"
rename mm30_5 dfs_agentiss_noknow
la var dfs_agentiss_noknow "agent issue: agent didn't know how to perform trans (mm30_5)"
rename mm30_6 dfs_agentiss_overcharge
la var dfs_agentiss_overcharge "agent issue: agent overchareged or asked for deposit (mm30_6)"
rename mm30_7 dfs_agentiss_wrongcash
la var dfs_agentiss_wrongcash "agent issue: agent didn't give all cash owed (mm30_7)"
rename mm30_8 dfs_agentiss_netdown
la var dfs_agentiss_netdown "agent issue: mobile network down (mm30_8)"
rename mm30_9 dfs_agentiss_agsysdown
la var dfs_agentiss_agsysdown "agent issue: agent system down (mm30_9)"
rename mm30_10 dfs_agentiss_notime
la var dfs_agentiss_notime "agent issue: transaction too time consuming (mm30_10)"
rename mm30_11 dfs_agentiss_noreceipt
la var dfs_agentiss_noreceipt "agent issue: didn't get receipt (mm30_11)"
rename mm30_12 dfs_agentiss_chargedep
la var dfs_agentiss_chargedep "agent issue: agent charged for depositing money (mm30_12)"
rename mm30_13 dfs_agentiss_pin
la var dfs_agentiss_pin "agent issue: agent asked for PIN (mm30_13)"
rename mm30_14 dfs_agentiss_women
la var dfs_agentiss_women "agent issue: agent dismissive of women (mm30_14)"
rename mm30_15 dfs_agentiss_fraud
la var dfs_agentiss_fraud "agent issue: agent committed fraud (mm30_15)"
rename mm30_16 dfs_agentiss_insecure
la var dfs_agentiss_insecure "agent issue: place not secure, suspicious people (mm30_16)"
rename mm30_17 dfs_agentiss_shareinfo
la var dfs_agentiss_shareinfo "agent issue: agent shared info with other people (mm30_17)"
rename mm30_18 dfs_agentiss_scam
la var dfs_agentiss_scam "agent issue: agent assisted others in defrauding or scamming (mm30_18)"
rename mm30_19 dfs_agentiss_other
la var dfs_agentiss_other "agent issue: other(mm30_19)"

rename sfc1 sat_bankacct_before
la var sat_bankacct_before "rate 1-10 rate choice of financial options available before having bank acct"
rename sfc2 sat_bankacct_after
la var sat_bankacct_after "rate 1-10 rate choice of financial options available after you have bank acct"
rename sfc3 sat_dfs_before
la var sat_dfs_before "rate 1-10 rate choice of financial options available before you started using DFS"
rename sfc4 sat_dfs_after
la var sat_dfs_after "rate 1-10 rate choice of financial options available after you started using DFS"
rename mm43 dfs_prob_who
la var dfs_prob_who "when an mm transaction goes wrong, who do you go to to help you resolve it? (mm43)"


//recode renamed dummy variables to be 0=no and 1=yes
recode phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw dfs_deposit /*
*/ dfs_withdraw dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paynatgas dfs_paytv /*
*/dfs_paygov dfs_payfam_reg dfs_payfam_noreg dfs_recfam_reg dfs_recfam_noreg dfs_recgov_welfpen /*
*/dfs_recgov_otherben dfs_recwage1 dfs_recwage2 dfs_paylarge dfs_payins dfs_recins dfs_takeloan dfs_giveloan dfs_savepurchase /*
*/dfs_savepen dfs_saveunknown dfs_invest dfs_paystore dfs_transferacct dfs_transferbank dfs_transferother dfs_rent /*
*/dfs_bus_payemp dfs_bus_paysup dfs_bus_recpaycust dfs_bus_recpaydist dfs_bus_invest dfs_bus_payexp dfs_bus_ag dfs_bus_other /*
*/dfs_bus_none dfs_agent_same dfs_agentiss_absent dfs_agentiss_rude dfs_agentiss_nocash dfs_agentiss_refuse /*
*/dfs_agentiss_noknow dfs_agentiss_overcharge dfs_agentiss_wrongcash dfs_agentiss_netdown dfs_agentiss_agsysdown dfs_agentiss_notime /*
*/dfs_agentiss_noreceipt dfs_agentiss_chargedep dfs_agentiss_pin dfs_agentiss_women dfs_agentiss_fraud dfs_agentiss_insecure /*
*/dfs_agentiss_shareinfo dfs_agentiss_scam dfs_agentiss_other (2=0)


#d ;
local yesnorename phone_own phone_access sim_own sim_access bank_own bank_access dfs_aware_gen dfs_deposit dfs_withdraw dfs_deposit 
dfs_withdraw dfs_airtime dfs_payschool dfs_paymed dfs_payelectric dfs_paywater dfs_paynatgas dfs_paytv 
dfs_paygov dfs_payfam_reg dfs_payfam_noreg dfs_recfam_reg dfs_recfam_noreg dfs_recgov_welfpen 
dfs_recgov_otherben dfs_recwage1 dfs_recwage2 dfs_paylarge dfs_payins dfs_recins dfs_takeloan dfs_giveloan dfs_savepurchase 
dfs_savepen dfs_saveunknown dfs_invest dfs_paystore dfs_transferacct dfs_transferbank dfs_transferother dfs_rent 
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
replace female=1 if dg2==2
replace female=0 if dg2==1
la var female "gender of respondent is female (DG2)"

**RURAL
gen rural=.
replace rural=1 if urban_rural==2
replace rural=0 if urban_rural==1
la var rural "person lives in a rural area"

**MARRIED (if monogomously or polygomously married - does not include widowed, divorced, etc.)
gen married=.
replace married=1 if marital_status ==2 | marital_status==3
replace married=0 if marital_status !=2 & marital_status!=3
la var married "person is monogomously or polygomously married (dg3)"

**OffICIAL ID (if answered yes to any type of official id; verify if we need to exclude any types)
gen official_id=.
replace official_id=1 if dg5_1 ==1 | dg5_2==1 | dg5_3==1 | dg5_4==1 | dg5_5==1 | dg5_6==1 | dg5_7==1 | dg5_8==1 | dg5_9==1 | dg5_10==1
replace official_id=0 if dg5_1 ==2 & dg5_2==2 & dg5_3==2 & dg5_4==2 & dg5_5==2 & dg5_6==2 & dg5_7==2 & dg5_8==2 & dg5_9==2 & dg5_10==2
la var official_id "has any type of official identification (dg5_1 to dg5_10)"

**EMPLOYED (if working full or part time for a regular salary, self-employed, or working occasionally, irregular pay)
gen employed=.
replace employed=1 if employment_status <=4 
replace employed=0 if employment_status>4
la var employed "person works full-time, part-time, irregularly, or is self-employed (dl1)"

**RECEIVE FINANCIAL SUPPORT FROM GOV, NON-PROFIT, OR FAMILY (pension/welfare/remittances)
gen rec_support=.
replace rec_support=1 if dl5 <=7 | dl5==10 | dl5==11 | dl5==12 
replace rec_support=0 if dl5 ==8 | dl5==9 | (dl5>=13 & dl5<=18)
la var rec_support "person is unemployed but receives financial support from family, government, or non-profit org (dl5)"

**SPONTANEOUS RECALL of DFS providers
gen dfs_aware_spont=.
replace dfs_aware_spont=1 if mm2_1==1 | mm2_2==1 | mm2_3==1 | mm2_4==1 | mm2_5==1 | mm2_6==1 | mm2_7==1 | mm2_8==1
replace dfs_aware_spont=0 if mm2_1==2 & mm2_2==2 & mm2_3==2 & mm2_4==2 & mm2_5==2 & mm2_6==2 & mm2_7==2 & mm2_8==2
la var dfs_aware_spont "person could spontaneously recall name of any DFS provider (mm2_1-8)"

**PROMPTED RECALL of DFS providers
gen dfs_aware_prompt=.
replace dfs_aware_prompt=1 if mm3_1==1 | mm3_2==1 | mm3_3==1 | mm3_4==1 | mm3_5==1 | mm3_6==1 | mm3_7==1 | mm3_8==1
replace dfs_aware_prompt=0 if mm3_1==2 & mm3_2==2 & mm3_3==2 & mm3_4==2 & mm3_5==2 & mm3_6==2 & mm3_7==2 & mm3_8==2
la var dfs_aware_prompt "person could recall name of any DFS provider when prompted with the provider's name(mm3_1-8)"

**SPONTANEOUS OR PROMPTED RECALL of DFS providers
gen dfs_aware_name=.
replace dfs_aware_name=1 if dfs_aware_spont==1 | dfs_aware_prompt==1
replace dfs_aware_name=0 if dfs_aware_spont==0 & dfs_aware_prompt==0

**SOURCE OF INFORMATION FROM WHICH THEY LEARNED ABOUT DFS
//Eliminated in Wave 3
//Question: From which source of information did you first learn about this mobile money service?
//each question asks where they learned about a specific provider so combining to learn how they learned about any provider

gen dfs_aware_radio=.
replace dfs_aware_radio=1 if mm4_1==1 | mm4_2==1 | mm4_3==1 | mm4_4==1 | mm4_5==1 | mm4_6==1 | mm4_7==1 | mm4_8==1
replace dfs_aware_radio=0 if mm4_1!=1 & mm4_2!=1 & mm4_3!=1 & mm4_4!=1 & mm4_5!=1 & mm4_6!=1 & mm4_7!=1 & mm4_8!=1
replace dfs_aware_radio=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_radio "person first learned about any DFS provider from radio (mm4_1-8)"

gen dfs_aware_tv=.
replace dfs_aware_tv=1 if mm4_1==2 | mm4_2==2 | mm4_3==2 | mm4_4==2 | mm4_5==2 | mm4_6==2 | mm4_7==2 | mm4_8==2
replace dfs_aware_tv=0 if mm4_1!=2 & mm4_2!=2 & mm4_3!=2 & mm4_4!=2 & mm4_5!=2 & mm4_6!=2 & mm4_7!=2 & mm4_8!=2
replace dfs_aware_tv=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_tv "person first learned about any DFS provider from television (mm4_1-8)"

gen dfs_aware_billboard=.
replace dfs_aware_billboard=1 if mm4_1==3 | mm4_2==3 | mm4_3==3 | mm4_4==3 | mm4_5==3 | mm4_6==3 | mm4_7==3 | mm4_8==3
replace dfs_aware_billboard=0 if mm4_1!=3 & mm4_2!=3 & mm4_3!=3 & mm4_4!=3 & mm4_5!=3 & mm4_6!=3 & mm4_7!=3 & mm4_8!=3
replace dfs_aware_billboard=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_billboard "person first learned about any DFS provider from a billboard/poster (mm4_1-8)"

gen dfs_aware_newspaper=.
replace dfs_aware_newspaper=1 if mm4_1==4 | mm4_2==4 | mm4_3==4 | mm4_4==4 | mm4_5==4 | mm4_6==4 | mm4_7==4 | mm4_8==4
replace dfs_aware_newspaper=0 if mm4_1!=4 & mm4_2!=4 & mm4_3!=4 & mm4_4!=4 & mm4_5!=4 & mm4_6!=4 & mm4_7!=4 & mm4_8!=4
replace dfs_aware_newspaper=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_newspaper "person first learned about any DFS provider from a newspaper/magazine (mm4_1-8)"

gen dfs_aware_household=. 
replace dfs_aware_household=1 if mm4_1==5 | mm4_2==5 | mm4_3==5 | mm4_4==5 | mm4_5==5 | mm4_6==5 | mm4_7==5 | mm4_8==5
replace dfs_aware_household=0 if mm4_1!=5 & mm4_2!=5 & mm4_3!=5 & mm4_4!=5 & mm4_5!=5 & mm4_6!=5 & mm4_7!=5 & mm4_8!=5
replace dfs_aware_household=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_household "person first learned about any DFS provider from a fam member in their household (mm4_1-8)"

gen dfs_aware_otherfam=.
replace dfs_aware_otherfam=1 if mm4_1==6 | mm4_2==6 | mm4_3==6 | mm4_4==6 | mm4_5==5 | mm4_6==6 | mm4_7==6 | mm4_8==6
replace dfs_aware_otherfam=0 if mm4_1!=6 & mm4_2!=6 & mm4_3!=6 & mm4_4!=6 & mm4_5!=5 & mm4_6!=6 & mm4_7!=6 & mm4_8!=6
replace dfs_aware_otherfam=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_otherfam "person first learned about any DFS provider from a fam member in another household (mm4_1-8)"

gen dfs_aware_friend=.
replace dfs_aware_friend=1 if mm4_1==7 | mm4_2==7 | mm4_3==7 | mm4_4==7 | mm4_5==7 | mm4_6==7 | mm4_7==7 | mm4_8==7
replace dfs_aware_friend=0 if mm4_1!=7 & mm4_2!=7 & mm4_3!=7 & mm4_4!=7 & mm4_5!=7 & mm4_6!=7 & mm4_7!=7 & mm4_8!=7
replace dfs_aware_friend=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_friend "person first learned about any DFS provider from a friend, neighbor, or other relative (mm4_1-8)"

gen dfs_aware_workmate=.
replace dfs_aware_workmate=1 if mm4_1==8 | mm4_2==8 | mm4_3==8 | mm4_4==8 | mm4_5==8 | mm4_6==8 | mm4_7==8 | mm4_8==8
replace dfs_aware_workmate=0 if mm4_1!=8 & mm4_2!=8 & mm4_3!=8 & mm4_4!=8 & mm4_5!=8 & mm4_6!=8 & mm4_7!=8 & mm4_8!=8
replace dfs_aware_workmate=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_workmate "person first learned about any DFS provider from a workmate or business partner (mm4_1-8)"

gen dfs_aware_cust=.
replace dfs_aware_cust=1 if mm4_1==9 | mm4_2==9 | mm4_3==9 | mm4_4==9 | mm4_5==9 | mm4_6==9 | mm4_7==9 | mm4_8==9
replace dfs_aware_cust=0 if mm4_1!=9 & mm4_2!=9 & mm4_3!=9 & mm4_4!=9 & mm4_5!=9 & mm4_6!=9 & mm4_7!=9 & mm4_8!=9
replace dfs_aware_cust=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_cust "person first learned about any DFS provider from a customer of their business (mm4_1-8)"

gen dfs_aware_admin=.
replace dfs_aware_admin=1 if mm4_1==10 | mm4_2==10 | mm4_3==10 | mm4_4==10 | mm4_5==10 | mm4_6==10 | mm4_7==10 | mm4_8==10
replace dfs_aware_admin=0 if mm4_1!=10 & mm4_2!=10 & mm4_3!=10 & mm4_4!=10 & mm4_5!=10 & mm4_6!=10 & mm4_7!=10 & mm4_8!=10
replace dfs_aware_admin=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_admin "person first learned about any DFS provider from elected/administrative officials (mm4_1-8)"

gen dfs_aware_bankemp=.
replace  dfs_aware_bankemp=1 if mm4_1==11 | mm4_2==11 | mm4_3==11 | mm4_4==11 | mm4_5==11 | mm4_6==11 | mm4_7==11 | mm4_8==11
replace  dfs_aware_bankemp=0 if mm4_1!=11 & mm4_2!=11 & mm4_3!=11 & mm4_4!=11 & mm4_5!=11 & mm4_6!=11 & mm4_7!=11 & mm4_8!=11
replace  dfs_aware_bankemp=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var  dfs_aware_bankemp "person first learned about any DFS provider from a bank/MFI employee (mm4_1-8)"

gen dfs_aware_fingroup=.
replace dfs_aware_fingroup=1 if mm4_1==12 | mm4_2==12 | mm4_3==12 | mm4_4==12 | mm4_5==12 | mm4_6==12 | mm4_7==12 | mm4_8==12
replace dfs_aware_fingroup=0 if mm4_1!=12 & mm4_2!=12 & mm4_3!=12 & mm4_4!=12 & mm4_5!=12 & mm4_6!=12 & mm4_7!=12 & mm4_8!=12
replace dfs_aware_fingroup=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_fingroup "person first learned about any DFS provider from informal financial group (mm4_1-8)"

gen dfs_aware_agent=.
replace dfs_aware_agent=1 if mm4_1==13 | mm4_2==13 | mm4_3==13 | mm4_4==13 | mm4_5==13 | mm4_6==13 | mm4_7==13 | mm4_8==13
replace dfs_aware_agent=0 if mm4_1!=13 & mm4_2!=13 & mm4_3!=13 & mm4_4!=13 & mm4_5!=13 & mm4_6!=13 & mm4_7!=13 & mm4_8!=13
replace dfs_aware_agent=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_agent "person first learned about any DFS provider from transactional DFS agent (mm4_1-8)"

gen dfs_aware_fieldagent=.
replace dfs_aware_fieldagent=1 if mm4_1==14 | mm4_2==14 | mm4_3==14 | mm4_4==14 | mm4_5==14 | mm4_6==14 | mm4_7==14 | mm4_8==14
replace dfs_aware_fieldagent=0 if mm4_1!=14 & mm4_2!=14 & mm4_3!=14 & mm4_4!=14 & mm4_5!=14 & mm4_6!=14 & mm4_7!=14 & mm4_8!=14
replace dfs_aware_fieldagent=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_fieldagent "person first learned about any DFS provider from a DFS field agent/promoter(mm4_1-8)"

gen dfs_aware_sms=.
replace dfs_aware_sms=1 if mm4_1==15 | mm4_2==15 | mm4_3==15 | mm4_4==15 | mm4_5==15 | mm4_6==15 | mm4_7==15 | mm4_8==15
replace dfs_aware_sms=0 if mm4_1!=15 & mm4_2!=15 & mm4_3!=15 & mm4_4!=15 & mm4_5!=15 & mm4_6!=15 & mm4_7!=15 & mm4_8!=15
replace dfs_aware_sms=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_sms "person first learned about any DFS provider from a SMS alert from provider (mm4_1-8)"

gen dfs_aware_event=.
replace dfs_aware_event=1 if mm4_1==16 | mm4_2==16 | mm4_3==16 | mm4_4==16 | mm4_5==16 | mm4_6==16 | mm4_7==16 | mm4_8==16
replace dfs_aware_event=0 if mm4_1!=16 & mm4_2!=16 & mm4_3!=16 & mm4_4!=16 & mm4_5!=16 & mm4_6!=16 & mm4_7!=16 & mm4_8!=16
replace dfs_aware_event=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_event "person first learned about any DFS provider from street event, bus, announcer (mm4_1-8)"

gen dfs_aware_other=.
replace dfs_aware_other=1 if mm4_1==17 | mm4_2==17 | mm4_3==17 | mm4_4==17 | mm4_5==17 | mm4_6==17 | mm4_7==17 | mm4_8==17
replace dfs_aware_other=0 if mm4_1!=17 & mm4_2!=17 & mm4_3!=17 & mm4_4!=17 & mm4_5!=17 & mm4_6!=17 & mm4_7!=17 & mm4_8!=17
replace dfs_aware_other=. if mm4_1==. & mm4_2==. & mm4_3==. & mm4_4==. & mm4_5==. & mm4_6==. & mm4_7==. & mm4_8==.
la var dfs_aware_other "person first learned about any DFS provider from other source (mm4_1-8)"

**EVER USED DFS
**Question: Have you ever used this mobile money service for any financial activity? (one question for each DFS provider, combining them to find out if they have ever used any DFS service)
gen dfs_adopt=.
replace dfs_adopt=1 if mm5_1==1 | mm5_2==1 | mm5_3==1 | mm5_4==1 | mm5_5==1 | mm5_6==1 | mm5_7==1 | mm5_8==1  
replace dfs_adopt=0 if mm5_1!=1 & mm5_2!=1 & mm5_3!=1 & mm5_4!=1 & mm5_5!=1 & mm5_6!=1 & mm5_7!=1 & mm5_8!=1
replace dfs_adopt=. if mm5_1==. & mm5_2==. & mm5_3==. & mm5_4==. & mm5_5==. & mm5_6==. & mm5_7==. & mm5_8==.
la var dfs_adopt "person has ever used DFS for any financial activity (mm5_2-8)"

**LAST USED DFS
//Question: Apart from today, when was the last time you conducted any financial activity with this mobile money service?
//One question for each DFS provider, so we are combining them to find out the last time individual used any of the DFS services
//Only including most recent use for each person

gen dfs_lastuse_yest=.
replace dfs_lastuse_yest=1 if mm7_1==1 | mm7_2==1 | mm7_3==1 | mm7_4==1 | mm7_5==1 | mm7_6==1 | mm7_7==1 | mm7_8==1
replace dfs_lastuse_yest=0 if mm7_1!=1 & mm7_2!=1 & mm7_3!=1 & mm7_4!=1 & mm7_5!=1 & mm7_6!=1 & mm7_7!=1 & mm7_8!=1
replace dfs_lastuse_yest=. if mm7_1==. & mm7_2==. & mm7_3==. & mm7_4==. & mm7_5==. & mm7_6==. & mm7_7==. & mm7_8==.
la var dfs_lastuse_yest "person used DFS yesterday (mm7_1-8)"

gen dfs_lastuse_week=.
replace dfs_lastuse_week=1 if mm7_1==2 | mm7_2==2 | mm7_3==2 | mm7_4==2 | mm7_5==2 | mm7_6==2 | mm7_7==2 | mm7_8==2
replace dfs_lastuse_week=0 if (mm7_1!=2 & mm7_2!=2 & mm7_3!=2 & mm7_4!=2 & mm7_5!=2 & mm7_6!=2 & mm7_7!=2 & mm7_8!=2) | dfs_lastuse_yest==1
replace dfs_lastuse_week=. if mm7_1==. & mm7_2==. & mm7_3==. & mm7_4==. & mm7_5==. & mm7_6==. & mm7_7==. & mm7_8==.
la var dfs_lastuse_week "person used DFS in the past 7 days (mm7_1-8)"

gen dfs_lastuse_month=.
replace dfs_lastuse_month=1 if mm7_1==3 | mm7_2==3 | mm7_3==3 | mm7_4==3 | mm7_5==3 | mm7_6==3 | mm7_7==3 | mm7_8==3
replace dfs_lastuse_month=0 if (mm7_1!=3 & mm7_2!=3 & mm7_3!=3 & mm7_4!=3 & mm7_5!=3 & mm7_6!=3 & mm7_7!=3 & mm7_8!=3) | dfs_lastuse_yest==1 | dfs_lastuse_week==1
replace dfs_lastuse_month=. if mm7_1==. & mm7_2==. & mm7_3==. & mm7_4==. & mm7_5==. & mm7_6==. & mm7_7==. & mm7_8==.
la var dfs_lastuse_month "person used DFS in the past 30 days (mm7_1-8)"

gen dfs_lastuse_90days=.
replace dfs_lastuse_90days=1 if mm7_1==4 | mm7_2==4 | mm7_3==4 | mm7_4==4 | mm7_5==4 | mm7_6==4 | mm7_7==4 | mm7_8==4
replace dfs_lastuse_90days=0 if (mm7_1!=4 & mm7_2!=4 & mm7_3!=4 & mm7_4!=4 & mm7_5!=4 & mm7_6!=4 & mm7_7!=4 & mm7_8!=4) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1
replace dfs_lastuse_90days=. if mm7_1==. & mm7_2==. & mm7_3==. & mm7_4==. & mm7_5==. & mm7_6==. & mm7_7==. & mm7_8==.
la var dfs_lastuse_90days "person used DFS in the past 90 days (mm7_1-8)"

gen dfs_lastuse_more90=.
replace dfs_lastuse_more90=1 if mm7_1==5 | mm7_2==5 | mm7_3==5 | mm7_4==5 | mm7_5==5 | mm7_6==5 | mm7_7==5 | mm7_8==5
replace dfs_lastuse_more90=0 if (mm7_1!=5 & mm7_2!=5 & mm7_3!=5 & mm7_4!=5 & mm7_5!=5 & mm7_6!=5 & mm7_7!=5 & mm7_8!=5) | dfs_lastuse_yest==1 | dfs_lastuse_week==1 | dfs_lastuse_month==1 | dfs_lastuse_90days==1
replace dfs_lastuse_more90=. if mm7_1==. & mm7_2==. & mm7_3==. & mm7_4==. & mm7_5==. & mm7_6==. & mm7_7==. & mm7_8==.
la var dfs_lastuse_more90 "person last used DFS more than 90 days ago (mm7_1-8)"


//Generating dfs_use categorical variable
egen dfs_use=rowmin(mm7_*)
replace dfs_use=. if dfs_adopt!=1
tab dfs_use
la var dfs_use "When did you last use MM?"
label define dfs_use1 1 "Yesterday" 2 "Less than a Week" 3 "Less than a Month" 4 "Less than 90 Days" 5 "More than 90 Days"
label values dfs_use dfs_use1


**REGISTERED ACCOUNT
//Question: Do you have a registered account (account registered in your name) with this mobile money service?
//One question for each DFS provider, so we are combining them 
gen dfs_regacct=.
replace dfs_regacct=1 if mm8_1==1 | mm8_2==1 | mm8_3==1 | mm8_4==1 | mm8_5==1 | mm8_6==1 | mm8_7==1 | mm8_8==1
replace dfs_regacct=0 if mm8_1!=1 & mm8_2!=1 & mm8_3!=1 & mm8_4!=1 & mm8_5!=1 & mm8_6!=1 & mm8_7!=1 & mm8_8!=1
replace dfs_regacct=. if mm8_1==. & mm8_2==. & mm8_3==. & mm8_4==. & mm8_5==. & mm8_6==. & mm8_7==. & mm8_8==.
la var dfs_regacct "person has a registered account with any DFS provider (mm8_1-8)"


**HOW DO YOU ACCESS DFS
//How do you usually access this mobile money service?
//One question for each DFS provider, so we are combining them 

//Over the counter or by using an agent’s account
gen dfs_access_otc=.
replace dfs_access_otc=1 if mm15_1==1 | mm15_2==1 | mm15_3==1 | mm15_4==1 | mm15_5==1 | mm15_6==1 | mm15_7==1 | mm15_8==1
replace dfs_access_otc=0 if mm15_1!=1 & mm15_2!=1 & mm15_3!=1 & mm15_4!=1 & mm15_5!=1 & mm15_6!=1 & mm15_7!=1 & mm15_8!=1
replace dfs_access_otc=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_otc "person usually accesses DFS over the counter (mm15_1-8)"

//Account of a family member in this household
gen dfs_access_fam=.
replace dfs_access_fam=1 if mm15_1==2 | mm15_2==2 | mm15_3==2 | mm15_4==2 | mm15_5==2 | mm15_6==2 | mm15_7==2 | mm15_8==2
replace dfs_access_fam=0 if mm15_1!=2 & mm15_2!=2 & mm15_3!=2 & mm15_4!=2 & mm15_5!=2 & mm15_6!=2 & mm15_7!=2 & mm15_8!=2
replace dfs_access_fam=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_fam "person usually accesses DFS from a family member's acct in the hh (mm15_1-8)"

//Account of a family member in another household, other relative, friend or a neighbor
gen dfs_access_nonhh=.
replace dfs_access_nonhh=1 if mm15_1==3 | mm15_2==3 | mm15_3==3 | mm15_4==3 | mm15_5==3 | mm15_6==3 | mm15_7==3 | mm15_8==3
replace dfs_access_nonhh=0 if mm15_1!=3 & mm15_2!=3 & mm15_3!=3 & mm15_4!=3 & mm15_5!=3 & mm15_6!=3 & mm15_7!=3 & mm15_8!=3
replace dfs_access_nonhh=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_nonhh "person usually accesses DFS from a family member in another hh, friend, or neib (mm15_1-8)"

//Account of a workmate or a business partner
gen dfs_access_work=.
replace dfs_access_work=1 if mm15_1==4 | mm15_2==4 | mm15_3==4 | mm15_4==4 | mm15_5==4 | mm15_6==4 | mm15_7==4 | mm15_8==4
replace dfs_access_work=0 if mm15_1!=4 & mm15_2!=4 & mm15_3!=4 & mm15_4!=4 & mm15_5!=4 & mm15_6!=4 & mm15_7!=4 & mm15_8!=4
replace dfs_access_work=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_work "person usually accesses DFS from a workmate or business partner (mm15_1-8)"

//Their own account
gen dfs_access_ownacct=.
replace dfs_access_ownacct=1 if mm15_1==5 | mm15_2==5 | mm15_3==5 | mm15_4==5 | mm15_5==5 | mm15_6==5 | mm15_7==5 | mm15_8==5
replace dfs_access_ownacct=0 if mm15_1!=5 & mm15_2!=5 & mm15_3!=5 & mm15_4!=5 & mm15_5!=5 & mm15_6!=5 & mm15_7!=5 & mm15_8!=5
replace dfs_access_ownacct=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_ownacct "person usually accesses DFS from their own account (mm15_1-8)"

//Other
gen dfs_access_other=.
replace dfs_access_other=1 if mm15_1==6 | mm15_2==6 | mm15_3==6 | mm15_4==6 | mm15_5==6 | mm15_6==6 | mm15_7==6 | mm15_8==6
replace dfs_access_other=0 if mm15_1!=6 & mm15_2!=6 & mm15_3!=6 & mm15_4!=6 & mm15_5!=6 & mm15_6!=6 & mm15_7!=6 & mm15_8!=6
replace dfs_access_other=. if mm15_1==. & mm15_2==. & mm15_3==. & mm15_4==. & mm15_5==. & mm15_6==. & mm15_7==. & mm15_8==.
la var dfs_access_other "person usually accesses DFS in an other way (mm15_1-8)"


*REMITTANCES
count if dl4_7==1 //Do you supplement your income by any of the following? Remittances/monetary or other help from other family members (siblings, cousins, etc.), relatives or friends [1032 missing for all DL4_* questions].
count if dl5==7 //You said you did not have a regular job/were not working in the past 12 months. What is your main source of money for daily expenses? 7= remittances/monetary or other help from other family members]
count if dl6_7==1 //What are your other/secondary sources of money? Remittances/monetary or other help from other family members (siblings, cousins, etc.), relatives or friends [1973 missing for all secondary source questions]

gen rec_remit=.
replace rec_remit=0 if dl4_7==2 | dl6_7==2 //0 if answered "no" to DL4_7 or DL6_7, not considering response to DL5 b/c it only asks if remittances are *main* source of money
replace rec_remit=1 if dl4_7==1 | dl5==7 | dl6_7==1 //if answered "yes" to any question asking about receipt of remittances 
la var rec_remit "person receives remittances (DL4_7, DL6_7, DL5)"

**COMFORT/SKILL WITH MOBILE TECHNOLOGY
//Basic Use - person can make phone calls
gen mobileskills_call=.
replace mobileskills_call=1 if tdl2_1==3 | tdl2_1==4  //if person can make phone calls somewhat or very well
replace mobileskills_call=0 if tdl2_1==0 | tdl2_1==1 | tdl2_1==2 //if person never does this or does it very or somewhat poorly
la var mobileskills_call "person can dial numbers on their phone somewhat or very well (TDL2_1)"

//Texting - person can either send or respond to text messages
gen mobileskills_text=.
replace mobileskills_text=1 if tdl2_4==3 | tdl2_4==4 | tdl2_5==3 | tdl2_5==4 //if person can either send or respond to text messages somewhat or very well
replace mobileskills_text=0	if (tdl2_4==0 | tdl2_4==1 | tdl2_4==2) & (tdl2_5==0 | tdl2_5==1 | tdl2_5==2) //if person can NEITHER send NOR respond to text messages somewhat or very well
la var mobileskills_text "person can send and/or respond to text messages somewhat or very well (DL2_4, DL2_5)"

count if (tdl2_4==3 | tdl2_4==4) & tdl2_5<3 //202 people can send text messages but cannot respond to text messages from other people -- these people still have a 1 for mobileskills_text

//Internet use
gen mobileskills_internet=.
replace mobileskills_internet=1 if tdl2_8>=3 | tdl2_9>=3 | tdl2_10>=3 | tdl2_11>=3 | tdl2_13>=3
replace mobileskills_internet=0	if tdl2_8<3 & tdl2_9<3 & tdl2_10<3 & tdl2_11<3 & tdl2_13<3 
replace mobileskills_internet=. if tdl2_8==. & tdl2_9==. & tdl2_10==. & tdl2_11==. & tdl2_13==. 
la var mobileskills_internet "person can use their phone to access internet somewhat or very well (TDL2_8,9,10,11,13"


//Label newly generated variable values 0=no; 1=yes 
#d ;
local yesnogen rural married official_id employed dfs_aware_spont dfs_aware_prompt dfs_aware_radio dfs_aware_tv 
	dfs_aware_billboard dfs_aware_newspaper dfs_aware_household dfs_aware_otherfam dfs_aware_friend dfs_aware_workmate 
	dfs_aware_cust dfs_aware_admin dfs_aware_bankemp dfs_aware_fingroup dfs_aware_agent dfs_aware_fieldagent dfs_aware_sms 
	dfs_aware_event dfs_aware_other dfs_adopt dfs_lastuse_yest dfs_lastuse_week dfs_lastuse_month dfs_lastuse_90days 
	dfs_lastuse_more90 dfs_regacct dfs_access_otc dfs_access_fam dfs_access_nonhh dfs_access_work dfs_access_ownacct dfs_access_other
	mobileskills_call mobileskills_text mobileskills_internet rec_remit ppi_cutoff literate numerate dfs_aware_name rural_female
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

save "R:\Project\EPAR\Working Files\317 - Gender and DFS Adoption\DTAs\W2\Pakistan_W2_Clean.dta", replace



