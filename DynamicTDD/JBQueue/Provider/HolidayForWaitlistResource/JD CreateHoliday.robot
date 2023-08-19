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


*** Test Cases ***

JD-TC-CreateHoliday-1
      [Documentation]   create a  holiday for the current day

      clear_service    ${PUSERNAME25}
      clear_location   ${PUSERNAME25}
      clear_queue      ${PUSERNAME25}
      ${resp}=  Encrypted Provider Login     ${PUSERNAME25}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID25}=  get_acc_id    ${PUSERNAME25}
      Set Suite Variable          ${ACC_ID25}  
      ${resp}=  Create Sample Location
      Set Suite Variable    ${loc_id}   ${resp}
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
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
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  6  00   
      Set Suite Variable    ${end_time}  
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      Set Suite Variable   ${parallel}
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q_id}   ${resp.json()}
      ${cur_time}=  add_timezone_time  ${tz}  1  30  
      Set Suite Variable   ${cur_time}
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
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
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
      ${resp}=  Get Waiting Time Of Providers  ${ACC_ID25}-${loc_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200     
      Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                             ${ACC_ID25}      
      Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}                   ${q_id}      
      Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['name']}                 ${q_name} 
      Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['serviceTime']}          ${strt_time} 
      Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['isAvailableToday']}     ${bool[1]}   
    
JD-TC-CreateHoliday-2
      [Documentation]  create  a future date holiday 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${FUTRE_DAY}=  db.add_timezone_date  ${tz}  6  
      Set Suite Variable   ${FUTRE_DAY}
      ${holi_time}=  add_timezone_time  ${tz}  5  00  
      Set Suite Variable   ${holi_time}
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${FUTRE_DAY}  ${FUTRE_DAY}  ${EMPTY}  ${cur_time}  ${holi_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${holidayId1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${FUTRE_DAY}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${FUTRE_DAY}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${holi_time}
  
      ${resp}=  Get Waiting Time Of Providers  ${ACC_ID25}-${loc_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${queue_id1}      
      # Should Be Equal As Strings  ${resp.json()[0]['name']}  ${queue_name1}    
      # Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}   ${st_time}        
      # Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}   ${en_time}        
       
JD-TC-CreateHoliday-3
      [Documentation]  Create a holiday for all queues in an account

      clear_location  ${PUSERNAME26}
      clear_service   ${PUSERNAME26}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID26}=  get_acc_id  ${PUSERNAME26}
      Set Suite Variable  ${ACC_ID26}
      ${resp}=  Create Sample Queue
      Set Suite Variable   ${loc_id1}   ${resp['location_id']}
      Set Suite Variable   ${ser_id1}   ${resp['service_id']}
      Set Suite Variable   ${que_id1}   ${resp['queue_id']}
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable      ${q_name1}
      ${start_time1}=   add_timezone_time  ${tz}  2  00  
      Set Suite Variable   ${start_time1}
      ${end_time1}=     add_timezone_time  ${tz}  5  00  
      Set Suite Variable   ${end_time1}
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${start_time1}  ${end_time1}    ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue By Location and service By Date  ${loc_id1}  ${ser_id1}  ${CUR_DAY}  ${ACC_ID26}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable   ${h_start_time}    ${resp.json()[1]['effectiveSchedule']['timeSlots'][0]['sTime']} 
      Set Suite Variable   ${h_end_time}      ${resp.json()[1]['effectiveSchedule']['timeSlots'][0]['eTime']}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Not Contain  ${resp.json()}  id=${ACC_ID26}
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${h_start_time}  ${end_time1}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${h_start_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}
   
      ${resp}=  Get Waiting Time Of Providers  ${ACC_ID26}-${loc_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      
JD-TC-CreateHoliday-4
      [Documentation]  Create a holiday and update schedule

      clear_location  ${PUSERNAME27}
      clear_service   ${PUSERNAME27}
      clear_queue      ${PUSERNAME27}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID27}=  get_acc_id  ${PUSERNAME27}
      Set Suite Variable  ${ACC_ID27}
      ${resp}=  Create Sample Queue
      Set Suite Variable   ${loc_id2}   ${resp['location_id']}
      Set Suite Variable   ${ser_id2}   ${resp['service_id']}
      Set Suite Variable   ${que_id2}   ${resp['queue_id']}
      ${resp}=   Get Location ById  ${loc_id2}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}
      ${DAY_ONE}=  db.add_timezone_date  ${tz}  1
      Set Suite Variable   ${DAY_ONE}
      ${h_start_time1}=   add_timezone_time  ${tz}  0  50  
      Set Suite Variable   ${h_start_time1}
      ${h_end_time1}=     add_timezone_time  ${tz}   0  56
      Set Suite Variable   ${h_end_time1}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY_ONE}  ${DAY_ONE}  ${EMPTY}  ${h_start_time1}  ${h_end_time1}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY_ONE}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY_ONE}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${h_start_time1}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${h_end_time1}
   
      ${q_name2}=    FakerLibrary.name
      Set Suite Variable      ${q_name2}
      ${start_time2}=   add_timezone_time  ${tz}  0  45  
      Set Suite Variable   ${start_time2}
      ${end_time2}=   add_timezone_time  ${tz}  5  00  
      Set Suite Variable   ${end_time2}
      ${resp}=  Update Queue  ${que_id2}  ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY_ONE}  ${EMPTY}  ${EMPTY}  ${start_time2}  ${end_time2}   ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
     
