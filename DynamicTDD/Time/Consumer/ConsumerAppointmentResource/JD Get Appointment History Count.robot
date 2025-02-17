*** Settings ***
Suite Teardown    Run Keywords   Delete All Sessions  resetsystem_time
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2
${SERVICE3}    SERVICE3
${self}        0
${apptBy}       CONSUMER

*** Test Cases ***

JD-TC-Get Appointment history Count-1

    [Documentation]  Consumer Appointments History COUNT
    
    change_system_date   -5


    # clear_service   ${HLPUSERNAME48}
    # clear_location  ${HLPUSERNAME48}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${HLPUSERNAME48}
    Set Suite Variable  ${pid} 
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${DAY}=  db.get_date_by_timezone  ${tz}  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    Set Suite Variable  ${DAY2}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid1}  ${resp.json()}
    # clear_appt_schedule   ${HLPUSERNAME48}
      
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${s_id3}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3} 
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}   ${s_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id3}
    # Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
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


    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor2}=   Create List  ${apptfor1} 

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id2}
    # Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
    # ${apptfor3}=  Create Dictionary  id=${self}   apptTime=${slot2}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot2}   ${slots[${j}]}
    # ${apptfor4}=   Create List  ${apptfor3}

    # ${resp}=  ProviderLogout
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${fname}=  generate_firstname
    Set Suite Variable   ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable   ${lname}
   
    ${resp}=  AddCustomer  ${CUSERNAME6}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}



    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME6}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME6}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid1}  ${s_id1}
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
    Set Suite Variable   ${slot2}   ${slots[${j}]}



    ${apptfor12}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor22}=   Create List  ${apptfor12} 


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid1}  ${s_id2}
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
    Set Suite Variable   ${slot3}   ${slots[${j}]}

    ${apptfor13}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor4}=   Create List  ${apptfor13}

    ${cid}=  get_id  ${CUSERNAME6}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment    ${pid}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor22}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment    ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment    ${pid}  ${s_id3}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME48}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid1}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid1}=  Set Variable   ${resp.json()}

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid2}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid2}=  Set Variable   ${resp.json()}

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid3}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid3}=  Set Variable   ${resp.json()}



    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]} 
    
    ${resp}=    ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date   3

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get Consumer Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${len}=  Get Length  ${resp.json()}


    ${resp}=   Get Consumer Appointments History Count
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Integers  ${resp.json()}  3
    

JD-TC-Get Appointment history Count-2 

    [Documentation]  Get Appointment history count By appointmentEncId
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count           appointmentMode-eq=${appointmentMode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-3 

    [Documentation]   Get Appointment history count By location

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count           location-eq=${lid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2

JD-TC-Get Appointment history Count-4

    [Documentation]  Get Appointment history count By service
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200   

    ${resp}=  Get Consumer Appointments History Count           service-eq=${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-5 

    [Documentation]  Get Appointment history count By schedule
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count          schedule-eq=${sch_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-6 

    [Documentation]  Get Appointment history count By apptStatus
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count          apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2

JD-TC-Get Appointment history Count-7 

    [Documentation]  Get Appointment history Count By firstName
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable   ${cname1}    ${resp.json()['firstName']}
    
    ${resp}=  Get Consumer Appointments History Count          firstName-eq=${fname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-8 

    [Documentation]  Get Appointment history Count By Appmt Date
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Consumer Appointments History Count           date-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-9 

    [Documentation]  Get Appointment history count By Appmtby
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Consumer Appointments History Count           apptBy-eq=${apptBy}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-10 

    [Documentation]  Get Appointment history count By Appmtby  and  date
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count     apptBy-eq=${apptBy}     date-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-11 

    [Documentation]  Get Appointment history Count By apptStatus and firstName 
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count      apptStatus-eq=${apptStatus[1]}  firstName-eq=${fname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2

JD-TC-Get Appointment history Count-12 

    [Documentation]  Get Appointment history Count By schedule and apptStatus

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Consumer Appointments History Count       schedule-eq=${sch_id3}  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-13 

    [Documentation]  Get Appointment history Count By appointmentEncId and service
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Appointments History Count         appointmentMode-eq=${appointmentMode[2]}    service-eq=${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-14

    [Documentation]   Get Appointment history count with no input
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    
    ${resp}=  Get Consumer Appointments History Count             firstName-eq=${fname}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3
    
JD-TC-Get Appointment history Count-UH1

    [Documentation]   Get Appointment history count without Consumer login
    
    ${resp}=    Get Consumer Appointments History Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"