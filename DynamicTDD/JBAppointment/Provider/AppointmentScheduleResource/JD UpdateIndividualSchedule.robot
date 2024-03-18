*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Appointment, Schedule
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

** Keywords ***
Individual Schedule
    [Arguments]  ${name}   ${parallel}   ${consumerParallelServing}   ${loc}   ${batch}  @{vargs}   &{kwargs}

    ${location}=  Create Dictionary  id=${loc}
    ${data}=  Create Dictionary  name=${name}     parallelServing=${parallel}    consumerParallelServing=${consumerParallelServing}  location=${location}    batchEnable=${batch}   
    ${len}=  Get Length  ${vargs}
    ${services}=  Create List  
    FOR    ${index}    IN RANGE  0  ${len}
        Exit For Loop If  ${len}==0
    	${service}=  Create Dictionary  id=${vargs[${index}]} 
        Append To List  ${services}  ${service}
    END
    Run Keyword If  ${len}>0  Set To Dictionary  ${data}  services=${services}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END 
    RETURN  ${data}
Create Individual Schedule
    [Arguments]  ${name}   ${parallel}   ${consumerParallelServing}    ${loc}    ${batch}  @{vargs}   &{kwargs}
    ${data}=  Individual Schedule  ${name}   ${parallel}    ${consumerParallelServing}   ${loc}    ${batch}  @{vargs}     &{kwargs}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END 
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    RETURN  ${resp}

Update Individual Schedule
    [Arguments]  ${name}   ${parallel}   ${consumerParallelServing}    ${loc}    ${batch}  @{vargs}   &{kwargs}
    ${data}=  Individual Schedule  ${name}   ${parallel}    ${consumerParallelServing}   ${loc}    ${batch}  @{vargs}     &{kwargs}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END 
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    RETURN  ${resp}


*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading
${SERVICE9}  Threading12
${start}  110

@{provider_list}


*** Test Cases ***

JD-TC-CreateAppointmentSchedule-1
    [Documentation]    Create an Individual appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_service   ${PUSERNAME132}
    clear_location  ${PUSERNAME132}
    
    ${p1_lid}=  Create Sample Location
    Set Suite Variable   ${p1_lid}
    clear_appt_schedule   ${PUSERNAME132}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${resp}=  Create Individual Schedule  ${schedule_name}  ${parallel}    ${parallel}  ${p1_lid}    ${bool1}  ${s_id}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}      parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availableDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availabilityTime'][0]}  ${sTime1}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name1}=  FakerLibrary.bs
    ${resp}=  Update Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool1}  ${s_id}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}      parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availableDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availabilityTime'][0]}  ${sTime1}
    