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
${jcash_name1}   JCash111_offer1
${jcash_name2}   JCash111_offer2
${jcash_name3}   JCash111_offer3
${jcash_name4}   JCash111_offer4
${jcash_name5}   JCash111_offer5
${jcash_name6}   JCash111_offer6
${jcash_name7}   JCash111_offer7
${jcash_name8}   JCash111_offer8
${jcash_name9}   JCash111_offer9
${jcash_name10}   JCash22_offer10
${jcash_name11}   JCash22_offer11
${jcash_name12}   JCash22_offer12
${jcash_name13}   JCash22_offer13
${jcash_name14}   JCash22_offer14
${jcash_name15}   JCash22_offer15
${jcash_name16}   JCash22_offer16
${jcash_name17}   JCash22_offer17
${jcash_name18}   JCash22_offer18
${jcash_name19}   JCash22_offer19
${jcash_name20}   JCash22_offer20
${jcash_name21}   JCash22_offer21
${jcash_name22}   JCash22_offer22
${jcash_name23}   JCash22_offer23
${jcash_name24}   JCash22_offer24
${jcash_name25}   JCash22_offer25

${tz}   Asia/Kolkata


*** Test Cases ***
JD-TC-Create_JCash_Offer-1
    [Documentation]    Create Jaldee Cash Offers for all CONSUMERS signup.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${global_max_limit}=  Convert To Number  ${resp.content}  1
    Set Suite Variable   ${global_max_limit}

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name1}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.content}

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

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

   
JD-TC-Create_JCash_Offer-2
    [Documentation]    Create Jaldee Cash Offers for all domains(ALL_SPS) ONLINE_BOOKING.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${global_max_limit}=  Convert To Number  ${resp.content}  1
    # Set Suite Variable   ${global_max_limit}

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name2}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
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
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

   

