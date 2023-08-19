*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JaldeeCoupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/AppKeywords.robot


*** Variables ***

${CUSERPH}      ${CUSERNAME}
${tz}   Asia/Kolkata

*** Test Cases ***

JD-TC-GetAvailableJcashById-1

    [Documentation]    get Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${global_max_limit}    ${resp.content}
    ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
    Set Suite variable   ${global_max_limit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAvailableJcashById-2
   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    
    clear_jcashoffer   ${name}
    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH1}=  Evaluate  ${CUSERPH}+1077473201
    # Set Suite Variable   ${CUSERPH1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    # ${firstname}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname}
    # ${lastname}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH1}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${cons_id}   ${resp.json()['id']}      

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+806855
    Set Suite Variable   ${CUSERPH1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname} 
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id}   ${resp.json()['id']}      
                      
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Set Suite Variable   ${cash_id1}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['jCashOffer']['id']}                             ${offer_id}
    Should Be Equal As Strings  ${resp.json()['jCashOffer']['name']}                           ${name}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                               ${cons_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}         ${firstname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}          ${lastname}
    Should Be Equal As Strings  ${resp.json()['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()['triggerWhen']}                                  ${JCwhen[0]}

JD-TC-GetAvailableJcashById-3

    [Documentation]    tries to get Jaldee cash which the offer created for future date.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date1}=  db.add_timezone_date  ${tz}  1   
    ${end_date1}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt1}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt1}=  Convert To Number  ${minOnlinePaymentAmt1}  1
    ${maxValidUntil1}=  db.add_timezone_date  ${tz}   26  
    ${validForDays1}=  Random Int  min=5   max=10 
    ${ex_date1}=    db.add_timezone_date  ${tz}   ${validForDays1} 
    ${maxSpendLimit1}=  Random Int  min=30   max=100 
    ${maxSpendLimit1}=  Convert To Number  ${maxSpendLimit1}  1
    ${max_limit1}=   Set Variable If  ${maxSpendLimit1} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit1}
    ${issueLimit1}=  Random Int  min=1   max=5 
    ${amt1}=  Random Int  min=100   max=500  
    ${amt1}=  Convert To Number  ${amt1}   1
    
    # clear_jcashoffer   ${name1}
    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt1}  ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit1}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH1}=  Evaluate  ${CUSERPH}+1047890880
    # Set Test Variable   ${CUSERPH1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    # ${firstname1}=  FakerLibrary.first_name
    # ${lastname1}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname1}  ${lastname1}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH1}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable   ${cons_id1}   ${resp.json()['id']}  

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+8098765454
    Set Suite Variable   ${CUSERPH1}
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname1} 
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname1} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname1}  ${lastname1}  ${address}  ${CUSERPH1}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id1}   ${resp.json()['id']}      

                                                   
                                                                                                  

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Set Suite Variable   ${cash_id2}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['jCashOffer']['id']}                             ${offer_id}
    Should Be Equal As Strings  ${resp.json()['jCashOffer']['name']}                           ${name}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                               ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}         ${firstname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}          ${lastname1}
    Should Be Equal As Strings  ${resp.json()['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()['triggerWhen']}                                  ${JCwhen[0]}


JD-TC-GetAvailableJcashById-UH1

    [Documentation]    Tries to Get available jaldee cash by invalid cash id.

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Jaldee Cash Available By Id  00
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_INVALID}"

JD-TC-GetAvailableJcashById-UH2

    [Documentation]    Get Available jaldee cash without login.
    
    ${resp}=  Get Jaldee Cash Available By Id  ${cash_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED_IN_SA}"

JD-TC-GetAvailableJcashById-UH3

    [Documentation]    Get Available jaldee cash by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Available By Id  ${cash_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  []

JD-TC-GetAvailableJcashById-clear

    [Documentation]    Clear jash offers frm super admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
