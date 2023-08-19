*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Jcash
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

JD-TC-GetJcashDetails

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

JD-TC-GetJcashDetails-1
   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=   FakerLibrary.name
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
    ${validForDays}=  Random Int  min=5   max=15 
    Set Suite Variable   ${validForDays}
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    Set Suite Variable   ${ex_date}
    ${maxSpendLimit}=  Random Int  min=60   max=149 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    Set Suite Variable   ${max_limit}
    ${issueLimit}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit}
    ${amt}=  Random Int  min=100   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt}   ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH1}=  Evaluate  ${CUSERPH}+1077400201
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


    ${CUSERPH1}=  Evaluate  ${CUSERPH}+806856
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
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
JD-TC-GetJcashDetails-2

    [Documentation]    get more than one Jaldee cash to spent now for consumer.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=   FakerLibrary.name
    Set Suite Variable   ${name2}
    ${EMPTY_List}=  Create List
    ${start_date1}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable   ${start_date1}
    ${end_date1}=  db.add_timezone_date  ${tz}  11  
    Set Suite Variable   ${end_date1}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil1}=  db.add_timezone_date  ${tz}   24 
    Set Suite Variable   ${maxValidUntil1}
    ${validForDays1}=  Random Int  min=5   max=15 
    Set Suite Variable   ${validForDays1}
    ${ex_date1}=    db.add_timezone_date  ${tz}   ${validForDays1}
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

    ${resp}=  Create Jaldee Cash Offer  ${name2}  ${ValueType[0]}  ${amt1}  ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil1}  ${validForDays1}  ${max_limit1}  ${issueLimit1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id1}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name3}=   FakerLibrary.name
    Set Suite Variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date2}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable   ${start_date2}
    ${end_date2}=  db.add_timezone_date  ${tz}   10 
    Set Suite Variable   ${end_date2}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil2}=  db.add_timezone_date  ${tz}   14  
    Set Suite Variable   ${maxValidUntil2}
    ${validForDays2}=  Random Int  min=5   max=15 
    Set Suite Variable   ${validForDays2}
    ${ex_date2}=    db.add_timezone_date  ${tz}   ${validForDays2} 
    Set Suite Variable   ${ex_date2}
    ${maxSpendLimit2}=  Random Int  min=30   max=49 
    ${maxSpendLimit2}=  Convert To Number  ${maxSpendLimit2}  1
    Set Suite Variable   ${maxSpendLimit2}
    ${issueLimit2}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit2}
    ${amt2}=  Random Int  min=100   max=500  
    ${amt2}=  Convert To Number  ${amt2}   1
    Set Suite Variable   ${amt2}

    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt2}  ${start_date2}  ${end_date2}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil2}  ${validForDays2}  ${maxSpendLimit2}  ${issueLimit2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id2}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH0}=  Evaluate  ${CUSERPH}+100104401
    # Set Suite Variable   ${CUSERPH0}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+48752
    # ${firstname1}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname1}
    # ${lastname1}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname1}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname1}  ${lastname1}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH0}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+8068653
    Set Suite Variable   ${CUSERPH0}
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname1} 
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname1} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname1}${CUSERPH0}${CUSERPH}.ynwtest@netvarth.com
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

    sleep   2s
    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${cons_id1}   ${resp.json()['id']}                                                         

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id1}   ${resp.json()['id']}                                                         

    ${tot_amt}=  Evaluate   ${amt} + ${amt1} + ${amt2}
    Set Suite Variable   ${tot_amt}
    ${valid_day}=   Set Variable If  ${validForDays} < ${validForDays1}   ${validForDays}   ${validForDays1}
    ${valid_day1}=   Set Variable If  ${valid_day} < ${validForDays2}   ${valid_day}   ${validForDays2}
    
    ${min_exp_date}=   db.add_timezone_date  ${tz}    ${valid_day1}
    Set Suite Variable   ${min_exp_date}
 
    ${first_exp_amt}=  Run Keyword If  ${valid_day1} == ${validForDays}   Set Variable   ${amt}
            ...    ELSE IF  ${valid_day1} == ${validForDays1}     Set Variable   ${amt1}
            ...    ELSE     Set Variable   ${amt2}
   
    Log   ${min_exp_date}
    Log   ${first_exp_amt}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${min_exp_date}
    # Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${first_exp_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${min_exp_date}

