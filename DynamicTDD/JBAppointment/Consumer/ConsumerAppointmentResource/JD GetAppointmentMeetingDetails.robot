

*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Teleservice
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Variables ***

${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09

${self}     0
@{service_names}

&{Emptydict}



*** Test Cases ***
JD-TC-GetAppointmentMeetingDetails-1
    [Documentation]  Create Teleservice meeting request for Appointment in WhatsApp (ONLINE CHECKIN)
    
    ${NewCustomer}=  Generate Random 555 Number
    ${UserZOOM_id0}=  Format String  ${ZOOM_url}  ${NewCustomer}

    Set Suite Variable  ${ZOOM_id2}    ${UserZOOM_id0}
    Set Suite Variable  ${WHATSAPP_id2}   ${countryCodes[0]}${NewCustomer}
    

    ${firstname}  ${lastname}  ${PUSERPH0}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH0}

    sleep   01s

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERPH0}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+50505
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   countryCode=${countryCodes[0]}  status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes1}=  Create List  ${VScallingMode1}
    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}
    

    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}
    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Description2}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Description2}
    ${virtualCallingModes2}=  Create List  ${VScallingMode1}
    ${Total2}=   Random Int   min=100   max=500
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${description2}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total2}  ${bool[0]}   ${bool[0]}   ${vstype2}   ${virtualCallingModes2}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE2}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype2}
    


    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # clear_appt_schedule   ${PUSERPH0}
   

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Suite Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor} 
      


   #............provider consumer creation..........


    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lname}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${CUSERNAME6}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME6}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME6}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    
    
    ${cid}=  get_id  ${CUSERNAME6}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${WHATSAPP_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Create Appointment Meeting Request   ${apptid1}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid1}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid1}   ${CallingModes[1]}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    
JD-TC-GetAppointmentMeetingDetails-2
    [Documentation]  Create Teleservice meeting request for Appointment in Zoom (ONLINE CHECKIN)

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME6}    

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Appointment Meeting Request   ${apptid2}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid2}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid2}    ${CallingModes[0]}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['startingUl']}   ${ZOOM_id2}
    Should Be Equal As Strings  ${resp.json()['joiningUrl']}   ${ZOOM_id2}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200



    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid2}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   

JD-TC-GetAppointmentMeetingDetails-UH1
    [Documentation]  Create Teleservice meeting request for Appointment  in Zoom and WhatsApp (ONLINE CHECKIN)


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME6}    


    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}   ${WHATSAPP_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Appointment Meeting Request   ${apptid3}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Appointment Meeting Request    ${apptid3}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"


    ${resp}=  Create Appointment Meeting Request   ${apptid3}   ${CallingModes[1]}  ${waitlistedby[1]}  ${waitlistedby[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid3}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME6}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid3}   ${CallingModes[1]}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid3}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    
