*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${self}     0
@{service_names}
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}

*** Test Cases ***

JD-TC-GetFutureAppointment-1

    [Documentation]  Get provider's future appointment list and their count.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
    clear_customer   ${PUSERNAME256}
    
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
    ${eTime1}=  add_timezone_time  ${tz}  3   30  
    Set Suite Variable   ${eTime1}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Suite Variable  ${s_id}

    ${SERVICE2}=  generate_service_name
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
        Set Suite Variable  ${sch_id1}  ${resp.json()}
    ELSE
        Set Suite Variable  ${sch_id1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Suite Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
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

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname1}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME33}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${fname2}=  generate_firstname
    ${lname2}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME34}   firstName=${fname2}   lastName=${lname2}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid1}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME34}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME34}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token} 
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id1}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}
    Set Suite Variable    ${apptid2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}          ${fname1}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}           ${lname1}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}          ${fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}           ${lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    END

JD-TC-GetFutureAppointment-2

    [Documentation]  Get provider's future appointment list and their count when appointment taken for 2 different schedules
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_location_n_service  ${PUSERNAME256}
       
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${lid}=  Create Sample Location
    #     ${resp}=   Get Location ById  ${lid}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # ELSE
    #     Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    #     Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    # END

    # ${s_id}=  Create Sample Service  ${SERVICE1}
  
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${DAY4}=  db.add_timezone_date  ${tz}  6  
    # ${DAY2}=  db.add_timezone_date  ${tz}  10      
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name1}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id1}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${sTime2}=  add_timezone_time  ${tz}  3  35  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   
    Set Test Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME33}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME33}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME33}    ${pid}  ${token} 
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id2}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid4}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  4

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}'     
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid4}'     
            CONTINUE
        END
    END

JD-TC-GetFutureAppointment-3

    [Documentation]  Get provider's future appointment list with prepayment and their count 
    
    # ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=20   max=30
    # Log   ${billable_providers}
    # Set Suite Variable   ${billable_providers}
    # Log   ${multilocPro}
    # Set Suite Variable   ${multilocPro}
    # ${pro_len}=  Get Length   ${billable_providers}
    # # clear_service   ${PUSERNAME257}
    # # clear_location  ${PUSERNAME257}
    ${pid}=  get_acc_id  ${PUSERNAME257}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
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

    # clear_appt_schedule   ${PUSERNAME257}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME34}  firstName=${fname}   lastName=${lname}     email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME34}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME34}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
 
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}    []
    ${len}=  Get Length  ${resp.json()}
    @{uid_list}=  Create List
    FOR    ${index}    IN RANGE    ${len}
        Append To List  ${uid_list}  ${resp.json()[${index}]['uid']}
    END
    Log  ${uid_list}
    List Should Contain Value   ${uid_list}   ${apptid1}  


    # ${resp}=  Get Future Appointments
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}   0

JD-TC-GetFutureAppointment-4

    [Documentation]  Get provider's future appointment list based on payment status
    
    # Log   ${billable_providers}
    # Set Suite Variable   ${billable_providers}
    # ${pro_len}=  Get Length   ${billable_providers}
    # clear_service   ${PUSERNAME257}
    # clear_location  ${PUSERNAME257}
    ${pid}=  get_acc_id  ${PUSERNAME257}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
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

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    Set Test Variable  ${accountId1}  ${resp.json()['accountId']}

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

    # clear_appt_schedule   ${PUSERNAME257}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}

    ${resp}=  Auto Invoice Generation For Service   ${s_id2}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp.content}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}                                                                                                            ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token1} 
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${merchantid}   ${resp.json()['merchantId']}
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME257}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment Details By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME33}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amount_payable} =  Evaluate  ${servicecharge} - ${min_pre}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${amount_payable}  ${purpose[1]}  ${apptid1}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment Details By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments   paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-5

    [Documentation]  Get provider's future appointment list with different appointment statuses
    
    # ${pid}=  get_acc_id  ${PUSERNAME256}
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Appointment Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['enableAppt']}==${bool[0]}   
    #     ${resp}=   Enable Disable Appointment   ${toggle[0]}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    # clear_location_n_service  ${PUSERNAME256}
        
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${lid}=  Create Sample Location
    #     ${resp}=   Get Location ById  ${lid}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # ELSE
    #     Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    #     Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    # END

    # ${s_id}=  Create Sample Service  ${SERVICE1}
   
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY3}=  db.add_timezone_date  ${tz}  3  
    # ${DAY4}=  db.add_timezone_date  ${tz}  6  
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

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id1}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Future Appointments   apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

