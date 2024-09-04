*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Queue
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-Enable Disable Queue-1
    [Documentation]  Enable  Queue of valid  provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service  ${HLPUSERNAME6}
    clear_location  ${HLPUSERNAME6}
    clear_queue  ${HLPUSERNAME6}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[1]} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=DISABLED 
    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=ENABLED

JD-TC-Enable Disable Queue-UH1
    [Documentation]  Enable Queue by consumer

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME4}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Enable Disable Queue-UH2
    [Documentation]  Enable queue without login
    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Enable Disable Queue-UH3
    [Documentation]  Enable queue by another  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_queue  ${PUSERNAME225}
    ${resp}=  Get queues
    Log  ${resp.json()}
    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    
JD-TC-Enable Disable Queue-UH4
    [Documentation]  Enable Queue using Invalid queue id
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Enable Disable Queue  0   ${toggleButton[1]}
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"
       
JD-TC-Enable Disable Queue-UH5
    [Documentation]  Enable a already enabled queue
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=ENABLED
    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]}
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_ALREADY_ENABLED}"

JD-TC-Enable Disable Queue-UH6
    [Documentation]  Enable queue to a conflicting time
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}
    # ${resp}=  Enable Disable Queue  ${q_id1}    ${toggleButton[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Queue ById  ${q_id1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  queueState=DISABLED 
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"