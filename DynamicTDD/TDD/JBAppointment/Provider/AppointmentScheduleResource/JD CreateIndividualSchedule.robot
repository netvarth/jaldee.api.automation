*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Appointment, Schedule
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

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

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['individualScheduleId']}  ${sch_id}

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['individualScheduleId']}  0

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
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availableDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availabilityTime'][0]}  ${sTime1}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-CreateAppointmentSchedule-2
    [Documentation]    Create a individual schedule with same details of another provider
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${licId}  ${licname}=  get_highest_license_pkg
    FOR   ${a}  IN RANGE   ${start}  ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    Set Test Variable   ${pkgId}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    ${resp2}=   Get Domain Settings    ${domain}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Log  ${resp.content}
    Set Test Variable  ${check}  ${resp2.json()['multipleLocation']}
    Run Keyword If  "${check}"=="True" and "${pkgId}"=="${licId}"  Exit For Loop
    END
    Set Suite Variable  ${a}
    clear_service   ${PUSERNAME${a}}
    clear_location  ${PUSERNAME${a}}
    
    ${p2_lid}=  Create Sample Location
    Set Suite Variable  ${p2_lid}
    clear_appt_schedule   ${PUSERNAME${a}}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${resp}=  Create Individual Schedule  ${schedule_name}  ${parallel}    ${parallel}  ${p2_lid}    ${bool1}  ${s_id1}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}      parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availableDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availabilityTime'][0]}  ${sTime1}

JD-TC-CreateAppointmentSchedule-3
    [Documentation]    Two individual schedules have same timings ,one individual schedule is enabled and another one disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME134}
    # clear_location  ${PUSERNAME134}
    clear_service   ${PUSERNAME134}
    clear_location  ${PUSERNAME134}

    ${p2_lid1}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME134}
    Set Suite Variable  ${p2_lid1}


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

    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}

    ${s_id3}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id3}

    ${sTime3}=  add_timezone_time  ${tz}  0  50
    Set Suite Variable  ${sTime3}

    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}

    ${eTime3}=  add_two   ${sTime3}  ${delta} 
    Set Suite Variable  ${eTime3}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable  ${parallel}
    
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    Set Suite Variable  ${duration}

    ${bool1}=  Random Element  ${bool}
    
    ${time}=   Create List    ${sTime1}
    Set Suite Variable  ${time}

    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    Set Suite Variable  ${iA}
    
    ${resp}=  Create Individual Schedule  ${schedule_name}  ${parallel}    ${parallel}  ${p2_lid1}    ${bool1}  ${s_id2}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}      parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}  ${SERVICE3}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availableDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['individualApptSchedule'][0]['availabilityTime'][0]}  ${sTime1}

    ${resp}=  Disable Appointment Schedule  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${resp}=  Create Individual Schedule  ${schedule_name}  ${parallel}    ${parallel}  ${p2_lid1}    ${bool1}  ${s_id2}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

JD-TC-CreateAppointmentSchedule-4
    [Documentation]    try to create recurring type schedule with same details of the individual schedule.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool[1]}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-5
    [Documentation]    Provider create individual schedule for Future date.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME134}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY2}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id2}=  Create Sample Service  ${SERVICE5}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p2_lid1}    ${bool[1]}  ${s_id2}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

JD-TC-CreateAppointmentSchedule-6
    [Documentation]    Provider create individual schedule for past date.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${DAY2}=  db.subtract_timezone_date  ${tz}  10   
    # Set Suite Variable  ${DAY2}

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY2}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id2}=  Create Sample Service  ${SERVICE4}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id2}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${APPT_START_DATE_PAST}

JD-TC-CreateAppointmentSchedule-7
    [Documentation]    Provider create individual schedule with scheduleType is recurring.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=recurring
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NECESSARY_FIELD_MISSING}

JD-TC-CreateAppointmentSchedule-8
    [Documentation]     create individual schedule with EMPTY parallel.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${EMPTY}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NECESSARY_FIELD_MISSING}

JD-TC-CreateAppointmentSchedule-9
    [Documentation]     create individual schedule with EMPTY Consumerparallel.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${EMPTY}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-10
    [Documentation]     create individual schedule with EMPTY Location.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${EMPTY}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NECESSARY_FIELD_MISSING}

JD-TC-CreateAppointmentSchedule-11
    [Documentation]     create individual schedule with EMPTY service.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${EMPTY}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-12
    [Documentation]     create individual schedule with EMPTY scheduleType.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-13
    [Documentation]     create individual schedule with EMPTY availabilityTime.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${EMPTY}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-14
    [Documentation]     create individual schedule with EMPTY availableDate.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs

    ${time}=   Create List    ${sTime1}
    ${iA}=   Create Dictionary  availableDate=${EMPTY}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-15
    [Documentation]     create individual schedule for multiple time.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs
    ${sTime2}=  add_timezone_time  ${tz}  0  16  
    ${sTime3}=  add_timezone_time  ${tz}  0  17  

    ${time}=   Create List    ${sTime1}     ${sTime2}   ${sTime3}
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p1_lid}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateAppointmentSchedule-16
    [Documentation]     create individual schedule with another providers location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME132}
    clear_service   ${PUSERNAME132}

    ${schedule_name1}=  FakerLibrary.bs
 
    ${time}=   Create List    ${sTime1}     
    ${iA}=   Create Dictionary  availableDate=${DAY1}       availabilityTime=${time}
    ${iA}=   Create List    ${iA}
    ${s_id3}=  Create Sample Service  ${SERVICE6}

    ${resp}=  Create Individual Schedule  ${schedule_name1}  ${parallel}    ${parallel}  ${p2_lid1}    ${bool[1]}  ${s_id3}      individualApptSchedule=${iA}    scheduleType=individual
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200