JD-TC-Create_JCash_Offer-3
    [Documentation]    Create Jaldee Cash Offers for a single domain or some specific domains ONLINE_BOOKING.
    
    ${resp}=  Get BusinessDomainsConf
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${domain1}   ${resp.json()[0]['domain']}
    Set Suite Variable  ${d1}        ${resp.json()[0]['id']}
    Set Suite Variable  ${domain2}   ${resp.json()[1]['domain']}
    Set Suite Variable  ${d2}        ${resp.json()[1]['id']}
    Set Suite Variable  ${domain3}   ${resp.json()[2]['domain']}
    Set Suite Variable  ${d3}        ${resp.json()[2]['id']}
    Set Suite Variable  ${domain4}   ${resp.json()[3]['domain']}
    Set Suite Variable  ${d4}        ${resp.json()[3]['id']}
    Set Suite Variable  ${domain5}   ${resp.json()[4]['domain']}
    Set Suite Variable  ${d5}        ${resp.json()[4]['id']}
    Set Suite Variable  ${domain6}   ${resp.json()[5]['domain']}
    Set Suite Variable  ${d6}        ${resp.json()[5]['id']}
    Set Suite Variable  ${domain7}   ${resp.json()[6]['domain']}
    Set Suite Variable  ${d7}        ${resp.json()[6]['id']}
    Set Suite Variable  ${domain8}   ${resp.json()[7]['domain']}
    Set Suite Variable  ${d8}        ${resp.json()[7]['id']}
    Set Suite Variable  ${domain9}   ${resp.json()[8]['domain']}
    Set Suite Variable  ${d9}        ${resp.json()[8]['id']}
    Set Suite Variable  ${domain10}  ${resp.json()[9]['domain']}
    Set Suite Variable  ${d10}       ${resp.json()[9]['id']}
    Set Suite Variable  ${sub_domain11}    ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd11}            ${resp.json()[0]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain12}    ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd12}            ${resp.json()[0]['subDomains'][1]['id']}
    Set Suite Variable  ${sub_domain13}    ${resp.json()[0]['subDomains'][2]['subDomain']}
    Set Suite Variable  ${sd13}            ${resp.json()[0]['subDomains'][2]['id']}
    Set Suite Variable  ${sub_domain14}    ${resp.json()[0]['subDomains'][3]['subDomain']}
    Set Suite Variable  ${sd14}            ${resp.json()[0]['subDomains'][3]['id']}
    Set Suite Variable  ${sub_domain15}    ${resp.json()[0]['subDomains'][4]['subDomain']}
    Set Suite Variable  ${sd15}            ${resp.json()[0]['subDomains'][4]['id']}
    Set Suite Variable  ${sub_domain16}    ${resp.json()[0]['subDomains'][5]['subDomain']}
    Set Suite Variable  ${sd16}            ${resp.json()[0]['subDomains'][5]['id']}
    Set Suite Variable  ${sub_domain21}    ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd21}            ${resp.json()[1]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain22}    ${resp.json()[1]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd22}            ${resp.json()[1]['subDomains'][1]['id']}
    Set Suite Variable  ${sub_domain23}    ${resp.json()[1]['subDomains'][2]['subDomain']}
    Set Suite Variable  ${sd23}            ${resp.json()[1]['subDomains'][2]['id']}
    Set Suite Variable  ${sub_domain31}    ${resp.json()[2]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd31}            ${resp.json()[2]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain32}    ${resp.json()[2]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd32}            ${resp.json()[2]['subDomains'][1]['id']}
    Set Suite Variable  ${sub_domain33}    ${resp.json()[2]['subDomains'][2]['subDomain']}
    Set Suite Variable  ${sd33}            ${resp.json()[2]['subDomains'][2]['id']}
    Set Suite Variable  ${sub_domain34}    ${resp.json()[2]['subDomains'][3]['subDomain']}
    Set Suite Variable  ${sd34}            ${resp.json()[2]['subDomains'][3]['id']}
    Set Suite Variable  ${sub_domain35}    ${resp.json()[2]['subDomains'][4]['subDomain']}
    Set Suite Variable  ${sd35}            ${resp.json()[2]['subDomains'][4]['id']}
    Set Suite Variable  ${sub_domain36}    ${resp.json()[2]['subDomains'][5]['subDomain']}
    Set Suite Variable  ${sd36}            ${resp.json()[2]['subDomains'][5]['id']}
    Set Suite Variable  ${sub_domain41}    ${resp.json()[3]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd41}            ${resp.json()[3]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain42}    ${resp.json()[3]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd42}            ${resp.json()[3]['subDomains'][1]['id']}
    Set Suite Variable  ${sub_domain43}    ${resp.json()[3]['subDomains'][2]['subDomain']}
    Set Suite Variable  ${sd43}            ${resp.json()[3]['subDomains'][2]['id']}
    Set Suite Variable  ${sub_domain44}    ${resp.json()[3]['subDomains'][3]['subDomain']}
    Set Suite Variable  ${sd44}            ${resp.json()[3]['subDomains'][3]['id']}
    Set Suite Variable  ${sub_domain45}    ${resp.json()[3]['subDomains'][4]['subDomain']}
    Set Suite Variable  ${sd45}            ${resp.json()[3]['subDomains'][4]['id']}
    Set Suite Variable  ${sub_domain46}    ${resp.json()[3]['subDomains'][5]['subDomain']}
    Set Suite Variable  ${sd46}            ${resp.json()[3]['subDomains'][5]['id']}
    Set Suite Variable  ${sub_domain51}    ${resp.json()[4]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd51}            ${resp.json()[4]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain52}    ${resp.json()[4]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd52}            ${resp.json()[4]['subDomains'][1]['id']}
    Set Suite Variable  ${sub_domain61}    ${resp.json()[5]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${sd61}            ${resp.json()[5]['subDomains'][0]['id']}
    Set Suite Variable  ${sub_domain62}    ${resp.json()[5]['subDomains'][1]['subDomain']}
    Set Suite Variable  ${sd62}            ${resp.json()[5]['subDomains'][1]['id']}
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${Domain_List1}=  Create List   ${d3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name3}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[3]}  ${Domain_List1}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id21}   ${resp.content}

    ${Domain_List2}=  Create List   ${d2}   ${d3}   ${d1}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name4}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[3]}  ${Domain_List2}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id22}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${Domain_List1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id22}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[1]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${Domain_List2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


   
JD-TC-Create_JCash_Offer-4
    [Documentation]    Create Jaldee Cash Offers for specific subdomains of a single domain.
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${Domain_List1}=  Create List   ${d1}
    ${SubDomain_List1}=  Create List   ${sd11}  ${sd13}  ${sd15}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name5}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[4]}  ${Domain_List1}  ${SubDomain_List1}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id31}   ${resp.content}

    ${Domain_List2}=  Create List   ${d2}
    ${SubDomain_List2}=  Create List   ${sd21}  ${sd22}  ${sd23}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name6}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[4]}  ${Domain_List2}  ${SubDomain_List2}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id32}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id31}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${Domain_List1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${SubDomain_List1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}


    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id32}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${Domain_List2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${SubDomain_List2}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create_JCash_Offer-5
    [Documentation]    Create Jaldee Cash Offers only for specific providers (Scope = SP).
    ${pid1}=  get_acc_id  ${PUSERNAME101}
    ${pid2}=  get_acc_id  ${PUSERNAME28}
    ${pid3}=  get_acc_id  ${PUSERNAME133}
    ${pid4}=  get_acc_id  ${PUSERNAME47}

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${Provider_List1}=  Create List   ${pid1}  ${pid2}  ${pid3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name7}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${Provider_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id51}   ${resp.content}


    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id51}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${Provider_List1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create_JCash_Offer-6
    [Documentation]    Create Jaldee Cash Offers for all providers (Scope = ALL_SPS).
    
    ${pid4}=  get_acc_id  ${PUSERNAME47}

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${Provider_List1}=  Create List   ${pid4}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name8}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${Provider_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id51}   ${resp.content}



    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id51}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amt']}                                                                   ${amt}
    Should Be Equal As Strings  ${resp.json()['faceValueType']}                                                         ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveFrom']}                                     ${start_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['effectiveTo']}                                       ${end_date}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['when']}                              ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forDomains']}           ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSubDomains']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['forSpLabels']}          ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['allSps']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['spList']}               ${Provider_List1}
    Should Be Equal As Strings  ${resp.json()['eligibilityRules']['eligibleWhen']['whenRules']['minOnlinePaymentAmt']}  ${minOnlinePaymentAmt}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxValidUntil']}                                     ${maxValidUntil}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['validForDays']}                                      ${validForDays}
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}                                  ${maxSpendLimit}
    Should Be Equal As Strings  ${resp.json()['offerIssueRules']['issueLimit']}                                         ${issueLimit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create_JCash_Offer-7
    [Documentation]    Create Jaldee Cash Offers when maximum_Spend_Limit is EMPTY.
    ${pid1}=  get_acc_id  ${PUSERNAME101}
    ${pid2}=  get_acc_id  ${PUSERNAME28}
    ${pid3}=  get_acc_id  ${PUSERNAME133}
    ${pid4}=  get_acc_id  ${PUSERNAME47}

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${Provider_List1}=  Create List   ${pid1}  ${pid2}  ${pid3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name9}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${Provider_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${EMPTY}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id71}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id71}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create_JCash_Offer-UH1
    [Documentation]    Create Jaldee Cash Offers again using same details (Same offer Name).

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1 

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name10}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name10}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${JCASH_OFFER_NAME_ALREADY_EXIST}=   Replace String  ${JCASH_OFFER_NAME_ALREADY_EXISTS}  {}  ${jcash_name10}

    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_NAME_ALREADY_EXIST}"

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

   
JD-TC-Create_JCash_Offer-UH2
    [Documentation]    Create Jaldee Cash Offers without using offer name.
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${EMPTY}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_NAME_RERQUIRED}"


