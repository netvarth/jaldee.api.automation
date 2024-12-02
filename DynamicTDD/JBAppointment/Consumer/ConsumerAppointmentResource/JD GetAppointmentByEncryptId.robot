*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment, EncryptId
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
@{service_names}
${apptStatus}   Confirmed                            

*** Test Cases ***    

JD-TC-GetApptByEncryptedIDconsumer-1

    [Documentation]   Get Appointment details By Encrypted ID.

    ${firstname}  ${lastname}  ${PUSERNAME_X}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_X}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}


    # clear_service   ${PUSERNAME_X}
    # clear_location  ${PUSERNAME_X}

    ${pid}=  get_acc_id  ${PUSERNAME_X}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_appt_schedule   ${PUSERNAME_X}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable   ${SERVICE1} 
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}



    #............provider consumer creation..........


    ${fname1}=  generate_firstname
    Set Suite Variable  ${fname1}
    ${lastname1}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${CUSERNAME10}    firstName=${fname1}   lastName=${lastname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME10}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
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
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid1}=  Set Variable   ${resp.json()}
    Set Suite Variable    ${A_uuid1}

    ${resp}=  Get consumer Appointment By Id  ${pid}  ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   appointmentEncId=${A_uuid1}

    ${resp}=  Get Appointment By EncodedId    ${A_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['uid']}                 ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                 ${apptStatus}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                         ${apptid1}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME10}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Consumer Appointment By EncodedId   ${A_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                 ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                 ${apptStatus}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                         ${apptid1}

JD-TC-GetApptByEncryptedIDconsumer-2

    [Documentation]   Consumer without login Get Appointment Encrypted ID.

    ${resp}=   Get Consumer Appointment By EncodedId   ${A_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                 ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                 ${apptStatus}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                         ${apptid1}

JD-TC-GetApptByEncryptedIDconsumer-UH1

    [Documentation]     Passing Consumer Appointment Encrypted ID is Zero.

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME10}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}  ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Consumer Appointment By EncodedId    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${APPOINTMENT_ID_NO_LONGER_ACTIVE}"

JD-TC-GetApptByEncryptedIDconsumer-UH2

    [Documentation]     Passing Consumer Appointment id as Encrypted ID  

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME10}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Consumer Appointment By EncodedId    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${APPOINTMENT_ID_NO_LONGER_ACTIVE}"

# *** Comments ***

JD-TC-GetApptByEncryptedIDconsumer-3

    [Documentation]    Get Consumer Appointment Encrypted ID of another consumer

    ${resp}=    Send Otp For Login    ${CUSERNAME3}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME3}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${EMPTY}  ${CUSERNAME3}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME3}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    
    ${resp}=  Get Consumer Appointment By EncodedId     ${A_uuid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    uid=${apptid1}   appmtDate=${DAY1}  apptStatus=${apptStatus} 
    Should Be Equal As Strings  ${resp.json()['service']['name']}              ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                          ${apptid1}