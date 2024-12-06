*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${self}     0
@{service_names}
@{service_duration}  10  20  30   40   50

*** Test Cases ***

JD-TC-Block Appointment-1

    [Documentation]  Provider blocks appointment slot for a consumer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite Variable   ${DAY2}    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable   ${list}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable   ${delta}
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    Set Suite Variable   ${eTime1}
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Suite Variable  ${s_id}

    ${SERVICE2}=  generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    Set Suite Variable   ${min_pre}
    ${s_id1}=  Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre} 
    Set Suite Variable  ${s_id1}

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    ${s_id2}=  Create Sample Service  ${SERVICE3}   maxBookingsAllowed=10
    Set Suite Variable  ${s_id2}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        Set Suite Variable   ${parallel}
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}  ${s_id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Suite Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Suite Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-2

    [Documentation]  Provider blocks 2 appointment slots for consumers
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    # clear_appt_schedule   ${PUSERNAME370}
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j1}]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    # Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${items}     Get Dictionary Items   ${resp.json()}
    Set Test Variable   ${i}  0
    FOR  ${key}    ${value}    IN    @{items}
        ${i}=  Evaluate  ${i}+1
        Set Test Variable  ${encId${i}}   ${key}
        Set Test Variable  ${apptid${i}}   ${value}
    END
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId2}   uid=${apptid2}  appmtDate=${DAY1} 
    ...    appmtTime=${slot2}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-3

    [Documentation]  Provider blocks all appointment slots for consumers
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${slot_length}=  Get Length  ${resp.json()['availableSlots']}
    FOR  ${i}  IN RANGE  ${slot_length}
        Set Test Variable  ${slot${i}}   ${resp.json()['availableSlots'][${i}]['time']}
    END
    
    ${apptfor}=  Create List
    FOR  ${i}  IN RANGE  ${slot_length}    
        ${apptfor1}=  Create Dictionary   apptTime=${slot${i}}
        Append To List   ${apptfor}  ${apptfor1}
    END           

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptids}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    ${items}     Get Dictionary Items   ${resp.json()}
    Set Test Variable   ${i}  0
    FOR  ${key}    ${value}    IN    @{items}
        ${i}=  Evaluate  ${i}+1
        Set Test Variable  ${encId${i}}   ${key}
        Set Test Variable  ${apptid${i}}   ${value}
    END

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Block Appointment-4

    [Documentation]  Provider blocks appointment slot for a virtual service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    # clear_appt_schedule   ${PUSERNAME370}

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERNAME370}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   countryCode=${countryCodes[0]}  value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes1}=  Create List  ${VScallingMode1}
    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total1}  ${bool[0]}   serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${vs_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${parallel}=  FakerLibrary.Random Int  min=20  max=25
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id}  ${Vs_id1} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${vs_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${vs_id1}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${vs_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${vs_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-5

    [Documentation]  Provider blocks appointment slot for a consumer, unblocks it and blocks the same slot again
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # 
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Unblock Appointment Slot   ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[7]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-6

    [Documentation]  Provider blocks appointment slot for a consumer, unblocks it and blocks the same slot again for a different service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    reset_queue_metric  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Unblock Appointment Slot   ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[7]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id1}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-7

    [Documentation]  Provider blocks appointment slot for a consumer, unblocks it and blocks the same slot again for a different schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${lid1}=  Create Sample Location 
    
    # clear_appt_schedule   ${PUSERNAME370}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    reset_queue_metric  ${pid}

    ${resp}=  Create Sample Schedule  ${lid1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${parallel}   ${resp.json()['parallelServing']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${parallel1}   ${resp.json()['parallelServing']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Unblock Appointment Slot   ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[7]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id1}  ${DAY1}  ${apptfor} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId2}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot2}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel1-1}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId2}   uid=${apptid2}  appmtDate=${DAY1} 
    ...    appmtTime=${slot2}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