JD-TC-CreateHoliday-5
      [Documentation]  Create a holiday and update schedule

      clear_queue      ${PUSERNAME27}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Sample Queue
      Set Suite Variable   ${loc_id4}   ${resp['location_id']}
      Set Suite Variable   ${ser_id4}   ${resp['service_id']}
      Set Suite Variable   ${que_id4}   ${resp['queue_id']}
      ${resp}=   Get Location ById  ${loc_id4}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${DAY_TWO}=  db.add_timezone_date  ${tz}   4
      Set Suite Variable    ${DAY_TWO}
      ${cur_time1}=  add_timezone_time  ${tz}  1  45  
      Set Suite Variable     ${cur_time1}      
      ${holi_time2}=   add_timezone_time  ${tz}  4   00
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}
      ${resp}=   Get Holiday By Account
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY_TWO}  ${DAY_TWO}  ${EMPTY}  ${cur_time1}  ${holi_time2}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY_TWO}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY_TWO}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time1}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${holi_time2}
   
      ${q_name3}=    FakerLibrary.name
      Set Suite Variable      ${q_name3}
      ${new_strt_time}=   add_timezone_time  ${tz}   1   00
      Set Suite Variable   ${new_strt_time}
      ${new_end_time}=    add_timezone_time  ${tz}   3   30
      Set Suite Variable   ${new_end_time}
      ${resp}=  Update Queue  ${que_id4}  ${q_name3}  ${recurringtype[1]}  ${list}  ${DAY_TWO}  ${EMPTY}  ${EMPTY}  ${new_strt_time}  ${new_end_time}   ${parallel}   ${capacity}     ${loc_id4}  ${ser_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
     
JD-TC-CreateHoliday-6
      [Documentation]  Create a holiday without start time or end time of the schedule

      clear_queue      ${PUSERNAME28}
      clear_service    ${PUSERNAME28}
      clear_location   ${PUSERNAME28}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID28}=  get_acc_id   ${PUSERNAME28}
      Set Suite Variable   ${ACC_ID28}
      ${resp}=   Create Sample Queue
      Set Suite Variable   ${loc_id3}   ${resp['location_id']}
      Set Suite Variable   ${ser_id3}   ${resp['service_id']}
      Set Suite Variable   ${que_id3}   ${resp['queue_id']}
      ${resp}=   Get Location ById  ${loc_id3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${qu_name}=    FakerLibrary.name
      Set Suite Variable      ${qu_name}
      ${start_tim}=   add_timezone_time  ${tz}  2  00  
      Set Suite Variable   ${start_tim}
      ${end_tim}=     add_timezone_time  ${tz}  5  00  
      Set Suite Variable   ${end_tim}
      ${resp}=  Create Queue    ${qu_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${start_tim}  ${end_tim}    ${parallel}   ${capacity}    ${loc_id3}  ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${DAY_THREE}=  db.add_timezone_date  ${tz}   3
      Set Suite Variable   ${DAY_THREE}
      ${current_time}=   add_timezone_time  ${tz}     2  50
      Set Suite Variable   ${current_time}
      ${e_time}=     add_timezone_time  ${tz}     4  00
      Set Suite Variable   ${e_time}
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}

      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY_THREE}  ${DAY_THREE}  ${EMPTY}  ${current_time}  ${e_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY_THREE}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY_THREE}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${current_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${e_time}
   
      ${resp}=    Get Queues   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}      ${resp.json()[0]['id']}
      Set Suite Variable  ${qname11}    ${resp.json()[0]['name']}
      Set Suite Variable   ${stime11}    ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}
      Set Suite Variable   ${etime11}    ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}
      Set Suite Variable  ${qid2}      ${resp.json()[1]['id']}
      Set Suite Variable  ${qname12}    ${resp.json()[1]['name']}
      Set Suite Variable   ${stime12}    ${resp.json()[1]['queueSchedule']['timeSlots'][0]['sTime']}
      Set Suite Variable   ${etime12}    ${resp.json()[1]['queueSchedule']['timeSlots'][0]['eTime']}
    
