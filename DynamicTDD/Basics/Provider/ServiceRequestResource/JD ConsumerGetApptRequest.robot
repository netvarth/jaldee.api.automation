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

JD-TC-ConsumerGetApptRequest-1

    [Documentation]   Consumer create an appt request and verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable   ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

    clear_appt_schedule   ${PUSERNAME36}

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
    
    ${resp}=  Create Sample Schedule   ${lid}   ${sid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${acc_id1}
    Log  ${resp.content}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cons_note}=    FakerLibrary.word
    Set Suite Variable   ${cons_note}
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME10}  ${coupons}  ${apptfor}
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

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['apptTakenTime']}         ${statusUpdatedTime}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

JD-TC-ConsumerGetApptRequest-2

    [Documentation]   Consumer create an appt request and verify it.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${self}   
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY2}=  db.add_timezone_date  ${tz}   2
    ${cons_note1}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY2}  ${cons_note1}  ${countryCodes[0]}  ${CUSERNAME10}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid2}  ${apptid[0]}
    
    ${resp}=  Consumer Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}


JD-TC-ConsumerGetApptRequest-3

    [Documentation]   Consumer create an appt request for his family member and verify it.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${cons_note2}=    FakerLibrary.word
    Set Suite Variable   ${cons_note2}
    ${coupons}=  Create List
    ${resp}=  Consumer Create Appt Service Request  ${acc_id1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME5}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_req1}  ${apptid[0]}

    ${resp}=  Consumer Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_req1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note2}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[2]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[2]['appointmentMode']}         ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[2]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[2]['apptBy']}                  ${apptBy[1]} 
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[2]['location']['id']}          ${lid}

JD-TC-ConsumerGetApptRequest-UH1

    [Documentation]    get an appt request without login.

    ${resp}=  Consumer Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-ConsumerGetApptRequest-UH2

    [Documentation]    get an appt request by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${NO_ACCESS_TO_URL}"