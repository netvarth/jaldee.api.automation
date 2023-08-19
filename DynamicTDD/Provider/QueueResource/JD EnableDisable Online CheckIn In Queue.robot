*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      OnlineCheckin
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${SERVICE1}    Bridal MakeupQ2
${SERVICE2}    Bridal 


*** Test Cases ***

JD-TC-Online CheckIn In Queue-1
    [Documentation]  Enable  Online checkin in queuelevel
    ${resp}=  Provider Login  ${PUSERNAME126}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME126}
    clear_location  ${PUSERNAME126}
    clear_queue  ${PUSERNAME126}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_time  0  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   0  30
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Online Checkin In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['onlineCheckIn']}   True
    Should Be Equal As Strings  ${resp.json()['futureWaitlist']}   True

    ${resp}=  Online Checkin In Queue  ${qid}  False
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['onlineCheckIn']}   False
    Should Be Equal As Strings  ${resp.json()['futureWaitlist']}   True

JD-TC-Online CheckIn In Queue-2
    [Documentation]  Enable  Online checkin in accountlevel when queue level is false
    ${resp}=  Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME127}  
    clear_location  ${PUSERNAME127}  
    clear_queue  ${PUSERNAME127}  
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Online Checkin In Queue  ${qid1}  False
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False
    ${resp}=  Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-3
    [Documentation]  Enable  Online checkin in accountlevel when queue level is true
    ${resp}=  Provider Login  ${PUSERNAME139}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME139}
    clear_location  ${PUSERNAME139}
    clear_queue  ${PUSERNAME139}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}
    ${resp}=  Online Checkin In Queue  ${qid2}  True
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=True
    ${resp}=  Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-UH1
    [Documentation]  Enable  Online checkin in accountlevel when queue level is false
    ${resp}=  Provider Login  ${PUSERNAME240}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME240}
    clear_location  ${PUSERNAME240}
    clear_queue  ${PUSERNAME240}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    clear_queue  ${PUSERNAME240}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}
    ${resp}=  Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=False

    ${resp}=  Online Checkin In Queue  ${qid3}  True
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_SAME_DAY_CHECKIN_ALREADY_OFF}"
    ${resp}=  Enable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-UH2
    [Documentation]  Enable Online CheckIn In Queue by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Online CheckIn In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Online CheckIn In Queue-UH3
    [Documentation]  Enable Online CheckIn In Queue without login
    ${resp}=  Online CheckIn In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Online CheckIn In Queue-UH4
    [Documentation]  Enable Online CheckIn In Queue by another  provider
    ${resp}=  ProviderLogin  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_queue  ${PUSERNAME23}
    ${resp}=  Online CheckIn In Queue  ${qid}  True
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"
    
JD-TC-Online CheckIn In Queue-UH5
    [Documentation]  Enable Online CheckIn In Queue using Invalid queue id
    ${resp}=  ProviderLogin  ${PUSERNAME126}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Online CheckIn In Queue  0  True
    Should Be Equal As Strings  ${resp.status_code}  404   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"

JD-TC-Verify Online CheckIn In Queue-2
    [Documentation]  Verification of case 2
    ${resp}=  Provider Login  ${PUSERNAME127}    ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=False
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False

    ${resp}=  Enable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=True
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False
    ${resp}=  Disable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Verify Online CheckIn In Queue-3
    [Documentation]  Verification of case 3
    ${resp}=  Provider Login  ${PUSERNAME139}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=False
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False

    ${resp}=  Enable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=True
    ${resp}=  Get Queue ById  ${qid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=True
    ${resp}=  Disable Search Data
    Should Be Equal As Strings  ${resp.status_code}  200