JD-TC-Create_JCash_Offer-UH3
    [Documentation]   Create a Jaldee Cash Offer without login  
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name11}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"


JD-TC-Create_JCash_Offer-UH4
    [Documentation]  Create a Jaldee Cash Offer by consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name11}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"


JD-TC-Create_JCash_Offer-UH5
    [Documentation]   Create a Jaldee Cash Offer by provider login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name12}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"



JD-TC-Create_JCash_Offer-UH6
    [Documentation]    Create Jaldee Cash Offers when offer amount is less than maximum_Spend_Limit.
    ${pid1}=  get_acc_id  ${PUSERNAME101}
    ${pid2}=  get_acc_id  ${PUSERNAME28}
    ${pid3}=  get_acc_id  ${PUSERNAME133}
    ${pid4}=  get_acc_id  ${PUSERNAME47}

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
    ${issueLimit}=  Random Int  min=2   max=10
    ${maxSpendLimit}=  Random Int  min=20   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=10   max=${maxSpendLimit-1}
    
    ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}=  Format String   ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}   ${global_max_limit}
    ${Provider_List1}=  Create List   ${pid1}  ${pid2}  ${pid3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name12}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${Provider_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}"

JD-TC-Create_JCash_Offer-UH7
    [Documentation]    Create Jaldee Cash Offers when maximum_Spend_Limit is greater than Global_maximum_Spend_Limit.

    ${pid1}=  get_acc_id  ${PUSERNAME101}
    ${pid2}=  get_acc_id  ${PUSERNAME28}
    ${pid3}=  get_acc_id  ${PUSERNAME133}
    ${pid4}=  get_acc_id  ${PUSERNAME47}

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
    ${issueLimit}=  Random Int  min=2   max=10
    ${maxSpendLimit}=  Random Int  min=${global_max_limit+1}   max=${global_max_limit+100}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=251   max=349

    ${Provider_List1}=  Create List   ${pid1}  ${pid2}  ${pid3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name13}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[1]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${Provider_List1}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_MAX_SPENT_LIMIT_NOT_EXCEED_GLOBAL_MAX}"


