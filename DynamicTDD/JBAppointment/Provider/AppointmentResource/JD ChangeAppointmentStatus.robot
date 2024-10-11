*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${self}     0

*** Test Cases ***

JD-TC-ChangeAppointmentStatus-1

    [Documentation]  Verify the status as Confirmed from prepaymentpending after doing the payment for services with prepayment

    ${pid}=  get_acc_id  ${PUSERNAME377}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
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

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=    Get Service   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} == ${bool[0]}
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}   isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE
            Set Test Variable  ${min_pre}  ${resp.json()[0]['minPrePaymentAmount']}
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=5  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
  
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite variable   ${NewCustomer}
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
   
    ${apptTakenTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${apptTakenTime}
    ${nextMin}=  db.add_timezone_time   ${tz}    0    1
    ${apptTknTm}=    Create List   ${apptTakenTime}   ${nextMin}   
    Set Suite Variable   ${apptTknTm} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-2

    [Documentation]  change status to Started from confirmed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

JD-TC-ChangeAppointmentStatus-3

    [Documentation]  change status to Completed from Started

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}
   
JD-TC-ChangeAppointmentStatus-4

    [Documentation]  change status to Completed from Arrived

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  FakerLibrary.first_name
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
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

JD-TC-ChangeAppointmentStatus-5

    [Documentation]  change status to Completed from confirmed

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE 
        ${resp}=  Enable Disable Appointment Schedule   ${resp.json()[0]['id']}  ${Qstate[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

JD-TC-ChangeAppointmentStatus-UH1

    [Documentation]  change status to Started from confirmed

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

JD-TC-ChangeAppointmentStatus-6

    [Documentation]  change status to Cancelled from confirmed

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

JD-TC-ChangeAppointmentStatus-7

    [Documentation]  change status to Cancelled from Arrived
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

JD-TC-ChangeAppointmentStatus-UH2

    [Documentation]  change status to Cancelled from Started

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[3]}   ${apptStatus[4]}
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

JD-TC-ChangeAppointmentStatus-8

    [Documentation]  change status to Rejected from Arrived
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

JD-TC-ChangeAppointmentStatus-UH3

    [Documentation]  change status to Rejected from Started
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE 
        ${resp}=  Enable Disable Appointment Schedule   ${resp.json()[0]['id']}  ${Qstate[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    END

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
        ${fname}=  FakerLibrary.first_name
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
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}
    
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[3]}   ${apptStatus[5]}
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-UH4

    [Documentation]  change status to Rejected from Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
   
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}
    
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[4]}   ${apptStatus[5]}
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[3]['appointmentStatus']}   ${apptStatus[5]}

JD-TC-ChangeAppointmentStatus-UH5

    [Documentation]  change status to Arrived from Started
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
   
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[3]}   ${apptStatus[2]}
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[2]}

JD-TC-ChangeAppointmentStatus-10

    [Documentation]  change status to confirmed from Started when appointment taken by provider.
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
   
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-11

    [Documentation]  change status to confirmed from Started when appointment taken from consumer side

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    # ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[3]}   ${apptStatus[1]}
    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appointmentStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-UH6

    [Documentation]  change status to Started from Completed

    ${pid}=  get_acc_id  ${PUSERNAME377}
    ${cid}=  get_id  ${NewCustomer}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}   sort_keys=False 
    # Set Test Variable   ${slot1}   ${Keys[0]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appointmentStatus']}   ${apptStatus[6]}

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[6]}   ${apptStatus[3]}
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[3]}

