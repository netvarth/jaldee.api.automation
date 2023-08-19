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

*** Test Cases ***

JD-TC-GetJcashOfferStatCount-1

    [Documentation]    Get jaldee cash offer stat count AWARDED TODAY by superadmin login   

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
    ${start_date}=  get_date  
    ${end_date}=  add_date   12  
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
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

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashOfferStatCount-2

    [Documentation]    Get jaldee cash offer stat count AWARDED TODAY after one consumer signup(one jcash offer).   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${jname}=  FakerLibrary.name
    Set Suite Variable   ${jname}
    ${EMPTY_List}=  Create List
    ${start_day}=  get_date
    Set Suite Variable   ${start_day}  
    ${end_day}=  add_date   12  
    Set Suite Variable   ${end_day}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${jamt}=  Random Int  min=100   max=150 
    # ${jamt}=  Convert To Number  ${jamt}   1
    Set Suite Variable   ${jamt}
   
    ${resp}=  Create Jaldee Cash Offer  ${jname}  ${ValueType[0]}  ${jamt}   ${start_day}  ${end_day}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+17788553
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${create_day}=  get_date
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_id}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${jname}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${jamt}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_day}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_day}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashOfferStatCount-3

    [Documentation]    Get jaldee cash offer stat count AWARDED TODAY after one consumer signup(multiple jcash offers).   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date}=  get_date  
    Set Suite Variable   ${start_date}
    ${end_date}=  add_date   12  
    Set Suite Variable   ${end_date}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=100   max=150 
    # ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}
    
    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${EMPTY_List}=  Create List
    ${start_date1}=  get_date  
    Set Suite Variable   ${start_date1}
    ${end_date1}=  add_date   14
    Set Suite Variable   ${end_date1}  
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt1}=  Random Int  min=100   max=150 
    # ${amt1}=  Convert To Number  ${amt1}   1
    Set Suite Variable   ${amt1}

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt1}   ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id1}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+17788558
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${create_day}=  get_date
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+44680012
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_id}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${jname}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${jamt}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_day}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_day}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${name1}
    # Should Be Equal As Strings  ${resp.json()[1]['amt']}            ${amt}
    Should Be Equal As Strings  ${resp.json()[1]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveFrom']}  ${start_date}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveTo']}    ${end_date}
    Should Be Equal As Strings  ${resp.json()[1]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[1]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[2]['name']}           ${name2}
    # Should Be Equal As Strings  ${resp.json()[2]['amt']}            ${amt1}
    Should Be Equal As Strings  ${resp.json()[2]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['effectiveFrom']}  ${start_date1}
    Should Be Equal As Strings  ${resp.json()[2]['effectiveTo']}    ${end_date1}
    Should Be Equal As Strings  ${resp.json()[2]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[2]['targetScope']}    ${JCscope[3]}

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOfferStatCount-4

    [Documentation]    Get jaldee cash offer stat count AWARDED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${jname}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${jamt}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_day}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_day}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${name1}
    # Should Be Equal As Strings  ${resp.json()[1]['amt']}            ${amt}
    Should Be Equal As Strings  ${resp.json()[1]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveFrom']}  ${start_date}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveTo']}    ${end_date}
    Should Be Equal As Strings  ${resp.json()[1]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[1]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[2]['name']}           ${name2}
    # Should Be Equal As Strings  ${resp.json()[2]['amt']}            ${amt1}
    Should Be Equal As Strings  ${resp.json()[2]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['effectiveFrom']}  ${start_date1}
    Should Be Equal As Strings  ${resp.json()[2]['effectiveTo']}    ${end_date1}
    Should Be Equal As Strings  ${resp.json()[2]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[2]['targetScope']}    ${JCscope[3]}


JD-TC-GetJcashOfferStatCount-5

    [Documentation]    Get jaldee cash offer stat count AWARDED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[0]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetJcashOfferStatCount-6

    [Documentation]    Get jaldee cash offer stat count EXPIRED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date2}=  get_date  
    Set Suite Variable   ${start_date2}
    ${end_date2}=  add_date   10  
    Set Suite Variable   ${end_date2}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt2}=  Random Int  min=100   max=150 
    # ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt2}
    
    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt2}   ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+1778963
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}
    
    ${create_day}=  get_date
    Set Suite Variable   ${create_day}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname2}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname2}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL3}=   Set Variable  ${C_Email}ph${CUSERPH3}.ynwtest@netvarth.com
    Set Suite Variable   ${CUSERMAIL3}
    ${resp}=  Consumer SignUp  ${firstname2}  ${lastname2}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id3}    ${resp.json()['id']} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[1]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name3}
    # # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${amt2}
    # Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_day2}
    # Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_day2}
    # Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashOfferStatCount-7

    [Documentation]    Get jaldee cash offer stat count REDEEMED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4}
    ${EMPTY_List}=  Create List
    ${start_date3}=  get_date  
    Set Suite Variable   ${start_date3}
    ${end_date3}=  add_date   17 
    Set Suite Variable   ${end_date3}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10   
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt3}=  Random Int  min=100   max=150 
    ${amt3}=  Convert To Number  ${amt3}   1
    Set Suite Variable   ${amt3}
    
    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt3}   ${start_date3}  ${end_date3}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME114}
    clear_location   ${PUSERNAME114}
    clear_service    ${PUSERNAME114}
    clear_customer   ${PUSERNAME114}
    clear_Coupon     ${PUSERNAME114}

    ${resp}=  ProviderLogin  ${PUSERNAME114}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME114}
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME114}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME114}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
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
    
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  1   00
    ${eTime}=  add_time   4   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH5}=  Evaluate  ${CUSERPH}+10456789
    Set Suite Variable   ${CUSERPH5}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH5}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH5}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+4468
    ${firstname5}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname5}
    ${lastname5}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname5}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL5}=   Set Variable  ${C_Email}ph${CUSERPH5}.ynwtest@netvarth.com
    Set Suite Variable   ${CUSERMAIL5} 
    ${resp}=  Consumer SignUp  ${firstname5}  ${lastname5}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL5}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL5}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id5}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
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

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt3} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name4}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${jamt}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_date3}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_date3}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashOfferStatCount-8

    [Documentation]    Get jaldee cash offer stat count REDEEMED TOTAL.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name4}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${jamt}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_date3}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_date3}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}


