*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}         0
${digits}       0123456789

*** Test Cases ***

JD-TC-AppointmentCancelByConsumer-1

    [Documentation]  Consumer Cancel an appointment for a valid Provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME131}
    clear_location  ${PUSERNAME131}    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${pid}=  get_acc_id  ${PUSERNAME131}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    clear_appt_schedule   ${PUSERNAME131}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME19}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME19}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    
    ${cid}=  get_id  ${CUSERNAME19}   
    Set Suite Variable   ${cid}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}


    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${appt_status[4]}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}


    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}
  
    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AppointmentCancelByConsumer-2

    [Documentation]  Consumer Cancel an appointment for a valid another Provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME132}
    clear_location  ${PUSERNAME132} 

    ${pid01}=  get_acc_id  ${PUSERNAME132}
    Set Suite Variable   ${pid01}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    clear_appt_schedule   ${PUSERNAME132}
    clear_appt_schedule   ${PUSERNAME132}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid01}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid01}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${f_Name1}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name1}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no1}  ${resp.json()['primaryPhoneNumber']}
    
    ${cid1}=  get_id  ${CUSERNAME20}   
    Set Suite Variable   ${cid1}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid01}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot3}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}



    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid01}   ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Appointment By Consumer  ${apptid3}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${appt_status[4]}



    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid01}   ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}
  
    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AppointmentCancelByConsumer-UH1

    [Documentation]  Consumer Cancel an already started appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid01}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${APPT_STATUS_NOT_CHANGEABLE}=   Format String  ${APPT_STATUS_NOT_CHANGEABLE}  ${appt_status[3]}   ${appt_status[4]}

    ${resp}=  Cancel Appointment By Consumer  ${apptid4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"      "${APPT_STATUS_NOT_CHANGEABLE}"

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[3]}

JD-TC-AppointmentCancelByConsumer-UH2

    [Documentation]  Consumer taken Appointment and Cancel with another Consumer

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Cancel Appointment By Consumer  ${apptid3}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-AppointmentCancelByConsumer-UH3

    [Documentation]  Consumer trying to Cancel Appointment with another ProviderId

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid01}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=       get_acc_id   ${PUSERNAME1}
    ${resp}=  Cancel Appointment By Consumer  ${apptid2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-AppointmentCancelByConsumer-UH4

    [Documentation]  Consumer trying to Cancel an already Cancelled Appointment.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${APPT_STATUS_NOT_CHANGEABLE}=   Replace String  ${APPT_STATUS_NOT_CHANGEABLE}  {}  ${appt_status[4]}  

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[4]}
    
    ${resp}=  Cancel Appointment By Consumer  ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"      "${APPT_STATUS_NOT_CHANGEABLE}"

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[4]}

JD-TC-AppointmentCancelByConsumer-UH5

    [Documentation]  Cancel an Appointment without consumer login

    ${resp}=  Cancel Appointment By Consumer  ${apptid3}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"