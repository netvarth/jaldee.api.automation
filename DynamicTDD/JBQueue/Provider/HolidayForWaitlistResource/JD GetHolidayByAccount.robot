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
JD-TC-GetHolidays-1
    [Documentation]  Get Holidays 

    clear_location    ${PUSERNAME34}
    clear_service     ${PUSERNAME34}
    ${resp}=  ProviderLogin  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID34}=  get_acc_id   ${PUSERNAME34}
    ${CUR_DAY}=  get_date
    Set Suite Variable   ${CUR_DAY}
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id}   ${resp['location_id']}
    Set Suite Variable   ${ser_id}   ${resp['service_id']}
    Set Suite Variable   ${que_id}   ${resp['queue_id']}
    ${resp}=  Get Queue By Location and service By Date  ${loc_id}  ${ser_id}  ${CUR_DAY}  ${ACC_ID34}
    Log   ${resp.json()}
    Set Suite Variable   ${strt_time}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']} 
    Set Suite Variable   ${end_time}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}
    ${DAY1}=  add_date  1
    Set Suite Variable   ${DAY1}
    ${desc1}=    FakerLibrary.name
    Set Suite Variable      ${desc1}
    ${desc2}=    FakerLibrary.name
    Set Suite Variable      ${desc2}
    ${cur_time}=  add_time  0  48
    Set Suite Variable   ${cur_time}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holi_id1}    ${resp.json()['holidayId']}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holi_id2}    ${resp.json()['holidayId']}
     
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

    ${resp}=  ProviderLogin  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    Verify Response List  ${resp}  0  description=${desc1}   id=${holi_id1} 
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
   
    Verify Response List  ${resp}  1  description=${desc2}   id=${holi_id2} 
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${DAY1}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
   
     