JD-TC-ChangeAppointmentStatus-UH7

    [Documentation]  change status to Arrived from Completed
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE 
        ${resp}=    Get Appointment Schedules
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  '${resp.json()[1]['apptState']}' != '${Qstate[1]}'   
            ${resp}=  Enable Disable Appointment Schedule   ${resp.json()[1]['id']}  ${Qstate[1]}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${sTime1}=  add_timezone_time  ${tz}  4  00  
        ${eTime1}=  add_timezone_time  ${tz}  5  00  
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  02s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[6]}   ${apptStatus[2]}
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-UH8

    [Documentation]  change status to confirmed from Completed
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[1]['id']}
        Set Test Variable  ${lid}  ${resp.json()[1]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[1]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[6]}   ${apptStatus[1]}
    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-UH9

    [Documentation]  change status to Cancelled from Completed
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[1]['id']}
        Set Test Variable  ${lid}  ${resp.json()[1]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[1]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[6]}   ${apptStatus[4]}
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[6]}

JD-TC-ChangeAppointmentStatus-UH10

    [Documentation]  change status to Cancelled from Rejected
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep  02s
    
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[5]}   ${apptStatus[4]}
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

JD-TC-ChangeAppointmentStatus-UH11

    [Documentation]  Change status to prepaymentpending from confirmed.

    ${pid}=  get_acc_id  ${PUSERNAME376}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
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

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=    Get Service   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} == ${bool[0]}
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}   isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE
            Set Test Variable  ${min_pre}  ${resp.json()[0]['minPrePaymentAmount']}
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
  
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite variable   ${NewCustomer}
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
   
    ${apptTakenTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${apptTakenTime}
    ${nextMin}=  db.add_timezone_time   ${tz}    0    1
    ${apptTknTm}=    Create List   ${apptTakenTime}   ${nextMin}   
    Set Suite Variable   ${apptTknTm} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-UH12

    [Documentation]  Change status to prepaymentpending from Arrived.

    ${pid}=  get_acc_id  ${PUSERNAME376}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} != ${bool[0]}
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=10
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-UH13

    [Documentation]  Change status to prepaymentpending from Started.
   
    ${pid}=  get_acc_id  ${PUSERNAME376}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-UH14

    [Documentation]  Change status to prepaymentpending from confirmed.
   
    ${pid}=  get_acc_id  ${PUSERNAME376}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-UH15

    [Documentation]  Change status to prepaymentpending from Cancelled.

    ${pid}=  get_acc_id  ${PUSERNAME376}
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-UH16

    [Documentation]  Change status to prepaymentpending from Rejected.

    ${pid}=  get_acc_id  ${PUSERNAME376}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[0]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_ACTION}

JD-TC-ChangeAppointmentStatus-12

    [Documentation]  Change status to confirmed from Cancelled.

    ${pid}=  get_acc_id  ${PUSERNAME375}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
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

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=    Get Service   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE IF   ${resp.json()[0]['isPrePayment']} == ${bool[0]}
            ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
            ${SERVICE1}=    generate_service_name
            ${s_id}=  Create Sample Service  ${SERVICE1}   isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
            ${resp}=   Get Service By Id  ${s_id}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
        ELSE
            Set Test Variable  ${min_pre}  ${resp.json()[0]['minPrePaymentAmount']}
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END

        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
  
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite variable   ${NewCustomer}
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-UH17

    [Documentation]  Change status to Arrived from Cancelled.

    ${pid}=  get_acc_id  ${PUSERNAME375}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
   
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[4]}   ${apptStatus[2]}
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-UH18

    [Documentation]  Change status to Started from Cancelled.

    ${pid}=  get_acc_id  ${PUSERNAME375}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
  
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[4]}   ${apptStatus[3]}
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-13

    [Documentation]  Change status to confirmed from Rejected.

    ${pid}=  get_acc_id  ${PUSERNAME375}
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[1]}

JD-TC-ChangeAppointmentStatus-UH19

    [Documentation]  Change status to Arrived from Rejected.

    ${pid}=  get_acc_id  ${PUSERNAME375}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[5]}   ${apptStatus[2]}
    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-UH20

    [Documentation]  Change status to Started from Rejected.

    ${pid}=  get_acc_id  ${PUSERNAME375}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite Variable  ${NewCustomer}
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
  
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid1}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${APPT_STATUS_NOT_CHANGEABLE}=  Format String    ${APPT_STATUS_NOT_CHANGEABLE}    ${apptStatus[5]}   ${apptStatus[3]}
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_STATUS_NOT_CHANGEABLE}