JD-TC-Create_JCash_Offer-UH8
    [Documentation]    Create Jaldee Cash Offers when offer amount is zero.
    
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
    Set Test Variable   ${maxSpendLimit}   50
    Set Test Variable   ${amt}   0
    
    ${Domain_List1}=  Create List   ${d1}  ${d2}  ${d3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name13}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${Domain_List1}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_AMT_INVALID}"




JD-TC-Create_JCash_Offer-UH9
    [Documentation]    Create Jaldee Cash Offers when maximum_Spend_Limit is zero.
    
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
    Set Test Variable   ${maxSpendLimit}   0
    Set Test Variable   ${amt}   10
    
    ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}=  Format String   ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}   ${global_max_limit}
    ${Domain_List1}=  Create List   ${d1}  ${d2}  ${d3}
    ${resp}=  Create Jaldee Cash Offer  ${jcash_name13}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${Domain_List1}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}"



JD-TC-Create_JCash_Offer-UH10
    [Documentation]    Create Jaldee Cash Offers when 'Effective from date' is EMPTY.
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name14}  ${ValueType[0]}  ${amt}  ${EMPTY}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_EFFECTIVE_FROM_INVALID}"



JD-TC-Create_JCash_Offer-UH11
    [Documentation]    Create Jaldee Cash Offers when 'Effective to date' is EMPTY.
    
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name15}  ${ValueType[0]}  ${amt}  ${start_date}  ${EMPTY}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_EFFECTIVE_TO_INVALID}"



JD-TC-Create_JCash_Offer-UH12
    [Documentation]    Create Jaldee Cash Offers when 'Effective from date' is a past date.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.subtract_timezone_date  ${tz}   2  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name15}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_EFFECTIVE_FROM_INVALID_DATE}"



JD-TC-Create_JCash_Offer-UH13
    [Documentation]    Create Jaldee Cash Offers when 'Effective to date' is a past date.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz}  
    ${end_date}=  db.subtract_timezone_date  ${tz}   2  
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name16}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_EFFECTIVE_TO_INVALID_DATE}"


JD-TC-Create_JCash_Offer-UH14
    [Documentation]    Create Jaldee Cash Offers when 'maximum Valid Until date' is before than Offer 'effective from date'.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}   3  
    ${end_date}=  db.add_timezone_date  ${tz}   10  
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   2 
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1 
    ${validForDays}=  Random Int  min=5   max=10   
    ${issueLimit}=  Random Int  min=1   max=5   
    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit}
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${resp}=  Create Jaldee Cash Offer  ${jcash_name16}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_MAX_VALID_UNTIL_DT_BEFORE_EFFECTIVE_FROM}"



# JD-TC-Create_JCash_Offer-UH12
#     [Documentation]    Create Jaldee Cash Offers when maximum Spend Limit as negative integer.
    
#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${EMPTY_List}=  Create List
#     ${start_date}=  db.get_date_by_timezone  ${tz}  
#     ${end_date}=  db.add_timezone_date  ${tz}  12    
#     ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
#     ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
#     ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
#     ${validForDays}=  Random Int  min=5   max=10   
#     Set Test Variable   ${issueLimit}   -1   
#     Set Test Variable   ${maxSpendLimit}   -1
#     Set Test Variable   ${amt}   1
    