JD-TC-CreateHoliday-7
      [Documentation]  Create a holiday which affects multiple queues
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${DAY1}=  db.add_timezone_date  ${tz}  1
      ${hol_sTime}    add_timezone_time  ${tz}   0   55
      Set Test Variable    ${hol_sTime} 
      ${hol_eTime}    add_timezone_time  ${tz}   2   50
      Set Test Variable    ${hol_eTime}  
      ${desc}=    FakerLibrary.name
      Set Test Variable      ${desc}  
   
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${hol_sTime}  ${hol_eTime}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY1}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${hol_sTime}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${hol_eTime}
   
      ${resp}=  Get Queue By Location and service By Date  ${loc_id3}  ${ser_id3}  ${DAY1}  ${ACC_ID28}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List         ${resp}  0  id=${qid2}  name=${qname12}
      Verify Response List         ${resp}  1  id=${qid1}  name=${qname11}
    
JD-TC-CreateHoliday-8
      [Documentation]  create  a holiday with end time greater than scheduled end time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queues
      Log   ${resp.json()}
      ${FUTRE_DAY1}=    db.add_timezone_date  ${tz}  9
      ${START_TIME1}=   add_timezone_time  ${tz}   00  47
      ${END_TIME1}=     add_timezone_time  ${tz}   6   30 
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${FUTRE_DAY1}  ${FUTRE_DAY1}  ${EMPTY}  ${START_TIME1}  ${END_TIME1}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_CREATE_TIME}"
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response    ${resp}  description=${desc}   id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${FUTRE_DAY1}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${FUTRE_DAY1}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${START_TIME1}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${END_TIME1}
   
