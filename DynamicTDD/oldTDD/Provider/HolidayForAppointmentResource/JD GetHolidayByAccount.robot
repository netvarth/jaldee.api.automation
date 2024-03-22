*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Holiday
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${self}   0  
${service_duration}   2
${parallel}           1

*** Test Cases ***

JD-TC-GetHolidays-1
    [Documentation]  Provider create appointment schedule and today appointment is enabled then create a holiday
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME182}
    clear_location  ${PUSERNAME182}
    clear_customer   ${PUSERNAME182}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME182}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${cur_time1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable  ${cur_time1}
    ${DAY}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${DAY}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable  ${eTime1}
    ${desc1}=    FakerLibrary.name
    Set Suite Variable  ${desc1}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${cur_time1}  ${eTime1}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc1}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
  
    ${cur_time2}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable  ${cur_time2}
    ${DAY2}=  db.add_timezone_date  ${tz}  6  
    Set Suite Variable  ${DAY2}
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable  ${eTime2}
    ${desc2}=    FakerLibrary.name
    Set Suite Variable  ${desc2}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${cur_time2}  ${eTime2}  ${desc2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId2}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc2}  id=${holidayId2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime2}
  
  
JD-TC-GetHolidays-UH1      
    [Documentation]  Get  holiday by login as consumer

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-GetHolidays-UH2
    [Documentation]  Get holiday without login

    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"


JD-TC-Verify GetHolidays-1
    [Documentation]  Verify Get Holidays 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    Verify Response List  ${resp}  0  description=${desc1}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
  
    Verify Response List  ${resp}  1  description=${desc2}   id=${holidayId2} 
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time2}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime2}
  
  
     
