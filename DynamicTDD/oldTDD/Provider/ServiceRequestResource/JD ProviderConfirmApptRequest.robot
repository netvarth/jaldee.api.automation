*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appt Request
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

JD-TC-ProviderConfirmApptRequest-1

    [Documentation]   Provider create an appt request for today and confirm it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}

    clear_appt_schedule   ${PUSERNAME35}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
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
    ...   ${bool[1]}   date=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${sid2}
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

    ${resp}=  Create Sample Schedule   ${lid}   ${sid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${sid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME25}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${apptfor1}=  Create Dictionary  id=${pcid1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid1}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}    ${apptStatus[11]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Appt Service Request   ${appt_reqid1}  ${pcid1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${appt_reqid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[1]}

JD-TC-ProviderConfirmApptRequest-2

    [Documentation]   Provider create an appt request for today and confirm it for another day.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${pcid1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid1}  ${sid2}  ${sch_id2}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid2}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}    ${apptStatus[11]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY}=   db.add_timezone_date  ${tz}  2  
    ${resp}=  Confirm Appt Service Request   ${appt_reqid2}  ${pcid1}  ${sid2}  ${sch_id2}  ${DAY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${appt_reqid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}      ${DAY}


JD-TC-ProviderConfirmApptRequest-UH1

    [Documentation]   Provider create an appt request for today and confirm with another request id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${pcid1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid1}  ${sid2}  ${sch_id2}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid3}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}    ${apptStatus[11]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Appt Service Request   ${appt_reqid1}  ${pcid1}  ${sid2}  ${sch_id2}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${INVALID_APPOINTMENT_REQUEST}"

JD-TC-ProviderConfirmApptRequest-UH2

    [Documentation]   Provider create an appt request for today and confirm without request id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=   db.add_timezone_date  ${tz}  2  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    ${coupons}=  Create List
    ${resp}=  Confirm Appt Service Request   ${EMPTY}  ${pcid1}  ${sid2}  ${sch_id2}  ${DAY}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME25}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${INVALID_APPOINTMENT_REQUEST}"

JD-TC-ProviderConfirmApptRequest-UH3

    [Documentation]   Provider try to confirm 2 appt request to the same slot.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