JD-TC-CreateHoliday-9
      [Documentation]  create  a holiday with start time less than scheduled start time

      clear_queue     ${PUSERNAME26}     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${sat_time}=   add_timezone_time  ${tz}  3  30  
      Set Suite Variable  ${sat_time} 
      ${ed_time}=    add_timezone_time  ${tz}  4  00  
      Set Suite Variable  ${ed_time} 
      ${q_name4}=    FakerLibrary.name
      Set Suite Variable      ${q_name4}
      ${resp}=  Create Queue    ${q_name4}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sat_time}  ${ed_time}  ${parallel}    ${capacity}   ${loc_id1}  ${ser_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${queue_id}  ${resp.json()}
      ${les_strt_time}=  add_timezone_time  ${tz}  3  25
      ${les_end_time}=  add_timezone_time  ${tz}  3  50
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${les_strt_time}  ${les_end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}    ${resp.json()['holidayId']}
      ${resp}=   Get Holiday By Id  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200 
      Verify Response    ${resp}  description=${desc}  id=${id} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${les_strt_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${les_end_time}
      
JD-TC-CreateHoliday-10
      [Documentation]   Take waitlist and then create a  holiday for the 3 days and try to check waitliststatus

      clear_service    ${PUSERNAME30}
      clear_location   ${PUSERNAME30}
      clear_queue      ${PUSERNAME30}
      clear_customer   ${PUSERNAME30}


      ${resp}=  Encrypted Provider Login     ${PUSERNAME30}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID30}=  get_acc_id    ${PUSERNAME30}
      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id}   ${resp}
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Test Variable    ${CUR_DAY}

      ${Last_Day}=  db.add_timezone_date  ${tz}   3

      ${resp}=  AddCustomer  ${CUSERNAME11}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      # ${strt_time}=   db.get_time_by_timezone   ${tz}  
      ${strt_time}=   db.get_time_by_timezone  ${tz}   
      ${end_time}=    add_timezone_time  ${tz}  2  00   
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
      ${endday}=   db.add_timezone_date  ${tz}  15  
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}   ${resp.json()}
      
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
      
      # ${cur_time}=  db.get_time_by_timezone   ${tz}  
      ${cur_time}=  db.get_time_by_timezone  ${tz}    
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${holidayId1}    ${resp.json()['holidayId']}
      Should Be Equal As Strings   ${resp.json()['waitlistCount']}    2

      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

      ${resp}=  Get Waitlist By Id  ${wid2} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

      ${resp}=   Activate Holiday    ${boolean[1]}  ${holidayId1}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200 

      sleep   04s
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

      ${resp}=  Get Waitlist By Id  ${wid2} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

      ${resp}=   Get Holiday By Id   ${holidayId1}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200 
      Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
      Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  

JD-TC-CreateHoliday-UH1
     [Documentation]  Create an already existing holiday

     ${resp}=  Encrypted Provider Login   ${PUSERNAME25}   ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${holi_name}=    FakerLibrary.name
     Set Suite Variable      ${holi_name}
     ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${holi_time}  ${holi_name}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"

JD-TC-CreateHoliday-UH2
     [Documentation]  Create a holiday without login

     ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${holi_time}  ${holi_name}
     Log   ${resp.json()}
     Should Be Equal As Strings   ${resp.status_code}  419  
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-CreateHoliday-UH3
     [Documentation]  Create a holiday using consumer login

     ${resp}=  ConsumerLogin  ${CUSERNAME10}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${holi_time}  ${holi_name}
     Log   ${resp.json()}
     Should Be Equal As Strings   ${resp.status_code}  401 
     Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-CreateHoliday-UH6
      [Documentation]  create a past date  holiday for a valid provider

      ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${PAST_DAY}=  db.add_timezone_date  ${tz}  -1
      Set Suite Variable   ${PAST_DAY}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${PAST_DAY}  ${PAST_DAY}  ${EMPTY}  ${strt_time}  ${holi_time}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_START_DATE_INCORRECT}"

JD-TC-CreateHoliday-UH7
      [Documentation]  create  an overlapping end time for an existing holiday

      ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${holi_time}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"

JD-TC-CreateHoliday-UH8
      [Documentation]  create a holiday with already existing starttime and endtime less than existing one

      ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${strt_time}  ${end_time1}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"
      
