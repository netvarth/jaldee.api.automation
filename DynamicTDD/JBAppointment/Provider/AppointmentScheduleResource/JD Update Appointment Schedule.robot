*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${SERVICE1}  manicure 
${SERVICE2}  pedicure
${SERVICE3}  Nail Art
${self}     0
@{service_names}
@{emptylist}

*** Test Cases ***

JD-TC-Update schedule-1

    [Documentation]    Update an appointment schedule name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-2

    [Documentation]    Update an appointment schedule recurring interval.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME210}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME210}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${list1}=  Create List  1  2  3  4  7
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list1}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-3

    [Documentation]    Update an appointment schedule start date and end date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY4}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-4

    [Documentation]    Update an appointment schedule start time and end time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${sTime2}=  add_timezone_time  ${tz}  0  30  
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id} 

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-5

    [Documentation]    Update an appointment schedule parallel serving to more than existing parallel serving value.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # FOR  ${i}  IN RANGE  5
    #     ${parallel1}=  Random Int  min=1  max=10
    #     Run Keyword If    ${parallel1} != ${parallel}   Exit For Loop
    #     ...  ELSE  Continue For Loop
    # END
    ${parallel1}=  FakerLibrary.Random Int  min=6  max=10
    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_PARALLE_CAPACITY}"

    # ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-6

    [Documentation]    Update an appointment schedule parallel serving to more than existing parallel serving value.
    ...   When there is an active appointment in it

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${fname1}=  generate_firstname
    Set Suite Variable   ${fname1}
    ${lname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lname1}
   
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # FOR  ${i}  IN RANGE  5
    #     ${parallel1}=  Random Int  min=1  max=10
    #     Run Keyword If    ${parallel1} != ${parallel}   Exit For Loop
    #     ...  ELSE  Continue For Loop
    # END
    ${parallel1}=  FakerLibrary.Random Int  min=6  max=10
    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_PARALLE_CAPACITY}"

    # ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-7
    [Documentation]    Update an appointment schedule location.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # ${lid1}=  Create Sample Location
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-8
    [Documentation]    Update an appointment schedule time duration.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime2}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    FOR   ${i}  IN RANGE   5
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${delta}
        Exit For Loop If  ${duration1} != ${duration}
    END
    # ${duration1}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_SLOTDURATION}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-9
    [Documentation]    Update an appointment schedule service.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update schedule-10
    [Documentation]    Update an appointment schedule to have multiple services.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE3}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id2}

JD-TC-Update schedule-11
    [Documentation]    Update an appointment schedule to enable batch.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-12
    [Documentation]    Update appointment schedule with same name
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-13
    [Documentation]    Update appointment schedule with same name as another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME207}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME207}
    # clear_location  ${PUSERNAME207}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME207}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-14
    [Documentation]    Update appointment schedule with same start and end dates as another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME207}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME207}
    # clear_location  ${PUSERNAME207}
    # clear_service   ${PUSERNAME207}
    # clear_location  ${PUSERNAME207}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME207}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY4} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-15

    [Documentation]    Update appointment schedule with same start time and end time as another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${sTime2}=  add_timezone_time  ${tz}  0  30  
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    Set Suite Variable   ${sTime2}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
  
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}   
        ${s_id}=  Create Sample Service  ${SERVICE1}  
    ELSE
        Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
    END

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-16

    [Documentation]    Update appointment schedule with same duration as another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME282}
    clear_Label  ${PUSERNAME282}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name1}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    FOR   ${i}  IN RANGE   5
        ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
        Exit For Loop If  ${duration} != ${duration1}
    END
    # ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_SLOTDURATION}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-17
    [Documentation]    Update appointment schedule with same location as another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME283}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME283}
    clear_Label  ${PUSERNAME283}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name1}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}      
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid1}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-18
    [Documentation]    Update appointment schedule with same service as another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME283}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME283}
    clear_Label  ${PUSERNAME283}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name1}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    # ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  notificationType=${notifytype[2]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # Set Test Variable  ${s_id1}  ${resp.json()}
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update schedule-19
    [Documentation]    Update appointment schedule with same location as another schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${random_mins}=  FakerLibrary.Random Int  min=${delta}  max=60
    ${schedule_name1}=  FakerLibrary.bs
    ${sTime2}=  add_timezone_time  ${tz}  0  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    # ${lid1}=  Create Sample Location
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-20
    [Documentation]    Update appointment schedule with same service as another existing schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=   db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${bool1}=  Random Element  ${bool}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update schedule-21
    [Documentation]    Update appointment schedule with same service and location as another existing schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=   db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${bool1}=  Random Element  ${bool}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    
    # ${lid1}=  Create Sample Location
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}


