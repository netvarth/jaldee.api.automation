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
${jcash_name1}   JCash111_offer1881
${jcash_name2}   JCash111_offer2882
${jcash_name3}   JCash111_offer3883
${jcash_name4}   JCash111_offer4884
${jcash_name5}   JCash111_offer5885


*** Test Cases ***
JD-TC-Enable_JCash_Offer-UH1
    [Documentation]    Enable already Enabled Jaldee Cash Offer
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${global_max_limit}=  Convert To Number  ${resp.content}  1
    Set Suite Variable   ${global_max_limit}

    ${EMPTY_List}=  Create List
    ${start_date}=  get_date  
    ${end_date}=  add_date   12  
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=50   max=1500
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name1}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offerId1}   ${resp.content}

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

    ${resp}=  Enable Jaldee Cash Offer  ${offerId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As strings  ${resp.content}  "${JCASH_OFFER_STATUS_ALREADY_ENABLED}"


JD-TC-Enable_JCash_Offer-1
    [Documentation]    Disable Jaldee Cash Offer and Enable after that
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offerId1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Cash Offer  ${offerId1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Enable_JCash_Offer-UH2
    [Documentation]    Enable an invalid Jaldee Cash Offer
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_JCash}=  Random Int  min=500000   max=555555
    ${resp}=  Enable Jaldee Cash Offer  ${invalid_JCash}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As strings  ${resp.content}  "${JCASH_OFFER_ID_DOES_NOT_EXISTS}"


JD-TC-Enable_JCash_Offer -UH3
    [Documentation]   Enable a Jaldee Cash Offer without login  
    ${resp}=  Enable Jaldee Cash Offer  ${offerId1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

JD-TC-Enable_JCash_Offer -UH4
    [Documentation]  Enable a Jaldee Cash Offer by consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Enable Jaldee Cash Offer  ${offerId1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

JD-TC-Enable_JCash_Offer -UH5
    [Documentation]   Enable a Jaldee Cash Offer by provider login
    ${resp}=   ProviderLogin  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Cash Offer  ${offerId1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"


JD-TC-Enable_JCash_Offer-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${jcash_name1}
    clear_jcashoffer   ${jcash_name2}
    clear_jcashoffer   ${jcash_name3}
    clear_jcashoffer   ${jcash_name4}
    clear_jcashoffer   ${jcash_name5}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


