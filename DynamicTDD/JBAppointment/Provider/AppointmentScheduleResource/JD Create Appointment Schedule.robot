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
    [Documentation]    Create an appointment schedule
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

JD-TC-CreateAppointmentSchedule-2
    [Documentation]    Create a schedule with same details of another provider
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p2_lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}


JD-TC-CreateAppointmentSchedule-3
    [Documentation]    Create a second schedule to the same location with more services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE5}
    ${s_id5}=  Create Sample Service  ${SERVICE6}
    ${sTime2}=  add_timezone_time  ${tz}  0  35  
    Set Suite Variable   ${sTime2}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    Set Suite Variable  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid}  ${duration}  ${bool1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['services'][2]['id']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['services'][3]['id']}  ${s_id5}

JD-TC-CreateAppointmentSchedule-4
    [Documentation]    Create a second schedule to the same location with same time and different services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id6}=  Create Sample Service  ${SERVICE7}
    ${s_id7}=  Create Sample Service  ${SERVICE8}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid}  ${duration}  ${bool1}  ${s_id6}  ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id6}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id7}


JD-TC-CreateAppointmentSchedule-5
    [Documentation]    Create 2 schedules with same time on different days
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p2_lid1}=  Create Sample Location
    Set Suite Variable  ${p2_lid1}
    # clear_service   ${PUSERNAME${a}}
    # clear_location  ${PUSERNAME${a}}
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

    ${sTime3}=  add_timezone_time  ${tz}  0  50
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime3}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  3  5  7
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3} 
    ${list}=  Create List  2  4  6
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}  ${s_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

JD-TC-CreateAppointmentSchedule-6
    [Documentation]    Two schedules have same timings ,one schedule is enabled and another one disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME134}
    # clear_location  ${PUSERNAME134}
    clear_service   ${PUSERNAME134}
    clear_location  ${PUSERNAME134}

    ${p2_lid1}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME134}

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
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    ${sTime3}=  add_timezone_time  ${tz}  0  50
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime3}  ${delta}    
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

    ${resp}=  Disable Appointment Schedule  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}  ${s_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}  

JD-TC-CreateAppointmentSchedule-7
    [Documentation]    create a schedule that overlap another two schedules
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_location  ${PUSERNAME${a}} 
    # clear_service   ${PUSERNAME${a}}  
    
    clear_service   ${PUSERNAME${a}}
    clear_location  ${PUSERNAME${a}}

    ${p2_lid1}=  Create Sample Location
    Set Suite Variable  ${p2_lid1}
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

    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${sTime1}=  add_timezone_time  ${tz}  1  35
    Set Suite Variable  ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable  ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${delta}
    Set Suite Variable  ${duration1}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration1}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}

    ${resp}=  Disable Appointment Schedule  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration1}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}

    ${sTime2}=  add_timezone_time  ${tz}  2  35
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    Set Suite Variable  ${eTime2}
    ${duration2}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration2}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}
    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration2}  apptState=${Qstate[1]}  parallelServing=${parallel}  batchEnable=${bool1}

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration2}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id3}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration2}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}

JD-TC-CreateAppointmentSchedule-8
    [Documentation]    Create a schedule in different location with overlapping time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking_type}    Random Element  ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${sTime}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}    
    ${resp}=  Create Location  ${city}a  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_lid2}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    Set Suite Variable  ${duration}
    Set Suite Variable  ${schedule_name}
    Set Suite Variable  ${parallel}
    Set Suite Variable  ${bool1}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid2}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id4}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_lid2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}    
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    

JD-TC-CreateAppointmentSchedule-UH1
    [Documentation]    Create a schedule in different location with another service and already existing schedule name and time 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid2}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_SCHEDULE_NAME_ALREADY_EXISTS}"

JD-TC-CreateAppointmentSchedule-UH2
    [Documentation]    Create a schedule to the same location with overlapping time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateAppointmentSchedule-UH3
    [Documentation]    Create a schedule in a location without service details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"

JD-TC-CreateAppointmentSchedule-UH4
    [Documentation]    Create a schedule in a location without location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${EMPTY}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"

JD-TC-CreateAppointmentSchedule-UH5
    [Documentation]    Create a schedule with another providers location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id5}=  Create Sample Service  ${SERVICE3}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p2_lid}  ${duration}  ${bool1}  ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_NOT_FOUND}"