JD-TC-CreateHoliday-UH9
      [Documentation]   create a  holiday for the 3 days and try to take checkin on holiday

      clear_service    ${PUSERNAME30}
      clear_location   ${PUSERNAME30}
      clear_queue      ${PUSERNAME30}
      clear_customer   ${PUSERNAME30}


      ${resp}=  Encrypted Provider Login     ${PUSERNAME30}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID30}=  get_acc_id    ${PUSERNAME30}
      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id}   ${resp}
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Test Variable    ${CUR_DAY}

      ${Last_Day}=  db.add_timezone_date  ${tz}   3

      ${resp}=  AddCustomer  ${CUSERNAME11}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
      ${end_time}=    add_timezone_time  ${tz}  4  00   
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      ${endday}=   db.add_timezone_date  ${tz}  15  
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}   ${resp.json()}
      # ${cur_time}=  db.get_time_by_timezone   ${tz}  
      ${cur_time}=  db.get_time_by_timezone  ${tz}     
      # ${hol_time}=    add_timezone_time  ${tz}  1  00   
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${holidayId1}    ${resp.json()['holidayId']}


      ${resp}=   Get Holiday By Id   ${holidayId1}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200 

      ${availableDate}=  db.add_timezone_date  ${tz}   4
      ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200     
      Should Be Equal As Strings   ${resp.json()['availableDate']}      ${availableDate}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${Last_Day}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"


JD-TC-CreateHoliday-UH10
      [Documentation]  create a past time  holiday for a valid provider

      clear_service    ${PUSERNAME30}
      clear_location   ${PUSERNAME30}
      clear_queue      ${PUSERNAME30}
      clear_customer   ${PUSERNAME30}


      ${resp}=  Encrypted Provider Login     ${PUSERNAME30}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID30}=  get_acc_id    ${PUSERNAME30}
      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id}   ${resp}
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Test Variable    ${CUR_DAY}

      ${Last_Day}=  db.add_timezone_date  ${tz}   3

      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      # ${strt_time}=   db.get_time_by_timezone   ${tz}  
      ${strt_time}=   db.get_time_by_timezone  ${tz}      
      ${end_time}=    add_timezone_time  ${tz}  6  00   
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      ${endday}=   db.add_timezone_date  ${tz}  15  
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}   ${resp.json()}

      ${ptime}=  subtract_timezone_time  ${tz}  0  1
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${ptime}  ${end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_START_TIME_INCORRECT}"

      # Should Be Equal As Strings  "${resp.json()}"  "${STARTCANTBEAPASTTIME}"
  
JD-TC-CreateHoliday-UH11
      [Documentation]   create  holiday and then creating another holiday between this day(start date is already a holiday )

      clear_service    ${PUSERNAME188}
      clear_location   ${PUSERNAME188}
      clear_queue      ${PUSERNAME188}
      ${resp}=  Encrypted Provider Login     ${PUSERNAME188}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID30}=  get_acc_id    ${PUSERNAME188} 
      ${resp}=  Create Sample Location
      Set Suite Variable    ${loc_id5}   ${resp}
      ${resp}=   Get Location ById  ${loc_id5}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name5}=    FakerLibrary.name
      Set Test Variable     ${ser_name5}
      ${resp}=  Create Sample Service   ${ser_name5}
      Set Suite Variable    ${ser_id5}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable    ${CUR_DAY}
      ${q_name5}=    FakerLibrary.name
      Set Suite Variable    ${q_name5}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      # ${sone}=   db.get_time_by_timezone   ${tz}
      ${sone}=   db.get_time_by_timezone  ${tz}
      ${eone}=   add_timezone_time  ${tz}  3  00  
    
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      ${resp}=  Create Queue    ${q_name5}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id5}  ${ser_id5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q_id5}   ${resp.json()}

      ${DAY}=  db.add_timezone_date  ${tz}  1  
      ${DAY2}=  db.add_timezone_date  ${tz}  3  

      ${holitm}=   add_timezone_time  ${tz}  1  00  
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
  
      ${resp}=  AddCustomer  ${CUSERNAME14}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id5}  ${q_id5}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
          
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}

      ${resp}=  Get Next Availability    ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${holitm}  ${eone}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      #create  another oveelapped one

      ${DAY3}=  db.add_timezone_date  ${tz}  2  
      ${DAY4}=  db.add_timezone_date  ${tz}  4  
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"
     
      ${resp}=   Delete Holiday  ${holidayId}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Get Holiday By Account
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Not Contain   ${resp.json()}  "id":"${holidayId}"

