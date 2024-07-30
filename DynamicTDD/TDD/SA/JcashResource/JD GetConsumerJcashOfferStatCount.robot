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
Resource          /ebs/TDD/AppKeywords.robot


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

JD-TC-GetConsumerJcashOfferStatCount-1

    [Documentation]    Get consumer jaldee cash offer stat count AWARDED TODAY by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetConsumerJcashOfferStatCount-2

    [Documentation]    Get consumer jaldee cash offer stat count AWARDED TODAY after one consumer signup(one jcash offer).   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+17788552
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${create_day}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${create_day}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL1}=   Set Variable  ${C_Email}ph${CUSERPH1}.${test_mail}
    Set Suite Variable   ${CUSERMAIL1}
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id1}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id1} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH1}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL1}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day}   

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetConsumerJcashOfferStatCount-3

    [Documentation]    Get consumer jaldee cash offer stat count AWARDED TODAY after one consumer signup(multiple jcash offers).   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2} 
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

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
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
    ${amt1}=  Random Int  min=100   max=150 
    ${amt1}=  Convert To Number  ${amt1}   1

    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt1}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH2}=  Evaluate  ${CUSERPH}+17788558
    Set Suite Variable   ${CUSERPH2}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH2}${\n}
  
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+4468
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname1}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH2}.${test_mail}
    Set Suite Variable   ${CUSERMAIL2}
    ${resp}=  Android App Consumer SignUp  ${firstname1}  ${lastname1}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id2}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id1} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH1}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL1}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day}   
    
    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id2} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname1}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname1}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH2}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL2}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day}   

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetConsumerJcashOfferStatCount-4

    [Documentation]    Get consumer jaldee cash offer stat count EXPIRED TODAY.   
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4} 
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.get_date_by_timezone  ${tz}  
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

    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+17788550
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH3}${\n}
    
    ${create_day}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${create_day}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname2}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname2}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL3}=   Set Variable  ${C_Email}ph${CUSERPH3}.${test_mail}
    Set Suite Variable   ${CUSERMAIL3}
    ${resp}=  Android App Consumer SignUp  ${firstname2}  ${lastname2}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id3}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[1]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id3} 
    # Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname3}  
    # Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname3}  
    # Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH3}  
    # Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL3}      
    # Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetConsumerJcashOfferStatCount-5

    [Documentation]    Get consumer jaldee cash offer stat count REDEEMED TODAY by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
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

    ${min_pre1}=   Random Int   min=160   max=250
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
    
    ${CUSERPH5}=  Evaluate  ${CUSERPH}+104996369
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
    Set Suite Variable   ${CUSERMAIL5} 
    ${resp}=  Android App Consumer SignUp  ${firstname5}  ${lastname5}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL5}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL5}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH5}  ${PASSWORD}
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
    
    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id5} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname5}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname5}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH5}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL5}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day}   
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetConsumerJcashOfferStatCount-6

    [Documentation]    Get consumer jaldee cash offer stat count REDEEMED TODAY by multiple consumers.  
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
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
    
    ${CUSERPH6}=  Evaluate  ${CUSERPH}+104996371
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
    ${resp}=  Android App Consumer SignUp  ${firstname6}  ${lastname6}  ${address}  ${CUSERPH6}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL6}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL6}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL6}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH6}  ${PASSWORD}
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
    
    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id6} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname6}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname6}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH6}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL6}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day}   

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id5} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname5}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname5}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH5}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL5}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetConsumerJcashOfferStatCount-7

    [Documentation]    Get consumer jaldee cash offer stat count REDEEMED TOTAL by multiple consumers.  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id5} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname5}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname5}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH5}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL5}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 

    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id6} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname6}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname6}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH6}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL6}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day}   