JD-TC-Block Appointment-8

    [Documentation]  Provider blocks appointment slot for a consumer, unblocks it and blocks the same slot again for a different day

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  4  

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${parallel}   ${resp.json()['parallelServing']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Unblock Appointment Slot   ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[7]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY3}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId2}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId2}   uid=${apptid2}  appmtDate=${DAY3} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-9

    [Documentation]  Provider blocks appointment slot for a consumer, with consumer details and confirms it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME37}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary   id=${cid}   apptTime=${slot1}  firstName=${fname}   lastName=${lname}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()}
    # Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Blocked Appointment   ${cid}   ${apptid1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}   
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[2]}   appmtDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-Block Appointment-10

    [Documentation]  Provider takes appointment for another consumer in a blocked slot

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${NewCustomer}    Generate random string    10    123456789
        ${NewCustomer}    Convert To Integer  ${NewCustomer}
        Set Suite variable   ${NewCustomer}
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${lname}  ${resp.json()[0]['lastName']}
    END
    
    ${apptfor1}=  Create Dictionary   id=${cid}   apptTime=${slot1}  firstName=${fname}   lastName=${lname}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()}
    # Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME39}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Blocked Appointment   ${cid1}   ${apptid1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Block Appointment-UH1

    [Documentation]  Provider blocks already taken appointment slot for a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${NewCustomer}    Generate random string    10    123456789
        ${NewCustomer}    Convert To Integer  ${NewCustomer}
        Set Suite variable   ${NewCustomer}
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    END

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[1]} 
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH2

    [Documentation]  Provider blocks already blocked appointment slot for a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH3

    [Documentation]  Provider blocks already blocked and confirmed appointment slot for a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${value[0]}
    ${Keys}=  Get Dictionary Keys  ${resp.json()}
    Set Test Variable  ${encId1}  ${Keys[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel-1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  appointmentEncId=${encId1}   uid=${apptid1}  appmtDate=${DAY1} 
    ...    appmtTime=${slot1}  apptStatus=${apptStatus[9]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${NewCustomer}    Generate random string    10    123456789
        ${NewCustomer}    Convert To Integer  ${NewCustomer}
        Set Suite variable   ${NewCustomer}
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    END

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Blocked Appointment   ${cid}   ${apptid1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH4

    [Documentation]  Provider blocks appointment for a servie not available in the schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    reset_queue_metric  ${pid}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id1}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${SERVICE_NOT_AVAILABLE_IN_SCHEDULE}

JD-TC-Block Appointment-UH5

    [Documentation]  Provider blocks slot of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid1}=  Create Sample Location  
    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=20
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME351}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta}=  FakerLibrary.Random Int  min=20  max=40        
    ${sTime1}=  add_timezone_time  ${tz}  0  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH6

    [Documentation]  Provider blocks slot for schedule of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=   Get Appointment Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['enableAppt']}==${bool[0]}   
    #     ${resp}=   Enable Disable Appointment   ${toggle[0]}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    # ${lid1}=  Create Sample Location  
    # clear_appt_schedule   ${PUSERNAME370}
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${sTime1}=  db.get_time_by_timezone  ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=10  max=20
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}  
    # ${s_id1}=  Create Sample Service  ${SERVICE1}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME351}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME351}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=20  max=40
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

JD-TC-Block Appointment-UH7

    [Documentation]  Provider blocks slot for service of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME351}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_location_n_service  ${PUSERNAME351}
    clear_customer   ${PUSERNAME351}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME351}
    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}    
        ${s_id}=  Create Sample Service  ${SERVICE1}  
    ELSE
        Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=20  max=40
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

JD-TC-Block Appointment-UH8

    [Documentation]  Provider blocks slot for non existant service 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    # clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${s_id1}=  FakerLibrary.Numerify  %%%%
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id1}  ${sch_id}  ${DAY1}  ${apptfor} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${SERVICE_NOT_AVAILABLE_IN_SCHEDULE}

JD-TC-Block Appointment-UH9

    [Documentation]  Provider blocks slot for non existant schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${sch_id1}=  FakerLibrary.Numerify  %%%%
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id1}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${SCHEDULE_NOT_AVAILABLE}

