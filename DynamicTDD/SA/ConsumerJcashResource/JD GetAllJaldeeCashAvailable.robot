*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Jaldee Cash
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
${countryCode}     +91

*** Test Cases ***

JD-TC-GetAvailableJcash-1

    [Documentation]    Set Jaldee Cash Global Max Spendlimit

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

JD-TC-GetAvailableJcash-2

    [Documentation]    get available Jaldee cash to spent now for consumer.

    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}
    clear_jcashoffer   ${name}
    ${EMPTY_List}=  Create List
    ${start_date}=  get_date 
    Set Suite Variable   ${start_date}
    ${end_date}=  add_date   12  
    Set Suite Variable   ${end_date}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt}
    ${maxValidUntil}=  add_date   26  
    Set Suite Variable   ${maxValidUntil}
    ${validForDays}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays}
    ${ex_date}=    add_date   ${validForDays} 
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

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+8067801175
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}${CUSERPH}.${test_mail}
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

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['id']}                             ${offer_id}
    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${cons_id}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[0]}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAvailableJcash-3

    [Documentation]    get all available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date1}=  get_date  
    Set Suite Variable   ${start_date1}
    ${end_date1}=  add_date   11
    Set Suite Variable   ${end_date1}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil1}=  add_date   24 
    Set Suite Variable   ${maxValidUntil1}
    ${validForDays1}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays1}
    ${ex_date1}=    add_date   ${validForDays1}
    Set Suite Variable   ${ex_date1} 
    ${maxSpendLimit1}=  Random Int  min=30   max=100 
    ${maxSpendLimit1}=  Convert To Number  ${maxSpendLimit1}  1
    ${max_limit1}=   Set Variable If  ${maxSpendLimit1} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit1}
    Set Suite Variable   ${max_limit1}
    ${issueLimit1}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit1}
    ${amt1}=  Random Int  min=100   max=500  
    ${amt1}=  Convert To Number  ${amt1}   1
    Set Suite Variable   ${amt1}

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt1}  ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil1}  ${validForDays1}  ${max_limit1}  ${issueLimit1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${EMPTY_List}=  Create List
    ${start_date2}=  get_date  
    Set Suite Variable   ${start_date2}
    ${end_date2}=  add_date   10 
    Set Suite Variable   ${end_date2}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil2}=  add_date   14  
    Set Suite Variable   ${maxValidUntil2}
    ${validForDays2}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays2}
    ${ex_date2}=    add_date   ${validForDays2} 
    Set Suite Variable   ${ex_date2}
    ${maxSpendLimit2}=  Random Int  min=30   max=100 
    ${maxSpendLimit2}=  Convert To Number  ${maxSpendLimit2}  1
    ${max_limit2}=   Set Variable If  ${maxSpendLimit2} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit2}
    Set Suite Variable   ${max_limit2}
    ${issueLimit2}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit2}
    ${amt2}=  Random Int  min=100   max=500  
    ${amt2}=  Convert To Number  ${amt2}   1
    Set Suite Variable   ${amt2}

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt2}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays2}  ${max_limit2}  ${issueLimit2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    

  


    ${CUSERPH0}=  Evaluate  ${CUSERPH}+8067801164
    Set Suite Variable   ${CUSERPH0}
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname1} 
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname1} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname1}${CUSERPH0}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname1}  ${lastname1}  ${address}  ${CUSERPH0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id1}   ${resp.json()['id']}      

                                                   

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}



    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}

        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id1}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
        
        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id2}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
    
    END

JD-TC-GetAvailableJcash-4

    [Documentation]    consumer didn't get any existing jcash offer created after his signup.

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}

        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id1}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
        
        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id2}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
    
    END
    
JD-TC-GetAvailableJcash-5

    [Documentation]    disable one jcash offer after the signup, then get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}

        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id1}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
        
        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id2}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
    
    END
    