JD-TC-Update schedule-22
    [Documentation]    Update appointment schedule with same start date and end date, but different time, as existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=   db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${DAY3}=  db.add_timezone_date  ${tz}  11 
    ${DAY4}=  db.add_timezone_date  ${tz}  15        
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
	# ${sTime2}=  add_timezone_time  ${tz}  1  30  
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-23
    [Documentation]    Update appointment schedule with same start time and end time, but different dates as existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  11 
    ${DAY4}=  db.add_timezone_date  ${tz}  15  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-24
    [Documentation]    Update appointment schedule with same duration, but different dates and time as existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY4}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    FOR   ${i}  IN RANGE   5
        ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
        Exit For Loop If  ${duration1} != ${duration}
    END
    # ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_SLOTDURATION}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-25
    [Documentation]    Update appointment schedule with same duration, start time and end time, but different dates as another existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  11
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  15        
    Set Suite Variable  ${DAY4}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    FOR   ${i}  IN RANGE   5
        ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
        Exit For Loop If  ${duration1} != ${duration}
    END
    # ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_SLOTDURATION}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-26
    [Documentation]   update an appointment schedule's start time to before the original start time with multiple of duration and check available slots

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


    ${sTime2}=  add_timezone_time  ${tz}  0  ${duration}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-27
    [Documentation]   update an appointment schedule's start time to after the original start time with multiple of duration and check available slots

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*5}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


    ${sTime2}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Update schedule-28
    [Documentation]   update an appointment schedule's end time to a time after the original end time with multiple of duration and check available slots
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${eTime2}=  add_two   ${sTime1}  ${duration*5}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-29
    [Documentation]   update an appointment schedule's end time to a time before the original end time with multiple of duration and check available slots
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*5}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${eTime2}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    
    ${sch_length}=  get_slot_length  ${duration*4}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    END

JD-TC-Update schedule-30
    [Documentation]   update an appointment schedule's start time and end time to 12:00 AM and 11:59 PM  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${sTime2}=  Set Variable   00:00 AM
    ${converted_sTime2}=  db.convert_12AM   ${sTime2}
    ${eTime2}=  Set Variable   11:59 PM
    ${converted_eTime2}=  db.convert_time   ${eTime2}

    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${converted_sTime2}  ${converted_eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-31

    [Documentation]   update an appointment schedule's duration to 1440 mins (24 hours)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    # ${duration}=  Set Variable  1440
    ${sTime1}=  Set Variable   00:00 AM
    ${converted_sTime1}=  db.convert_12AM   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  Set Variable   11:59 PM
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${duration1}=  Set Variable  1440

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_SLOTDURATION}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-32

    [Documentation]   update an appointment schedule name with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME208}
    

    ${lid}=  Create Sample Location
    Set Suite Variable    ${lid}
    ${lid1}=  Create Sample Location
    Set Suite Variable    ${lid1}
    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite Variable    ${DAY2} 
    ${DAY3}=  db.add_timezone_date  ${tz}  3    
    Set Suite Variable    ${DAY3} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable    ${sTime1} 
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable    ${converted_sTime1} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable    ${delta} 
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable    ${eTime1} 
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable    ${converted_eTime1} 
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id} 

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${s_id1} 
    ${schedule_name}=  FakerLibrary.bs
    # Set Suite Variable    ${schedule_name} 
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable    ${parallel} 
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    Set Suite Variable    ${duration} 
    ${bool1}=  Random Element  ${bool}
    Set Suite Variable    ${bool1} 
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname1}   lastName=${lname1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    comment   Update schedule name.
    
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name1}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-33
    [Documentation]   add an extra service to appointment schedule with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

