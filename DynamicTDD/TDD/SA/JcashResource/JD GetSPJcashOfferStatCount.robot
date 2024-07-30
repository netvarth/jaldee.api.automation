*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JCash
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/Keywords.robot


*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${CUSERPH}      ${CUSERNAME}
${tz}   Asia/Kolkata



*** Test Cases ***

JD-TC-GetSPJcashOfferStatCount-1

    [Documentation]    Get SP jaldee cash offer stat count AWARDED TODAY by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.content}
    
    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetSPJcashOfferStatCount-2

    [Documentation]    Get SP jaldee cash offer stat count AWARDED TODAY after provider signup.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Test Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Test Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7850021
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetSPJcashOfferStatCount-3

    [Documentation]    Get SP jaldee cash offer stat count AWARDED TODAY after consumer signup.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+177882
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${create_day}=  db.get_date_by_timezone  ${tz}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_id}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetSPJcashOfferStatCount-5

    [Documentation]    Get SP jaldee cash offer stat count REDEEMED TODAY by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME120}
    clear_location   ${PUSERNAME120}
    clear_service    ${PUSERNAME120}
    clear_customer   ${PUSERNAME120}
    clear_Coupon     ${PUSERNAME120}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${pid}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME120}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME120}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
	
    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=60   max=150
    ${Tot}=   Random Int   min=200   max=1000
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  1  00  
    ${eTime}=  add_timezone_time  ${tz}   4   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH5}=  Evaluate  ${CUSERPH}+10499789
    Set Suite Variable   ${CUSERPH5}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH5}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH5}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+4468
    ${firstname5}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname5}
    ${lastname5}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname5}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL5}=   Set Variable  ${C_Email}ph${CUSERPH5}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname5}  ${lastname5}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL5}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL5}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id5}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetSPJcashOfferStatCount-6

    [Documentation]    Get SP jaldee cash offer stat count REDEEMED TODAY by multiple consumers for same SP.  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name5}=  FakerLibrary.name
    Set Suite Variable   ${name5}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name5}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH6}=  Evaluate  ${CUSERPH}+104998
    Set Suite Variable   ${CUSERPH6}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH6}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH6}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH6}+4468
    ${firstname6}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname6}
    ${lastname6}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname6}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL6}=   Set Variable  ${C_Email}ph${CUSERPH6}.${test_mail}
    Set Suite Variable   ${CUSERMAIL6} 
    ${resp}=  Consumer SignUp  ${firstname6}  ${lastname6}  ${address}  ${CUSERPH6}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL6}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL6}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL6}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id6}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid1}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid1}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-GetSPJcashOfferStatCount-7

    [Documentation]    Get SP jaldee cash offer stat count REDEEMED TODAY by multiple consumers for different SP. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name6}=  FakerLibrary.name
    Set Suite Variable   ${name6}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name6}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME121}
    clear_location   ${PUSERNAME121}
    clear_service    ${PUSERNAME121}
    clear_customer   ${PUSERNAME121}
    clear_Coupon     ${PUSERNAME121}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid1}=  get_acc_id  ${PUSERNAME121}
    Set Suite Variable  ${pid1}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME120}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid1}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME120}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
	
    ${p1_lid1}=  Create Sample Location

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid1}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=60   max=150
    ${Tot}=   Random Int   min=200   max=1000
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    # Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    # Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    # Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid3}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    # Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid4}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  1  00  
    ${eTime}=  add_timezone_time  ${tz}   4   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid1}  ${p1_sid3}  ${p1_sid4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH7}=  Evaluate  ${CUSERPH}+1049974
    Set Suite Variable   ${CUSERPH7}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH7}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH7}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH7}+4468
    ${firstname7}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname7}
    ${lastname7}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname7}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL7}=   Set Variable  ${C_Email}ph${CUSERPH7}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname7}  ${lastname7}  ${address}  ${CUSERPH7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL7}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL7}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id7}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist AdvancePayment Details   ${pid1}  ${p1_qid1}  ${DAY}  ${p1_sid3}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p1_qid1}  ${DAY}  ${p1_sid3}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid1}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid1}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 
    Should Be equal As Strings    ${resp.json()[1]['account']['id']}  ${pid1} 
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetSPJcashOfferStatCount-8

    [Documentation]    Get SP jaldee cash offer stat count REDEEMED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 
    Should Be equal As Strings    ${resp.json()[1]['account']['id']}  ${pid1} 

JD-TC-GetSPJcashOfferStatCount-9

    [Documentation]    Get SP jaldee cash offer stat count REDEEMED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetSPJcashOfferStatCount-10

    [Documentation]    Get SP jaldee cash offer stat count AWARDED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []
  

JD-TC-GetSPJcashOfferStatCount-11

    [Documentation]    Get SP jaldee cash offer stat count AWARDED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []
  
JD-TC-GetSPJcashOfferStatCount-12

    [Documentation]    Get SP jaldee cash offer stat count REFUNDED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name7}=  FakerLibrary.name
    Set Suite Variable   ${name7}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name7}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH7}=  Evaluate  ${CUSERPH}+1049456
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH7}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH7}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH7}+4468
    ${firstname7}=  FakerLibrary.first_name
    ${lastname7}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL7}=   Set Variable  ${C_Email}ph${CUSERPH7}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname7}  ${lastname7}  ${address}  ${CUSERPH7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL7}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL7}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  3  
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid2}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid2}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid2}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  Cancel Waitlist  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Sleep  3s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
JD-TC-GetSPJcashOfferStatCount-13

    [Documentation]    Get SP jaldee cash offer stat count REFUNDED TODAY by multiple consumers for different SPs.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name8}=  FakerLibrary.name
    Set Suite Variable   ${name8}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name8}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH7}=  Evaluate  ${CUSERPH}+104945786
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH7}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH7}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH7}+4468
    ${firstname7}=  FakerLibrary.first_name
    ${lastname7}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL7}=   Set Variable  ${C_Email}ph${CUSERPH7}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname7}  ${lastname7}  ${address}  ${CUSERPH7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL7}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL7}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  3  
    ${resp}=  Waitlist AdvancePayment Details   ${pid1}  ${p1_qid1}  ${DAY1}  ${p1_sid3}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p1_qid1}  ${DAY1}  ${p1_sid3}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid2}  ${wid[0]} 
   
    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid2}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    # Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid2}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  Cancel Waitlist  ${cwid2}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 
    Should Be equal As Strings    ${resp.json()[1]['account']['id']}  ${pid1} 

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
JD-TC-GetSPJcashOfferStatCount-14

    [Documentation]    Get SP jaldee cash offer stat count REFUNDED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['account']['id']}  ${pid} 
    Should Be equal As Strings    ${resp.json()[1]['account']['id']}  ${pid1} 

  
JD-TC-GetSPJcashOfferStatCount-15

    [Documentation]    Get SP jaldee cash offer stat count REFUNDED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []
  
JD-TC-GetSPJcashOfferStatCount-16

    [Documentation]    Get SP jaldee cash offer stat count EXPIRED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[1]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetSPJcashOfferStatCount-17

    [Documentation]    Get SP jaldee cash offer stat count EXPIRED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[1]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetSPJcashOfferStatCount-18

    [Documentation]    Get SP jaldee cash offer stat count EXPIRED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get SP Jaldee Cash Offer Stat Count   ${statType[1]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []


JD-TC-GetSPJcashOfferStatCount-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${name4}
    clear_jcashoffer   ${name5}
    clear_jcashoffer   ${name6}
    clear_jcashoffer   ${name7}
    clear_jcashoffer   ${name8}
   
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
