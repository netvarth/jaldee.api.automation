*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment, Schedule
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
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${self}         0
${Empty_list}   []
${def_sch_id}   1
${def_sch_name}   Schedule 1

*** Test Cases *** 
   
JD-TC-GetConsumerApptSchedulesByConsumer-1

    [Documentation]   When provider never create Appointment Schedules

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME210}
    Set Suite Variable  ${PUSERNAME210_id}   ${accId}
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME210}
    clear_location  ${PUSERNAME210}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}

    ${lid}=  Create Sample Location

    ${resp}=  Get Location By Id   ${lid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Appointment Schedules Consumer  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   []
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetConsumerApptSchedulesByConsumer-2

    [Documentation]   When provider create appointment schedules
       
    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME210}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
   
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}
    Set Suite Variable  ${P1_sch_name1}  ${resp.json()['name']}
    Set Suite Variable  ${list}          ${resp.json()['apptSchedule']['repeatIntervals']}
    Set Suite Variable  ${DAY1}          ${resp.json()['apptSchedule']['startDate']}
    Set Suite Variable  ${DAY2}          ${resp.json()['apptSchedule']['terminator']['endDate']}
    Set Suite Variable  ${sTime1}        ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${eTime1}        ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${p1_s2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}
    Set Suite Variable  ${P1_sch_name2}  ${resp.json()['name']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptState']}   ${Qstate[0]}
 
    Verify Response List  ${resp}  1  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptState']}       ${Qstate[0]}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetConsumerApptSchedulesByConsumer-3

    [Documentation]   When prodider Disable appointment schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME210}

    ${resp}=  Disable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptState']}       ${Qstate[1]}

    Verify Response List  ${resp}  1  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptState']}       ${Qstate[1]}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetConsumerApptSchedulesByConsumer-4

    [Documentation]   When prodider Enable Disabled appointment schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME210}

    ${resp}=  Enable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptState']}   ${Qstate[0]}
 
    Verify Response List  ${resp}  1  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptState']}       ${Qstate[0]}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-GetConsumerApptSchedulesByConsumer-UH1

    [Documentation]   Get Appointment without consumer login

    ${resp}=  Get Appointment Schedules Consumer  ${PUSERNAME210_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetConsumerApptSchedulesByConsumer-UH2

    [Documentation]   A provider try to get Appointment Schedules of another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment Schedules Consumer  ${PUSERNAME210_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${Empty_list}

JD-TC-GetConsumerApptSchedulesByConsumer-UH3

    [Documentation]   When same provider try to get his own Appointment Schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Appointment Schedules Consumer  ${PUSERNAME210_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptState']}   ${Qstate[0]}
 
    Verify Response List  ${resp}  1  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptState']}       ${Qstate[0]}
