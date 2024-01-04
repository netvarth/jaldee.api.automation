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

JD-TC-GetJcashOfferStatCountToday-1

    [Documentation]    Get jaldee cash offer stat count today by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.content}
    
    ${jname}=  FakerLibrary.name
    Set Suite Variable   ${jname}
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

    ${resp}=  Create Jaldee Cash Offer  ${jname}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOfferStatCountToday-2

    [Documentation]    Get jaldee cash offer stat count today awarded to one consumer.  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${global_max_limit}    ${resp.content}
    ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
    Set Suite variable   ${global_max_limit}

    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date}
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    Set Suite Variable   ${end_date}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt}
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    Set Suite Variable   ${maxValidUntil}
    ${validForDays}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays}
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    Set Suite Variable   ${ex_date}
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    Set Suite Variable   ${max_limit}
    ${issueLimit}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit}
    ${amt}=  Random Int  min=100   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}

    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+879564
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  1
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0

JD-TC-GetJcashOfferStatCountToday-3

    [Documentation]    Get jaldee cash offer stat count today awarded to multiple consumers(same jcash offer).  
    
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+879587
    Set Suite Variable   ${CUSERPH2}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH2}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH2}${\n}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${total_amt}=  Evaluate   ${amt} + ${amt}
    Set Suite Variable   ${total_amt}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  2
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0

JD-TC-GetJcashOfferStatCountToday-4

    [Documentation]    Create J cash offer for future then tries to Get jaldee cash offer stat count today by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.content}
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}   2  
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

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  2
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0


JD-TC-GetJcashOfferStatCountToday-5

    [Documentation]    Get jaldee cash offer stat count today awarded to multiple consumers(multiple jcash offer).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    ${end_date}=  db.add_timezone_date  ${tz}   17 
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10 
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit1}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    Set Suite Variable   ${max_limit1}
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt1}=  Random Int  min=100   max=500  
    ${amt1}=  Convert To Number  ${amt1}   1
    Set Suite Variable   ${amt1}

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt1}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit1}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+879569
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH3}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH3}${\n}


    ${CUSERPH4}=  Evaluate  ${CUSERPH}+879568
    Set Suite Variable   ${CUSERPH4}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH4}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH4}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH4}${\n}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${total}=  Evaluate   ${amt1} + ${amt1}
    ${total_amt1}=  Evaluate   ${total} + ${total_amt} + ${total_amt}
    Set Suite Variable   ${total_amt1}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt1}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  4
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     2
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0


JD-TC-GetJcashOfferStatCountToday-6

    [Documentation]    Get jaldee cash offer stat count today redeemed by one consumer.

    clear_queue      ${PUSERNAME101}
    clear_location   ${PUSERNAME101}
    clear_service    ${PUSERNAME101}
    clear_customer   ${PUSERNAME101}
    clear_Coupon     ${PUSERNAME101}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME101}
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
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
    
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${elig_amt}=  Evaluate   ${max_limit} + ${max_limit1}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${elig_amt}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${elig_amt}
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

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${total}=  Evaluate   ${amt1} + ${amt1}
    # ${total_amt1}=  Evaluate   ${total} + ${total_amt} 
    # Set Suite Variable   ${total_amt1}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt1}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  4
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     2
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0


JD-TC-GetJcashOfferStatCountToday-7

    [Documentation]    Get jaldee cash offer stat count today redeemed by multiple consumers.

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}   3
    ${elig_amt}=  Evaluate   ${max_limit} + ${max_limit1}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${elig_amt}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${elig_amt}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 
    
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
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

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${total}=  Evaluate   ${amt1} + ${amt1}
    # ${total_amt1}=  Evaluate   ${total} + ${total_amt}
    # Set Suite Variable   ${total_amt1}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt1}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  4
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     2
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0


JD-TC-GetJcashOfferStatCountToday-8

    [Documentation]    Get jaldee cash offer stat count today refunded by one consumer.

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Cancel Waitlist  ${cwid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${total}=  Evaluate   ${amt1} + ${amt1}
    # ${total_amt1}=  Evaluate   ${total} + ${total_amt}
    # Set Suite Variable   ${total_amt1}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt1}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  4
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     2
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0

JD-TC-GetJcashOfferStatCountToday-9

    [Documentation]    Get jaldee cash offer stat count today expiring today.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    ${end_date}=  db.get_date_by_timezone  ${tz}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10 
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit2}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    Set Suite Variable   ${max_limit2}
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt2}=  Random Int  min=100   max=500  
    ${amt2}=  Convert To Number  ${amt1}   1
    Set Suite Variable   ${amt2}

    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt2}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit2}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+879580
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH3}${\n}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${total_amt2}=  Evaluate   ${total_amt1} + ${amt2}
    Set Suite Variable   ${total_amt2}

    ${resp}=  Get Jaldee Cash Offer Stat Count for Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt2}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  5
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     3
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[0]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0


JD-TC-GetJcashOfferStatCountToday-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${jname}
   
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-GetJcashOfferStatCountToday-UH1

#     [Documentation]    Get jaldee cash offer stat count today without login.  
    
#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

# JD-TC-GetJcashOfferStatCountToday-UH2

#     [Documentation]    Get jaldee cash offer stat count today by consumer login.  
    
#     ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

# JD-TC-GetJcashOfferStatCountToday-UH3

#     [Documentation]    Get jaldee cash offer stat count today by provider login.  
    
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

