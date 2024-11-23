*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appt request
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

@{emptylist}
${self}     0
@{service_names}

*** Test Cases ***

JD-TC-ConsumerCreateApptRequest-1

    [Documentation]   Consumer create an appt request.

    # clear_appt_schedule   ${HLPUSERNAME45}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id1}  ${decrypted_data['id']}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Suite Variable  ${lic_name}  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}


    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}



    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${sid1}=  Create Sample Service  ${SERVICE1}  date=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Set Suite Variable   ${sid1}

    ${resp}=   Get Service By Id  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${sid2}=  Create Sample Service  ${SERVICE2}  dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Set Suite Variable   ${sid2}

    ${resp}=   Get Service By Id  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${SERVICE3}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE3}
    # ${service_duration}=   Random Int   min=5   max=10
    # ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    # ${servicecharge}=   Random Int  min=100  max=500

    # ${resp}=  Create Service  ${SERVICE3}   ${desc}   ${service_duration}   ${status[0]}  
    # ...  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]} 
    # ...   ${bool[1]}   dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid3}  ${resp.json()}

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    ${sid3}=  Create Sample Service  ${SERVICE3}  dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Set Suite Variable   ${sid3}

    ${resp}=   Get Service By Id  ${sid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${resp}=   Get Location By Id   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${sid1}  ${sid2}  ${sid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}


    ${fname}=  generate_firstname
    Set Suite Variable   ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable   ${lname}

    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cid}  ${resp.json()['providerConsumer']}


    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid1}  ${apptid[0]}

    ${apptTime}=  db.get_tz_time_secs  ${tz} 
    ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
    ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

    ${resp}=  Consumer Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['apptTakenTime']}     ${statusUpdatedTime}
    Should Be Equal As Strings    ${resp.json()[0]['uid']}               ${appt_reqid1}

JD-TC-ConsumerCreateApptRequest-2

    [Documentation]   Consumer create an appt request for a future date with for the same schedule.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY}=  db.add_timezone_date  ${tz}   2
    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid2}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-3

    [Documentation]   Provider create a service request with date/time mode, 
    ...   then consumer try to create appt request with time slot.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${acc_id1}  ${DAY1}  ${lid}  ${sid2}
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

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${appt_reqid1}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-4

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request without time slot and date.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${service_duration}=   Random Int   min=5   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500

    # ${resp}=  Update Service  ${sid2}  ${SERVICE2}  ${desc}  ${service_duration}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}    serviceBookingType=${serviceBookingType[1]}
    ${resp}=  Update Service  ${sid2}  ${SERVICE2}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  noDateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}

    # ${resp}=  Update Service  ${sid2}  ${SERVICE2}   ${desc}   ${service_duration}   ${bool[0]}  ${servicecharge}  ${bool[0]}
    # ...     noDateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${apptfor1}=  Create Dictionary  id=${self} 
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${EMPTY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${appt_reqid1}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-5

    [Documentation]   Consumer create an appt request for his family member.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${family_fname2}=  generate_firstname
    Set Suite Variable   ${family_fname2}
    ${family_lname2}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname2}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}


    ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
    ${address}                    FakerLibrary.address

    ${resp}=    Create Family Member   ${family_fname2}  ${family_lname2}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${cidfor2}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cidfor2} 
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_req1}  ${apptid[0]}


JD-TC-ConsumerCreateApptRequest-UH1

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request with date.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "${DATE_NOT_NEEDED}"


JD-TC-ConsumerCreateApptRequest-UH2

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request with timeslot.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${apptfor1}=  Create Dictionary  id=${self}  apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${EMPTY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "${TIME_NOT_NEEDED}"


JD-TC-ConsumerCreateApptRequest-UH3

    [Documentation]   consumer create an appt request with a service not in that schedule.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  25  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${sid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${acc_id1}  ${DAY1}  ${lid}  ${sid2}
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

    ${apptfor1}=  Create Dictionary  id=${self}  apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid3}  ${sch_id}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${SERVICE_NOT_AVAILABLE_IN_SCHEDULE}"


JD-TC-ProviderCreateApptRequest-UH4

    [Documentation]   Consumer create an appt request without login.

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME20}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

