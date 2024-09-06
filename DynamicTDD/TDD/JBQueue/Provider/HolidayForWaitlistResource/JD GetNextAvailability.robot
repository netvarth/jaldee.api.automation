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
JD-TC-GetNextAvailability-1
    [Documentation]   create a  holiday for the current day and check availability

    clear_service    ${PUSERNAME50}
    clear_location   ${PUSERNAME50}
    clear_queue      ${PUSERNAME50}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME50}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID35}=  get_acc_id    ${PUSERNAME50}
    Set Suite Variable          ${ACC_ID35}  
    ${resp}=  Create Sample Location
    Set Suite Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Suite Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    Set Suite Variable    ${end_time}  
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    Set Suite Variable   ${parallel}
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    Set Suite Variable   ${capacity}
    ${endday}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable   ${endday}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}   ${resp.json()}

    ${cur_time}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${cur_time}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    Set Suite Variable   ${Last_Day}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
    ${resp}=  Get Waiting Time Of Providers  ${ACC_ID35}-${loc_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    # ${availableDate}=   db.add_timezone_date  ${tz}   4
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings   ${resp.json()['availableDate']}      ${CUR_DAY}
  

JD-TC-GetNextAvailability-2
    [Documentation]   create a  full time holiday for the current day and queue schedule end date is empty 

    clear_service    ${PUSERNAME50}
    clear_location   ${PUSERNAME50}
    clear_queue      ${PUSERNAME50}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME50}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID35}=  get_acc_id    ${PUSERNAME50}
    Set Test Variable          ${ACC_ID35}  
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
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
    ${cur_time}=  add_timezone_time  ${tz}  1  30  
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
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
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
    ${resp}=  Get Waiting Time Of Providers  ${ACC_ID35}-${loc_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    # ${availableDate}=   db.add_timezone_date  ${tz}   4
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings   ${resp.json()['availableDate']}      ${CUR_DAY}

JD-TC-GetNextAvailability-3
    [Documentation]   create a  holiday for 3 days and queue schedule end date is empty and delete that holiday then try to take checkin

    clear_service    ${PUSERNAME36}
    clear_location   ${PUSERNAME36}
    clear_queue      ${PUSERNAME36}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME36}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID36}=  get_acc_id    ${PUSERNAME36}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id1}   ${resp}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id1}   ${resp}   
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}   ${resp.json()}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId2}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
    ${resp}=  Get Waiting Time Of Providers  ${ACC_ID36}-${loc_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${availableDate}=   db.add_timezone_date  ${tz}   4
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings   ${resp.json()['availableDate']}      ${availableDate}
   
    ${resp}=   Delete Holiday  ${holidayId2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId2}"


    ${resp}=  AddCustomer  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${q_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-GetNextAvailability-UH1
	[Documentation]  without login
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${cur_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   

JD-TC-GetNextAvailability-UH2
	[Documentation]  without consumer login
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${cur_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"   

JD-TC-GetNextAvailability-UH3
    [Documentation]   create a  holiday for 3 days and try to take checkin on holiday

    clear_service    ${PUSERNAME36}
    clear_location   ${PUSERNAME36}
    clear_queue      ${PUSERNAME36}
    ${resp}=  Encrypted Provider Login     ${PUSERNAME36}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID36}=  get_acc_id    ${PUSERNAME36}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id1}   ${resp}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id1}   ${resp}   
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}   ${resp.json()}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
   

    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId2}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
    ${resp}=  Get Waiting Time Of Providers  ${ACC_ID36}-${loc_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${availableDate}=   db.add_timezone_date  ${tz}   4
    ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings   ${resp.json()['availableDate']}      ${availableDate}

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${q_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    



    