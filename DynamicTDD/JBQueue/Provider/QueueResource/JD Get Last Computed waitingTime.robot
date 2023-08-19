*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        WaitingTime
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
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading

*** Test Cases ***

JD-TC-GetLastComputedwaitingTime-1
    [Documentation]  Get Last Computed waitingTime
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comment ***
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Get Last Computed waitingTime  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  "${resp.json()}"  "${Time}"

JD-TC-GetLastComputedwaitingTime-UH1
    [Documentation]  Get Last Computed waitingTime using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Last Computed waitingTime  ${qid} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetLastComputedwaitingTime-UH2
    [Documentation]  Get Last Computed waitingTime without login
    ${resp}=  Get Last Computed waitingTime  ${qid} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetLastComputedwaitingTime-UH3
    [Documentation]  Get Last Computed waitingTime of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Last Computed waitingTime  ${qid} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"