JD-TC-GetJcashOfferStatCount-9

    [Documentation]    Get jaldee cash offer stat count REDEEMED LAST_WEEK.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[3]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []

JD-TC-GetJcashOfferStatCount-10

    [Documentation]    Get jaldee cash offer stat count REFUNDED TODAY.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name5}=  FakerLibrary.name
    Set Suite Variable   ${name5}
    ${EMPTY_List}=  Create List
    ${start_date4}=  get_date  
    Set Suite Variable   ${start_date4}
    ${end_date4}=  add_date   12  
    Set Suite Variable   ${end_date4}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    add_date   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt4}=  Random Int  min=100   max=150 
    ${amt4}=  Convert To Number  ${amt4}   1
    Set Suite Variable   ${amt4}

    ${resp}=  Create Jaldee Cash Offer  ${name5}  ${ValueType[0]}  ${amt4}   ${start_date4}  ${end_date4}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH7}=  Evaluate  ${CUSERPH}+104996387
    Set Suite Variable   ${CUSERPH7}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH7}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH7}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH7}+4468
    ${firstname7}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname7}
    ${lastname7}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname7}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL7}=   Set Variable  ${C_Email}ph${CUSERPH7}.ynwtest@netvarth.com
    Set Suite Variable   ${CUSERMAIL7} 
    ${resp}=  Consumer SignUp  ${firstname7}  ${lastname7}  ${address}  ${CUSERPH7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL7}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL7}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id7}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  add_date  3
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid2}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid2}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt4} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt4}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt4}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid2}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid2}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  Delete Waitlist Consumer  ${cwid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name5}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${amt4}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_date4}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_date4}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOfferStatCount-11

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED TODAY by multiple consumers.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}
    
    ${name6}=  FakerLibrary.name
    Set Suite Variable   ${name6}
    ${EMPTY_List}=  Create List
    ${start_date5}=  get_date
    Set Suite Variable   ${start_date5}  
    ${end_date5}=  add_date   12  
    Set Suite Variable   ${end_date5}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  add_date   26  
    ${validForDays}=  Random Int  min=5   max=10
    ${ex_date}=    add_date   ${validForDays}    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt5}=  Random Int  min=100   max=150 
    ${amt5}=  Convert To Number  ${amt5}   1
    Set Suite Variable   ${amt5}

    ${resp}=  Create Jaldee Cash Offer  ${name6}  ${ValueType[0]}  ${amt5}   ${start_date5}  ${end_date5}  ${JCwhen[0]}  ${JCscope[3]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH8}=  Evaluate  ${CUSERPH}+104978536
    Set Suite Variable   ${CUSERPH8}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH8}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH8}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH8}+4468
    ${firstname8}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname8}
    ${lastname8}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname8}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL8}=   Set Variable  ${C_Email}ph${CUSERPH8}.ynwtest@netvarth.com
    Set Suite Variable   ${CUSERMAIL8} 
    ${resp}=  Consumer SignUp  ${firstname8}  ${lastname8}  ${address}  ${CUSERPH8}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL8}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL8}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL8}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id8}    ${resp.json()['id']} 
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  add_date  5
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid3}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid3}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt5} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt5}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt5}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid3}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid3}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid3}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid3}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    ${resp}=  Delete Waitlist Consumer  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name5}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${amt4}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_date4}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_date4}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${name6}
    # Should Be Equal As Strings  ${resp.json()[1]['amt']}            ${amt5}
    Should Be Equal As Strings  ${resp.json()[1]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveFrom']}  ${start_date5}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveTo']}    ${end_date5}
    Should Be Equal As Strings  ${resp.json()[1]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[1]['targetScope']}    ${JCscope[3]}

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetJcashOfferStatCount-12

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED TOTAL.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${name5}
    # Should Be Equal As Strings  ${resp.json()[0]['amt']}            ${amt4}
    Should Be Equal As Strings  ${resp.json()[0]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveFrom']}  ${start_date4}
    Should Be Equal As Strings  ${resp.json()[0]['effectiveTo']}    ${end_date4}
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[0]['targetScope']}    ${JCscope[3]}

    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${name6}
    # Should Be Equal As Strings  ${resp.json()[1]['amt']}            ${amt5}
    Should Be Equal As Strings  ${resp.json()[1]['faceValueType']}  ${ValueType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveFrom']}  ${start_date5}
    Should Be Equal As Strings  ${resp.json()[1]['effectiveTo']}    ${end_date5}
    Should Be Equal As Strings  ${resp.json()[1]['triggerWhen']}    ${JCwhen[0]}
    Should Be Equal As Strings  ${resp.json()[1]['targetScope']}    ${JCscope[3]}

JD-TC-GetJcashOfferStatCount-13

    [Documentation]    Get consumer jaldee cash offer stat count REFUNDED LAST_WEEK.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Offer Stat Count   ${statType[4]}  ${dateCategory[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     []


JD-TC-GetJcashOfferStatCount-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${jname}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${name4}
    clear_jcashoffer   ${name5}
    clear_jcashoffer   ${name6}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