JD-TC-CreateAppointmentSchedule-UH6
    [Documentation]    Create a schedule with another providers service  details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id6}=  Create Sample Service  ${SERVICE6}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mins_between}=  mins_diff  ${eTime1}  ${eTime2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${mins_between}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${eTime1}  ${eTime2}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-CreateAppointmentSchedule-UH7
    [Documentation]    Create a schedule with eTime is less than sTime
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_appt_schedule   ${PUSERNAME${a}}
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sTime9}=  add_timezone_time  ${tz}  5  15  
    ${eTime9}=  add_timezone_time  ${tz}  4  30  
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${parallel}    ${parallel}  ${p2_lid1}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_END_TIME_MISMATCH}"

JD-TC-CreateAppointmentSchedule-UH8
    [Documentation]    Create a schedule with schedule time is less than  duration
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime9}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime9}=  add_two   ${sTime9}  ${delta}
    ${min}=  Evaluate  ${delta}+1
    ${max}=  Evaluate  ${delta}+100
    ${duration}=  FakerLibrary.Random Int  min=${min}  max=${max}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${parallel}    ${parallel}  ${p2_lid2}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SLOT_DURATION_IS_MORE}" 

JD-TC-CreateAppointmentSchedule-UH9
    [Documentation]    Create two appointment schedules with same services on same timings
    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME133}
    # clear_location  ${PUSERNAME133}

    clear_service   ${PUSERNAME133}
    clear_location  ${PUSERNAME133}

    ${p1_lid}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME133}

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
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"

JD-TC-CreateAppointmentSchedule-9
    [Documentation]    Create an appointment schedule for user
    ${resp}=  Encrypted Provider Login   ${HLMUSERNAME0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+365
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}   


    ${whpnum}=  Evaluate  ${PUSERPH0}+556245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+556345 
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  state=${state}  deptId=${dep_id}  
    ${city1} = 	Convert To Lower Case 	${city}
    ${city2} = 	Convert To Lower Case 	${resp.json()['city']}
    Should Be Equal As Strings   ${city1}  ${city2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


JD-TC-CreateAppointmentSchedule-UH10
    [Documentation]    create schedule with start date, a past date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME133}
    clear_location  ${PUSERNAME133}

    ${p1_lid}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME133}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.subtract_timezone_date  ${tz}   5
    ${DAY2}=  db.add_timezone_date  ${tz}  10         
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_DATE_PAST}"


JD-TC-CreateAppointmentSchedule-UH11
    [Documentation]    create schedule with start date and end date, as past dates
    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME133}
    clear_location  ${PUSERNAME133}

    ${p1_lid}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME133}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.subtract_timezone_date  ${tz}   10
    ${DAY2}=  db.subtract_timezone_date  ${tz}   1       
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_DATE_PAST}"


JD-TC-CreateAppointmentSchedule-10
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[0]}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-11
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule without end date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}
    