JD-TC-Update schedule-34
    [Documentation]   remove unused service from a schedule with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Not Contain  ${resp.json()['services']}  ${s_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

    
JD-TC-Update schedule-35
    [Documentation]   update service in a schedule with active appointments in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}


JD-TC-Update schedule-36
    [Documentation]   update an appointment schedule's start time to before the original start time and check available slots
    ...     when new start time is not a multiple of duration

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${sTime2}=  add_timezone_time  ${tz}  0  ${duration-2}
    ${actual_sTime2}=  add_timezone_time  ${tz}  0  ${duration}
    ${converted_sTime2}=  db.convert_time   ${actual_sTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-37
    [Documentation]   update an appointment schedule's end time to a time after the original end time and check available slots
    ...   when end time is not a multiple of duration
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${eTime2}=  add_two   ${sTime1}  ${duration*5+2}
    ${actual_eTime2}=  sub_two   ${eTime2}  2
    ${converted_eTime2}=  db.convert_time   ${actual_eTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update schedule-38
    [Documentation]   update an appointment schedule's start time to a time before the original start time and check available slots
    ...   when start time is a multiple of duration
    ...     and Schedule has an appointment in it
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${sTime2}=  sub_two   ${sTime1}  ${duration}
    Set Suite Variable    ${sTime2} 
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    Set Suite Variable    ${converted_sTime2} 
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mins_between}=  mins_diff  ${sTime2}  ${eTime1}
    ${sch_length}=  get_slot_length  ${mins_between}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        # Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    END

JD-TC-Update schedule-39
    [Documentation]   update an appointment schedule's end time to a time after the original end time and check available slots
    ...   when end time is a multiple of duration
    ...     and Schedule has an appointment in it
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${eTime2}=  add_two   ${eTime1}  ${duration}
    Set Suite Variable    ${eTime2} 
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    Set Suite Variable    ${converted_eTime2} 
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mins_between}=  mins_diff  ${sTime1}  ${eTime2}
    ${sch_length}=  get_slot_length  ${mins_between}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        # Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    END


JD-TC-Update schedule-40
    [Documentation]   update an appointment schedule's start time to a time before the original start time and check available slots
    ...   when start time is not a multiple of duration
    ...     and Schedule has an appointment in it
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${sTime2}=  sub_two   ${sTime1}  ${duration+2}
    Set Test Variable    ${sTime2} 
    ${sTime2_dur}=  sub_two   ${sTime1}  ${duration}
    ${converted_sTime2}=  db.convert_time   ${sTime2_dur}
    Set Test Variable    ${converted_sTime2} 
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mins_between}=  mins_diff  ${sTime2_dur}  ${eTime1}
    ${sch_length}=  get_slot_length  ${mins_between}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime2_dur}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime2_dur}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        # Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    END

JD-TC-Update schedule-41
    [Documentation]   update an appointment schedule's end time to a time after the original end time and check available slots
    ...   when end time is not a multiple of duration
    ...     and Schedule has an appointment in it
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration*2}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${eTime2}=  add_two   ${eTime1}  ${duration+2}
    Set Test Variable    ${eTime2} 
    ${etime2_dur}=  add_two   ${eTime1}  ${duration}
    ${converted_eTime2}=  db.convert_time   ${etime2_dur}
    Set Test Variable    ${converted_eTime2} 
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mins_between}=  mins_diff  ${sTime1}  ${etime2_dur}
    ${sch_length}=  get_slot_length  ${mins_between}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        # Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    END


