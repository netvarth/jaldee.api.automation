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
${jcash_name1}   JCash33111_offer1
${jcash_name2}   JCash33111_offer2
${jcash_name3}   JCash33111_offer3
${jcash_name4}   JCash33111_offer4
${jcash_name5}   JCash33111_offer5
${jcash_name6}   JCash33111_offer6
${jcash_name7}   JCash33111_offer7
${jcash_name8}   JCash33111_offer8
${jcash_name9}   JCash33111_offer9
${jcash_name10}   JCash4422_offer10
${jcash_name11}   JCash4422_offer11
${jcash_name12}   JCash4422_offer12
${jcash_name13}   JCash4422_offer13
${jcash_name14}   JCash4422_offer14
${jcash_name15}   JCash4422_offer15
${jcash_name16}   JCash4422_offer16
${jcash_name17}   JCash4422_offer17
${jcash_name18}   JCash4422_offer18
${jcash_name19}   JCash4422_offer19
${jcash_name20}   JCash4422_offer20
${jcash_name21}   JCash4422_offer21
${jcash_name22}   JCash4422_offer22
${jcash_name23}   JCash4422_offer23
${jcash_name24}   JCash4422_offer24
${jcash_name25}   JCash4422_offer25
${tz}   Asia/Kolkata



*** Test Cases ***

JD-TC-Update_JCash_Offer-1
    [Documentation]    Create Jaldee Cash Offers and Update offer name when offer is valid from future date. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${global_max_limit}=  Convert To Number  ${resp.content}  1
    Set Suite Variable   ${global_max_limit}

    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  1     
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name1}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name1}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${start_date2}=  db.add_timezone_date  ${tz}  2   
    ${end_date2}=  db.add_timezone_date  ${tz}   14
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   30

    ${resp}=  Update Jaldee Cash Offer  ${offer_id1}   ${jcash_name2}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name2}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil2}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

   
JD-TC-Update_JCash_Offer-2
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update offer into ONLINE_BOOKING

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  3    
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name3}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name3}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${start_date2}=  db.add_timezone_date  ${tz}  1   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20
    ${resp}=  Update Jaldee Cash Offer  ${offer_id2}   ${jcash_name3}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name3}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil2}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Update_JCash_Offer-3
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP, Consumer completes signup and achieve offer. After that Update scope into ONLINE_BOOKING
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit} 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=200   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name4}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+55781
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+4468
    ${firstname_C0}=  FakerLibrary.first_name
    ${lastname_C0}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lastname_C0}${CUSERPH0}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${CPH0_id}   ${resp.json()['id']}

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Total JCash And Credit Amount   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  jCashAmt=${maxSpendLimit}   creditAmt=0.0

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_date2}=  db.add_timezone_date  ${tz}  1   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20
    ${resp}=  Update Jaldee Cash Offer  ${offer_id}   ${jcash_name4}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}     "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"
    # ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get All Jaldee Cash Available
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
  
    # ${resp}=  Get Total JCash And Credit Amount   
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  jCashAmt=${maxSpendLimit}   creditAmt=0.0



# JD-TC-Update_JCash_Offer-4
#     [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP, Consumer achieve and redeem that offer. After that Update scope into ONLINE_BOOKING


JD-TC-Update_JCash_Offer-UH1
    [Documentation]   Update Jaldee Cash Offer with invalid offer id
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  1  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=50   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${start_date2}=  db.add_timezone_date  ${tz}  2   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer   00   ${jcash_name2}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_ID_DOES_NOT_EXISTS}"


JD-TC-Update_JCash_Offer-UH2
    [Documentation]   Update Jaldee Cash Offer without using offer name.
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  1  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=50   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${start_date2}=  db.add_timezone_date  ${tz}  2   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer   ${offer_id1}   ${EMPTY}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_NAME_RERQUIRED}"


JD-TC-Update_JCash_Offer -UH3
    [Documentation]   Update Jaldee Cash Offer without login  
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  1  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=50   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${start_date2}=  db.add_timezone_date  ${tz}  2   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer   ${offer_id1}   ${jcash_name2}   ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"


JD-TC-Update_JCash_Offer -UH4
    [Documentation]   Consumer try to Update Jaldee Cash Offer
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  1  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=50   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${start_date2}=  db.add_timezone_date  ${tz}  2   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer   ${offer_id1}   ${jcash_name2}   ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"


JD-TC-Update_JCash_Offer-UH5
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update offer_Redeem_Rules after "effectiveFrom" date
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name8}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id8}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name8}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${start_date2}=  db.add_timezone_date  ${tz}  1   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer  ${offer_id8}   ${jcash_name8}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"


    ${start_date2}=  db.add_timezone_date  ${tz}  1   
    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20

    ${resp}=  Update Jaldee Cash Offer  ${offer_id8}   ${jcash_name8}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"



