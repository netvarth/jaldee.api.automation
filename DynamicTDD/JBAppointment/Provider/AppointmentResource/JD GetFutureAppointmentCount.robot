*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           FakerLibrary
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

${self}     0


*** Test Cases ***

JD-TC-GetFutureAppointmentCount-1

    [Documentation]  Get provider's future appointment list and their count.

    ${pid}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${pid}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname1}=  FakerLibrary.first_name
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME17}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${fname2}=  FakerLibrary.first_name
    ${lname2}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY4}  ${lid}  ${s_id}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
  
JD-TC-GetFutureAppointmentCount-2

    [Documentation]  Get provider's future appointment list and their count when appointment taken for 2 different schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME17}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME17}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME17}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname2}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY4}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[1]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[1]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[1]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id2}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
   
JD-TC-GetFutureAppointmentCount-3

    [Documentation]  Get provider's future appointment list with prepayment and their count 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    clear_appt_schedule   ${PUSERNAME179}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
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

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME17}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
 
    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY3}  ${lid}  ${s_id}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
 
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-GetFutureAppointmentCount-4

    [Documentation]  Get provider's future appointment list based on payment status

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}

    ${resp}=  Auto Invoice Generation For Service   ${s_id2}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${PUSERNAME179}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6       
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}                                                                                                            ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
 
    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY3}  ${lid}  ${s_id1}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME179}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${available_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${available_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   2

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointment Count   paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Future Appointment Count   paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${amount_payable} =  Evaluate  ${servicecharge} - ${min_pre}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${amount_payable}  ${purpose[1]}  ${apptid1}  ${s_id2}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointment Count   paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-5

    [Documentation]  Get provider's future appointment list with different appointment statuses
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname2}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY4}  ${lid}  ${s_id}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Appointment Count   apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetFutureAppointmentCount-6

    [Documentation]  Get provider's future appointment list with provider consumer id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
   
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    Comment   ${CUSERNAME18} has taken appointment for this provider from consumer side in the last 5 cases.

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  consumer-eq=${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-7

    [Documentation]  Get provider's future appointment list for specific service
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
  
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-8

    [Documentation]  Get provider's future appointment list for consumers with firstName
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${fname1}   ${resp.json()[0]['firstName']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-9

    [Documentation]  Get provider's future appointment list for consumers with lastname
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
   
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${lname1}   ${resp.json()[0]['lastName']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-10

    [Documentation]  Get provider's future appointment list for consumers with appointmentEncId
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY4}  ${cnote}  ${apptfor}
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

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-11

    [Documentation]  Get provider's future appointment list for consumers in schedule
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY4}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  schedule-eq=${sch_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-12

    [Documentation]  Get provider's future appointment list for given date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY4}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  date-eq=${DAY3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-13

    [Documentation]  Get provider's future appointment list based on appointment taken by info (apptBy)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname2}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY3}  ${lid}  ${s_id}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  apptBy-eq=PROVIDER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetFutureAppointmentCount-14

    [Documentation]  Get provider's future appointment list based on appointment time slot info (apptTime)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-15

    [Documentation]  Get provider's future appointment list based on location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME180}
    clear_location  ${PUSERNAME180}

    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}

    ${lid2}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}

    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME180}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${fname1}=  FakerLibrary.first_name
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME17}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${fname2}=  FakerLibrary.first_name
    ${lname2}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id1}  ${sch_id2}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  location-eq=${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-16

    [Documentation]  Get provider's future appointment list based on appointment start time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${slot1_time}=  Get Substring   ${slot1}  0  5
   
    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-17

    [Documentation]  Get provider's future appointment list based on cancel reason

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${reason1}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${num}=  Get Length  ${cancelReason}
    FOR   ${i}  IN RANGE   ${num}
        ${reason2}=  Random Element  ${cancelReason}
        Exit For Loop If  "${reason2}" != "${reason1}"
    END  
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid2}    cancelReason=${reason2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointment Count  cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-18

    [Documentation]  Get provider's future appointment list based on appointmentMode
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    
    ${lid}=  Create Sample Location
    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6       
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Appointment Slots By Schedule and Date  ${sch_id}  ${DAY3}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY3}   appmtTime=${slot2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY3}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointments  appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetFutureAppointmentCount-20
    [Documentation]  Get provider's future appointment list based on gender
    @{gens}=  Create List
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob1}   ${resp.json()['userProfile']['dob']}
    Set Test Variable  ${gender1}   ${resp.json()['userProfile']['gender']}
    Append To List   ${gens}   ${resp.json()['userProfile']['gender']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To List   ${gens}   ${resp.json()['userProfile']['gender']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  UpdateCustomer without email  ${cid1}   ${NULL}  ${NULL}  ${NULL}  ${gender1}  ${dob1}  ${NULL}  ${NULL}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY3}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY3}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    Log  ${gens}
    ${count_male}=  Get Match Count  ${gens}  ${Genderlist[1]}
    ${count_female}=  Get Match Count  ${gens}  ${Genderlist[0]}

    ${resp}=  Get Future Appointments   gender-eq=${Genderlist[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_male}
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  gender-eq=${Genderlist[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_male}

    ${resp}=  Get Future Appointments   gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_female}
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_female}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-21
    [Documentation]  Get provider's future appointment list based on dob
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob1}   ${resp.json()['userProfile']['dob']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob2}   ${resp.json()['userProfile']['dob']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY3}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY3}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointments   dob-eq=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  dob-eq=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-22
    [Documentation]  Get provider's future appointment list based on label
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY3}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    clear_Label  ${PUSERNAME179}
    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Values}=  FakerLibrary.Words  	nb=3
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  id=${label_id}  label=${labelname[0]}   displayName=${labelname[1]}  description=${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value1}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Appointment   ${apptid1}  ${labelname[0]}  ${label_value1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname[0]}=${label_value1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   uid=${apptid1}   appointmentEncId=${encId1}  label=${label1}

    
    FOR   ${i}  IN RANGE   ${len-1}
        ${label_value2}=   Set Variable   ${ValueSet[${i}]['value']}
        Exit For Loop If  "${label_value2}" != "${label_value1}"
    END 
    # ${i}=   Random Int   min=0   max=${len-1}
    # ${label_value2}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Appointment   ${apptid2}  ${labelname[0]}  ${label_value2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label2}=    Create Dictionary  ${labelname[0]}=${label_value2}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   uid=${apptid2}   appointmentEncId=${encId2}  label=${label2}

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY3}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${labelinput}=  Set Variable  ${labelname[0]}::${label_value1}

    ${resp}=  Get Future Appointments   label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-UH1
    [Documentation]  Get provider's future appointment list for a date after schedule
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME179}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${DAY5}=  db.add_timezone_date  ${tz}  15    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY3}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY3}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Future Appointments   date-eq=${DAY5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length   ${resp.json()}
    # Should Be Equal As Strings  ${len}  1
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY3}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Future Appointment Count  date-eq=${DAY5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointmentCount-UH2
    [Documentation]  Get provider's future appointment list filtered by account id of another provider
    ${pid}=  get_acc_id  ${PUSERNAME177}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments   account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Appointment Count  account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetFutureAppointmentCount-UH3
    [Documentation]  Get provider's future appointment list without provider login

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"      

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}    
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetFutureAppointmentCount-UH4
    [Documentation]  Get provider's future appointment list with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

    ${resp}=  Get Future Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"