JD-TC-Block Appointment-UH10

    [Documentation]  Provider blocks slot for non existant slot

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${a}=  Fetch From Left  ${slot1}   -
    ${b}=  Fetch From Right  ${slot2}   -
    ${slot} =   Catenate    SEPARATOR=-   ${a}   ${b}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH11

    [Documentation]  Provider blocks slot for invalid slot

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${sTime2}=  add_two   ${eTime1}  ${duration}
    ${eTime2}=  add_two   ${sTime2}  ${duration}
    ${slot} =   Catenate    SEPARATOR=-   ${sTime2}   ${eTime2}

    ${INVALID_TIMESLOT}=  Format String    ${INVALID_TIMESLOT}    ${slot}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_TIMESLOT}

JD-TC-Block Appointment-UH12

    [Documentation]  Provider blocks slot for a holiday

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    ${holidayname}=   FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${desc}=    FakerLibrary.name
    # ${resp}=  Create Holiday  ${DAY3}  ${holidayname}  ${sTime1}  ${eTime1}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}
   
    ${resp}=   Get Holiday By Id  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200
    

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY3}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH13

    [Documentation]  Provider blocks slot for a non working day

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    ${weekday}=   get_weekday_by_date  ${DAY3}
    ${weekday}=   Convert To String  ${weekday}
    ${list}=  Create List  1  2  3  4  5  6  7
    Remove Values From List  ${list}  ${weekday}
    Log  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY3}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}

JD-TC-Block Appointment-UH14

    [Documentation]  Provider blocks slot without date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    ${weekday}=   get_weekday_by_date  ${DAY3}
    ${weekday}=   Convert To String  ${weekday}
    ${list}=  Create List  1  2  3  4  5  6  7
    Remove Values From List  ${list}  ${weekday}
    Log  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${EMPTY}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${NECESSARY_FIELD_MISSING}

JD-TC-Block Appointment-UH15

    [Documentation]  Provider blocks slot without slot

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    # clear_customer   ${PUSERNAME270}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # clear_appt_schedule   ${PUSERNAME370}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    ${weekday}=   get_weekday_by_date  ${DAY3}
    ${weekday}=   Convert To String  ${weekday}
    ${list}=  Create List  1  2  3  4  5  6  7
    Remove Values From List  ${list}  ${weekday}
    Log  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}    
        ${s_id}=  Create Sample Service  ${SERVICE1}  
    ELSE
        Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
    END

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${INVALID_TIMESLOT}=  Format String    ${INVALID_TIMESLOT}    ${EMPTY}
    
    ${apptfor1}=  Create Dictionary   apptTime=${EMPTY}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_TIMESLOT}

JD-TC-Block Appointment-UH16

    [Documentation]  Provider blocks slot without schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=   Get Appointment Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['enableAppt']}==${bool[0]}   
    #     ${resp}=   Enable Disable Appointment   ${toggle[0]}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    # # clear_location_n_service  ${PUSERNAME370}
    # clear_customer   ${PUSERNAME370}

    # ${lid}=  Create Sample Location  
    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # # clear_appt_schedule   ${PUSERNAME370}
    
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${d}=  FakerLibrary.Random Int  min=1  max=6
    # ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    # ${weekday}=   get_weekday_by_date  ${DAY3}
    # ${weekday}=   Convert To String  ${weekday}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Remove Values From List  ${list}  ${weekday}
    # Log  ${list}
    # # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${sTime1}=  db.get_time_by_timezone  ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}  
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
    Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${EMPTY}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${NECESSARY_FIELD_MISSING}

JD-TC-Block Appointment-UH17

    [Documentation]  Provider blocks slot without service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME370}
    clear_customer   ${PUSERNAME370}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # ${lid}=  Create Sample Location  
    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME370}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}  
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}   
    ${weekday}=   get_weekday_by_date  ${DAY3}
    ${weekday}=   Convert To String  ${weekday}
    ${list}=  Create List  1  2  3  4  5  6  7
    Remove Values From List  ${list}  ${weekday}
    Log  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${EMPTY}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  500
    Should Be Equal As Strings   ${resp.json()}    ${JALDEE_OUT_OF_REACH_PROBLEM}

JD-TC-Block Appointment-UH18

    [Documentation]  Provider blocks slot without provider login

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-Block Appointment-UH19

    [Documentation]  Provider blocks slot with consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME370}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=  AddCustomer  ${CUSERNAME15}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
    
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}