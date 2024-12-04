*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library 	      JSONLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  sampleservice1 
${SERVICE2}  sampleservice2
${SERVICE3}  sampleservice3
${SERVICE4}  sampleservice4
${self}     0
@{service_names}
${digits}       0123456789


*** Test Cases ***

JD-TC-GetConsumerAppointments-1

    [Documentation]  takes two online appointment for today and verify consumer appointment details.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid1}=  get_acc_id  ${PUSERNAME100}
    Set Suite Variable   ${pid1}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME100}
    clear_customer   ${PUSERNAME100}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable   ${DAY1}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}



    # ${resp}=  Provider Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME20}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cons_id1}   ${resp.json()['id']}
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid1}  ${DAY1}  ${lid}  ${s_id}
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
    ${k}=  Random Int  max=${num_slots-2}
    Set Test Variable   ${slot2}   ${slots[${k}]}   

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}


    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${cons_id1}   ${resp.json()[0]['id']}

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Test Variable   ${encId1}   

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Test Variable   ${encId2}   

    # ${resp}=  Provider Logout
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME20}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
              Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId1}       
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
              Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
              Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
              Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
              Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
              Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
              Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
              Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
              Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id}
              Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   

              Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId2}       
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
              Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
              Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
              Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
              Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
              Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
              Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
              Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
              Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
              Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id}
              Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id}
        END 
    END 

JD-TC-GetConsumerAppointments-2

    [Documentation]  Get consumer appointments for today and future.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${account_id}=  get_acc_id  ${HLPUSERNAME53}
    Set Suite Variable   ${account_id}


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Enable Disable Department  ${toggle[0]}

    # clear_service   ${HLPUSERNAME53}
    # clear_location  ${HLPUSERNAME53}

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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7



    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url

    ${bs1}=  TimeSpec  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${sTime1}  ${eTime1}
    ${bs1}=  Create List  ${bs1}
    ${bs1}=  Create Dictionary  timespec=${bs1}

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}   ${postcode}  ${address}     googleMapUrl=${url}   parkingType=${parking}  open24hours=${24hours}   bSchedule=${bs1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # clear_appt_schedule   ${HLPUSERNAME53}

    # ${resp}=  Enable Disable Department  ${toggle[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  2s
    # ${resp}=  Get Departments
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    # END
    
    ${DAY10}=  db.add_timezone_date  ${tz}  10   
    Set Suite Variable  ${DAY1}     
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${s_id1}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}   department=${dep_id}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}   department=${dep_id}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}   department=${dep_id}
    Set Suite Variable  ${s_id4}


    reset_queue_metric  ${account_id}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${lname}
   
    ${resp}=  AddCustomer  ${CUSERNAME21}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY10}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    # ${sTime2}=  db.get_time_by_timezone   ${tz}  
    ${sTime2}=  db.get_time_by_timezone  ${tz}  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime1}  ${delta}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/4}
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

    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${DAY2}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${cons_id2}   ${resp.json()['id']}
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid1}  ${s_id1}
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
    ${k}=  Random Int  max=${num_slots-2}
    Set Suite Variable   ${slot2}   ${slots[${k}]}   

    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${cid}   ${resp.json()[0]['id']}

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId11}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId11}   

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId22}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId22}   

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END

    END 

JD-TC-GetConsumerAppointments-3

    [Documentation]  Get consumer appointments by service.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid1}  ${s_id1}
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
    ${l}=  Random Int  max=${num_slots-3}
    Set Suite Variable   ${slot3}   ${slots[${l}]}

    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id2}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId3}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${encId3}  

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    service-eq=${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}    ${lname}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-4

    [Documentation]  Get consumer appointments by appointmentEncId.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    appointmentEncId-eq=${encId3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}    ${lname}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetConsumerAppointments-5

    [Documentation]  Get consumer appointments by first name.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    firstName-eq=${fname}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-6

    [Documentation]  Get consumer appointments by last name.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    lastName-eq=${lname}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-7

    [Documentation]  Get consumer's appointments where appointment taken by consumer(apptBy)..

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    apptBy-eq=CONSUMER
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-8

    [Documentation]  Get consumer appointments by schedule id.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments     schedule-eq=${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-9

    [Documentation]  Get consumer appointments by appointment time.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments     apptTime-eq=${slot1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings       ${resp.json()[0]['appointmentEncId']}                       ${encId11}       
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cid}      
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}  
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}    
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}                 ${lname}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}



JD-TC-GetConsumerAppointments-10

    [Documentation]  Get consumer appointments by location.

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments     location-eq=${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-11

    [Documentation]  Get consumer appointments by Appointment status Arrived.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.text}  ${apptStatus[2]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[2]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-12

    [Documentation]  Get consumer appointments by Appointment status started.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.text}  ${apptStatus[3]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[3]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[3]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-13

    [Documentation]  Get consumer appointments by Appointment status completed.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.text}  ${apptStatus[6]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[6]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId11}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[6]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-14

    [Documentation]   Get consumer appointments by Appointment status Canceled.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid2}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.text}  ${apptStatus[4]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

       IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'      
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${encId22}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[4]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}                ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}                 ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 



JD-TC-GetConsumerAppointments-15

    [Documentation]   Get consumer appointments by Appointment status Rejected.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid3}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.text}  ${apptStatus[5]}


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments    apptStatus-eq=${apptStatus[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF     '${resp.json()[${i}]['uid']}' == '${apptid3}'   
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentEncId']}                       ${encId3}
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[4]}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cid}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['uid']}                                    ${apptid3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}
        END
    
    END 

JD-TC-GetConsumerAppointments-16

    [Documentation]  Get consumer's appointments today with provider login
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
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

JD-TC-GetConsumerAppointments-17

    [Documentation]  Get consumer appointments by paymentstatus(partially paid).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov_id}=  get_acc_id  ${HLPUSERNAME52}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END


    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    ${loc_id1}=  Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # clear_appt_schedule   ${HLPUSERNAME52}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Account Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
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


    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME27}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME27}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${providerConsumer}   ${resp.json()['providerConsumer']}  
    Set Test Variable   ${cid}  ${resp.json()['id']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${prov_id}  ${DAY1}  ${loc_id1}  ${ser_id1}
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
    Set Suite Variable   ${slot21}   ${slots[${j}]}


    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot21}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY6}=  db.add_timezone_date  ${tz}   6
    Set Suite Variable   ${DAY6}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${prov_id}  ${ser_id1}  ${schedule_id1}  ${DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid6}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${prov_id}  ${apptid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 



   
    ${resp}=  Make payment Consumer Mock  ${prov_id}  ${min_pre}  ${purpose[0]}  ${apptid6}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${providerConsumer}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}



    sleep  01s


    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details By UUId  ${apptid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME27}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment EncodedID   ${apptid6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId21}=  Set Variable   ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME27}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Appointments    paymentStatus-eq=${paymentStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId21}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY6}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot21}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid6}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${loc_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${schedule_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1



