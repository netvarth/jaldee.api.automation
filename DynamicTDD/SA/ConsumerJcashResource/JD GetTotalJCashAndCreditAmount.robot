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
${self}    0
@{countryCode}     91   +91   48
${SERVICE1}    SERVICE1234511
${SERVICE2}    SERVICE1234522
${SERVICE3}    SERVICE1234533
${SERVICE4}    SERVICE1234544

${catalogName1}   catalog15Name1
${catalogName2}   catalog15Name2
${catalogName3}   catalog15Name3
${catalogName4}   catalog15Name4
${catalogName5}   catalog15Name5
${catalogName6}   catalog15Name6

${itemCode1}    item15Code811
${itemCode2}    item15Code822
${itemCode3}    item15Code833
${itemCode4}    item15Code844
${itemCode5}    item15Code855
${itemCode6}    item15Code866
${itemCode7}    item15Code877

${itemName1}    item15Name811
${itemName2}    item15Name822
${itemName3}    item15Name833
${itemName4}    item15Name844
${itemName5}    item15Name855
${itemName6}    item15Name866
${itemName7}    item15Name877

${displayName1}    display11Name88881
${displayName2}    display11Name88882
${displayName3}    display11Name88883
${displayName4}    display11Name88884
${displayName5}    display11Name88885
${displayName6}    display11Name88886
${displayName7}    display11Name88887

${jcash_name1}   JCash81118_offer1
${jcash_name2}   JCash81118_offer2
${jcash_name3}   JCash81118_offer3
${jcash_name4}   JCash81118_offer4
${jcash_name5}   JCash81118_offer5
${jcash_name6}   JCash81118_offer6
${jcash_name7}   JCash81118_offer7
${jcash_name8}   JCash81118_offer8
${jcash_name9}   JCash81118_offer9

${CUSERPH}      ${CUSERNAME}
${tz}   Asia/Kolkata

*** Test Cases ***
JD-TC-GetTotalJCashAndCreditAmount-1
    [Documentation]    Get Total JCash And Credit Amount when consumer get a single JCASH offer.
    clear_queue    ${PUSERNAME47}
    clear_service  ${PUSERNAME47}
    clear_customer   ${PUSERNAME47}
    clear_Item   ${PUSERNAME47}
    clear_Coupon   ${PUSERNAME47}

    ${Acc_pid1}=  get_acc_id  ${PUSERNAME47}
    ${Acc_pid2}=  get_acc_id  ${PUSERNAME28}
    ${Acc_pid3}=  get_acc_id  ${PUSERNAME133}
    ${Acc_pid4}=  get_acc_id  ${PUSERNAME101}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
     
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetTotalJCashAndCreditAmount-2
    [Documentation]    Get Total JCash And Credit Amount when consumer get a single JCASH offer.

    clear_queue    ${PUSERNAME47}
    clear_service  ${PUSERNAME47}
    clear_customer   ${PUSERNAME47}
    clear_Item   ${PUSERNAME47}
    clear_Coupon   ${PUSERNAME47}

    ${Acc_pid1}=  get_acc_id  ${PUSERNAME47}
    ${Acc_pid2}=  get_acc_id  ${PUSERNAME28}
    ${Acc_pid3}=  get_acc_id  ${PUSERNAME133}
    ${Acc_pid4}=  get_acc_id  ${PUSERNAME101}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    Set Suite Variable   ${EMPTY_List}
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
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit} 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    Set Suite Variable   ${maxSpendLimit}
    ${issueLimit}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit}
    ${amt}=  Random Int  min=100   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name1}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${CUSERPH0}=  Evaluate  ${CUSERPH}+97675
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${firstname_C0}=  FakerLibrary.first_name
    ${lastname_C0}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname_C0}${CUSERPH0}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
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
    Set Suite Variable   ${CPH0_id}   ${resp.json()['id']} 

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['id']}                             ${offer_id}
    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${jcash_name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${CPH0_id}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${firstname_C0}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lastname_C0}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[0]}
    Set Suite Variable   ${remainingAmt1}    ${resp.json()[0]['remainingAmt']}   

  
    ${resp}=  Get Total JCash And Credit Amount   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  jCashAmt=${maxSpendLimit}   creditAmt=0.0



JD-TC-GetTotalJCashAndCreditAmount-3
    [Documentation]    Get Total JCash And Credit Amount for shopping cart when consumer get more than one JCASH offer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${num1}=  Random Int  min=5  max=10
    ${maxSpendLimit2}=  Evaluate  ${global_max_limit} - ${num1}  
    ${maxSpendLimit2}=  Convert To Number  ${maxSpendLimit2}  1
    Set Suite Variable   ${maxSpendLimit2}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name3}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit2}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id3}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}    ${maxSpendLimit2}

    # ${num2}=  Random Int  min=10  max=20
    # ${maxSpendLimit3}=  Evaluate  ${global_max_limit} - ${num2}  
    # ${maxSpendLimit3}=  Convert To Number  ${maxSpendLimit3}  1
    # Set Suite Variable   ${maxSpendLimit3}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name4}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${EMPTY}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id4}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}    ${global_max_limit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

 

    ${CUSERPH2}=  Evaluate  ${CUSERPH}+9864233
    Set Suite Variable   ${CUSERPH2}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    ${firstname_C0}=  FakerLibrary.first_name
    ${lastname_C0}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname_C0}${CUSERPH2}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH2}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
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
    Set Suite Variable   ${CPH2_id}   ${resp.json()['id']} 


    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  3

    # Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['id']}                             ${offer_id}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${jcash_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${CPH2_id}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${firstname_C0}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lastname_C0}
    # Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    # Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${maxSpendLimit}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    # Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[0]}
    # Set Suite Variable   ${remainingAmt1}    ${resp.json()[0]['remainingAmt']}   

    ${Net_offer_Amt}=  Evaluate  ${maxSpendLimit} + ${maxSpendLimit2} + ${global_max_limit}
    ${resp}=  Get Total JCash And Credit Amount   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  jCashAmt=${Net_offer_Amt}   creditAmt=0.0




JD-TC-GetTotalJCashAndCreditAmount-5
    [Documentation]    Get Total JCash And Credit Amount when consumer doesn't have any Jaldee Cash offer.
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0

    ${resp}=  Get Total JCash And Credit Amount
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  jCashAmt=0.0   creditAmt=0.0


JD-TC-GetTotalJCashAndCreditAmount-UH1
    [Documentation]    Get Total JCash And Credit Amount without login.
    ${resp}=  Get Total JCash And Credit Amount
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-GetTotalJCashAndCreditAmount-UH2
    [Documentation]    Get Total JCash And Credit Amount by provider login.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Total JCash And Credit Amount
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  ${resp.content}  "${NO_PERMISSION}"


JD-TC-GetTotalJCashAndCreditAmount-clear

    [Documentation]    Clear jash offers frm super admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${jcash_name1}
    clear_jcashoffer   ${jcash_name2}
    clear_jcashoffer   ${jcash_name3}
    clear_jcashoffer   ${jcash_name4}
    clear_jcashoffer   ${jcash_name5}
    clear_jcashoffer   ${jcash_name6}
    clear_jcashoffer   ${jcash_name7}
    clear_jcashoffer   ${jcash_name8}
    clear_jcashoffer   ${jcash_name9}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