JD-TC-CreateHoliday-UH12
      [Documentation]   create 3  holiday and then creating another holiday between this day(end date is already a holiday)

      ${resp}=  Encrypted Provider Login     ${PUSERNAME188}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${DAY}=  db.add_timezone_date  ${tz}  3  
      ${DAY2}=  db.add_timezone_date  ${tz}  6  

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
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${DAY}  ${EMPTY}  ${holitm}  ${eone}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ENDDATE_OVERLAPPED}"
     
JD-TC-Verify CreateHoliday-1
      [Documentation]   Verify create a  holiday for the current day

      ${resp}=  Encrypted Provider Login     ${PUSERNAME25}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue By Location and service By Date  ${loc_id}  ${ser_id}  ${CUR_DAY}  ${ACC_ID25}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}   1
      Verify Response List         ${resp}  0  id=${q_id}  name=${q_name}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${strt_time}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${cur_time}
   
      ${resp}=  Get Queue By Location and service By Date  ${loc_id}  ${ser_id}  ${FUTRE_DAY}  ${ACC_ID25}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1 
      Verify Response List         ${resp}  0  id=${q_id}  name=${q_name}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${strt_time}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${cur_time}
      Should Be Equal As Strings   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${strt_time}
      Should Be Equal As Strings   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${end_time}
      
JD-TC-Verify CreateHoliday-4
      [Documentation]  verify Create a holiday and update schedule

      ${resp}=  Encrypted Provider Login     ${PUSERNAME27}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue By Location and service By Date  ${loc_id2}  ${ser_id2}  ${DAY_ONE}  ${ACC_ID27}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List         ${resp}  0  id=${que_id2}  name=${q_name2}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${start_time2}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${h_start_time1}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][1]['sTime']}  ${h_end_time1}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][1]['eTime']}  ${end_time2}

      ${resp}=  Get Queue By Location and service By Date  ${loc_id4}  ${ser_id4}  ${DAY_TWO}  ${ACC_ID27}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List         ${resp}  0  id=${que_id4}  name=${q_name3}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${new_strt_time}
      Should Be Equal As Strings   ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${cur_time1}


JD-TC-CreateHoliday-11
    [Documentation]    create an order By provider for home delivery and then creare a holiday
    
    clear_queue    ${PUSERNAME100}
    clear_service  ${PUSERNAME100}
    clear_customer   ${PUSERNAME100}
    clear_Item   ${PUSERNAME100}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
#     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${pid}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    ${accId}=  get_acc_id  ${PUSERNAME100}
    Set Suite Variable  ${accId} 

    clear_queue    ${PUSERNAME100}
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME100}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  30   
    Set Suite Variable    ${eTime2}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime3}=  add_timezone_time  ${tz}  2  40
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable  ${eTime3}  
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName1}=   FakerLibrary.first_name 
    Set Suite Variable  ${catalogName1} 

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}  ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email0}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME20}    ${email0}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.add_timezone_date  ${tz}  3    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${startDate}  ${DAY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${startDate}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime2}
  
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get Order By Id    ${accId}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

 

JD-TC-CreateHoliday-12
    [Documentation]    create an order By provider on holiday.
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${address}=  get_address
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.ynwtest@netvarth.com

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY}    ${CUSERPH}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

























***comment***