JD-TC-GetJcashDetails-3

    [Documentation]    consumer didn't get any existing jcash offer created after his signup.

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${min_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${min_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
JD-TC-GetJcashDetails-4

    [Documentation]    disable one jcash offer after the signup, then get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tot_amt}=  Evaluate   ${amt} + ${amt1} + ${amt2}
    
    ${valid_day}=   Set Variable If  ${validForDays} < ${validForDays1}   ${validForDays}   ${validForDays1}
    ${valid_day1}=   Set Variable If  ${valid_day} < ${validForDays2}   ${valid_day}   ${validForDays2}
    
    ${min_exp_date}=   db.add_timezone_date  ${tz}    ${valid_day1}
 
    ${first_exp_amt12}=  Run Keyword If  ${valid_day1} == ${validForDays}   Set Variable   ${amt}
            ...    ELSE IF  ${valid_day1} == ${validForDays1}     Set Variable   ${amt1}
            ...    ELSE     Set Variable   ${amt2}
      
    Log   ${min_exp_date}
    Log   ${first_exp_amt12}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${min_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${first_exp_amt12}
    

JD-TC-GetJcashDetails-5

    [Documentation]    create jcash offer and disable the offer then tries to get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}
    ${EMPTY_List}=  Create List
    ${start_date5}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date5}
    ${end_date5}=  db.add_timezone_date  ${tz}  12    
    Set Suite Variable   ${end_date5}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt5}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt5}
    ${maxValidUntil5}=  db.add_timezone_date  ${tz}   26  
    Set Suite Variable   ${maxValidUntil5}
    ${validForDays5}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays5}
    ${ex_date5}=    db.add_timezone_date  ${tz}   ${validForDays5} 
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

    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt5}  ${start_date5}  ${end_date5}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt5}  ${maxValidUntil5}  ${validForDays5}  ${max_limit5}  ${issueLimit5}
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
   
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+809086321
    Set Suite Variable   ${CUSERPH2}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname} 
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}${CUSERPH}.ynwtest@netvarth.com
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
    Set Suite Variable   ${cons_id1}   ${resp.json()['id']}      

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tot_amt5}=  Evaluate   ${amt1} + ${amt2}  
    ${max_exp_date}=   Set Variable If  ${validForDays1} < ${validForDays2}   ${ex_date1}   ${ex_date2}
    ${first_exp_amt}=  Set Variable If  ${validForDays1} < ${validForDays2}    ${amt1}   ${amt2}      

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt5}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt5}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt5}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${max_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${first_exp_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${max_exp_date}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Cash Offer  ${offer_id5} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashDetails-6

    [Documentation]    create jcash offer for ONLINE_BOOKING then tries to get available Jaldee cash to spent now for consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4}
    ${EMPTY_List}=  Create List
    ${start_date5}=  db.get_date_by_timezone  ${tz} 
    ${end_date5}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt5}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil5}=  db.add_timezone_date  ${tz}   26  
    ${validForDays5}=  Random Int  min=5   max=10 
    ${ex_date5}=    db.add_timezone_date  ${tz}   ${validForDays5} 
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit5}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit5} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit5}
    ${issueLimit5}=  Random Int  min=1   max=5 
    ${amt1}=  Random Int  min=100   max=500  
    ${amt5}=  Convert To Number  ${amt}   1
     
    ${resp}=  Create Jaldee Cash Offer  ${name4}  ${ValueType[0]}  ${amt5}   ${start_date5}  ${end_date5}  ${JCwhen[1]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}   ${EMPTY_List}  ${minOnlinePaymentAmt5}  ${maxValidUntil5}  ${validForDays5}  ${max_limit}  ${issueLimit5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${offer_id5}   ${resp.content}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}     ${JCstatus[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
 
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+541231
    Set Suite Variable   ${CUSERPH3}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname} 
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname}${CUSERPH3}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id}   ${resp.json()['id']}      

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}
    
    sleep  2s

    # ${resp}=  Android App Consumer Login  ${CUSERPH3}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${cons_id}   ${resp.json()['id']}      

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tot_amt12}=  Evaluate   ${amt1} + ${amt2}  
    ${max_exp_date}=   Set Variable If  ${validForDays1} < ${validForDays2}   ${ex_date1}   ${ex_date2}
    ${first_exp_amt}=  Set Variable If  ${validForDays1} < ${validForDays2}    ${amt1}   ${amt2}      

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt12}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt12}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt12}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${max_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${first_exp_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${max_exp_date}


JD-TC-GetJcashDetails-UH1

    [Documentation]    Get Available jaldee cash without login.
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED_IN_SA}"


JD-TC-GetJcashDetails-UH2

    [Documentation]    Get Available jaldee cash by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetJcashDetails-UH3

    [Documentation]    try to delete a jaldee cash offer after applied.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Delete Jaldee Cash Offer  ${offer_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_CANNOT_DELETE_AFTER_EFFECTIVE_FROM_DATE}"



JD-TC-GetJcashDetails-UH4

    [Documentation]    Apply Jaldee cash to consumer then update jaldee cash offer and check consumer wallet.

    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tot_amt}=  Evaluate   ${amt1} + ${amt2}  
    ${max_exp_date}=   Set Variable If  ${validForDays1} < ${validForDays2}   ${ex_date1}   ${ex_date2}
    ${first_exp_amt}=  Set Variable If  ${validForDays1} < ${validForDays2}    ${amt1}   ${amt2}      

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${max_exp_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${first_exp_amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${max_exp_date}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name5}=  FakerLibrary.name
    Set Suite Variable   ${name5}
    ${EMPTY_List}=  Create List
    ${start_date5}=  db.get_date_by_timezone  ${tz} 
    ${end_date5}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt5}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil5}=  db.add_timezone_date  ${tz}   26  
    ${validForDays5}=  Random Int  min=5   max=10 
    ${ex_date5}=    db.add_timezone_date  ${tz}   ${validForDays5} 
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit5}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit5} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit5}
    ${amt}=  Random Int  min=100   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    ${issueLimit}=  Random Int  min=1   max=5 
   
    ${resp}=  Update Jaldee Cash Offer  ${offer_id1}  ${name5}  ${ValueType[0]}  ${amt}   ${start_date5}  ${end_date5}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}   ${EMPTY_List}  ${minOnlinePaymentAmt5}  ${maxValidUntil5}  ${validForDays5}  ${max_limit}  ${issueLimit} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${JCASH_OFFER_AMT_CANNOT_UPDATE}"



JD-TC-GetJcashDetails-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name2}
    clear_jcashoffer   ${name3}
    clear_jcashoffer   ${name4}
    # clear_jcashoffer   ${name5}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
