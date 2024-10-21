*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  sampleservice1 
${SERVICE2}  sampleservice2
${SERVICE3}  sampleservice3
${digits}       0123456789
${self}          0
@{service_names}



*** Test Cases ***

JD-TC-GetFutureAppointment-1

    [Documentation]  Get consumer's future appointments.



    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${HLPUSERNAME49}${\n}
    Set Suite Variable  ${HLPUSERNAME49}


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz}
    # ${DAY1}=  db.get_date_by_timezone  ${tz}


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # FOR  ${i}  IN RANGE   5
    #     ${city1}=   get_place
    #     Exit For Loop If  '${city1}' != '${city}'
    # END
    # Set Test Variable  ${city}  ${city1}  
    
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz1}
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${lid1}  ${resp.json()}


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
    Set Suite Variable  ${lid1}  ${resp.json()}


    ${pid1}=  get_acc_id  ${HLPUSERNAME49}
    Set Suite Variable   ${pid1}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        


    

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id11}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id11}   name=${schedule_name}  apptState=${Qstate[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
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
    Set Suite Variable   ${slot11}   ${slots[${j}]}
    
    ${resp}=  AddCustomer  ${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot11}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}   location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid11}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment EncodedID   ${apptid11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime3}  ${delta}   

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}



    # ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # ${cid1}=  get_id  ${CUSERNAME29}
    # # Set Suite Variable   ${cid1}
    # Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    # ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${fname}=  generate_firstname
    Set Suite Variable   ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable   ${lname}
   
    ${resp}=  AddCustomer  ${CUSERNAME16}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}



    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME16}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}



    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid1}  ${DAY1}  ${lid}  ${s_id1}
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

    
    # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}
    
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Customer Take Appointment   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${apptid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable   ${DAY2}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${family_fname2}=  generate_firstname
    Set Suite Variable   ${family_fname2}
    ${family_lname2}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname2}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    # ${resp}=  AddFamilyMember   ${family_fname2}  ${family_lname2}  ${dob}  ${gender}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${cidfor2}   ${resp.json()}

    ${primnum}  FakerLibrary.Numerify   text=%%%%%%%%%%
    ${address}  FakerLibrary.address

    ${resp}=    Create Family Member       ${family_fname2}  ${family_lname2}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${cidfor2}   ${resp.json()}
    

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    # ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot2}   ${slots[${j}]}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid1}  ${DAY1}  ${lid}  ${s_id2}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

 
    # ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot2}   firstName=${family_fname2}
    # ${apptfor}=   Create List  ${apptfor1}
    
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot2}   firstName=${family_fname2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable   ${DAY3}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${family_fname3}=  generate_firstname
    Set Suite Variable   ${family_fname3}
    ${family_lname3}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname3}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    # ${resp}=  AddFamilyMember   ${family_fname3}  ${family_lname3}  ${dob}  ${gender}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${cidfor3}   ${resp.json()}

    ${primnum}  FakerLibrary.Numerify   text=%%%%%%%%%%
    ${address}  FakerLibrary.address

    ${resp}=    Create Family Member       ${family_fname3}  ${family_lname3}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${cidfor3}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot3}   ${slots[${j}]}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid1}  ${DAY1}  ${lid1}  ${s_id2}
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
    Set Test Variable   ${slot3}   ${slots[${j}]}
    ${k}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot4}   ${slots[${k}]}
    
    # ${apptfor}=  Create Dictionary  id=${cidfor3}   apptTime=${slot3}   firstName=${family_fname3}
    # ${apptfor}=   Create List  ${apptfor}
   
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${apptfor}=  Create Dictionary  id=${cidfor3}   apptTime=${slot3}   firstName=${family_fname3}
    ${apptfor}=   Create List  ${apptfor}
    
    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable   ${DAY4}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    # ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid3}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot4}   ${slots[${j}]}
    
    # ${apptfor}=  Create Dictionary  id=${self}   apptTime=${slot4}   
    # ${apptfor}=   Create List  ${apptfor}
  
    # ${DAY5}=  db.add_timezone_date  ${tz}   5
    # Set Suite Variable   ${DAY5}
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY5}  ${cnote}   ${apptfor}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${apptfor}=  Create Dictionary  id=${self}   apptTime=${slot4}
    ${apptfor4}=   Create List  ${apptfor}
  
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}
    # ${apptid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['firstName']}' == '${fname}'
           Set Suite Variable   ${cons_id1}   ${resp.json()[${i}]['id']}
        ELSE IF     '${resp.json()[${i}]['firstName']}' == '${family_fname2}' 
           Set Suite Variable   ${cons_id2}   ${resp.json()[${i}]['id']}
        ELSE IF     '${resp.json()[${i}]['firstName']}' == '${family_fname3}' 
           Set Suite Variable   ${cons_id3}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  ListFamilyMemberByProvider   ${cons_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid1}   

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid2}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid2} 

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid3}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid3} 

    ${resp}=   Get Appointment EncodedID    ${apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid4}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid4} 

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get Consumer Future Appointments  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END

JD-TC-GetFutureAppointment-2

	[Documentation]  Filter future Appointment by service id.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments    service-eq=${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
    
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
    
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END


JD-TC-GetFutureAppointment-3

	[Documentation]  Filter future Appointment by appointmentEncId.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  

            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        END
    END
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}     []

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0

JD-TC-GetFutureAppointment-4

	[Documentation]  Filter future Appointment by first name.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   firstName-eq=${fname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        END
    END

JD-TC-GetFutureAppointment-5

	[Documentation]  Filter future Appointment by last name.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   lastName-eq=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        END
    END

JD-TC-GetFutureAppointment-6

	[Documentation]  Filter future Appointment by schedule id.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   schedule-eq=${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        END
    END

JD-TC-GetFutureAppointment-7

	[Documentation]  Get consumer's future appointments where appointment taken by consumer(apptBy).


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptBy-eq=CONSUMER
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}


        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END

JD-TC-GetFutureAppointment-8

	[Documentation]   Filter future Appointment by location.


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   location-eq=${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}


        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        END
    END

JD-TC-GetFutureAppointment-9

	[Documentation]   Filter future Appointment by Appointment status Arrived.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
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


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[2]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[2]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        END
    END
JD-TC-GetFutureAppointment-UH4

	[Documentation]   Filter future Appointment by status started.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0


JD-TC-GetFutureAppointment-11

	[Documentation]   Filter future Appointment by Appointment status completed.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[6]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[6]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${fname}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${lname}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}


        END
    END
JD-TC-GetFutureAppointment-12

	[Documentation]   Filter future Appointment by Appointment status cancelled.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[4]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname2}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}
        END
    END

JD-TC-GetFutureAppointment-13

	[Documentation]   Filter future Appointment by Appointment status Rejected.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
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

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[5]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid3}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[5]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END

JD-TC-GetFutureAppointment-14

	[Documentation]  Filter future Appointment by appointment Date.


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Future Appointments   date-eq=${DAY4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid3}'  
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[5]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
            # Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['firstName']}   ${family_fname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['providerConsumer']['lastName']}    ${family_lname3}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END


JD-TC-GetFutureAppointment-UH1

    [Documentation]  Get consumer's future appointments with provider login
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer Future Appointments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NO_ACCESS_TO_URL}"

JD-TC-GetFutureAppointment-UH2

    [Documentation]  Get consumer's future appointments without consumer login
    
    ${resp}=  Get Consumer Future Appointments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetFutureAppointment-UH3

    [Documentation]  Get consumer's future appointments when today date given.
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${pid1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Future Appointments    date-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}     ${INCORRECT_DATE}