JD-TC-CreateHoliday-UH9
      [Documentation]  create a holiday on a non-working day

      clear_queue     ${PUSERNAME26}     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Sample Location
      Set Suite Variable    ${loc_id1}   ${resp}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${d}=  get_timezone_weekday  ${tz}
      ${d1}=  Evaluate  ${d}-2
      ${DAY2}=  db.add_timezone_date  ${tz}  ${d1}
      ${list1}=  Create List  ${d}
      Set Suite Variable  ${list1} 
     
      ${sat_time}=   add_timezone_time  ${tz}  0  50  
      Set Suite Variable  ${sat_time} 
      ${ed_time}=    add_timezone_time  ${tz}   3  25
      Set Suite Variable  ${ed_time} 
      ${q_name4}=    FakerLibrary.name
      Set Suite Variable      ${q_name4}
      # ${lll}=  Create List  1  2  3  4  5  
      ${resp}=  Create Queue    ${q_name4}  ${recurringtype[1]}  ${list1}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sat_time}  ${ed_time}  ${parallel}    ${capacity}     ${loc_id1}  ${ser_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queues
      Set Suite Variable   ${queue_id}    ${resp.json()[0]['id']}
      ${c_time}=  add_timezone_time  ${tz}  1  00  
      ${e_time}=  add_timezone_time  ${tz}  2  00  
      Set Test Variable    ${e_time}
      # ${resp}=  Create Holiday  ${DAY2}  ${holi_name}  ${c_time}  ${e_time}
      # ${DAY5}=  db.add_timezone_date  ${tz}  5  

      ${DATE}=  Convert Date   ${DAY2}  result_format=%d-%m-%Y
      ${DATE1}=  Convert Date  ${DAY2}  result_format=%a, %d %b %Y
      ${DATE_NOT_FOUND}=  Format String    ${HOLIDAY_SCHEDULE_DATE_NOT_FOUND}   ${DATE1}

      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list1}  ${DAY2}  ${DAY2}  ${EMPTY}  ${c_time}  ${e_time}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${DATE_NOT_FOUND}"
      # Should Be Equal As Strings  "${resp.json()}"  "${SHEDULE_NOT_FOUND}"


