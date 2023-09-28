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
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

@{emptylist}
${self}     0

*** Test Cases ***

JD-TC-ConsumerCreateApptRequest-1

    [Documentation]   Consumer create an appt request.

    clear_appt_schedule   ${PUSERNAME36}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Suite Variable  ${lic_name}  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}
    # Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    # Set Test Variable   ${lic_name}   ${resp.json()['accountLicenseDetails']['accountLicense']['name']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}

    ${SERVICE1}=    FakerLibrary.word
    
    ${service_duration}=   Random Int   min=5   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${SERVICE1}   ${desc}   ${service_duration}   ${status[0]}  
    ...  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]} 
    ...   ${bool[1]}   date=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    FakerLibrary.word
    ${service_duration}=   Random Int   min=5   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${SERVICE2}   ${desc}   ${service_duration}   ${status[0]}  
    ...  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]} 
    ...   ${bool[1]}   dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${SERVICE3}=    FakerLibrary.word
    ${service_duration}=   Random Int   min=5   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${SERVICE3}   ${desc}   ${service_duration}   ${status[0]}  
    ...  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]} 
    ...   ${bool[1]}   dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}

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
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
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

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
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

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY}=  db.add_timezone_date  ${tz}   2
    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid2}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-3

    [Documentation]   Provider create a service request with date/time mode, 
    ...   then consumer try to create appt request with time slot.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${appt_reqid1}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-4

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request without time slot and date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE2}=    FakerLibrary.word
    ${service_duration}=   Random Int   min=5   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Update Service  ${sid2}  ${SERVICE2}   ${desc}   ${service_duration}   ${status[0]}  
    ...  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]} 
    ...   ${bool[1]}   noDateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self} 
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${EMPTY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${appt_reqid1}  ${apptid[0]}

JD-TC-ConsumerCreateApptRequest-5

    [Documentation]   Consumer create an appt request for his family member.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${family_fname2}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname2}
    ${family_lname2}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname2}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname2}  ${family_lname2}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor2}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cidfor2} 
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_req1}  ${apptid[0]}


JD-TC-ConsumerCreateApptRequest-UH1

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request with date.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${DATE_NOT_NEEDED}"


JD-TC-ConsumerCreateApptRequest-UH2

    [Documentation]   Provider create a service request with date/time mode and update the service with no datetime mode, 
    ...   then consumer try to create appt request with timeslot.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self}  apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid2}  ${sch_id1}  ${EMPTY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${TIME_NOT_NEEDED}"


JD-TC-ConsumerCreateApptRequest-UH3

    [Documentation]   consumer create an appt request with a time slot not in that schedule.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
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

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}  apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid3}  ${sch_id}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.content}   "${TIME_NOT_NEEDED}"


JD-TC-ProviderCreateApptRequest-UH4

    [Documentation]   Consumer create an appt request without login.

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

JD-TC-ProviderCreateApptRequest-UH5

    [Documentation]   Consumer create an appt request by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"