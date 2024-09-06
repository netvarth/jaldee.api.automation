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

*** Test Cases ***

JD-TC-UpdateHoliday-1
    [Documentation]  update a  holiday for a valid provider

    clear_location    ${PUSERNAME135}
    clear_service     ${PUSERNAME135}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID35}=  get_acc_id   ${PUSERNAME135}
    
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id}   ${resp['location_id']}
    Set Suite Variable   ${ser_id}   ${resp['service_id']}
    Set Suite Variable   ${que_id}   ${resp['queue_id']}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Queue By Location and service By Date  ${loc_id}  ${ser_id}  ${CUR_DAY}  ${ACC_ID35}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${strt_time}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']} 
    Set Suite Variable   ${end_time}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${desc1}=    FakerLibrary.word
    Set Test Variable      ${desc1}
    ${desc2}=    FakerLibrary.word
    Set Test Variable      ${desc2}
    ${holi_time}=   add_timezone_time  ${tz}   0   55
    Set Suite Variable    ${holi_time}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId}    ${resp.json()['holidayId']}

    ${resp}=  Update Holiday   ${holidayId}  ${desc2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${holi_time}  ${end_time}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}  description=${desc2}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holi_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  

JD-TC-UpdateHoliday-2
    [Documentation]  update a holiday with date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  3  
    ${desc}=    FakerLibrary.word
    # ${resp}=  Update Holiday  ${DAY2}  ${desc}  ${strt_time}  ${end_time}  ${id}
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${holi_time}  ${end_time}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANT_CHANGE_DATE}"
    ${resp}=   Get Holiday By Id  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holi_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}


JD-TC-UpdateHoliday-3
    [Documentation]  update a holiday with end time greater than scheduled end time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${end_time}=   add_timezone_time  ${tz}  2  00  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  
    ${desc}=    FakerLibrary.word
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
JD-TC-UpdateHoliday-4
    [Documentation]  Update  a holiday with start time less than scheduled start time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${strt_time}=   add_timezone_time  ${tz}   0   2
    ${DAY2}=  db.add_timezone_date  ${tz}  3  
    ${desc}=    FakerLibrary.word
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

JD-TC-UpdateHoliday-5
    [Documentation]   create a future holiday and then update the holiday's start date to current day

    clear_service    ${PUSERNAME187}
    clear_location   ${PUSERNAME187}
    clear_queue      ${PUSERNAME187}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME187} 
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id4}   ${resp}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id4}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    
    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}   ${resp.json()}

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sone}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY2}  ${EMPTY}  ${sone}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    
    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

JD-TC-UpdateHoliday-6
      [Documentation]   create 3  holiday and then updating the holiday here extending the last date

    clear_service    ${PUSERNAME184}
    clear_location   ${PUSERNAME184}
    clear_queue      ${PUSERNAME184}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME184}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME184} 
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id4}   ${resp}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id4}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}   ${resp.json()}

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sone}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${DAY5}=  db.add_timezone_date  ${tz}  8  
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY5}  ${EMPTY}  ${sone}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY5}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    
    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

     
JD-TC-UpdateHoliday-7
    [Documentation]   create 3  holiday and take waitlist and appointment for future date then updating that holiday to this future date and check waitlist status

    clear_service    ${PUSERNAME184}
    clear_location   ${PUSERNAME184}
    clear_queue      ${PUSERNAME184}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME184}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME184} 
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id4}   ${resp}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id4}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}   ${resp.json()}

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sone}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${resp}=  AddCustomer  ${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${q_id4}  ${DAY4}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${DAY_end}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY_end}  ${EMPTY}  ${sone}  ${eone}  ${parallel}    ${parallel}  ${loc_id4}  ${duration}  ${bool[1]}  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY4}  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][1]['time']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id4}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}
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

    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY4}  ${EMPTY}  ${sone}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   1
    Should Be Equal As Strings   ${resp.json()['apptCount']}   1

    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY4}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}


    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