JD-TC-Update schedule-UH1
    [Documentation]    Update appointment schedule with same name as another existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY4}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${sTime2}=  add_timezone_time  ${tz}  1  30  
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool2}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${APPT_SCHEDULE_NAME_ALREADY_EXISTS}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-UH2
    [Documentation]    Update appointment schedule with same start date, end date, start time and end time as existing appointment schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  11
    Set Suite Variable  ${DAY3} 
    ${DAY4}=  db.add_timezone_date  ${tz}  15        
    Set Suite Variable  ${DAY4}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${random_mins}=  FakerLibrary.Random Int  min=1  max=10
    ${sTime2}=  add_two  ${eTime1}  ${random_mins}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${duration1}=  FakerLibrary.Random Int  min=5  max=${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"   "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH3
    [Documentation]    Update appointment schedule with schedule id of another provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME284}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME284}
    clear_Label  ${PUSERNAME284}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name1}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    Set Suite Variable   ${duration}
    ${bool1}=  Random Element  ${bool}
    Set Suite Variable   ${bool1}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
	Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-UH4
    [Documentation]    Update appointment schedule with location of another provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME284}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME284}
    clear_Label  ${PUSERNAME284}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
	Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Update schedule-UH5
    [Documentation]    Update appointment schedule with service of another provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME285}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME282}
    clear_customer   ${PUSERNAME285}
    clear_Label  ${PUSERNAME285}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name1}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
	Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
   
JD-TC-Update schedule-UH6

    [Documentation]    Update appointment schedule without provider login.

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
	Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Update schedule-UH7

    [Documentation]   update an appointment schedule's start time with time that is not a multiple of duration without disabling
    ...     when new start time is after original start time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta-1}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${sTime2}=  add_timezone_time  ${tz}  0  ${delta}
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH8
    [Documentation]   update an appointment schedule's end time with time that is not a multiple of duration
    ...     And less than existing end time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${sTime1}=  add_timezone_time  ${tz}  0  ${duration}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_two   ${sTime1}  ${duration*4}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${eTime2}=  add_two   ${sTime1}  ${duration*4-5}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-UH9
    [Documentation]   update an appointment schedule's duration as greater than 1440 mins (24 hours)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    # ${duration}=  Set Variable  1440
    ${sTime1}=  Set Variable   00:00 AM
    ${converted_sTime1}=  db.convert_12AM   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  Set Variable   11:59 PM
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${duration1}=  Set Variable  1441

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SLOT_DURATION_LESS}"

JD-TC-Update schedule-UH10

    [Documentation]   update an appointment schedule's duration as 0 mins (24 hours)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    # ${duration}=  Set Variable  1440
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=   add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${duration1}=  Set Variable  0

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SLOT_DURATION_GREATER}"

JD-TC-Update schedule-UH11

    [Documentation]   update an appointment schedule's duration as a negative value (24 hours)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    # ${duration}=  Set Variable  1440
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${eTime1}=   add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${duration1}=  Set Variable  -5

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SLOT_DURATION_GREATER}"

