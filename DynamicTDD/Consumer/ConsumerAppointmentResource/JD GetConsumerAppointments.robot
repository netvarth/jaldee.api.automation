*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  sampleservice1 
${SERVICE2}  sampleservice2
${SERVICE3}  sampleservice3
${SERVICE4}  sampleservice4
${self}     0
${digits}       0123456789

*** Test Cases ***

JD-TC-GetConsumerAppointments-1

    [Documentation]  Get consumer appointments for today and future.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME140}
    Set Suite Variable   ${pid1}
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Appointment
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    clear_service   ${PUSERNAME140}
    clear_location  ${PUSERNAME140}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid1}=  Create Sample Location 
    Set Suite Variable  ${lid1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  30
    ${eTime1}=  add_time  1  00
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()} 
    clear_appt_schedule   ${PUSERNAME140}
    
    ${DAY10}=  add_date  10 
    Set Suite Variable  ${DAY1}     
    ${sTime1}=  db.get_time
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id4}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY10}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${sTime2}=  db.get_time
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime1}  ${delta}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY10}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id3}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY2}=  add_date  2
    Set Suite Variable  ${DAY2}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME30}
    Set Suite Variable   ${cid1}
    Set Suite Variable  ${f_Name1}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name1}  ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
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
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME30}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id1}   ${resp.json()[0]['id']}

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId1}   

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId2}   

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
    END 

JD-TC-GetConsumerAppointments-2

    [Documentation]  Get consumer appointments by service.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot3}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId3}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId3}  

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    service-eq=${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-3

    [Documentation]  Get consumer appointments by appointmentEncId.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    appointmentEncId-eq=${encId3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-4

    [Documentation]  Get consumer appointments by first name.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    firstName-eq=${f_Name1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
    
    END 

JD-TC-GetConsumerAppointments-5

    [Documentation]  Get consumer appointments by last name.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    lastName-eq=${l_Name1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

    
    END 

JD-TC-GetConsumerAppointments-6

    [Documentation]  Get consumer appointments by schedule id.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot4}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot4}
    ${apptfor}=   Create List  ${apptfor1}
   
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id3}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment EncodedID    ${apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId4}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId4}  

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    schedule-eq=${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

    
    END 

    ${resp}=  Get Consumer Appointments    schedule-eq=${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId4}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot4}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid4}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id2}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-7

    [Documentation]  Get consumer's appointments where appointment taken by consumer(apptBy).

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptBy-eq=CONSUMER
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  4

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid4}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId4}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

    END 

JD-TC-GetConsumerAppointments-8

    [Documentation]  Get consumer appointments by appointment time.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptTime-eq=${slot4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId4}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot4}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid4}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id2}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-9

    [Documentation]  Get consumer appointments by paymentstatus(partially paid).

    ${billable_doms}=  get_billable_domain
    Log  ${billable_doms}
    Set Suite Variable  ${dom}  ${billable_doms[0][0]}
    Set Suite Variable  ${sub_dom}  ${billable_doms[1][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+5166147
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${resp}=  Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_D}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_D}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY2}=  add_date   9      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  5  00
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${prov_id}=  get_acc_id  ${PUSERNAME_D}
    
    ${resp}=  Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Appointment
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${loc_id1}=  Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME_D}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  4  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${schedule_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${schedule_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${schedule_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${prov_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${schedule_id1}   ${prov_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${schedule_id1}   ${prov_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot21}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot21}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY6}=  add_date   6
    Set Suite Variable   ${DAY6}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${prov_id}  ${ser_id1}  ${schedule_id1}  ${DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid6}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${prov_id}  ${apptid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid6}   appmtDate=${DAY6}   appmtTime=${slot21}  apptStatus=${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${schedule_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot21}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id1}

    #  ${resp}=  ProviderLogin  ${PUSERNAME_D}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid6}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Make payment Consumer Mock  ${prov_id}  ${min_pre}  ${purpose[0]}  ${apptid6}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

   
    # ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s
    ${resp}=  Get Bill By consumer  ${apptid6}  ${prov_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid6}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${prov_id}

    ${resp}=  Get Payment Details By UUId  ${apptid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid6}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}  
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${prov_id}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

    # Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${apptid6}
    # Should Be Equal As Strings  ${resp.json()[1]['status']}  ${cupnpaymentStatus[0]}  
    # Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  ${pay_mode_selfpay}
    # Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${min_pre} 
    # Should Be Equal As Strings  ${resp.json()[1]['custId']}  ${jdconID}   
    # Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}  ${payment_modes[5]}  
    # Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${prov_id}    
    # Should Be Equal As Strings  ${resp.json()[1]['paymentGateway']}  RAZORPAY
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME27}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id2}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment EncodedID   ${apptid6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId21}=  Set Variable   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   paymentStatus-eq=${paymentStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId21}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY6}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot21}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid6}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${loc_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${schedule_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-10

    [Documentation]  Get consumer appointments by location.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    location-eq=${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
  
    END 

JD-TC-GetConsumerAppointments-11

    [Documentation]  Get consumer appointments by appointment start time.

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${slot1_time}=  Get Substring   ${slot4}  0  5

    ${resp}=  Get Consumer Appointments    apptstartTime-eq=${slot1_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot4}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid4}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id2}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-12

    [Documentation]  Get consumer appointments by Appointment status Arrived.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[2]}
    Should Contain  "${resp.json()}"  ${apptStatus[2]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-13

    [Documentation]  Get consumer appointments by Appointment status Started.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[3]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-14

    [Documentation]  Get consumer appointments by Appointment status Completed.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[3]['appointmentStatus']}   ${apptStatus[6]}
    Should Contain  "${resp.json()}"  ${apptStatus[6]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[6]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[6]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-15

    [Documentation]  Get consumer appointments by Appointment status Canceled.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason}  ${msg}  ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId2}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[4]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot2}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-16

    [Documentation]  Get consumer appointments by Appointment status Rejected.

    ${resp}=  Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Reject Appointment  ${apptid3}  ${reason}  ${msg}  ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}
    Should Contain  "${resp.json()}"  ${apptStatus[5]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[5]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-17

    [Documentation]  Get consumer's appointments today with provider login
    
    ${resp}=  Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer Appointments 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NO_ACCESS_TO_URL}"

JD-TC-GetConsumerAppointments-UH1

    [Documentation]  Get consumer's appointments today without consumer login
    
    ${resp}=  Get Consumer Appointments 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
