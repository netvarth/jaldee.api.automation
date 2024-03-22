*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup

*** Test Cases ***

JD-TC-GetQueuesCount-1
    [Documentation]    Create a queue and Get queues count
    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME148}
    clear_location  ${PUSERNAME148}
    clear_queue  ${PUSERNAME148}
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable  ${eTime1}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}
    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

JD-TC-GetQueuesCount-UH1
    [Documentation]  Enable Queue by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queues Counts
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-GetQueuesCount-UH2
    [Documentation]  Enable queue without login
    ${resp}=  Get Queues Counts
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-VerifyGetQueuesCount-1
    [Documentation]    Verification of case1
    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Queues Counts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetQueuesCount-2
    [Documentation]    Create more queues and check queues counts
    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable  ${eTime1}
    ${queue_name2}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name2}
    ${resp}=  Create Queue  ${queue_name2}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}
    ${resp}=  Get Queues Counts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetQueuesCount-3
    [Documentation]   Disable a queue then check queues counts
    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Disable Queue  ${q_id2}
    sleep  02s
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queues Counts
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    ${resp}=  Enable Queue  ${q_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queues Counts
     Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2