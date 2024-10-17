*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-GetApptScheduleWithLocationServiceDate-1

    [Documentation]    Get Appt Schedule for today.

    ${firstname}  ${lastname}  ${PUSERPH0}  ${login_id}=  Provider Signup  
    Set Suite Variable    ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}    
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=6
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id}   ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['name']}                                   ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}          ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}        ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id}
    
JD-TC-GetApptScheduleWithLocationServiceDate-2

    [Documentation]    Get Appt Schedule for future.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${DAY}=  db.add_timezone_date  ${tz}  5      
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id}
    
JD-TC-GetApptScheduleWithLocationServiceDate-3

    [Documentation]    Get Appt Schedule for future(schedule finished).

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${DAY}=  db.add_timezone_date  ${tz}  15      
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

JD-TC-GetApptScheduleWithLocationServiceDate-4

    [Documentation]    Update the schedule with an extanded date then try to get the schedule with the updated date.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  15      
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${DAY2}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id2}   ${DAY2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id2}

JD-TC-GetApptScheduleWithLocationServiceDate-5

    [Documentation]    Update the schedule with another service then try to get the schedule with the updated service.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id2}

JD-TC-GetApptScheduleWithLocationServiceDate-6

    [Documentation]    Update the schedule with another location then try to get the schedule with the updated location.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}   ${lid1}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id2}

JD-TC-GetApptScheduleWithLocationServiceDate-7

    [Documentation]    Get Appt Schedule for today (2 schedules having same location and service).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD}
    Log  ${resp.content}    
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable   ${s_id}
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=6
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  15  
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid}    ${s_id}   ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}                      ${s_id}

    Should Be Equal As Strings  ${resp.json()[1]['id']}                                     ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['services'][0]['id']}                      ${s_id}
    
JD-TC-GetApptScheduleWithLocationServiceDate-UH1

    [Documentation]    Disable the schedule then try to get the schedule with the location, service and date.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetApptScheduleWithLocationServiceDate-UH2

    [Documentation]    try to get the schedule by another provider with the location, service and date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}

JD-TC-GetApptScheduleWithLocationServiceDate-UH3

    [Documentation]     get the schedule for a past date.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  db.subtract_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

JD-TC-GetApptScheduleWithLocationServiceDate-UH4

    [Documentation]    Disable the location then try to get the schedule with the disabled location.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Location  ${lid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${LOCATION_DISABLED}

JD-TC-GetApptScheduleWithLocationServiceDate-UH5

    [Documentation]   get the schedule without login.

    ${DAY}=  db.add_timezone_date  ${tz}  4     
    ${resp}=  Get Appointment Schedule By Location service Date   ${lid1}    ${s_id2}   ${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
	Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