JD-TC-UpdateHoliday-8
    [Documentation]   update a  current day holiday to future date for a valid provider

    clear_location    ${PUSERNAME136}
    clear_service     ${PUSERNAME136}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID36}=  get_acc_id   ${PUSERNAME136}
    
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id1}   ${resp['location_id']}
    Set Suite Variable   ${ser_id1}   ${resp['service_id']}
    Set Suite Variable   ${que_id1}   ${resp['queue_id']}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Queue By Location and service By Date  ${loc_id1}  ${ser_id1}  ${CUR_DAY}  ${ACC_ID36}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${strt_time1}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']} 
    Set Suite Variable   ${end_time1}    ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}
    
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    
    ${desc1}=    FakerLibrary.word
    Set Test Variable      ${desc1}
    ${desc2}=    FakerLibrary.word
    Set Test Variable      ${desc2}
    ${holi_time1}=   add_timezone_time  ${tz}   0   55
    Set Suite Variable    ${holi_time1}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time1}  ${end_time1}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}

    ${resp}=  Update Holiday   ${holidayId1}  ${desc2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${holi_time1}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId1}
    Verify Response    ${resp}  description=${desc2}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holi_time1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

JD-TC-UpdateHoliday-9
    [Documentation]   create 3  holiday and take waitlist and appointment for current date then updating that holiday time start time to earlier time and check waitlist status

    clear_service    ${PUSERNAME187}
    clear_location   ${PUSERNAME187}
    clear_queue      ${PUSERNAME187}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME187} 
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id4}   ${resp}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id4}   ${resp} 
    ${ser_name5}=    FakerLibrary.name
    Set Test Variable     ${ser_name5} 
    ${resp}=  Create Sample Service   ${ser_name5}
    Set Test Variable    ${ser_id5}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  5  00  

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${DAY_end}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=5  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY_end}  ${EMPTY}  ${sone}  ${eone}  ${parallel}    ${parallel}  ${loc_id4}  ${duration}  ${bool[1]}  ${ser_id4}  ${ser_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${CUR_DAY}  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${length}=  Get Length    ${resp.json()['availableSlots']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id4}  ${sch_id}  ${CUR_DAY}  ${cnote}  ${apptfor}
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

    ${DAY2}=  db.add_timezone_date  ${tz}  3  
    ${sone1}=   add_timezone_time  ${tz}  2  00  
    ${eone1}=   add_timezone_time  ${tz}  4  00  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY2}  ${EMPTY}  ${sone1}  ${eone1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone1}


    ${sone2}=   add_timezone_time  ${tz}  1  00  
    ${eone2}=   add_timezone_time  ${tz}  4  00  
    ${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY2}  ${EMPTY}  ${sone2}  ${eone2}  
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"
 

JD-TC-UpdateHoliday-UH1
    [Documentation]  Update holiday of a different provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.word
    Set Suite Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()['holidayId']}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Holiday   ${id}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${holi_time}  ${end_time}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-UpdateHoliday-UH3
    [Documentation]  Update a holiday without login

    ${resp}=  Update Holiday   ${id}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-UpdateHoliday-UH4
    [Documentation]  Update a holiday using consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Holiday   ${id}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateHoliday-UH5
    [Documentation]  update holiday to a past time 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cur_time}=  add_timezone_time  ${tz}  0  52
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()['holidayId']}
    # ${c_time}=  db.get_time_by_timezone   ${tz}  
    ${c_time}=  db.get_time_by_timezone  ${tz}  
    ${ptime}=  db.subtract_timezone_time  ${tz}  0  1
    ${resp}=  Update Holiday   ${id1}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${ptime}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_START_TIME_INCORRECT}"
      