JD-TC-GetAvailableJcash-6

    [Documentation]    create jcash offer and disable the offer then tries to get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name5}=  FakerLibrary.name
    Set Suite Variable   ${name5}
    ${EMPTY_List}=  Create List
    ${start_date5}=  get_date 
    Set Suite Variable   ${start_date5}
    ${end_date5}=  add_date   12  
    Set Suite Variable   ${end_date5}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt5}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt5}
    ${maxValidUntil5}=  add_date   26  
    Set Suite Variable   ${maxValidUntil5}
    ${validForDays5}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays5}
    ${ex_date5}=    add_date   ${validForDays5} 
    Set Suite Variable   ${ex_date5}
    ${maxSpendLimit5}=  Random Int  min=30   max=100 
    ${maxSpendLimit5}=  Convert To Number  ${maxSpendLimit5}  1
    ${max_limit5}=   Set Variable If  ${maxSpendLimit5} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit5}
    Set Suite Variable   ${max_limit5}
    ${issueLimit5}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit5}
    ${amt}=  Random Int  min=100   max=500  
    ${amt5}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt5}

    ${resp}=  Create Jaldee Cash Offer  ${name5}  ${ValueType[0]}  ${amt5}  ${start_date5}  ${end_date5}  ${JCwhen[0]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt5}  ${maxValidUntil5}  ${validForDays5}  ${max_limit5}  ${issueLimit5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id5}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}     ${JCstatus[0]}

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id5} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}     ${JCstatus[1]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200



    ${CUSERPH2}=  Evaluate  ${CUSERPH}+8067801464
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76035
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id12}   ${resp.json()['id']}      

                                                   

    
    # ${CUSERPH2}=  Evaluate  ${CUSERPH}+10703556
    # Set Suite Variable   ${CUSERPH2}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+48895
    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH2}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable   ${cons_id}   ${resp.json()['id']}                                                         

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id1}'      
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id12}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
        
        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id2}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id12}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
    
    END

    
JD-TC-GetAvailableJcash-7

    [Documentation]    create jcash offer for ONLINE_BOOKING then tries to get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3} 
    ${EMPTY_List}=  Create List
    ${start_date5}=  get_date 
    ${end_date5}=  add_date   12  
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt5}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil5}=  add_date   26  
    ${validForDays5}=  Random Int  min=5   max=10 
    ${ex_date5}=    add_date   ${validForDays5} 
    ${maxSpendLimit5}=  Random Int  min=30   max=100 
    ${maxSpendLimit5}=  Convert To Number  ${maxSpendLimit5}  1
    ${max_limit5}=   Set Variable If  ${maxSpendLimit5} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit5}
    ${issueLimit5}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=500  
    ${amt5}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt5}  ${start_date5}  ${end_date5}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt5}  ${maxValidUntil5}  ${validForDays5}  ${max_limit5}  ${issueLimit5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id5}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}     ${JCstatus[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH2}=  Evaluate  ${CUSERPH}+107035896
    # Set Suite Variable   ${CUSERPH2}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+48895
    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH2}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable   ${cons_id}   ${resp.json()['id']}    
   
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+8067804244
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760868
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id22}   ${resp.json()['id']}      



    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id1}'      
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id22}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
        
        ...    ELSE IF     '${resp.json()[${i}]['jCashOffer']['id']}' == '${offer_id2}'     
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['id']}                                  ${offer_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashOffer']['name']}                           ${name2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['id']}                               ${cons_id22}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}         ${firstname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}          ${lastname}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['type']}                                         ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['originalAmt']}                                  ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['remainingAmt']}                                 ${amt2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedDt']}                   ${start_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashIssueInfo']['issuedBy']}                   SA
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['triggerWhen']}                                  ${JCwhen[0]}
    
    END


JD-TC-GetAvailableJcash-UH1

    [Documentation]    Get Available jaldee cash by provider login.

    ${resp}=  ProviderLogin  ${PUSERNAME199}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}    []


JD-TC-GetAvailableJcash-UH2

    [Documentation]    Get Available jaldee cash without login.
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED_IN_SA}"


JD-TC-GetAvailableJcash-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${name5}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
