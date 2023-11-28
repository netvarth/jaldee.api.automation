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

JD-TC-GetJcashOfferCount-1

    [Documentation]    Get jaldee cash offer count by superadmin login   

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
    ${start_date}=  db.add_timezone_date  ${tz}  1    
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
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer Count  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   1

JD-TC-GetJcashOfferCount-2

    [Documentation]    Create multiple jaldee cash offer and get the count.  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offers By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer1}   ${resp.json()[0]['id']}

    ${resp}=  Delete Jaldee Cash Offer   ${offer1}
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
    ${amt}=  Random Int  min=150   max=500
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${EMPTY_List}=  Create List
    ${start_date1}=  db.add_timezone_date  ${tz}  3    
    ${end_date1}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt1}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil1}=  db.add_timezone_date  ${tz}   26  
    ${validForDays1}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit1}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit1}=  Random Int  min=1   max=5 
    ${amt}=  Evaluate   ${maxSpendLimit1} * ${issueLimit1}
    ${amt1}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt1}   ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt1}  ${maxValidUntil1}  ${validForDays1}  ${max_limit}  ${issueLimit1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Count  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   2

JD-TC-GetJcashOfferCount-3

    [Documentation]    Get jaldee cash offer count with effectiveFrom filter.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  4   
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
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer Count   effectiveFrom-eq=${start_date}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   1

JD-TC-GetJcashOfferCount-4

    [Documentation]    Get jaldee cash offer count with effectiveTo filter. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  2  
    ${end_date}=  db.add_timezone_date  ${tz}  13   
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer Count   effectiveTo-eq=${end_date}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   1


JD-TC-GetJcashOfferCount-5

    [Documentation]    Get jaldee cash offer count with triggerWhen filter. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name5}=  FakerLibrary.name
    Set Suite Variable   ${name5}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  2  
    ${end_date}=  db.add_timezone_date  ${tz}  13   
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name5}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer Count   triggerWhen-eq=${JCwhen[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   1


JD-TC-GetJcashOfferCount-6

    [Documentation]    Get jaldee cash offer count with maxValidUntilDt filter. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name6}=  FakerLibrary.name
    Set Suite Variable   ${name6}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  2  
    ${end_date}=  db.add_timezone_date  ${tz}  13   
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   25  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Create Jaldee Cash Offer  ${name6}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer Count   maxValidUntilDt-eq=${maxValidUntil}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.content}   1


JD-TC-GetJcashOfferCount-7

    [Documentation]    Get jaldee cash offer count with spIdList filter. 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${pid}   ${resp.json()['id']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name7}=  FakerLibrary.name
    Set Suite Variable   ${name7}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.add_timezone_date  ${tz}  2  
    ${end_date}=  db.add_timezone_date  ${tz}  13   
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    ${sp}=   Create List   ${pid}

    ${resp}=  Create Jaldee Cash Offer  ${name7}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[1]}  ${JCscope[0]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${sp}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.content}

    # ${resp}=  Get Jaldee Cash Offer Count   spIdList-like=${sp}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Integers  ${resp.content}   1


JD-TC-GetJcashOfferCount-clear

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









