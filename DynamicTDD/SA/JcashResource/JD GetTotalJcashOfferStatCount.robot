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

    ${resp}=  Get Total Jaldee Cash Offer Stat Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Numbers  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Numbers  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Numbers  ${resp.json()[3]['count']['amount']}          0.0
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

    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
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

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
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
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Total Jaldee Cash Offer Stat Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  1
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[2]}
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
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
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

    ${resp}=  Get Total Jaldee Cash Offer Stat Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  2
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[2]}
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
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
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

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Total Jaldee Cash Offer Stat Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[0]['statType']}                 ${statType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['count']['amount']}          ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['count']['consumersCount']}  2
    Should Be Equal As Strings  ${resp.json()[0]['count']['offersCount']}     1
    Should Be Equal As Strings  ${resp.json()[0]['count']['spsCount']}        0
    
    Should Be Equal As Strings  ${resp.json()[1]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[1]['statType']}                 ${statType[3]}
    Should Be Equal As Strings  ${resp.json()[1]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[1]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[1]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[1]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[2]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[2]['statType']}                 ${statType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[2]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[2]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[2]['count']['spsCount']}        0

    Should Be Equal As Strings  ${resp.json()[3]['dateCategory']}             ${dateCategory[2]}
    Should Be Equal As Strings  ${resp.json()[3]['statType']}                 ${statType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['count']['amount']}          0.0
    Should Be Equal As Strings  ${resp.json()[3]['count']['consumersCount']}  0
    Should Be Equal As Strings  ${resp.json()[3]['count']['offersCount']}     0
    Should Be Equal As Strings  ${resp.json()[3]['count']['spsCount']}        0

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashOfferStatCountToday-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
   
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-GetJcashOfferStatCountToday-UH1

#     [Documentation]    Get jaldee cash offer stat count today without login.  
    
#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SESSION_EXPIRED_IN_SA}"

# JD-TC-GetJcashOfferStatCountToday-UH2

#     [Documentation]    Get jaldee cash offer stat count today by consumer login.  
    
#     ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SESSION_EXPIRED_IN_SA}"

# JD-TC-GetJcashOfferStatCountToday-UH3

#     [Documentation]    Get jaldee cash offer stat count today by provider login.  
    
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Jaldee Cash Offer Stat Count for Today
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   419
#     Should Be Equal As Strings   ${resp.content}   "${SESSION_EXPIRED_IN_SA}"

