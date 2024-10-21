*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
@{service_names}

*** Test Cases ***

JD-TC-GetConsumerAppointmentById-1

    [Documentation]  Consumer get appointment ById for a valid Provider.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME47}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME47}
    # clear_location  ${HLPUSERNAME47}
    ${pid1}=  get_acc_id  ${HLPUSERNAME47}
    Set Suite Variable   ${pid1}
    

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}


    ${fname}=  generate_firstname
    Set Suite Variable   ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable   ${lname}
   
    ${resp}=  AddCustomer  ${CUSERNAME11}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME11}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cid}  ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid1}  ${DAY1}  ${lid}  ${s_id1}
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
    ${resp}=   Customer Take Appointment  ${pid1}   ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                         ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                          ${lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}             ${CUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['uid']}                                                   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                             ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                             ${slot1} 
    Should Be Equal As Strings  ${resp.json()['appointmentMode']}                                       ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()['account']}                                               ${pid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                         ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                            ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                              ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                               ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                               ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                        ${lid}

JD-TC-GetConsumerAppointmentById-2

    [Documentation]  Consumer get appointment ById, When Consumer Mode is ONLINE Appointment.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME46}
    # clear_location  ${HLPUSERNAME46}
    ${pid2}=  get_acc_id  ${HLPUSERNAME46}
    Set Suite Variable   ${pid2}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}



    ${f_Name1}=  generate_firstname
    Set Suite Variable   ${f_Name1}
    ${l_Name1}=  FakerLibrary.last_name
    Set Suite Variable   ${l_Name1}
   
    ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${f_Name1}   lastName=${l_Name1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME5}    ${pid2}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid2}  ${DAY1}  ${lid}  ${s_id2}
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
    ${resp}=    Take Appointment with ApptMode For Provider    ${appointmentMode[2]}   ${pid2}  ${s_id2}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid2}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}  appointmentMode=${appointmentMode[2]}    uid=${apptid2}  appmtDate=${DAY1}  appmtTime=${slot1}  
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                         ${f_Name1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                          ${l_Name1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                           ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['uid']}                                                   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                             ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                             ${slot1} 
    Should Be Equal As Strings  ${resp.json()['appointmentMode']}                                       ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${f_Name1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${l_Name1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-GetConsumerAppointmentById-UH1

	[Documentation]  Get Consumer Appointment By Id  another consumer using AppmtId.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME5}    ${pid2}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pidUH1}=  get_acc_id  ${PUSERNAME15}
    ${resp}=   Get consumer Appointment By Id   ${pidUH1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}" 

JD-TC-GetConsumerAppointmentById-UH2

	[Documentation]  Get Consumer Appointment ById without login. 

    ${pidUH2}=  get_acc_id  ${PUSERNAME}
    ${resp}=   Get consumer Appointment By Id   ${pidUH2}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"

JD-TC-GetConsumerAppointmentById-UH3

	[Documentation]  Get Consumer Appointment ById  using another provider.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pidUH3}=  get_acc_id  ${PUSERNAME46}
    ${resp}=   Get consumer Appointment By Id   ${pidUH3}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"



JD-TC-GetConsumerAppointmentById-UH4

	[Documentation]  Get Consumer Appointment ById using another ConsumerLogin with Different Provider ID.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME5}    ${pid2}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-GetConsumerAppointmentById-UH5

	[Documentation]  Get Consumer Appointment By Id using another Consumer Login with Different Provider ID.
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get consumer Appointment By Id   ${pid2}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"