JD-TC-ChangeAppointmentStatus-UH21

    [Documentation]  Change status to confirmed from Cancelled and take another appointment on same time slot for another consumer.
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME375}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
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

        ${resp}=    Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${SERVICE1}=    generate_service_name   
            ${s_id}=  Create Sample Service  ${SERVICE1}  
        ELSE
            Set Test Variable  ${s_id}   ${resp.json()[0]['id']}
        END
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=3  max=10
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

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
        ${fname}=  FakerLibrary.first_name
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
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor2}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptforlist}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptforlist}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  424
    Should Be Equal As Strings  ${resp.json()}      ${APPOINTMET_SLOT_NOT_AVAILABLE}
   
JD-TC-ChangeAppointmentStatus-UH22

    [Documentation]  Change appointment status of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-ChangeAppointmentStatus-UH23

    [Documentation]  Change appointment status without login

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-ChangeAppointmentStatus-UH24

    [Documentation]  Change appointment status of invalid appointment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[1]}   000000abcd
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_APPOINTMENT}"

JD-TC-ChangeAppointmentStatus-UH25

    [Documentation]  change appointment status from cancelled to confirmed after taking another appointment
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME377}
    # clear_location  ${PUSERNAME377}
    # clear_appt_schedule   ${PUSERNAME377}
    clear_location_n_service  ${PUSERNAME377}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep  01s

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[2]}

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    
    ${apptfor2}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptforlist}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptforlist}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPOINTMET_AlREADY_TAKEN}"

JD-TC-ChangeAppointmentStatus-UH26

    [Documentation]  change appointment status with details to cancel appointment
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME377}
    # clear_location  ${PUSERNAME377}
    # clear_appt_schedule   ${PUSERNAME377}
    clear_location_n_service  ${PUSERNAME377}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname}   ${resp.json()[0]['firstName']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    
JD-TC-ChangeAppointmentStatus-14

    [Documentation]  change appointment status to completed for an appointment taken by provider consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME377}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME377}
    # clear_location  ${PUSERNAME377}
    # clear_appt_schedule   ${PUSERNAME377}
    clear_location_n_service  ${PUSERNAME377}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${EMPTY}  ${NewCustomer}  ${pid}  countryCode=${countryCodes[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200    

    # ${resp}=  Consumer Logout   
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}  ${pid}  ${token}   countryCode=${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointments Today  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${apptid1}

    ${resp}=  Get Appointments Today  consumer-eq=${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${APPOINTMET_AlREADY_TAKEN}"

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

*** Comments ***

JD-TC-ChangeAppointmentStatus-15

    [Documentation]  Change status to Confirmed from prepaymentpending without payment for services with prepayment
    
    ${billable_providers}=    Billable Domain Providers   min=80   max=100
    Log   ${billable_providers}
    Set Suite Variable  ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    ${pid}=  get_acc_id  ${PUSERNAME377}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME377}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  FakerLibrary.first_name
    Set Suite Variable   ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable   ${lname}
   
    ${resp}=  AddCustomer  ${CUSERNAME23}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME23}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME23}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME23}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Test Variable   ${slot1}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}   sort_keys=False 
    # Set Test Variable   ${slot1}   ${Keys[0]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    # ${apptTime}=  db.get_tz_time_secs  ${tz} 
    # ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${apptTakenTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${apptTakenTime}
    ${nextMin}=  db.add_timezone_time   ${tz}    0    1
    ${apptTknTm}=    Create List   ${apptTakenTime}   ${nextMin}   
    Set Suite Variable   ${apptTknTm} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME377}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Status   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[0]} 

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}   ${apptTakenTime}  
    Should Be Equal As Strings  ${resp.json()[0]['date']}   ${DAY1}  
    List Should Contain Value  ${apptTknTm}  ${resp.json()[0]['time']}