JD-TC-UpdateHoliday-UH6
    [Documentation]   create 3  holiday and then creating another holiday between this day(start date is already a holiday)

    clear_service    ${PUSERNAME187}
    clear_location   ${PUSERNAME187}
    clear_queue      ${PUSERNAME187}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME187} 
    ${resp}=  Create Sample Location
    Set Suite Variable    ${loc_id4}   ${resp}
    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Suite Variable    ${ser_id4}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${q_name3}=    FakerLibrary.name
    Set Suite Variable    ${q_name3}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    # ${sone}=   db.get_time_by_timezone   ${tz}
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}   ${resp.json()}

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sone}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${q_id4}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    
    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sone}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId4}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId4}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sone}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}


    #create  another oveelapped one
    ${DAY5}=  db.add_timezone_date  ${tz}  8  
    ${resp}=  Update Holiday   ${holidayId4}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY5}  ${EMPTY}  ${sone}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"
    
    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=   Delete Holiday  ${holidayId4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId4}"

JD-TC-UpdateHoliday-UH7
    [Documentation]   create 3  holiday and then update that holiday with overlapping the last date(last date is already a holiday)

    ${resp}=  Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${holitm}=   add_timezone_time  ${tz}  1  00  
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId4}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId4}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}


    ${resp}=  Update Holiday   ${holidayId4}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY3}  ${EMPTY}  ${holitm}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ALREADY_NON_WORKING_DAY}"
    
    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=   Delete Holiday  ${holidayId4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId4}"


JD-TC-UpdateHoliday-UH8
    [Documentation]   create 3  holiday and then update that holiday with start date as current day 

    ${resp}=  Encrypted Provider Login     ${PUSERNAME181}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service    ${PUSERNAME181}
    clear_location   ${PUSERNAME181}
    clear_queue      ${PUSERNAME181}
    clear_customer   ${PUSERNAME181}

    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${holitm}=   add_timezone_time  ${tz}  1  00  
    ${eone}=   add_timezone_time  ${tz}  2  00  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}


    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId4}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId4}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${DAY5}=  db.add_timezone_date  ${tz}  7  
    ${resp}=  Update Holiday   ${holidayId4}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY5}  ${EMPTY}  ${holitm}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ALREADY_NON_WORKING_DAY}"

    #   ${resp}=   Delete Holiday  ${holidayId}
    #   Should Be Equal As Strings  ${resp.status_code}  200
    #   ${resp}=   Get Holiday By Account
    #   Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    #   ${resp}=   Delete Holiday  ${holidayId4}
    #   Should Be Equal As Strings  ${resp.status_code}  200
    #   ${resp}=   Get Holiday By Account
    #   Should Not Contain   ${resp.json()}  "id":"${holidayId4}"


JD-TC-UpdateHoliday-UH9
    [Documentation]   create 3  holiday and then update that holiday with start date as current day 

    ${resp}=  Encrypted Provider Login     ${PUSERNAME181}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service    ${PUSERNAME181}
    clear_location   ${PUSERNAME181}
    clear_queue      ${PUSERNAME181}
    clear_customer   ${PUSERNAME181}

    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
    

    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  3  

    ${holitm}=   add_timezone_time  ${tz}  1  00  
    ${eone}=   add_timezone_time  ${tz}  3  00  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId4}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId4}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holitm}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eone}

    ${DAY5}=  db.add_timezone_date  ${tz}  7  
    ${resp}=  Update Holiday   ${holidayId4}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY5}  ${EMPTY}  ${holitm}  ${eone}  
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200
    #   Should Be Equal As Strings  ${resp.status_code}  422
    #   Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ENDDATE_OVERLAPPED}"

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId4}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${q_id}  ${DAY3}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



   #waiting time