#     ${Domain_List1}=  Create List   ${d1}  ${d2}  ${d3}
#     ${resp}=  Create Jaldee Cash Offer  ${jcash_name1}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${Domain_List1}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_MAX_SPENT_LIMIT_AMT_INVALID}"



JD-TC-Create_JCash_Offer-UH15
    [Documentation]    Create Jaldee Cash Offers without using OFFER_ELIGIBILITY_RULES.

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    # ${whenRules}=    Create Dictionary    scope=${JCscope[3]}  forDomains=${EMPTY_List}  forSubDomains=${EMPTY_List}  forSpLabels=${EMPTY_List}  spList=${EMPTY_List}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    # ${eligibleWhen}=    Create Dictionary    when=${JCwhen[0]}  whenRules=${whenRules} 
    # ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name17}  ${ValueType[0]}  ${amt}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_ELIGIBLE_RULES_INVALID}"


JD-TC-Create_JCash_Offer-UH16
    [Documentation]    Create Jaldee Cash Offers without using scope

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${whenRules}=    Create Dictionary    forDomains=${EMPTY_List}  forSubDomains=${EMPTY_List}  forSpLabels=${EMPTY_List}  spList=${EMPTY_List}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${JCwhen[0]}  whenRules=${whenRules} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name17}  ${ValueType[0]}  ${amt}  eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_TARGET_SCOPE_INVALID}"


JD-TC-Create_JCash_Offer-UH17
    [Documentation]    Create Jaldee Cash Offers without using whenRules

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    # ${whenRules}=    Create Dictionary    scope=${JCscope[3]}  forDomains=${EMPTY_List}  forSubDomains=${EMPTY_List}  forSpLabels=${EMPTY_List}  spList=${EMPTY_List}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${JCwhen[0]} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name18}  ${ValueType[0]}  ${amt}  eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_ELIGIBLE_RULES_INVALID}"


JD-TC-Create_JCash_Offer-UH18 
    [Documentation]    Create Jaldee Cash Offers without using eligibleWhen
 
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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1
 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name19}  ${ValueType[0]}  ${amt}  eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_ELIGIBLE_WHEN_INVALID}"


JD-TC-Create_JCash_Offer-UH19
    [Documentation]    Create Jaldee Cash Offers without using eligibilityRules

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name20}  ${ValueType[0]}  ${amt}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_ELIGIBLE_RULES_INVALID}"


JD-TC-Create_JCash_Offer-UH20 
    [Documentation]    Create Jaldee Cash Offers without using offerRedeemRules

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${whenRules}=    Create Dictionary    scope=${JCscope[3]}  forDomains=${EMPTY_List}  forSubDomains=${EMPTY_List}  forSpLabels=${EMPTY_List}  spList=${EMPTY_List}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${JCwhen[0]}  whenRules=${whenRules} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name21}  ${ValueType[0]}  ${amt}  eligibilityRules=${eligibilityRules}  offerIssueRules=${offerIssueRules}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_REDEEM_RULES_INVALID}"


JD-TC-Create_JCash_Offer-UH21
    [Documentation]    Create Jaldee Cash Offers without using offerIssueRules

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
    ${amt}=  Random Int  min=150   max=1000
    ${amt}=  Convert To Number  ${amt}  1

    ${whenRules}=    Create Dictionary    scope=${JCscope[3]}  forDomains=${EMPTY_List}  forSubDomains=${EMPTY_List}  forSpLabels=${EMPTY_List}  spList=${EMPTY_List}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${JCwhen[0]}  whenRules=${whenRules} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${start_date}  effectiveTo=${end_date}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 

    ${resp}=  Create JCash Offer    ${jcash_name22}  ${ValueType[0]}  ${amt}  eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings   ${resp.content}   "${}"



JD-TC-Create_JCash_Offer-clear

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

***Keywords***
Create JCash Offer
    [Arguments]  ${jcash_name}  ${faceValueType}  ${amt}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${JCash_Offer}=  Create Dictionary    name=${jcash_name}  faceValueType=${faceValueType}  amt=${amt}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${JCash_Offer}   ${key}=${value}
    END
    ${data}=  json.dumps  ${JCash_Offer}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jcash/offer    data=${data}  expected_status=any
    [Return]  ${resp}



