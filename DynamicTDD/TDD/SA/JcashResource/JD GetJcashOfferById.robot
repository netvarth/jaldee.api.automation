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


*** Variables ***
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-GetJcashOffer-1

    [Documentation]    Get jaldee cash offer by superadmin login   

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
    
    Should Be Equal As Strings  ${resp.json()['name']}                                                                  ${name}
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}                ${JCscope[3]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${max_limit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}
    Should Be Equal As Strings  ${resp.json()['status']}                                                                ${JCstatus[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOffer-2

    [Documentation]    Create Jcash offer with scope as ALL_SPS.

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

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}   ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}      ${JCscope[0]}

JD-TC-GetJcashOffer-3

    [Documentation]    Create Jcash offer with scope as SUB_DOMAIN.
    
    ${resp}=  Get BusinessDomainsConf
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${sub_domain11}    ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd11}            ${resp.json()[0]['subDomains'][0]['id']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    ${SubDomain_List1}=  Create List   ${sd11}  

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[4]}  ${EMPTY_List}  ${SubDomain_List1}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}      ${JCscope[4]}

JD-TC-GetJcashOffer-4

    [Documentation]    Create Jcash offer with scope as SP.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME99}
    Set Test Variable  ${pid} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    ${amt}=  Random Int  min=300   max=1550 
    ${amt}=  Convert To Number  ${amt}   1
    ${sp}=   Create List   ${pid}
    
    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${sp}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}      ${JCscope[1]}


JD-TC-GetJcashOffer-5

    [Documentation]    Create Jcash offer with scope as SP_BY_LABEL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[2]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}      ${JCscope[2]}


JD-TC-GetJcashOffer-6

    [Documentation]    Get multiple jaldee cash offers by superadmin login   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    ${maxSpendLimit}=  Random Int  min=30   max=100  
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=300   max=1550 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name5}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}                ${JCscope[3]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${max_limit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}
    Should Be Equal As Strings  ${resp.json()['status']}                                                                ${JCstatus[0]}
    
    ${name6}=  FakerLibrary.name
    Set Suite Variable   ${name6}
    ${EMPTY_List}=  Create List
    ${start_date1}=  db.get_date_by_timezone  ${tz}  
    ${end_date1}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt1}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil1}=  db.add_timezone_date  ${tz}   26  
    ${validForDays1}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit1}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit1} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit1}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit1}=  Random Int  min=1   max=5 
    ${amt1}=  Random Int  min=300   max=1550 
    ${amt1}=  Convert To Number  ${amt1}   1

    ${resp}=  Create Jaldee Cash Offer  ${name6}  ${ValueType[0]}  ${amt1}  ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt1}  ${maxValidUntil1}  ${validForDays1}  ${max_limit}  ${issueLimit1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt1}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}                ${JCscope[3]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt1}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil1}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays1}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${max_limit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit1}
    Should Be Equal As Strings  ${resp.json()['status']}                                                                ${JCstatus[0]}

JD-TC-GetJcashOffer-7

    [Documentation]    Create Jaldee cash offer as disabled status, then verify it.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name7}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}                ${JCscope[3]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${max_limit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}
    Should Be Equal As Strings  ${resp.json()['status']}                                                                ${JCstatus[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-GetJcashOffer-8

#     [Documentation]    Create Jaldee cash offer as disabled status, then enable jaldee cash offer and verify it.

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${name}=  FakerLibrary.name
#     ${EMPTY_List}=  Create List
#     ${start_date}=  db.get_date_by_timezone  ${tz}  
#     ${end_date}=  db.add_timezone_date  ${tz}  12    
#     ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
#     ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
#     ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
#     ${validForDays}=  Random Int  min=5   max=10   
#     ${maxSpendLimit}=  Random Int  min=30   max=100 
#     ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
#     ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
#     ${max_limit}=  Convert To Number  ${max_limit}  1
#     ${issueLimit}=  Random Int  min=1   max=5 
#     ${amt}=  Random Int  min=100   max=150 
#     ${amt}=  Convert To Number  ${amt}   1

#     ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${offer_id}   ${resp.content}

#      ${resp}=  Enable Jaldee Cash Offer  ${offer_id} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
#     Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['scope']}                ${JCscope[3]}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
#     Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
#     Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
#     Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
#     Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${max_limit}
#     Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}
#     Should Be Equal As Strings  ${resp.json()['status']}                                                                ${JCstatus[0]}

#     ${resp}=  SuperAdmin Logout 
#     Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOffer-UH1

    [Documentation]    Get jaldee cash offer by invalid offer id.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer By Id  00
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_ID_DOES_NOT_EXISTS}"

JD-TC-GetJcashOffer-UH2

    [Documentation]    Get jaldee cash offer without login.
    
    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SA_SESSION_EXPIRED}"

JD-TC-GetJcashOffer-UH3

    [Documentation]    Create jaldee cash offer with amount as zero and get the offer.   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name}=  FakerLibrary.name
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

    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  0  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${JCASH_OFFER_AMT_INVALID}"  

JD-TC-GetJcashOffer-UH4

    [Documentation]    Get jaldee cash offer by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SA_SESSION_EXPIRED}"

JD-TC-GetJcashOffer-UH5

    [Documentation]    Get jaldee cash offer by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SA_SESSION_EXPIRED}"


JD-TC-GetJcashOffer-clear

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
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

