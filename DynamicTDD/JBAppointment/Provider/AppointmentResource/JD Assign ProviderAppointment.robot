*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Vacation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
@{service_names}

***Test Cases***

JD-TC-AssignproviderAppointment-1

    [Documentation]  Assingn appointment to user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
 
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite variable   ${NewCustomer}
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${u_id1} =  Create Sample User

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}    provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}   provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${u_id2} =  Create Sample User

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  1  00  
    ${user_id}=  Create Dictionary   id=${u_id2}
    ${s_id2}=  Create Sample Service  ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}   provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${u_id3} =  Create Sample User

    ${sTime2}=  add_timezone_time  ${tz}   1  20
    ${eTime2}=  add_timezone_time  ${tz}  2  00 
    ${user_id}=  Create Dictionary   id=${u_id3} 
    ${s_id3}=  Create Sample Service   ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}  provider=${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id3}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Un Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id1}

JD-TC-AssignproviderAppointment-2

    [Documentation]  Assign appointment to user and then it again assign to another user

    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${u_id1} =  Create Sample User

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1} 
    ${s_id1}=  Create Sample Service   ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}   provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${u_id2} =  Create Sample User

    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    ${user_id}=  Create Dictionary   id=${u_id2} 
    ${s_id2}=  Create Sample Service   ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-AssignproviderAppointment-3

    [Documentation]   Assingn appointment to user here user doesn't have any service and queue
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}  ${ser_duratn}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph1}  ${u_id1} =  Create and Configure Sample User

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-4

    [Documentation]  Assingn appointment to user and it reassingn to the same user 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}  ${ser_duratn}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph1}  ${u_id1} =  Create and Configure Sample User

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

   ${ph2}  ${u_id2} =  Create and Configure Sample User

    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    ${user_id}=  Create Dictionary   id=${u_id2} 
    ${s_id2}=  Create Sample Service   ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-5

    [Documentation]  Assingn appointment to user and user generate bill

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
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
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${u_id1} =  Create Sample User

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    FakerLibrary.name
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${u_id1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${u_id2} =  Create Sample User

    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id2}=  Create Sample Service   ${SERVICE1}    provider=${u_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}         ${apptid1}
  
JD-TC-AssignproviderAppointment-6

    [Documentation]   Assingn 3 appointment to the same user and get count

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id}=  Create Sample Service  ${SERVICE2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
    Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][2]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote1}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote2}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote2}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${apptid2}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid2[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  AddCustomer  ${CUSERNAME10}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid2}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote3}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote3}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid3}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid3}  ${apptid3[0]}

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${u_id1}=  Create Sample User 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Assign provider Appointment   ${apptid2}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Appointment   ${apptid3}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-AssignproviderAppointment-7

    [Documentation]  Assingn appointment to user here user contain user side appointment and assigned appointment 
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}

    # clear_service   ${HLPUSERNAME17}
    # clear_appt_schedule   ${HLPUSERNAME17}
    clear_customer   ${HLPUSERNAME17}
    reset_user_metric  ${pid1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${u_id1}=  Create Sample User 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    ${eTime3}=  add_timezone_time  ${tz}  1  00  
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service   ${SERVICE2}  provider=${u_id1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}  ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid3}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote2}=   FakerLibrary.word
    ${resp}=   Take Appointment For Consumer     ${cid3}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote2}  ${apptfor}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-8

    [Documentation]  Assingn appointment to assistant usertype

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME17}
    # clear_appt_schedule   ${HLPUSERNAME17}
    clear_customer   ${HLPUSERNAME17}
    reset_user_metric  ${pid1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0
    
    ${PUSERNAME_U1}  ${u_id1} =  Create and Configure Sample User  
    
    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-9

    [Documentation]  Try to assign a completed appointment to user 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME17}
    # clear_appt_schedule   ${HLPUSERNAME17}
    clear_customer   ${HLPUSERNAME17}
    reset_user_metric  ${pid1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME17}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1} =  Create Sample User  
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}  provider=${u_id1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-10

    [Documentation]  Assingn appointment to admin usertype

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME17}
    # clear_appt_schedule   ${HLPUSERNAME17}
    clear_customer   ${HLPUSERNAME17}
    reset_user_metric  ${pid1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${PUSERNAME_U1}  ${u_id1} =  Create and Configure Sample User  

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderAppointment-UH1

    [Documentation]  User take appointment and try to assign another user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME1}

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${u_id1} =  Create Sample User  

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME7}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME7}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME7}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${JC_id01}=  get_id  ${CUSERNAME7} 

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid1}  ${s_id1}
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
    ${p}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${p}]}

    ${pcid1}=  get_acc_id  ${CUSERNAME7}
    ${appt_for1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}  
    ${apptfor1}=   Create List  ${appt_for1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id1}   ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${u_id2} =  Create Sample User  

    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id2}=  Create Sample Service   ${SERVICE1}  provider=${u_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id2}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid2}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_PROVIDER}"

JD-TC-AssignproviderAppointment-UH2

    [Documentation]  Assingn appointment to a invalid user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${u_id1} =  Create Sample User  

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}  provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}   provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=   Assign provider Appointment   ${apptid1}   000
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${USER_NOT_FOUND}"

JD-TC-AssignproviderAppointment-UH3

    [Documentation]  Assingn appointment to user by using invalid appointment id
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
    reset_user_metric  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${u_id1} =  Create Sample User 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule    ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=   Assign provider Appointment   000   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${INVALID_APPOINTMENT_UID}"

JD-TC-AssignproviderAppointment-UH4

    [Documentation]  Assingn appointment to another account's user

    ${resp}=  Encrypted Provider Login  ${PUSERNAME328}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid2}  ${decrypted_data['id']}

    # clear_service   ${PUSERNAME328}
    # clear_appt_schedule   ${PUSERNAME328}
    clear_customer   ${PUSERNAME328}
    reset_user_metric  ${pid2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid2}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${u_id5} =  Create Sample User 

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}  provider=${u_id5}
    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
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
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${u_id1} =  Create Sample User 
   
    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${NO_PERMISSION}"

JD-TC-AssignproviderAppointment-UH5

    [Documentation]   Try to Assingn cancelled appointment 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1} =  Create Sample User 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=  Create Dictionary   id=${u_id1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}   provider=${user_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${CANNOT_ASSIGN_APMT}=   Replace String  ${CANNOT_ASSIGN_APMT}  {}  ${apptStatus[4]}

    ${resp}=   Assign provider Appointment   ${apptid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_APMT}"

JD-TC-AssignproviderAppointment-UH6

    [Documentation]   Try to Assign appointment  with consumer login
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME1}

    # clear_service   ${HLPUSERNAME1}
    # clear_appt_schedule   ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME10}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid6}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${u_id6} =  Create Sample User 
    Set Suite Variable  ${u_id6}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service   ${SERVICE1}  provider=${u_id6}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  provider=${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME10}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Assign provider Appointment   ${apptid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AssignproviderAppointment-UH7

    [Documentation]   Assingn appointment without login
    
    ${resp}=   Assign provider Appointment    ${apptid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"