JD-TC-GetConsumerJcashOfferStatCount-8

    [Documentation]    Get consumer jaldee cash offer stat count REDEEMED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetConsumerJcashOfferStatCount-9

    [Documentation]    Get consumer jaldee cash offer stat count AWARDED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
   
    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id1} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH1}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL1}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day}   
    
    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id2} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname1}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname1}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH2}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL2}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day}   

    Should Be equal As Strings    ${resp.json()[2]['id']}           ${cons_id3} 
    Should Be equal As Strings    ${resp.json()[2]['firstName']}    ${firstname2}  
    Should Be equal As Strings    ${resp.json()[2]['lastName']}     ${lastname2}  
    Should Be equal As Strings    ${resp.json()[2]['phoneNumber']}  ${CUSERPH3}  
    Should Be equal As Strings    ${resp.json()[2]['email']}        ${CUSERMAIL3}      
    Should Be equal As Strings    ${resp.json()[2]['createdOn']}    ${create_day}   

    Should Be equal As Strings    ${resp.json()[3]['id']}           ${cons_id5} 
    Should Be equal As Strings    ${resp.json()[3]['firstName']}    ${firstname5}  
    Should Be equal As Strings    ${resp.json()[3]['lastName']}     ${lastname5}  
    Should Be equal As Strings    ${resp.json()[3]['phoneNumber']}  ${CUSERPH5}  
    Should Be equal As Strings    ${resp.json()[3]['email']}        ${CUSERMAIL5}      
    Should Be equal As Strings    ${resp.json()[3]['createdOn']}    ${create_day} 

    Should Be equal As Strings    ${resp.json()[4]['id']}           ${cons_id6} 
    Should Be equal As Strings    ${resp.json()[4]['firstName']}    ${firstname6}  
    Should Be equal As Strings    ${resp.json()[4]['lastName']}     ${lastname6}  
    Should Be equal As Strings    ${resp.json()[4]['phoneNumber']}  ${CUSERPH6}  
    Should Be equal As Strings    ${resp.json()[4]['email']}        ${CUSERMAIL6}      
    Should Be equal As Strings    ${resp.json()[4]['createdOn']}    ${create_day}   

  
JD-TC-GetConsumerJcashOfferStatCount-10

    [Documentation]    Get consumer jaldee cash offer stat count AWARDED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

  
JD-TC-GetConsumerJcashOfferStatCount-11

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
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
    
    ${CUSERPH7}=  Evaluate  ${CUSERPH}+104996387
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
    Set Suite Variable   ${CUSERMAIL7} 
    ${resp}=  Android App Consumer SignUp  ${firstname7}  ${lastname7}  ${address}  ${CUSERPH7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL7}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL7}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id7}    ${resp.json()['id']} 
    
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

    Sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  App Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id7} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname7}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname7}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH7}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL7}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

 
JD-TC-GetConsumerJcashOfferStatCount-12

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED TODAY by multiple consumers.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
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
    
    ${CUSERPH8}=  Evaluate  ${CUSERPH}+1049900227
    Set Suite Variable   ${CUSERPH8}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH8}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH8}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH8}+4468
    ${firstname8}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname8}
    ${lastname8}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname8}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL8}=   Set Variable  ${C_Email}ph${CUSERPH8}.${test_mail}
    Set Suite Variable   ${CUSERMAIL8} 
    ${resp}=  Android App Consumer SignUp  ${firstname8}  ${lastname8}  ${address}  ${CUSERPH8}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL8}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Activation  ${CUSERMAIL8}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL8}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Android App Consumer Login  ${CUSERPH8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id8}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  5  
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
    Set Suite Variable  ${cwid3}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid3}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
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
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid3}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid3}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid3}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid3}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  Cancel Waitlist  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  App Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id7} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname7}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname7}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH7}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL7}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 

    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id8} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname8}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname8}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH8}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL8}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day} 
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetConsumerJcashOfferStatCount-13

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED TOTAL.

     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be equal As Strings    ${resp.json()[0]['id']}           ${cons_id7} 
    Should Be equal As Strings    ${resp.json()[0]['firstName']}    ${firstname7}  
    Should Be equal As Strings    ${resp.json()[0]['lastName']}     ${lastname7}  
    Should Be equal As Strings    ${resp.json()[0]['phoneNumber']}  ${CUSERPH7}  
    Should Be equal As Strings    ${resp.json()[0]['email']}        ${CUSERMAIL7}      
    Should Be equal As Strings    ${resp.json()[0]['createdOn']}    ${create_day} 

    Should Be equal As Strings    ${resp.json()[1]['id']}           ${cons_id8} 
    Should Be equal As Strings    ${resp.json()[1]['firstName']}    ${firstname8}  
    Should Be equal As Strings    ${resp.json()[1]['lastName']}     ${lastname8}  
    Should Be equal As Strings    ${resp.json()[1]['phoneNumber']}  ${CUSERPH8}  
    Should Be equal As Strings    ${resp.json()[1]['email']}        ${CUSERMAIL8}      
    Should Be equal As Strings    ${resp.json()[1]['createdOn']}    ${create_day} 
    

JD-TC-GetConsumerJcashOfferStatCount-14

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED LAST_WEEK.

     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []


JD-TC-GetConsumerJcashOfferStatCount-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${name4}
    clear_jcashoffer   ${name5}
    clear_jcashoffer   ${name6}
    clear_jcashoffer   ${name7}
    clear_jcashoffer   ${name8}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

