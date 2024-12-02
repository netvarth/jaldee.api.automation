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

*** Test Cases ***

JD-TC-GetAppointmentTodayCount-1

    [Documentation]  takes two walkin appointment for today and verify today appointment details count.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME105}
    clear_customer   ${PUSERNAME105}

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

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
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
    IF  ${resp.json()['availableSlots'][${j1}]['noOfAvailbleSlots']} == 0   
        Remove From List    ${slots}    ${slot1}
    END
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j1}]}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME18}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME19}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid1}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetAppointmentTodayCount-2

    [Documentation]  takes two online appointment for today and verify today appointment details.
    
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid3}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname1}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid4}=  Get From Dictionary  ${resp.json()}  ${fname1}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetAppointmentTodayCount-3

    [Documentation]  takes a walkin appointment for today for a service with prepayment , and it should show in today appointment with status as confirmed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${prepay_amt}=   Random Int   min=50   max=100
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-4

    [Documentation]  takes an online appointment for today for a service with prepayment , and it should not show in today appointment with status as confirmed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${prepay_amt}=   Random Int   min=50   max=100
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  uid=
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid3}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-5

    [Documentation]  takes an online appointment for today for a service with prepayment then do the pre payment , and it should in today appointment with status as confirmed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${prepay_amt}=   Random Int   min=50   max=100
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${prepay_amt}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-6

    [Documentation]  takes an online and a walkin appointment for today, then verify the get appointment today with filter apptStatus as confirmed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

    ${resp}=  Get Appointments Today  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-7

    [Documentation]  takes two walkin appointment for today, change first appointemtn to started, then verify the get appointment today with filter apptStatus as started.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-8

    [Documentation]  takes two walkin appointment for today, change first appointemtn to completed, then verify the get appointment today with filter apptStatus as completed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
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

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1

