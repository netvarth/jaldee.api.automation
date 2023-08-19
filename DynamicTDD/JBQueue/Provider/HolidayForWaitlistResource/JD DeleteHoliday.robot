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
@{parl_max_servd}    2   3   4 

*** Test Cases ***
JD-TC-DeleteHoliday-1
    [Documentation]  Delete a holiday
      
    clear_location    ${PUSERNAME170}
    clear_service     ${PUSERNAME170}
    ${resp}=  ProviderLogin  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id}   ${resp['location_id']}
    Set Suite Variable   ${ser_id}   ${resp['service_id']}
    Set Suite Variable   ${que_id}   ${resp['queue_id']}
    ${DAY1}=  add_date  4
    Set Suite Variable   ${DAY1}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${CUR_TIME}=  add_time   0  46
    Set Suite Variable   ${CUR_TIME}
    ${END_TIME}=  add_time   0  50
    Set Suite Variable   ${END_TIME}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${CUR_TIME}  ${END_TIME}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id  ${id}
    Verify Response  ${resp}   description=${desc}  id=${id}
    ${resp}=   Delete Holiday  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Not Contain   ${resp.json()}  "id":"${id}"

JD-TC-DeleteHoliday-2
    [Documentation]  Create a holiday for all queues in an account then deleting that holiday

    ${resp}=  ProviderLogin  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${CUR_DAY}=  add_date  1
    ${q_name1}=    FakerLibrary.name
    Set Test Variable      ${q_name1}
    ${q_name2}=    FakerLibrary.name
    Set Test Variable      ${q_name2}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${start_time1}=   add_time   2  00
    ${end_time1}=     add_time   3  59
    ${start_time2}=   add_time   4  00
    ${end_time2}=     add_time   5  00
    ${parl_servd}=   Random Element    ${parl_max_servd}
    ${max_servd}=    Random Element    ${parl_max_servd}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${start_time1}  ${end_time1}  ${parl_servd}  ${max_servd}  ${loc_id}  ${ser_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${start_time2}  ${end_time2}  ${parl_servd}  ${max_servd}  ${loc_id}  ${ser_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  add_date  2
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${start_time1}  ${end_time2}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id  ${id}
    Verify Response  ${resp}   description=${desc}  id=${id}
    ${resp}=   Delete Holiday  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Not Contain   ${resp.json()}  "id":"${id}"

JD-TC-DeleteHoliday-UH1
    [Documentation]  Delete holiday of a different provider

    ${resp}=  ProviderLogin  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${CUR_TIME}  ${END_TIME}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${id} 
    # Should Contain   ${resp.json()}  "startDay":"${DAY1}" 
    Verify Response  ${resp}   description=${desc}  id=${id}     
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME31}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Delete Holiday  ${id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
      
      
JD-TC-DeleteHoliday-UH2
    [Documentation]  Delete a holiday without login

    ${resp}=   Delete Holiday  ${id}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
      
JD-TC-DeleteHoliday-UH3
    [Documentation]  Delete a holiday using consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Delete Holiday  ${id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DeleteHoliday-UH4
    [Documentation]  Delete an invalid holiday

    ${resp}=  ProviderLogin  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Delete Holiday   0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${HOLIDAY_NOT_FOUND}"      

JD-TC-DeleteHoliday-UH5
    [Documentation]   create a holiday and take waitlist then set activate status is false and delete that holiday 

    clear_service    ${PUSERNAME181}
    clear_location   ${PUSERNAME181}
    clear_queue      ${PUSERNAME181}
    clear_customer   ${PUSERNAME181}


    ${resp}=  ProviderLogin     ${PUSERNAME181}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME181}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${CUR_DAY}=  get_date
    Set Test Variable    ${CUR_DAY}

    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}  

    ${ser_name2}=    FakerLibrary.name 
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

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

    ${Last_Day}=  add_date   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.get_time  
    ${end_time}=    add_time  4  00 
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   add_date  15
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}  ${ser_id3}  ${sId_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${cur_time}=  db.get_time  
    ${desc1}=    FakerLibrary.name
    ${end_time}=    add_time  2  00 
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc1}
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
   
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc1}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

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
    Should Not Contain   ${resp.json()}  "id":"${holidayId1}"

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200