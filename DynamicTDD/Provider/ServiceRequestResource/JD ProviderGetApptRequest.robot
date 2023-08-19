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

JD-TC-ProviderGetApptRequest-1

    [Documentation]   Provider get an appt request for today and verify it.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}

    clear_appt_schedule   ${PUSERNAME6}

    ${DAY1}=  get_date
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
    ...   ${bool[1]}   dateTime=${bool[1]}  serviceBookingType=${serviceBookingType[1]}
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

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=  Create Sample Schedule   ${lid}   ${sid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time  1  15
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${sid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME3}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${apptfor1}=  Create Dictionary  id=${pcid1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note}=    FakerLibrary.word
    Set Suite Variable   ${cons_note}
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid1}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note}  ${countryCodes[0]}  ${CUSERNAME3}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid1}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

JD-TC-ProviderGetApptRequest-2

    [Documentation]   Provider get multiple appt request and verify it.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME4}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid2}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid2}  ${resp.json()[0]['id']}
    END

    ${apptfor1}=  Create Dictionary  id=${pcid2}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cons_note1}=    FakerLibrary.word
    Set Suite Variable   ${cons_note1}
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid2}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note1}  ${countryCodes[0]}  ${CUSERNAME4}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid2}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${pcid2}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

JD-TC-ProviderGetApptRequest-3

    [Documentation]   Provider create appt request for a provider consumers family member and verify it.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name 
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+3000230

    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid2}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
    Log  ${resp.json()}
    Set Suite Variable  ${mem_id0}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${mem_id0}  
    ${apptfor}=   Create List  ${apptfor1}

    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid2}  ${sid1}  ${sch_id1}  ${DAY1}  ${cons_note1}  ${countryCodes[0]}  ${CUSERNAME4}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid3}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${mem_id0}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[0]}  
    Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['id']}       ${pcid2}  
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[2]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[2]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[2]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[2]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[2]['location']['id']}          ${lid}

JD-TC-ProviderGetApptRequest-4

    [Documentation]   Provider get an appt request without create it.

    ${resp}=  Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-ProviderGetApptRequest-5

    [Documentation]   Provider get an appt request with location filter.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${con_not}=    FakerLibrary.word
    Set Suite Variable   ${con_not}
    ${coupons}=  Create List
    ${resp}=  Provider Create Appt Service Request   ${pcid1}  ${sid2}  ${sch_id2}  ${DAY1}  ${con_not}  ${countryCodes[0]}  ${CUSERNAME3}  ${coupons}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${appt_reqid5}  ${apptid[0]}

    ${resp}=  Provider Get Appt Service Request  location-eq=${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid5}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${con_not}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid1}

    ${resp}=  Provider Get Appt Service Request  location-eq=${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${mem_id0}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[0]}  
    Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['id']}       ${pcid2}  
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[2]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[2]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[2]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[2]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[2]['location']['id']}          ${lid}


JD-TC-ProviderGetApptRequest-6

    [Documentation]   Provider get an appt request with schedule filter.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Get Appt Service Request  schedule-eq=${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid5}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${con_not}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid1}

    ${resp}=  Provider Get Appt Service Request  schedule-eq=${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${mem_id0}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[0]}  
    Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['id']}       ${pcid2}  
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[2]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[2]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[2]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[2]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[2]['location']['id']}          ${lid}


JD-TC-ProviderGetApptRequest-7

    [Documentation]   Provider get an appt request with location and schedule filter.

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Get Appt Service Request  location-eq=${lid1}   schedule-eq=${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid5}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${con_not}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid1}

    ${resp}=  Provider Get Appt Service Request  location-eq=${lid}  schedule-eq=${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}                     ${appt_reqid3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}       ${mem_id0}   
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                     ${appt_reqid2}
    Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['consumerNote']}            ${cons_note1}
    Should Be Equal As Strings  ${resp.json()[1]['apptBy']}                  ${apptBy[0]}  
    Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['id']}       ${pcid2}  
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}  ${pcid2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}          ${lid}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                     ${appt_reqid1}
    Should Be Equal As Strings  ${resp.json()[2]['appmtDate']}               ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['apptStatus']}              ${apptStatus[11]}
    Should Be Equal As Strings  ${resp.json()[2]['appointmentMode']}         ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()[2]['consumerNote']}            ${cons_note}
    Should Be Equal As Strings  ${resp.json()[2]['apptBy']}                  ${apptBy[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['appmtFor'][0]['id']}       ${pcid1}   
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['id']}          ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[2]['location']['id']}          ${lid}

    ${resp}=  Provider Get Appt Service Request  location-eq=${lid1}  schedule-eq=${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-ProviderGetApptRequest-UH1

    [Documentation]    get an appt request without login.

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-ProviderGetApptRequest-UH2

    [Documentation]    get an appt request by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Get Appt Service Request
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"