JD-TC-Update schedule-UH12

    [Documentation]   update an appointment working days with an active appointment in it.
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME208}
    

    ${lid}=  Create Sample Location
    Set Suite Variable    ${lid}
    ${lid1}=  Create Sample Location
    Set Suite Variable    ${lid1}
    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite Variable    ${DAY2} 
    ${DAY3}=  db.add_timezone_date  ${tz}  3    
    Set Suite Variable    ${DAY3} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable    ${sTime1} 
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable    ${converted_sTime1} 
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable    ${delta} 
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable    ${eTime1} 
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable    ${converted_eTime1} 
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id} 

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${s_id1} 

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable    ${schedule_name} 
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable    ${parallel} 
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    Set Suite Variable    ${duration} 
    ${bool1}=  Random Element  ${bool}
    Set Suite Variable    ${bool1} 
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    comment   update an appointment working days with an active appointment in it.
    
    ${list1}=  Create List    2  3  4  5  6  7
    Set Suite Variable   ${list1}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list1}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"

    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-UH13

    [Documentation]   update an appointment working days without today included in it with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${list1}=  Create List
    ${today}=   get_timezone_weekday  ${tz}
    FOR   ${i}  IN RANGE   1   7
        Continue For Loop If    ${today} == ${i}  
        ${j}=   Convert To String  ${i}
        Append To List  ${list1}    ${j}
    END
    
    Set Suite Variable   ${list1}

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list1}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Update schedule-UH14
    [Documentation]   update an appointment recurring type to once with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri}=  Create List  ${today}

    ${schedule_name}=  FakerLibrary.bs
    ${SCHEDULE_RECURRING_TYPE}=  Format String    ${SCHEDULE_RECURRING_TYPE}    ${recurringtype[4]}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_RECURRING_TYPE}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Update schedule-UH15
    [Documentation]   update an appointment recurring type to once with an active future appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId2}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri}=  Create List  ${today}

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[4]}  ${list1}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-Update schedule-UH16
    [Documentation]   update start date in a schedule with active appointments in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${DAY4}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable    ${DAY4}
    ${DAY5}=  db.add_timezone_date  ${tz}  15    
    Set Suite Variable    ${DAY5}   
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    

JD-TC-Update schedule-UH17
    [Documentation]   update end date in a schedule with active appointments in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
      
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY5}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

JD-TC-Update schedule-UH18
    [Documentation]   update start time in a schedule with active appointments in it.
    ...     Start time is a multiple of duration.
    ...     Start time is after existing start time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
      
    ${sTime2}=  add_two   ${sTime1}  ${duration}
    Set Suite Variable    ${sTime2} 
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    Set Suite Variable    ${converted_sTime2} 
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    

JD-TC-Update schedule-UH19
    [Documentation]   update end time in a schedule with active appointments in it.
    ...     End time is a multiple of duration.
    ...     End time is before existing end time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
      
    
    ${eTime2}=  sub_two   ${eTime1}  ${duration}
    Set Suite Variable    ${eTime2} 
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    Set Suite Variable    ${converted_eTime2} 
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}


JD-TC-Update schedule-UH20
    [Documentation]   update start time in a schedule with active appointments in it.
    ...     Start time is not a multiple of duration.
    ...     Start time is after existing start time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
      
    ${sTime2}=  add_two   ${sTime1}  ${duration+2}
    Set Suite Variable    ${sTime2} 
    ${converted_sTime2}=  db.convert_time   ${sTime2}
    Set Suite Variable    ${converted_sTime2} 
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    

JD-TC-Update schedule-UH21
    [Documentation]   update end time in a schedule with active appointments in it.
    ...     End time is not a multiple of duration.
    ...     End time is before existing end time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
      
    
    ${eTime2}=  sub_two   ${eTime1}  ${duration+2}
    Set Suite Variable    ${eTime2} 
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    Set Suite Variable    ${converted_eTime2} 
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REDUCE_SCHEDULE_TIME}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}


JD-TC-Update schedule-UH22
    [Documentation]   update an appointment location with an active appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}   instantSchedule=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