JD-TC-Update_JCash_Offer-UH6
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update offer_Issue_Rules after "effectiveFrom" date
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1

    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name9}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id9}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id9}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name9}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${issueLimit2}=  Random Int  min=6   max=10  
    ${resp}=  Update Jaldee Cash Offer  ${offer_id9}   ${jcash_name9}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}   ${issueLimit2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"



JD-TC-Update_JCash_Offer-UH7
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update effectiveFrom date after starting current "effectiveFrom" date
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name10}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id10}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id10}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name10}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${start_date2}=  db.add_timezone_date  ${tz}  1   
    ${resp}=  Update Jaldee Cash Offer  ${offer_id10}   ${jcash_name10}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"



JD-TC-Update_JCash_Offer-UH8
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update effectiveTo date after starting current "effectiveFrom" date
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name11}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id11}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name11}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${end_date2}=  db.add_timezone_date  ${tz}   10
    ${resp}=  Update Jaldee Cash Offer  ${offer_id11}   ${jcash_name11}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"


JD-TC-Update_JCash_Offer-UH9
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update offer amount after "effectiveFrom" date
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=50   max=350  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name12}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id12}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name12}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${amt2}=  Random Int  min=350   max=600 
    ${amt2}=  Convert To Number  ${amt}  1

    ${resp}=  Update Jaldee Cash Offer  ${offer_id12}   ${jcash_name12}  ${ValueType[0]}  ${amt2}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"



JD-TC-Update_JCash_Offer-UH10
    [Documentation]    Create Jaldee Cash Offers for  APP_SIGNUP and Update both "effectiveFrom" and "effectiveTo" date of offer into past date.
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=250   max=500
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name13}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id13}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id13}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${jcash_name13}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${start_date2}=  db.subtract_timezone_date  ${tz}   20  
    ${end_date2}=  db.subtract_timezone_date  ${tz}   2 
    ${resp}=  Update Jaldee Cash Offer  ${offer_id13}   ${jcash_name13}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Update Jaldee Cash Offer  ${offer_id13}   ${jcash_name13}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_REDEEM_RULES_CANNOT_UPDATE}"


JD-TC-Update_JCash_Offer-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

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
    clear_jcashoffer   ${jcash_name10}
    clear_jcashoffer   ${jcash_name11}
    clear_jcashoffer   ${jcash_name12}
    clear_jcashoffer   ${jcash_name13}
    clear_jcashoffer   ${jcash_name14}
    clear_jcashoffer   ${jcash_name15}
    clear_jcashoffer   ${jcash_name16}
    clear_jcashoffer   ${jcash_name17}
    clear_jcashoffer   ${jcash_name18}
    clear_jcashoffer   ${jcash_name19}
    clear_jcashoffer   ${jcash_name20}
    clear_jcashoffer   ${jcash_name21}
    clear_jcashoffer   ${jcash_name22}
    clear_jcashoffer   ${jcash_name23}
    clear_jcashoffer   ${jcash_name24}
    clear_jcashoffer   ${jcash_name25}

   
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200



# JD-TC-UpdateJaldeeCoupon-UH3
#     [Documentation]   Check coupon updated for valid Sub_domain
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${EMPTY_List}=  Create List
#     ${start_date}=  db.add_timezone_date  ${tz}  1  
#     ${end_date}=  db.add_timezone_date  ${tz}  12    
#     ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
#     ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
#     ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
#     ${validForDays}=  Random Int  min=5   max=10   
#     ${issueLimit}=  Random Int  min=1   max=5   
#     ${maxSpendLimit}=  Random Int  min=50   max=100
#     ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
#     ${amt}=      Evaluate    ${maxSpendLimit} * ${issueLimit}
#     ${amt}=  Convert To Number  ${amt}  1

#     ${start_date2}=  db.add_timezone_date  ${tz}  2   
#     ${end_date2}=  db.add_timezone_date  ${tz}   10
#     ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20
#     ${SubDomain_List1}=  Create List   0
    
#     ${resp}=  Update Jaldee Cash Offer   ${offer_id1}   ${jcash_name}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[4]}  ${EMPTY_List}  ${SubDomain_List1}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit} 
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_SUBDOMAINS_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH4
#     [Documentation]   Check coupon updated for Invalid providers
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${EMPTY_List}=  Create List
#     ${start_date}=  db.add_timezone_date  ${tz}  1  
#     ${end_date}=  db.add_timezone_date  ${tz}  12    
#     ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
#     ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
#     ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
#     ${validForDays}=  Random Int  min=5   max=10   
#     ${issueLimit}=  Random Int  min=1   max=5   
#     ${maxSpendLimit}=  Random Int  min=50   max=100
#     ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
#     ${amt}=      Evaluate    ${maxSpendLimit} * ${issueLimit}
#     ${amt}=  Convert To Number  ${amt}  1

