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


*** Test Cases ***
JD-TC-GetHolidayById-1
    [Documentation]  Get holiday By Id

    clear_location    ${PUSERNAME32}
    clear_service     ${PUSERNAME32}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID32}=  get_acc_id   ${PUSERNAME32}
    
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id}   ${resp['location_id']}
    Set Suite Variable   ${ser_id}   ${resp['service_id']}
    Set Suite Variable   ${que_id}   ${resp['queue_id']}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Get Queue By Location and service By Date  ${loc_id}  ${ser_id}  ${CUR_DAY}  ${ACC_ID32}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${strt_time}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']} 
    Set Test Variable   ${end_time}     ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holi_id}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id  ${holi_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}  description=${desc}   id=${holi_id} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
   
JD-TC-GetHolidayById-UH1      
    [Documentation]  Get  holiday by login as consumer

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holi_id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-GetHolidayById-UH2
    [Documentation]  Get holiday without login

    ${resp}=   Get Holiday By Id  ${holi_id}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
     
     
JD-TC-GetHolidayById-UH3
    [Documentation]  Get holiday details of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holi_id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"

JD-TC-GetHolidayById-UH4
    [Documentation]  Get an invalid holiday details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id   0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${HOLIDAY_NOT_FOUND}"
     