JD-TC-CreateAppointmentSchedule-12
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with full repeat intervals

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-13
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with repeat intervals as today's weekday

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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
    # ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-14
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with repeat intervals as tomorrow's weekday

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
  
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
    # ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${DAY3}=  db.add_timezone_date  ${tz}  1     
    ${day3_weekday}=   get_weekday_by_date   ${DAY3} 
    ${list}=  Create List  ${day3_weekday}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-15
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with start date as future date 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY1}=  db.add_timezone_date  ${tz}  2    
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    # ${today}=   get_timezone_weekday  ${tz}
    # ${today}=   Convert To String  ${today}
    ${day1_weekday}=   get_weekday_by_date   ${DAY1} 
    ${day1_weekday}=   Convert To String  ${day1_weekday}
    ${ri_day1}=  Create List  ${day1_weekday}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_day1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-16
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with multiple services

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-17
    # [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    # ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule in multiple locations

   # ${billable_providers}=    Billable   
  #  Log   ${billable_providers}
  #  Set Suite Variable   ${billable_providers}
  #  ${pro_len}=  Get Length   ${billable_providers}
  #  Log  ${pro_len}
    

  #  ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=50   max=60
  #  Log Many  ${billable_providers} 	${multilocPro}
  #  Set Suite Variable   ${billable_providers}
  #  Set Suite Variable   ${multilocPro}


    ${billable_providers}   ${multilocPro}=    Multiloc and Billable highest license Providers    min=0   max=260
     Log Many  ${billable_providers} 	${multilocPro}
    Set Suite Variable   ${billable_providers}
    Set Suite Variable   ${multilocPro}


    ${resp}=  Encrypted Provider Login  ${multilocPro[10]}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    

    clear_service   ${multilocPro[10]}
    clear_location  ${multilocPro[10]}
    clear_appt_schedule   ${multilocPro[10]}
 
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
  
    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200


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
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    ${sTime2}=  add_two   ${eTime1}  ${delta}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration1}  ${bool2}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    ${sch_length}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel1}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-18
    # [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    # ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with the same details as that of another schedule in another location
     
   #   ${billable_providers}=    Billable   
    #Log   ${billable_providers}
    #Set Suite Variable   ${billable_providers}
    #${pro_len}=  Get Length   ${billable_providers}
    #Log  ${pro_len}

    #  ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=50   max=60
    #Log Many  ${billable_providers} 	${multilocPro}
    #Set Suite Variable   ${billable_providers}
    #Set Suite Variable   ${multilocPro}


    ${billable_providers}   ${multilocPro}=    Multiloc and Billable highest license Providers    min=0   max=260
     Log Many  ${billable_providers} 	${multilocPro}
    Set Suite Variable   ${billable_providers}
    Set Suite Variable   ${multilocPro}



    
    ${resp}=  Encrypted Provider Login  ${multilocPro[10]}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    clear_service   ${multilocPro[10]}
    clear_location  ${multilocPro[10]}
    clear_appt_schedule   ${multilocPro[10]}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}

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
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime2}=  add_two   ${eTime1}  ${delta}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime2}=  add_two   ${sTime2}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
    # ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool2}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sLength}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${emptydict}=   Create Dictionary
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${emptydict}


JD-TC-CreateAppointmentSchedule-19
    [Setup]   Run Keywords  clear_service   ${PUSERNAME133}  
    ...   AND  clear_location  ${PUSERNAME133}  AND  clear_appt_schedule   ${PUSERNAME133}
    [Documentation]    Create an instant schedule with the same details as that of another schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    

    # clear_service   ${PUSERNAME133}
    # clear_location  ${PUSERNAME133}
    
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME133}
    ${s_id}=  Create Sample Service  ${SERVICE1}

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
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today} 
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Set Test Variable  ${st}  ${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        
    END

    Log   ${slots}

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${today}=   get_timezone_weekday  ${tz}   
    ${list}=  Create List  ${today}
    # ${sTime2}=  add_two   ${eTime1}  ${delta}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime2}=  add_two   ${sTime2}  ${delta1}
    # ${schedule_name1}=  FakerLibrary.bs
    # ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool2}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_SCHEDULE_NAME_ALREADY_EXISTS}"

    
    
JD-TC-CreateAppointmentSchedule-20
    [Documentation]    Create an appointment schedule with consumerparallelserving
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
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallel}=  FakerLibrary.Random Int  min=1  max=5

    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${consumerparallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}  consumerParallelServing=${consumerparallel}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}


JD-TC-CreateAppointmentSchedule-21
    [Documentation]    Create an appointment schedule with a service having lead time.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME132}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${leadTime}=   Random Int   min=1   max=5
    ${s_id}=  Create Sample Service  ${SERVICE1}  leadTime=${leadTime}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumerparallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}  consumerParallelServing=${consumerparallel}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END


JD-TC-CreateAppointmentSchedule-22
    [Documentation]    Create an appointment schedule with a service having lead time and duration less than lead time.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME132}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${leadTime}=   Random Int   min=1   max=5
    ${s_id}=  Create Sample Service  ${SERVICE1}  leadTime=${leadTime}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallel}=  FakerLibrary.Random Int  min=1  max=5

    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumerparallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}  consumerParallelServing=${consumerparallel}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END


JD-TC-CreateAppointmentSchedule-23
    [Documentation]    Create an appointment schedule with duration less than service time.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME132}
    clear_appt_schedule   ${PUSERNAME132}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service By Id   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${srv_dur}  ${resp.json()['serviceDuration']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=1  max=${srv_dur}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumerparallel}  ${p1_lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}  consumerParallelServing=${consumerparallel}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END



   