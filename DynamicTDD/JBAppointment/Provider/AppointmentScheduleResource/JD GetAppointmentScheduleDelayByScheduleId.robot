*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Schedule Delay Time 
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${SERVICE1}     MESSAGENOW

*** Test Cases ***  
JD-TC-Get Appointment Schedule Delay Time By ScheduleId-1

    [Documentation]    Get Delay time and verifying sent notifications to Different consumers    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME91}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME91}

    clear_service   ${PUSERNAME91}
    clear_location  ${PUSERNAME91}
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME91}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   0  90
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=20
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200
    Verify Response  ${resp}     delayDuration=0

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    comment     Add Delay Time
    ${delay_time}=   Random Int  min=10   max=20
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

    comment     Update Delay Time
    ${delay_time1}=   Random Int  min=25   max=40
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time1}

    comment     Reduce Delay Time
    ${delay_time2}=   Random Int  min=2   max=8
    Set Suite Variable  ${delay_time2}
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time2}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Appointment Schedule Delay Time By ScheduleId-2
    [Documentation]   When Delay is Zero
    ${resp}=  Encrypted Provider Login  ${PUSERNAME91}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time2}

    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DELAY_DURATION}"

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time2}


JD-TC-Get Appointment Schedule Delay Time By ScheduleId-UH1
    [Documentation]  Get Delay using Consumer Login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Schedule Delay    ${sch_id} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Appointment Schedule Delay Time By ScheduleId-UH2
    [Documentation]  Get Delay without Login
    ${resp}=  Get Appointment Schedule Delay    ${sch_id} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Get Appointment Schedule Delay Time By ScheduleId-UH3
    [Documentation]  Get Delay of another Provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_appt_schedule  ${PUSERNAME1}
    ${resp}=  Get Appointment Schedule Delay    ${sch_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 
