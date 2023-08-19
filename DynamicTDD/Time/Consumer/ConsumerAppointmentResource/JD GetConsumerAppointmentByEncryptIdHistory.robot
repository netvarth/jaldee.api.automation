*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Appointment History
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

${waitlistedby}           CONSUMER
${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
${apptStatus}   Confirmed                            

*** Test Cases ***   

JD-TC-GetApptByEncryptedIDconsumerHistory-1

    [Documentation]   Get Appointment details By Encrypted ID

    change_system_date  -3

    clear_service   ${PUSERNAME170}
    clear_location  ${PUSERNAME170}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME170}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME170}
    Set Suite Variable   ${pid}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${SERVICE1}=   FakerLibrary.name
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}    

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    
    ${cid}=  get_id  ${CUSERNAME13}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${f_name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${l_name}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    ${encId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id  ${pid}  ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   appointmentEncId=${encId}

    ${resp}=  Get Appointment By EncodedId    ${encId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   uid=${apptid1}   appmtDate=${DAY1}  apptStatus=${apptStatus}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                         ${apptid1}

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Appointment By EncodedId   ${encId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    uid=${apptid1}   appmtDate=${DAY1}  apptStatus=${apptStatus} 
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['uid']}                         ${apptid1}

JD-TC-GetApptByEncryptedIDconsumerHistory-UH1

    [Documentation]   View Consumer Appointment By Encoded Id after changing the Date

    # change_system_date   3

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Appointment By EncodedId   ${encId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${APPOINTMENT_ID_NO_LONGER_ACTIVE}"   


JD-TC-GetApptByEncryptedIDconsumerHistory-UH2

    [Documentation]   Consumer Appointment By Encoded Id is Zero    
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Appointment By EncodedId   0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${APPOINTMENT_ID_NO_LONGER_ACTIVE}