JD-TC-CreateHoliday-UH10  
      [Documentation]  create  a holiday on disabled queue

      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      ${len}=  Evaluate  ${len}-1
      Set Suite Variable  ${domain}  ${domresp.json()[${len}]['domain']}    
      Set Suite Variable  ${subdomain}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
      ${firstname}=  FakerLibrary.name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+8843     
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
      ${pkg_id}=   get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_Z}  0
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_Z}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200 

      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
      ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
      ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.ynwtest@netvarth.com
      ${views}=  Evaluate  random.choice($Views)  random
      ${name1}=  FakerLibrary.name
      ${name2}=  FakerLibrary.name
      ${name3}=  FakerLibrary.name
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
      ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
      ${bs}=  FakerLibrary.bs
      ${companySuffix}=  FakerLibrary.companySuffix
      # ${city}=   get_place
      # ${latti}=  get_latitude
      # ${longi}=  get_longitude
      # ${postcode}=  FakerLibrary.postcode
      # ${address}=  get_address
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable   ${DAY}
     
      # ${sTime}=  db.get_time_by_timezone   ${tz}
      ${sTime}=  db.get_time_by_timezone  ${tz}
      ${eTime}=  add_timezone_time  ${tz}  0  15  
      ${desc}=   FakerLibrary.sentence
      ${url}=   FakerLibrary.url
      ${parking}   Random Element   ${parkingType}
      ${24hours}    Random Element    ['True','False']
      ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200 

      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id}   ${resp}
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id}   ${resp} 

      ${d}=  get_timezone_weekday  ${tz}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      # ${d1}=  Evaluate  ${d}
      ${list1}=  Create List  ${d}
      Set Suite Variable  ${list1} 
      ${sat_time}=   add_timezone_time  ${tz}  4  00  
      Set Suite Variable  ${sat_time} 
      ${ed_time}=    add_timezone_time  ${tz}  4  30  
      Set Suite Variable  ${ed_time} 
      ${q_name4}=    FakerLibrary.name
      Set Suite Variable      ${q_name4}
      ${resp}=  Create Queue    ${q_name4}  ${recurringtype[1]}  ${list1}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sat_time}  ${ed_time}  ${parallel}    ${capacity}   ${loc_id}  ${ser_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${queue_id}  ${resp.json()}
      ${resp}=  Disable Queue  ${queue_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue ById  ${queue_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  queueState=DISABLED
      ${les_strt_time}=  add_timezone_time  ${tz}  4  05
      ${les_end_time}=  add_timezone_time  ${tz}  4  15  
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${les_strt_time}  ${les_end_time}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SHEDULE_NOT_FOUND}" 

JD-TC-CreateHoliday-UH11
      [Documentation]  create  a future date holiday on disabled queue

      clear_queue     ${PUSERNAME26}     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${d}=  get_timezone_weekday  ${tz}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${d1}=  Evaluate  ${d} + 1
      ${DAY2}=  db.add_timezone_date  ${tz}  ${d1}
      ${list1}=  Create List  ${d}
      ${sat_time}=   add_timezone_time  ${tz}  4  30  
      Set Suite Variable  ${sat_time} 
      ${ed_time}=    add_timezone_time  ${tz}  4  45  
      Set Suite Variable  ${ed_time} 
      ${q_name4}=    FakerLibrary.name
      Set Suite Variable      ${q_name4}
      ${resp}=  Create Queue    ${q_name4}  ${recurringtype[1]}  ${list1}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sat_time}  ${ed_time}  ${parallel}    ${capacity}   ${loc_id1}  ${ser_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${queue_id}  ${resp.json()}
      ${resp}=  Disable Queue  ${queue_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue ById  ${queue_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  queueState=DISABLED
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${sat_time}  ${ed_time}  ${holi_name}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_CREATE_TIME}"      
      Should Be Equal As Strings  "${resp.json()}"  "${SHEDULE_NOT_FOUND}"


JD-TC-CreateHoliday-UH15
      [Documentation]   create a  holiday for the current day without start date and end date

      clear_service    ${PUSERNAME20}
      clear_location   ${PUSERNAME20}
      clear_queue      ${PUSERNAME20}
      ${resp}=  Encrypted Provider Login     ${PUSERNAME20}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID20}=  get_acc_id    ${PUSERNAME20}
      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id7}   ${resp}
      ${resp}=   Get Location ById  ${loc_id7}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id7}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      ${end_time}=    add_timezone_time  ${tz}  6  00   
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id7}  ${ser_id7}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id7}   ${resp.json()}
      ${cur_time}=  add_timezone_time  ${tz}  1  30  
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"
     

JD-TC-CreateHoliday-UH16
      [Documentation]   create a  holiday for the current day with out time schedule(Null)

      clear_service    ${PUSERNAME20}
      clear_location   ${PUSERNAME20}
      clear_queue      ${PUSERNAME20}
      ${resp}=  Encrypted Provider Login     ${PUSERNAME20}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ACC_ID20}=  get_acc_id    ${PUSERNAME20}
      ${resp}=  Create Sample Location
      Set Test Variable    ${loc_id7}   ${resp}
      ${resp}=   Get Location ById  ${loc_id7}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name}=    FakerLibrary.name
      Set Test Variable     ${ser_name}
      ${resp}=  Create Sample Service   ${ser_name}
      Set Test Variable    ${ser_id7}   ${resp}   
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      ${end_time}=    add_timezone_time  ${tz}  6  00   
      ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
      ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id7}  ${ser_id7}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id7}   ${resp.json()}
      ${cur_time}=  add_timezone_time  ${tz}  1  30  
      ${desc}=    FakerLibrary.name
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${NULL}  ${NULL}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"

 


      
      
      