JD-TC-Update schedule-UH23
    [Documentation]    Update an appointment schedule recurring type to once.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${ri}=  Create List  @{EMPTY}
    ${SCHEDULE_RECURRING_TYPE}=  Format String    ${SCHEDULE_RECURRING_TYPE}    ${recurringtype[4]}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_RECURRING_TYPE}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-UH24
    [Documentation]    Update an appointment schedule parallel serving to less than existing parallel serving value.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # FOR  ${i}  IN RANGE  5
    #     ${parallel1}=  Random Int  min=1  max=10
    #     Run Keyword If    ${parallel1} != ${parallel}   Exit For Loop
    #     ...  ELSE  Continue For Loop
    # END
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=5
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_PARALLE_CAPACITY}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH25
    [Documentation]    Update an appointment schedule parallel serving to less than existing parallel serving value.
    ...   With an active appointment in it
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME208}
    # 
    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # FOR  ${i}  IN RANGE  5
    #     ${parallel1}=  Random Int  min=1  max=10
    #     Run Keyword If    ${parallel1} != ${parallel}   Exit For Loop
    #     ...  ELSE  Continue For Loop
    # END
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=5
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_PARALLE_CAPACITY}"

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings  "${resp.json()}"   "${APPT_SCHEDULE_CANNOT_DISABLE}"

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action    ${apptStatus[4]}   ${apptid1}   cancelReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}


    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH26

    [Documentation]    Update an appointment schedule's end date to an earlier date,
    ...   When there is an active future appointment in it for a date after the new end date.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME208}
    
    clear_customer   ${PUSERNAME208}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${DAY3}=  db.add_timezone_date  ${tz}  9
    ${DAY4}=  db.add_timezone_date  ${tz}  7       
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY4}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH27

    [Documentation]    Update an appointment schedule's location, when there is an appointment in it.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME208}
    
    clear_customer   ${PUSERNAME208}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SCHEDULE_ACTIVE_APPT}"
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-Update schedule-UH28

    [Documentation]    Update an appointment schedule's service, when there is an appointment in it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME208}
    
    clear_customer   ${PUSERNAME208}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}



JD-TC-Update schedule-42
    [Documentation]    Update an appointment schedule consumerparallelserving
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_timezone_time  ${tz}  3  40 
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=10  max=15
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=5  max=${parallel}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}    consumerParallelServing=${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${consumerparallelserving1}=  FakerLibrary.Random Int  min=1    max=${consumerparallelserving}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${PLEASE_DISABLE_SCHEDULE}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  02s

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}    consumerParallelServing=${consumerparallelserving1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

JD-TC-Update schedule-43

    [Documentation]    create an appointment schedule and take Appointments ,then disable schedule and update consumerparallelserving.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallel}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}    consumerParallelServing=${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    # ${schedule_name1}=  FakerLibrary.bs
    # ${consumerparallelserving}=  FakerLibrary.Random Int  min=1    max=10
    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}    consumerParallelServing=${consumerparallelserving}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME8}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Suite Variable  ${lname}  ${resp.json()[0]['lastName']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${noOfAvailbleSlots}=   Evaluate  ${parallel}-1

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action   ${apptStatus[5]}   ${apptid1}  rejectReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerparallelserving1}=  FakerLibrary.Random Int  min=1    max=${parallel}
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool[1]}    consumerParallelServing=${consumerparallelserving1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

JD-TC-Update schedule-44
    [Documentation]    create Appoiment Schedule and Update an appointment schedule consumerparallelserving and take appointment.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=8  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=2
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}    consumerParallelServing=${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${consumerparallelserving1}=  FakerLibrary.Random Int  min=3   max=5
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}    consumerParallelServing=${consumerparallelserving1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME8}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Suite Variable  ${lname}  ${resp.json()[0]['lastName']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    
    ${noOfAvailbleSlots}=   Evaluate  ${parallel}-1

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['time']}   ${slot1} 
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${noOfAvailbleSlots}
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['capacity']}   ${parallel}

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
        #     Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        # END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${slot1}   ${slots[${j}]}