JD-TC-GetAppointmentMeetingDetails-3
    [Documentation]  Create Teleservice meeting request for Appointment in Zoom (WALK-IN CHECKIN)


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 



    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}



   #............provider consumer creation..........


    ${fname2}=  generate_firstname
    Set Suite Variable  ${fname2}
    ${lastname1}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${CUSERNAME16}    firstName=${fname2}   lastName=${lastname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()} 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    $${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME16}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token2}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200



    ${resp}=    Get All Schedule Slots By Date Location and Service  ${accId}  ${DAY1}  ${p1_l1}  ${p1_s2}
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

    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor} 

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    


    ${cnote}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}   virtualService=${virtualService}  location=${{str('${p1_l1}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid4}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Create Appointment Meeting Request   ${apptid4}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid4}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid4}   ${CallingModes[0]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['startingUl']}   ${ZOOM_id2}
    Should Be Equal As Strings  ${resp.json()['joiningUrl']}   ${ZOOM_id2}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid4}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-GetAppointmentMeetingDetails-4
    [Documentation]  Create Teleservice meeting request for Appointment in WhatsApp (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_customer   ${PUSERPH0}

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}



    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor} 



    ${cnote}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}   virtualService=${virtualService}  location=${{str('${p1_l1}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid5}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Create Appointment Meeting Request   ${apptid5}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid5}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid5}   ${CallingModes[1]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid5}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-GetAppointmentMeetingDetails-UH2
    [Documentation]  Create Teleservice meeting request for Appointment in Zoom and WhatsApp (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor} 
      

    ${cnote}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    ${resp}=  Take Appointment For Consumer   ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}   virtualService=${virtualService}  location=${{str('${p1_l1}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid6}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Create Appointment Meeting Request   ${apptid6}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid6}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Appointment Meeting Request   ${apptid6}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Appointment Meeting Request    ${apptid6}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"



     ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details   ${apptid6}   ${CallingModes[0]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['startingUl']}   ${ZOOM_id2}
    Should Be Equal As Strings  ${resp.json()['joiningUrl']}   ${ZOOM_id2}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid6}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   

JD-TC-GetAppointmentMeetingDetails-5

    [Documentation]   Create Appointment teleservice Zoom meeting request Which  is already created
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor} 
      


    ${cnote}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}   virtualService=${virtualService}  location=${{str('${p1_l1}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid7}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    #Step_1
    ${resp}=  Create Appointment Meeting Request   ${apptid7}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid7}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #Step_2
    ${resp}=  Create Appointment Meeting Request   ${apptid7}   ${CallingModes[0]}  ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid7}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details    ${apptid7}   ${CallingModes[0]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['startingUl']}   ${ZOOM_id2}
    Should Be Equal As Strings  ${resp.json()['joiningUrl']}   ${ZOOM_id2}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200



    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid7}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

 
JD-TC-GetAppointmentMeetingDetails-6

    [Documentation]   Create Appointment teleservice Whatsapp meeting request Which  is already created
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME6}    

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}   ${WHATSAPP_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid8}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Create Appointment Meeting Request   ${apptid8}   ${CallingModes[1]}  ${waitlistedby[1]}  ${waitlistedby[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid8}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Initial_Mtng_Request}  "${resp.json()}"



    ${resp}=  Create Appointment Meeting Request   ${apptid8}   ${CallingModes[1]}  ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid8}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  "${resp.json()}"   ${Initial_Mtng_Request}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Meeting Details    ${apptid8}    ${CallingModes[1]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid8}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-GetAppointmentMeetingDetails-UH3

    [Documentation]  Get Appointment teleservice meeting Details without login
    ${resp}=   Get Appointment Meeting Details   ${apptid1}    ${CallingModes[1]}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"




JD-TC-GetAppointmentMeetingDetails-7
    [Documentation]  Create Teleservice meeting request for Appointment  in Zoom 

    ${firstname}  ${lastname}  ${PUSERPH2}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH2}

    sleep   02s

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_id2}=  Format String  ${ZOOM_url}  ${PUSERPH2}
    Set Suite Variable   ${ZOOM_id2}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id2}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Suite Variable   ${ZOOM_Pid2}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
 

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p2_s1}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P2SERVICE1}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p2_s2}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P2SERVICE2}   ${resp.json()[1]['name']}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_l1}   ${resp.json()[0]['id']}
    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # clear_appt_schedule   ${PUSERPH2}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p2_l1}  ${duration}  ${bool1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}



    # ${resp}=  Get Consumer By Id  ${NewCustomer}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${jdconID0}   ${resp.json()['userProfile']['id']}
    # Set Suite Variable  ${f_Name0}   ${resp.json()['userProfile']['firstName']}
    # Set Suite Variable  ${l_Name0}   ${resp.json()['userProfile']['lastName']}
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${NewCustomer}=  Generate Random 555 Number
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid0}  ${resp.json()} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${p2_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid0}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}



    ${cnote}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_pid2}
    ${resp}=  Take Appointment For Consumer  ${pcid0}  ${p2_s1}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}   virtualService=${virtualService}  location=${{str('${p2_l1}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid9}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    #Step_1
    ${resp}=  Create Appointment Meeting Request   ${apptid9}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid9}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #Step_2
    ${resp}=  Create Appointment Meeting Request   ${apptid9}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Appointment Meeting Request    ${apptid9}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token3}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${pid}  ${token3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Appointment Meeting Details    ${apptid9}    ${CallingModes[0]}     ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['startingUl']}   ${ZOOM_pid2}
    Should Be Equal As Strings  ${resp.json()['joiningUrl']}   ${ZOOM_pid2}

