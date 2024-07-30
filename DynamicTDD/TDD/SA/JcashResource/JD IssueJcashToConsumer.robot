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


*** Variables ***
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-IssueJcashToConsumer-1

    [Documentation]    Issue a jaldee cash to an existing consumer.

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${cid1}=  get_id  ${CUSERNAME4}
    Set Suite Variable   ${cid1}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${global_max_limit}=  Convert To Number  ${resp.content}  1
    Set Suite Variable   ${global_max_limit}
    
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date}
    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name}   ${amt}   ${max_limit}    ${end_date}    ${cid1}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lname}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${end_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[5]}

JD-TC-IssueJcashToConsumer-2

    [Documentation]    Issue a jaldee cash to multiple consumer.
    
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname3}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname3}   ${resp.json()['lastName']}

    ${cid3}=  get_id  ${CUSERNAME3}
    Set Suite Variable   ${cid3}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname5}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname5}   ${resp.json()['lastName']}

    ${cid2}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}  
    ${end_date}=  db.add_timezone_date  ${tz}  11    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name1}   ${amt}   ${max_limit}    ${end_date}    ${cid2}   ${cid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${cid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${fname3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lname3}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${end_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[5]}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${fname5}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lname5}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${end_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[5]}

JD-TC-IssueJcashToConsumer-3

    [Documentation]    Issue a jaldee cash to already issued consumer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name2}   ${amt}   ${max_limit}    ${end_date}    ${cid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
JD-TC-IssueJcashToConsumer-4

    [Documentation]    Issue a jaldee cash with same name that another jcash have.
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME8}
    Set Suite Variable   ${cid8}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=30   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name}   ${amt}   ${max_limit}    ${end_date}    ${cid8}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-IssueJcashToConsumer-5

    [Documentation]    Issue a jaldee cash to an existing consumer with name as empty.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=30   max=100 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${EMPTY}   ${amt}   ${max_limit}    ${end_date}    ${cid1}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-IssueJcashToConsumer-6

    [Documentation]    Issue a jaldee cash to a family member of a consumer.

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${global_max_limit}=  Convert To Number  ${resp.content}  1
    Set Suite Variable   ${global_max_limit}
    
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date}
    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=30   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name}   ${amt}   ${max_limit}    ${end_date}    ${cid1}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${end_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lname}
    Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${end_date}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[5]}


JD-TC-IssueJcashToConsumer-UH1

    [Documentation]    Issue a jaldee cash with amount as zero to a consumer.
    
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid6}=  get_id  ${CUSERNAME6}
    Set Suite Variable   ${cid6}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid7}=  get_id  ${CUSERNAME7}
    Set Suite Variable   ${cid7}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=30   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    
    ${resp}=  Issue Jaldee Cash   ${name1}   0   ${max_limit}    ${end_date}    ${cid6}   ${cid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_AMT_INVALID}"
 

JD-TC-IssueJcashToConsumer-UH2

    [Documentation]    Issue a jaldee cash to a provider.

    ${Acc_pid1}=  get_acc_id  ${PUSERNAME47}
    ${Acc_pid2}=  get_acc_id  ${PUSERNAME28}
   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name}=  FakerLibrary.name
    Set Suite Variable   ${name}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=30   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    
    ${JCASH_CANNOT_ISSUE_FOR_THE_CONSUMERS}=  Format String   ${JCASH_CANNOT_ISSUE_FOR_THE_CONSUMERS}   ${Acc_pid1},${Acc_pid2}
    ${resp}=  Issue Jaldee Cash   ${name}   ${amt}   ${max_limit}    ${end_date}    ${Acc_pid1}     ${Acc_pid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_CANNOT_ISSUE_FOR_THE_CONSUMERS}"


JD-TC-IssueJcashToConsumer-UH3

    [Documentation]    Issue a jaldee cash to consumer with expiry date as past date.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name4}=  FakerLibrary.name
    Set Suite Variable   ${name4}  
    ${end_date}=  db.subtract_timezone_date  ${tz}    2  
    ${maxSpendLimit}=  Random Int  min=30   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name4}   ${amt}   ${max_limit}    ${end_date}    ${cid1}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_EXPIRY_DATE}"


JD-TC-IssueJcashToConsumer-UH4

    [Documentation]    Issue a jaldee cash to a consumer with amount less than the spendlimit.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid14}=  get_id  ${CUSERNAME14}
    Set Suite Variable   ${cid14}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${name6}=  FakerLibrary.name
    Set Suite Variable   ${name6}  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100  max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=10   max=25  
    ${amt}=  Convert To Number  ${amt}   1
    
    ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}=  Format String   ${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}   ${global_max_limit}
    ${resp}=  Issue Jaldee Cash   ${name6}   ${amt}   ${max_limit}    ${end_date}    ${cid1}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.content}   "${JCASH_OFFER_AMT_LESS_THAN_GLOBAL_MIN_AMT}"

JD-TC-IssueJcashToConsumer-UH5

    [Documentation]   Issue a jaldee cash to a consumer without login.  
    
    ${name1}=  FakerLibrary.name
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name1}   ${amt}   ${max_limit}    ${end_date}    ${cid2}   ${cid3}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

JD-TC-IssueJcashToConsumer-UH6

    [Documentation]    Get jaldee cash offer stat count today by consumer login.  
    
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=  FakerLibrary.name 
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name1}   ${amt}   ${max_limit}    ${end_date}    ${cid2}   ${cid3}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

JD-TC-IssueJcashToConsumer-UH7

    [Documentation]    Get jaldee cash offer stat count today by provider login.  
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=  FakerLibrary.name  
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${maxSpendLimit}=  Random Int  min=100   max=150 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    ${max_limit}=  Convert To Number  ${max_limit}  1
    ${amt}=  Random Int  min=150   max=500  
    ${amt}=  Convert To Number  ${amt}   1

    ${resp}=  Issue Jaldee Cash   ${name1}   ${amt}   ${max_limit}    ${end_date}    ${cid2}   ${cid3}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.content}   "${SA_SESSION_EXPIRED}"