JD-TC-GetAppointmentTodayCount-9

    [Documentation]  takes two walkin appointment for today, change first appointment to cancelled, then verify the get appointment today with filter apptStatus as cancelled.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action    ${apptStatus[4]}   ${apptid1}   cancelReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-10

    [Documentation]  takes two walkin appointment for today, change first appointment to rejected, then verify the get appointment today with filter as rejected.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action   ${apptStatus[5]}   ${apptid1}  rejectReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-11

    [Documentation]  takes two walkin appointment for today for two different services,then verify the get appointment today with filter as service.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${SERVICE2}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE2}
    # ${s_id1}=  Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${parallel}=  FakerLibrary.Random Int  min=20  max=25
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id}  ${s_id1}  ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-12

    [Documentation]  takes two walkin appointment for today for two different provider consumers, then verify the get appointment today with filter as firstName.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}    ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-13

    [Documentation]  takes two walkin appointment for today for two different provider consumers, then verify the get appointment today with filter as lastName.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    Set Test Variable  ${lname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  lastName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  lastName-eq=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-14

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as encoded id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Today Appointment Count  appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-15

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as schedule id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${parallel}=  FakerLibrary.Random Int  min=10  max=20
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}    ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  schedule-eq=${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-16

    [Documentation]  takes an online and a walkin appointment for today, then verify the get appointment today with filter as appointment by.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']} 

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today  apptBy-eq=${apptBy[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  apptBy-eq=${apptBy[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

    ${resp}=  Get Appointments Today  apptBy-eq=${apptBy[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  apptBy-eq=${apptBy[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-17

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as appt time.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-18

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as paymentStatus NotPaid.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-19

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as paymentStatus PartiallyPaid.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${description}=  FakerLibrary.sentence
    # ${ser_durtn}=   Random Int   min=2   max=10
    # ${prepay_amt}=   Random Int   min=50   max=100
    # ${ser_amount}=   Random Int   min=100   max=1000
    # ${ser_amount1}=   Convert To Number   ${ser_amount}
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Test Variable  ${s_id}  ${resp.json()}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash   ${apptid1}  ${payment_modes[0]}  ${min_pre}   ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-20

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as paymentStatus FullyPaid.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${description}=  FakerLibrary.sentence
    # ${ser_durtn}=   Random Int   min=2   max=10
    # ${prepay_amt}=   Random Int   min=50   max=100
    # ${ser_amount}=   Random Int   min=100   max=1000
    # ${ser_amount1}=   Convert To Number   ${ser_amount}
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Test Variable  ${s_id}  ${resp.json()}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_amount1}  ${resp.json()['totalAmount']} 

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash   ${apptid1}  ${payment_modes[0]}  ${ser_amount1}   ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-21

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as location.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${description}=  FakerLibrary.sentence
    # ${ser_durtn}=   Random Int   min=2   max=10
    # ${prepay_amt}=   Random Int   min=50   max=100
    # ${ser_amount}=   Random Int   min=100   max=1000
    # ${ser_amount1}=   Convert To Number   ${ser_amount}
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Test Variable  ${s_id}  ${resp.json()}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   location-eq=${lid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  location-eq=${lid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-23

    [Documentation]  takes two walkin appointment for today, then verify the get appointment today with filter as appt start time.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${slot1_time}=  Get Substring   ${slot1}  0  5

    ${resp}=  Get Appointments Today   apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-24

    [Documentation]  takes two walkin appointment for today, change first appointment to cancelled, then verify the get appointment today with filter cancel reason.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason1}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action    ${apptStatus[4]}   ${apptid1}   cancelReason=${reason1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason2}=  Random Element  ${cancelReason}
    ${num}=  Get Length  ${cancelReason}
    FOR   ${i}  IN RANGE   ${num}
        ${reason2}=  Random Element  ${cancelReason}
        Exit For Loop If  "${reason2}" != "${reason1}"
    END  
    ${msg}=   FakerLibrary.word
    ${resp}=     Appointment Action    ${apptStatus[4]}   ${apptid2}   cancelReason=${reason2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-25

    [Documentation]  takes an online and a walkin appointment for today, then verify the get appointment today with filter apptmode.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']} 

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today   appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

    ${resp}=  Get Appointments Today   appointmentMode-eq=${appointmentMode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  appointmentMode-eq=${appointmentMode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-26

    [Documentation]  takes two walkin appointment for today for two different provider consumers, then verify the get appointment today with filter as dob.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}
    clear_customer   ${PUSERNAME105}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}    ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${dob1}=    FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
   
    ${resp}=  AddCustomer  ${CUSERNAME16}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   gender=${gender}  dob=${dob1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}
    
    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${dob2}=    FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
   
    ${resp}=  AddCustomer  ${CUSERNAME17}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}   gender=${gender1}  dob=${dob2} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid1}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Today Appointment Count  dob-eq=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1

    ${resp}=  Get Today Appointment Count  dob-eq=${dob2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1

JD-TC-GetAppointmentTodayCount-27

    [Documentation]  takes two walkin appointment for today for two different provider consumers, then verify the get appointment today with filter as dob.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    # clear_service   ${PUSERNAME105}
    # clear_appt_schedule   ${PUSERNAME105}
    clear_Label  ${PUSERNAME105}
  
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}    ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}  ${resp.json()[0]['firstName']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
  
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname1}
  
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
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
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value1}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Appointment   ${apptid1}  ${labelname[0]}  ${label_value1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname[0]}=${label_value1}

    FOR   ${i}  IN RANGE   ${len-1}
        ${label_value2}=   Set Variable   ${ValueSet[${i}]['value']}
        Exit For Loop If  "${label_value2}" != "${label_value1}"
    END
    ${resp}=  Add Label for Appointment   ${apptid2}  ${labelname[0]}  ${label_value2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label2}=    Create Dictionary  ${labelname[0]}=${label_value2}
   
    ${labelinput}=  Set Variable  ${labelname[0]}::${label_value1}

    ${resp}=  Get Appointments Today   label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count  label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${len}

JD-TC-GetAppointmentTodayCount-28

    [Documentation]  taking a appt for a provider who has a branch in US. base location is India.(online appt from India),
    ...   then verify get appt today details. 

    # clear_location_n_service  ${PUSERNAME230}
    # clear_queue     ${PUSERNAME230}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME230}
    
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=   Create Sample Service  ${SERVICE1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${loc_id1}=  Create Sample Location
        Set Suite Variable   ${loc_id1}
        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${loc_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${firstName}${C_Email}.${test_mail}
    ${resp}=    Send Otp For Login    ${CUSERNAME9}    ${pid}  alternateLoginId=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp} 

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME9}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${pc_emailid1}  ${CUSERNAME9}  ${pid}  countryCode=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Consumer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME9}  ${pid}  ${token}   countryCode=${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${s_id1}
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
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}  location=${{str('${loc_id1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${len}

JD-TC-GetAppointmentTodayCount-UH1

    [Documentation]  Get provider's appointments today without provider login
    
    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetAppointmentTodayCount-UH2

    [Documentation]  Get provider's appointments today with consumer login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME16}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetAppointmentTodayCount-UH3

    [Documentation]  Get provider's appointments today filtered by account id of another provider
    
    ${pid}=  get_acc_id  ${PUSERNAME208}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Today Appointment Count  account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