JD-TC-Update schedule-45
    [Documentation]    create Appoiment Schedule and Update an appointment schedule consumerparallelserving and take  future appointment.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${DAY3}=  db.add_timezone_date  ${tz}  20      
    Set Suite Variable  ${DAY3}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=5  max=${parallel}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}    consumerParallelServing=${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${consumerparallelserving1}=  FakerLibrary.Random Int  min=1    max=4
    
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY3}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${PLEASE_DISABLE_SCHEDULE}

    ${resp}=    Enable Disable Appointment Schedule   ${sch_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY3}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}    consumerParallelServing=${consumerparallelserving1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME8}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Suite Variable  ${lname}  ${resp.json()[0]['lastName']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word

    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY3}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    
    ${noOfAvailbleSlots}=   Evaluate  ${parallel}-1

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['time']}   ${slot1} 
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${noOfAvailbleSlots}
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['active']}   True
    Should Be Equal As Strings     ${resp.json()['availableSlots'][0]['capacity']}   ${parallel}


JD-TC-Update schedule-UH29
    [Documentation]    Update an appointment schedule consumerparallelserving greater than parallel
    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # clear_service   ${PUSERNAME208}
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${converted_sTime1}=  db.convert_time   ${sTime1}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${converted_eTime1}=  db.convert_time   ${eTime1}
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallel}
    ${duration}=  FakerLibrary.Random Int  min=5  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}    consumerParallelServing=${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${converted_sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${converted_eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
    ${minparallel}=  Evaluate   ${parallel} + 1
    ${consumerparallelserving1}=  FakerLibrary.Random Int  min=${minparallel}    max=20
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallelserving1}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${SCHEDULE_PARALLE_CAPACITY_OF_CONSUMER}
    
JD-TC-Update schedule-UH30
    [Documentation]    Create service with  resourcesRequired .then add same value in parallelServing and increase parallelServing

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid01}=  get_acc_id  ${PUSERNAME208}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${resouces}=    FakerLibrary.Random Int  min=4  max=8
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}    resoucesRequired=${resouces}

    ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=5  max=3
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${resouces}    ${resouces}  ${lid}  ${duration}  ${bool1}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${parallel}=  Evaluate  ${resouces}+1
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME11}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${pid01}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${pid01}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME11}   

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid01}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid01}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}

    # ${parallel}=  Evaluate  ${resouces}+1
    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Update schedule-UH31
    [Documentation]    Create service with  resourcesRequired .then add same value in parallelServing and degrease parallelServing.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid01}=  get_acc_id  ${PUSERNAME208}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME208}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${resouces}=    FakerLibrary.Random Int  min=4  max=8
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}    resoucesRequired=${resouces}

    ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=5  max=3
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${resouces}    ${resouces}  ${lid}  ${duration}  ${bool1}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${parallel}=  Evaluate  ${resouces}-2
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
   
JD-TC-Update schedule-UH32

    [Documentation]    Create a schedule and update the schedule to a past date, then take an appt to past date then reschedule it to a future date.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME50}
    # clear_location  ${HLPUSERNAME50}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${p1_lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${p1_lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${p1_lid}  ${resp.json()['id']}
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${PAST_DAY1}=  db.subtract_timezone_date  ${tz}   5
    ${DAY2}=  db.add_timezone_date  ${tz}  10         
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${parallel}=  FakerLibrary.Random Int  min=20  max=25
    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${PAST_DAY1}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${p1_lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PAST_DAY2}=  db.subtract_timezone_date  ${tz}   3

    ${resp}=  Get Appointment Slots By Date Schedule   ${sch_id1}  ${PAST_DAY2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    Set Test Variable   ${slot1}   ${slots[0]}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer    ${cid}  ${s_id}  ${sch_id1}  ${PAST_DAY2}  ${cnote}  ${apptfor}   location=${{str('${p1_lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${h_apptid1}  ${resp.json()['uid']}

    ${FUT_DAY1}=  db.add_timezone_date  ${tz}  1

    ${resp}=  Get Appointment Slots By Date Schedule   ${sch_id1}  ${FUT_DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    Set Test Variable   ${slot2}   ${slots[0]}

    ${resp}=  Reschedule Consumer Appointment   ${h_apptid1}  ${slot2}  ${FUT_DAY1}  ${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${h_apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200