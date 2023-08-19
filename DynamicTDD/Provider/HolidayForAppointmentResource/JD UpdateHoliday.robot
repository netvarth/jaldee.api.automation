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
    [Documentation]  Provider create appointment schedule and today appointment is enabled then create a holiday
    
    ${resp}=  Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

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
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    clear_appt_schedule   ${PUSERNAME179}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${eTime1}=  add_time   4  00
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
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

    ${DAY}=  add_date  3
    ${sTime1}=  db.get_time
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

    ${sTime2}=  add_time   2  00
    ${eTime2}=  add_time   4  00
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId}  ${desc2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime2}  ${eTime2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId}
    Verify Response    ${resp}  description=${desc2}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime2}
  

JD-TC-UpdateHoliday-2
    [Documentation]   create a holiday then takes appointment for a valid provider and update holiday endtime with schedule endtime then check appointment status(activate status is true)
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_appt_schedule   ${PUSERNAME179}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    clear_appt_schedule   ${PUSERNAME179}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime2}=  add_time   0  30
    Set Test Variable  ${sTime2}
    ${eTime2}=  add_time   3  00
    Set Test Variable  ${eTime2}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=6  max=6
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${end_time1}=    add_time  2  00 
    ${DAY}=  add_date  3
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime2}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}


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
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][17]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][18]['time']}


      ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
   
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${apptid1}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid1[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    
    # ${holidayId}  ${desc2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime2}  ${eTime2}  
    #Log   ${resp.json()}
     # ${desc4}=    FakerLibrary.name

      ${resp}=  Update Holiday   ${holidayId1}    ${desc}   ${recurringtype[1]}    ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime2}   ${eTime2}



   # ${cur_time}=  db.get_time  
    #${end_time1}=    add_time  2  00 
    #${DAY4}=  add_date  8
    #${DAY5}=  add_date   10
    #${desc}=    FakerLibrary.name
    #${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY5}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId1}    ${resp.json()['holidayId']}


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
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime2}   
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime2}
  
  #  ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
   # Log  ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
   # Set Test Variable   ${slot4}   ${resp.json()['availableSlots'][0]['time']}
   # Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    #${resp}=  Get Appointment Schedule ById  ${sch_id}
    #Log  ${resp.json()}
   
  #  ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
  #  Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Set Test Variable  ${cid}   ${resp.json()}
    
    #${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    #${apptfor}=   Create List  ${apptfor1}
    
   # ${cnote}=   FakerLibrary.word
    #${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    #Log  ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200       
    #${apptid1}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    #Set Test Variable  ${apptid1}  ${apptid1[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

   # ${resp}=  AddCustomer  ${CUSERNAME9}  
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${cid1}   ${resp.json()}
    
   # ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
   # ${apptfor}=   Create List  ${apptfor1}
    
  #  ${cnote}=   FakerLibrary.word
  #  ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
  #  Log  ${resp.json()}
  #  Should Be Equal As Strings  ${resp.status_code}  200   
  #  ${apptid2}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
  #  Set Test Variable  ${apptid2}  ${apptid2[0]}

   # ${resp}=  Get Appointment EncodedID   ${apptid2}
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # ${encId2}=  Set Variable   ${resp.json()}

    #${resp}=  Get Appointment By Id   ${apptid1}
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    #Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
    #Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

  #  ${resp}=  Get Appointment By Id   ${apptid2}
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
   # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
   # Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
   # ${cur_time}=  db.get_time  
   # ${end_time1}=  add_time  3  00 
    #${desc}=    FakerLibrary.name
    #${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${cur_time}  ${end_time1}  
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    #Should Be Equal As Strings   ${resp.json()['apptCount']}       2
    

    #${resp}=   Activate Holiday  ${boolean[0]}   ${holidayId}
    #${end_time1}=    add_time  2  30 
    #${desc2}=    FakerLibrary.name
    #${resp}=  Update Holiday   ${holidayId1}  ${desc2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime2}  ${end_time1}  
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    
  #  ${resp}=   Get Holiday By Id  ${holidayId1}
   # Verify Response    ${resp}  description=${desc2}  id=${holidayId1} 
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime2}  
    #Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}
    #${resp}=   Activate Holiday  ${boolean[1]}   ${holidayId}
    #${resp}=   Activate Holiday  ${boolean[1]}   ${holidayId1}
    #Log   ${resp.json()}
    #Should Be Equal As Strings   ${resp.status_code}  200 
   # sleep   04s

    #${resp}=  Get Appointments Today
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[2]}
     #Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[2]}


JD-TC-UpdateHoliday-3
    [Documentation]  Provider takes appointment for a valid provider then create a holiday then check appointment status
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME185}  ${PASSWORD}
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

    clear_service   ${PUSERNAME185}
    clear_location  ${PUSERNAME185}
    clear_customer   ${PUSERNAME185}
    clear_appt_schedule   ${PUSERNAME185}


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
    clear_appt_schedule   ${PUSERNAME185}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  db.get_time
    Set Test Variable  ${sTime2}
    ${eTime2}=  add_time   4  00
    Set Test Variable  ${eTime2}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
    
   # ${cur_time}=  db.get_time  
    #${end_time1}=    add_time  2  00 
    #${DAY}=  add_date  3
    #${desc}=    FakerLibrary.name
    #${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    #Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
   # ${resp}=   Get Holiday By Id   ${holidayId}
  #  Log   ${resp.json()}
   # Should Be Equal As Strings   ${resp.status_code}  200 
    

  #  ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
   # Log  ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
   # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
   # Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


   # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Set Test Variable  ${cid}   ${resp.json()}
    
  #  ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
   # ${apptfor}=   Create List  ${apptfor1}
    
   # ${cnote}=   FakerLibrary.word
    #${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    #Log  ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
          
   # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
   # Set Test Variable  ${apptid1}  ${apptid[0]}

   # ${resp}=  Get Appointment EncodedID   ${apptid1}
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # ${encId1}=  Set Variable   ${resp.json()}

  #  ${resp}=  Get Appointment By Id   ${apptid1}
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
   # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
   # Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
   # Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
   # Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
   
    
    ${resp}=  AddCustomer  ${CUSERNAME9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

   
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

      ${cur_time}=  db.get_time  
    ${end_time1}=    add_time  2  00 
    ${DAY}=  add_date  3
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}
  

   # ${cur_time}=  db.get_time  
   # ${end_time1}=  add_time  3  00 
    #${desc}=    FakerLibrary.name
    #${resp}=  Update Holiday   ${holidayId}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${cur_time}  ${end_time1}  
    #Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Activate Holiday  ${boolean[1]}   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s

    

JD-TC-UpdateHoliday-4
    [Documentation]  update a holiday with end time greater than scheduled end time

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    ${cur_time}=  db.get_time 
    ${end_time}=   add_time  4   00
    ${DAY2}=  add_date  3
    ${desc}=    FakerLibrary.word
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${cur_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId1}
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
  
JD-TC-UpdateHoliday-5
    [Documentation]  Update  a holiday with start time less than scheduled start time

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    ${strt_time}=    db.get_time 
    ${end_time}=   add_time  3   00 
    ${DAY2}=  add_date  3
    ${desc}=    FakerLibrary.word
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Id  ${holidayId1}
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${strt_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