JD-TC-UpdateHoliday-10
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the starttime 
    ...               Here activate holiday is false and try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
      
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=0  serviceTime=${end_time1}

    # ${serviceTime}=   Evaluate   ${end_time1}+${duration}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${duration} 

    ${holi_time}=  add_timezone_time  ${tz}  0  30  
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${holi_time}  ${end_time}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${holi_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=0  

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${duration}  


JD-TC-UpdateHoliday-11
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime 
    ...               Here activate holiday is false and try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
      
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=0  serviceTime=${end_time}

    ${serviceTime}=   add_two   ${end_time}   ${duration}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${duration}   serviceTime=${serviceTime}

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=0  serviceTime=${end_time1} 
    
    ${serviceTime1}=   add_two   ${end_time1}   ${duration}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=${duration}  serviceTime=${serviceTime1}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${duration} 


JD-TC-UpdateHoliday-12
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime with the queue time 
    ...               here activate holiday is false and try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}

    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=0  serviceTime=${end_time} 

    ${serviceTime}=   add_two   ${end_time}   ${duration}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=${duration}   serviceTime=${serviceTime} 

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  4  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=0  

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=${duration}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${duration}
    
JD-TC-UpdateHoliday-13
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime
    ...               (cant serve the pending checkins with the given time,giving less working time with more checkins) here activate holiday is false and try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=11  max=20
    ${ser_name3}=   FakerLibrary.name
    ${resp}=  Create Service  ${ser_name3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${ser_id3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${sId_4}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
      
    ${wait_time}=  Evaluate  ((${duration}+${duration}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  40 
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   5
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${serviceTime1}=   add_two   ${end_time1}      ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   

JD-TC-UpdateHoliday-14 
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime
    ...               and cancel one waitlist, here activate holiday is false and try to check waitliststatus and waiting time


    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}  
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${ser_name3}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id3}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${sId_4}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${wait_time}=  Evaluate  ((${duration}+${duration}+${duration}+${s_dur2})/4)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   5
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${cncl_resn}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${serviceTime1}=   add_two   ${end_time1}      ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   

JD-TC-UpdateHoliday-15
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime 
     ...              here activate holiday is false and try to check waitliststatus of the tokens


    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=11  max=20
    ${ser_name3}=   FakerLibrary.name
    ${resp}=  Create Service  ${ser_name3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${ser_id3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${sId_4}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
      
    ${wait_time}=  Evaluate  ((${duration}+${duration}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  10 
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   5
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${serviceTime1}=   add_two   ${end_time1}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   

JD-TC-UpdateHoliday-16
    [Documentation]  create a holiday and take waitlist and then update that holiday by extending the endtime 
    ...              here activate holiday is false then delete that holiday and try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=11  max=20
    ${ser_name3}=   FakerLibrary.name
    ${resp}=  Create Service  ${ser_name3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${ser_id3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${sId_4}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
      
    ${wait_time}=  Evaluate  ((${duration}+${duration}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  2  40 
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   5
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
   
    ${resp}=   Delete Holiday   ${holidayId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId1}"

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateHoliday-17
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime 
    ...               here activate holiday is false and and cancel one waitlist and then revert it to checkin state then try to check waitliststatus and waiting time

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}  
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}
    

    ${ser_name3}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Test Variable    ${ser_id3}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0


    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}


    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${sId_4}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${wait_time}=  Evaluate  ((${duration}+${duration}+${duration}+${s_dur2})/4)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
    ${serviceTime3}=   add_two   ${serviceTime2}   ${wait_time}
    ${serviceTime4}=   add_two   ${serviceTime3}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime3}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[4]['serviceTime']}       ${serviceTime4}
    Should Be Equal As Strings  ${resp.json()[4]['waitlistStatus']}    ${wl_status[1]}
   
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   5
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0
    
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${cncl_resn}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateHoliday-18
    [Documentation]   create a holiday and take waitlist and then update that holiday by extending the endtime 
    ...               here activate holiday is true and try to check waitliststatus 

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}

    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    ${resp}=   Get Service By Id  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=0  serviceTime=${end_time} 

    ${serviceTime}=   add_two   ${end_time}   ${duration}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=${duration}   serviceTime=${serviceTime} 

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=  add_timezone_time  ${tz}  3  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0

    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}  

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}  
