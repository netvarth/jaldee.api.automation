*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      FutureCheckin
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

JD-TC-Future Checkin In Queue-1
    [Documentation]  Enable  Future Checkin in queuelevel
    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME141}
    clear_location  ${PUSERNAME141}
    clear_queue  ${PUSERNAME141}
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

    ${resp}=  Future Checkin In Queue  ${qid}  True
    Log  ${resp.json()}
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

    ${resp}=  Future Checkin In Queue  ${qid}  False
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
    Should Be Equal As Strings  ${resp.json()['futureWaitlist']}   False

JD-TC-Future Checkin In Queue-2
    [Documentation]  Enable  Future Checkin in accountlevel when queue level is false
    ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME142}
    clear_location  ${PUSERNAME142}
    clear_queue  ${PUSERNAME142}
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
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Future Checkin In Queue  ${qid1}  False
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=False
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=False
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=False
    ${resp}=   Enable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=False

JD-TC-Future Checkin In Queue-3
    [Documentation]  Enable  Future Checkin in accountlevel when queue level is false
    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME143}
    clear_location  ${PUSERNAME143}
    clear_queue  ${PUSERNAME143}
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
    Set Suite Variable  ${qid2}  ${resp.json()}
    ${resp}=  Future Checkin In Queue  ${qid2}  True
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=True
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Future Checkin In Queue-UH1
    [Documentation]  Future checkin in accountlevel when queue level is false
    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME144}
    clear_location  ${PUSERNAME144}
    clear_queue  ${PUSERNAME144}
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
    Set Suite Variable  ${qid4}  ${resp.json()}
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=False
    ${resp}=  Future Checkin In Queue  ${qid4}  True
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_FUTURE_CHECKIN_ALREADY_OFF}"
    ${resp}=   Enable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Future Checkin In Queue-UH2
    [Documentation]  Enable Future Checkin In Queue by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Future Checkin In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Future Checkin In Queue-UH3
    [Documentation]  Enable Future Checkin In Queue without login
    ${resp}=  Future Checkin In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Future Checkin In Queue-UH4
    [Documentation]  Enable Future Checkin In Queue by another  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_queue  ${PUSERNAME111}
    ${resp}=  Get queues
    Log  ${resp.json()}
    ${resp}=  Future Checkin In Queue  ${qid}  True
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"
    
JD-TC-Future Checkin In Queue-UH5
    [Documentation]  Enable Future Checkin In Queue using Invalid queue id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Future Checkin In Queue  0  True
    Should Be Equal As Strings  ${resp.status_code}  404   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"

JD-TC- Verify Future Checkin In Queue-3
    [Documentation]  Verification of case 3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=False
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=False
    ${resp}=   Enable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  futureWaitlist=True