#     ${start_date2}=  db.add_timezone_date  ${tz}  2   
#     ${end_date2}=  db.add_timezone_date  ${tz}   10
#     ${maxValidUntil2}=  db.add_timezone_date  ${tz}   20
#     ${InvalidSP_List1}=  Create List   0

#     ${resp}=  Update Jaldee Cash Offer   ${offer_id1}   ${jcash_name}  ${ValueType[0]}  ${amt}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${InvalidSP_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays}  ${maxSpendLimit}  ${issueLimit} 
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_SP_ID_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH8
#     [Documentation]   Check coupon updated for valid providers
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${p}=  get_id  ${CUSERNAME}
#     ${pro_ids}=  Create List  ${p}
#     ${cupn_code1}=    FakerLibrary.word
#     Set Suite Variable   ${cupn_code1}
#     clear_jaldeecoupon     ${cupn_code1}

#     ${resp}=  Update Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[0]}  ${DAY2}  ${DAY4}  ${discountType[0]}  500  1000  ${bool[1]}  ${bool[1]}  90  2500  1000  1  1  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${pro_ids}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JC_DOESNOT_EXISTS}"


# JD-TC-UpdateJaldeeCoupon-UH9
#     [Documentation]   Check coupon updated for valid dates(valid from,to)
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${DAY3}=  db.add_timezone_date  ${tz}  -2
#     ${DAY4}=  db.add_timezone_date  ${tz}  -1
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_DATES_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH10
#     [Documentation]   Check coupon created for valid dates(valid to date previous date than valid from date)
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${DAY3}=  db.get_date_by_timezone  ${tz}
#     ${DAY4}=  db.add_timezone_date  ${tz}  -1
#     Set Suite Variable  ${DAY2}  ${DAY2}
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_DATES_REQUIRED}"


# JD-TC-UpdateJaldeeCoupon-UH11
#     [Documentation]   Check discountValue of a created coupon is not greater than maxDiscountValue when discount type is PERCENTAGE
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  150  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JC_DISCOUNTVALUE_NOT_VALID}"


# JD-TC-UpdateJaldeeCoupon-UH12
#     [Documentation]   Check when alwaysEnabled of a created coupon is true then defaultEnable is true
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_RULES_ALWAYS_ENABLED_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH13
#     [Documentation]   Check when maxReimburse PERCENTAGE of a created coupon is not greater than 100
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  200  100  200  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_RULES_MAX_REIMBURSE_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH14
#     [Documentation]   When create a coupon,check given subdomians are corresponding given domains
#     ${resp}=  Get BusinessDomainsConf
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
#     Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
#     Set Test Variable  ${sd1}  ${resp.json()[2]['subDomains'][0]['subDomain']}
#     Set Test Variable  ${sd3}  ${resp.json()[3]['subDomains'][0]['subDomain']}
#     Set Test Variable  ${sd4}  ${resp.json()[3]['subDomains'][1]['subDomain']}
#     ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
#     ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}  ${d2}_${sd4}
#     ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
#     ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
#     ${locations}=  Create List  ${loc1}  ${loc2}
#     ${resp}=   Get Licensable Packages
#     Should Be Equal As Strings   ${resp.status_code}   200
#     Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
#     Set Suite Variable  ${lic2}  ${resp.json()[1]['pkgId']}
#     ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "No Sub Domain with name ${sd1}"


# JD-TC-UpdateJaldeeCoupon-UH16
#     [Documentation]   When create a coupon,if firstCheckinOnly is true then  firstCheckinPerProviderOnly should be false
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_RULES_FIRSTCHECKIN_INVALID}"

# JD-TC-UpdateJaldeeCoupon-UH17
#     [Documentation]   When create a coupon,if firstCheckinOnly is true then  maxConsumerUseLimit should not be greater than 1
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_INVALID}"


# JD-TC-UpdateJaldeeCoupon-UH18
#     [Documentation]   When create a coupon,if firstCheckinOnly is true then  MaxUsageLimitPerProvider should not be 0
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  1  0  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.content}  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_PER_PROVIDER_INVALID}"

# JD-TC-UpdateJaldeeCoupon-5
#     [Documentation]   When create a coupon,maxDiscountValue should not be greater than minBillAmount in Persentage discount type
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  1000  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code012}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code012}
#     Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
#     Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
#     Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
#     Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[1]}
#     Should Be Equal As Strings  ${resp.json()['discountValue']}  50.0
#     Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  1000.0
#     Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  100.0
#     Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  100.0
#     Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  100
#     Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  5
#     Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  2

