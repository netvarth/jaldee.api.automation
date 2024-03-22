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
&{empty_dict}


*** Test Cases ***    
JD-TC-GetAppointmentSlotsByScheduleandDate-1

    [Documentation]  Get next available appointment slots for today

    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERNAME117}
    # Set Suite Variable  ${accId}
    clear_service   ${PUSERNAME117}
    clear_location  ${PUSERNAME117}
   
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    # Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    # Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}    ${DAY1}   ${accId}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
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
    # ${slots}=   Create List
      
    Set Suite Variable  ${slot2}  ${resp.json()['availableSlots'][0]['time']}
          
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    # ${cid}=  get_id  ${CUSERNAME11}   
    # Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}


JD-TC-GetAppointmentSlotsByScheduleandDate-2

    [Documentation]  Get next available appointment slots for future date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${accId}
    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}
   
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    # Set Suite Variable  ${s_id1}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    # Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    # Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=2  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY3}=  db.add_timezone_date  ${tz}  3  

    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}    ${DAY3}   ${accId}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
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
    # ${slots}=   Create List
   
    Set Suite Variable  ${slot2}  ${resp.json()['availableSlots'][0]['time']}
          
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    # ${cid}=  get_id  ${CUSERNAME11}   
    # Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}


JD-TC-GetAppointmentSlotsByScheduleandDate-UH1

    [Documentation]   Provider try to Get Appointment Slots By Schedule and Date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME138}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERNAME138}
    # Set Test Variable   ${accId}  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}  ${DAY1}   ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-GetAppointmentSlotsByScheduleandDate-UH2

    [Documentation]  Get Appointment Slots By Schedule and Date without login
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}    ${DAY1}   ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetAppointmentSlotsByScheduleandDate-UH3

    [Documentation]  Get Appointment Slots By Schedule and Date with invalid schedule id
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Appointment Slots By Schedule and Date    0000   ${DAY1}   ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${APPT_SCHEDULE_NOT_FOUND}


JD-TC-GetAppointmentSlotsByScheduleandDate-UH4

    [Documentation]  Get Appointment Slots By Schedule and Date with date after schedule end date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERNAME120}

    ${DAY3}=  db.add_timezone_date  ${tz}  13
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}   ${DAY3}   ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${empty_dict}


JD-TC-GetAppointmentSlotsByScheduleandDate-3
    [Documentation]  Get next available appointment slots for today with consumerParallelServing

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accId}  ${resp.json()['id']}

   
    # ${leadTime}=   Random Int   min=1   max=5
    ${s_id1}=  Create Sample Service  ${SERVICE1}  #leadTime=${leadTime}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumerparallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}  ${DAY1}  ${accId}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
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
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['capacity']}   ${consumerparallel}
        Set Test Variable  ${st}  ${et}
    END



JD-TC-GetAppointmentSlotsByScheduleandDate-4
    [Documentation]  Get next available appointment slots for today with lead time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accId}  ${resp.json()['id']}

   
    ${leadTime}=   Random Int   min=25   max=30
    ${s_id1}=  Create Sample Service  ${SERVICE1}  leadTime=${leadTime}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${delta}=  FakerLibrary.Random Int  min=30  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=2  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id}  ${DAY1}  ${accId}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
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