JD-TC-GetFutureAppointment-6

    [Documentation]  Get provider's future appointment list with provider consumer id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
  
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    Comment   ${CUSERNAME34} has taken appointment for this provider from consumer side in the last 5 cases.

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   consumer-eq=${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-7

    [Documentation]  Get provider's future appointment list for specific service
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
 
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-8

    [Documentation]  Get provider's future appointment list for consumers with firstName
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME256}
    # clear_location  ${PUSERNAME256}
    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${fname1}   ${resp.json()[0]['firstName']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-9

    [Documentation]  Get provider's future appointment list for consumers with lastname
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${lname1}   ${resp.json()[0]['lastName']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-10

    [Documentation]  Get provider's future appointment list for consumers with appointmentEncId
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
   
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-11

    [Documentation]  Get provider's future appointment list for consumers in schedule
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY4}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   schedule-eq=${sch_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-12

    [Documentation]  Get provider's future appointment list for given date
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY4}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   date-eq=${DAY3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-13

    [Documentation]  Get provider's future appointment list based on appointment taken by info (apptBy)
    
    ${pid}=  get_acc_id  ${PUSERNAME256}
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id}=  Create Sample Service  ${SERVICE1}
    # # clear_appt_schedule   ${PUSERNAME256}


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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments  apptBy-eq=PROVIDER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

JD-TC-GetFutureAppointment-14

    [Documentation]  Get provider's future appointment list based on appointment time slot info (apptTime)
     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-15

    [Documentation]  Get provider's future appointment list based on location
    
    # ${multilocPro}=  MultiLocation
    Log  ${multilocPro}
    ${len}=  Get Length  ${multilocPro}

    ${resp}=  Encrypted Provider Login  ${multilocPro[6]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${multilocPro[6]}
    clear_customer   ${multilocPro[6]}
    
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${lid2}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    # # clear_appt_schedule   ${multilocPro[6]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    # ${DAY4}=  db.add_timezone_date  ${tz}  6     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${DAY4}=  db.get_date_by_timezone  ${tz1}
    ${DAY5}=  db.add_timezone_date  ${tz1}  10     
    ${DAY6}=  db.add_timezone_date  ${tz1}  3  
    # ${DAY4}=  db.add_timezone_date  ${tz}  6 
    ${sTime2}=  add_timezone_time  ${tz1}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY5}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY6}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME33}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${fname2}=  generate_firstname
    ${lname2}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME34}  firstName=${fname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id1}  ${sch_id2}  ${DAY6}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   location-eq=${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-16

    [Documentation]  Get provider's future appointment list based on appointment start time
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME256}
    # clear_location  ${PUSERNAME256}
    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-17

    [Documentation]  Get provider's future appointment list based on jaldeeConsumer id
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME256}
    # clear_location  ${PUSERNAME256}
    # clear_location_n_service  ${PUSERNAME256}
   
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${jdconID1}   ${resp.json()[0]['jaldeeConsumer']}

    ${fname1}=  generate_firstname
    ${resp}=  Update Customer Details  ${cid1}  firstName=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}

    ${fname2}=  generate_firstname
    ${resp}=  Update Customer Details  ${cid2}  firstName=${fname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   jaldeeConsumer-eq=${jdconID1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-18

    [Documentation]  Get provider's future appointment list based on cancel reason
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME256}
    # clear_location  ${PUSERNAME256}
    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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

    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${num}=  Get Length  ${cancelReason}
    FOR   ${i}  IN RANGE   ${num}
        ${reason2}=  Random Element  ${cancelReason}
        Exit For Loop If  "${reason2}" != "${reason1}"
    END  
    
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid2}    cancelReason=${reason2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-19

    [Documentation]  Get provider's future appointment list based on appointmentMode
    
    ${pid}=  get_acc_id  ${PUSERNAME256}
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME256}
    # clear_location  ${PUSERNAME256}
    # clear_location_n_service  ${PUSERNAME256}
        
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

    ${s_id}=  Create Sample Service  ${SERVICE1}
    # # clear_appt_schedule   ${PUSERNAME256}


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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME34}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments  appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

JD-TC-GetFutureAppointment-20

    [Documentation]  Get provider's future appointment list based on label
    
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    clear_Label  ${PUSERNAME256}
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

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    FOR   ${i}  IN RANGE   ${len-1}
        ${label_value2}=   Set Variable   ${ValueSet[${i}]['value']}
        Exit For Loop If  "${label_value2}" != "${label_value1}"
    END 
    
    ${resp}=  Add Label for Appointment   ${apptid2}  ${labelname[0]}  ${label_value2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label2}=    Create Dictionary  ${labelname[0]}=${label_value2}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${labelinput}=  Set Variable  ${labelname[0]}::${label_value1}

    ${resp}=  Get Future Appointments   label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        END
    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-UH1

    [Documentation]  Get provider's future appointment list for a date after schedule
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME256}
    
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

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    # # clear_appt_schedule   ${PUSERNAME256}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
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
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            CONTINUE
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            CONTINUE
        END
    END

    ${resp}=  Get Future Appointments   date-eq=${DAY5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetFutureAppointment-UH2

    [Documentation]  Get provider's future appointment list filtered by account id of another provider
    
    ${pid}=  get_acc_id  ${PUSERNAME177}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Future Appointments   account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetFutureAppointment-UH3

    [Documentation]  Get provider's future appointment list without provider login

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"      
