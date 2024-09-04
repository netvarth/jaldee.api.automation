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
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  sampleservice1 
${SERVICE2}  sampleservice2
${SERVICE3}  sampleservice3
${digits}       0123456789
${self}          0


*** Test Cases ***

JD-TC-GetAppointmentToday-1

    [Documentation]  Get consumer's appointments Today.

    # ${multilocdoms}=  get_mutilocation_domains
    # Log  ${multilocdoms}
    # Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    # Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${HLPUSERNAME51}=  Evaluate  ${PUSERNAME}+5566013
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${HLPUSERNAME51}    ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${HLPUSERNAME51}  0
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${HLPUSERNAME51}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${HLPUSERNAME51}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${HLPUSERNAME51}${\n}
    Set Suite Variable  ${HLPUSERNAME51}
    # Set Suite Variable  ${HLPUSERNAME51}   ${PUSERNAME136}
    # ${resp}=  Encrypted Provider Login  ${HLPUSERNAME51}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    # Set Test Variable  ${email_id}  ${P_Email}${HLPUSERNAME51}.${test_mail}

    # ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${HLPUSERNAME51}+15566124
    # ${ph2}=  Evaluate  ${HLPUSERNAME51}+25566128
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${HLPUSERNAME51}.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${companySuffix}=  FakerLibrary.companySuffix
    # # ${city}=   FakerLibrary.state
    # # ${latti}=  get_latitude
    # # ${longi}=  get_longitude
    # # ${postcode}=  FakerLibrary.postcode
    # # ${address}=  get_address

    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  2  45  
    # ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    # Log  ${fields.json()}
    # Should Be Equal As Strings    ${fields.status_code}   200

    # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${spec}=  get_Specializations  ${resp.json()}
    # ${resp}=  Update Specialization  ${spec}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Update Appointment Status   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${pid1}=  get_acc_id  ${HLPUSERNAME51}
    Set Suite Variable   ${pid1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    FOR  ${i}  IN RANGE   5
        ${city1}=   get_place
        Exit For Loop If  '${city1}' != '${city}'
    END
    Set Test Variable  ${city}  ${city1}  
    

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${SERVICE3}=   FakerLibrary.name
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
    
    ${resp}=  AddCustomer  ${CUSERNAME16}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
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

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid1}=  get_id  ${CUSERNAME29}
    # Set Suite Variable   ${cid1}
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${family_fname2}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname2}
    ${family_lname2}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname2}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname2}  ${family_lname2}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor2}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid1}
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
    Set Suite Variable   ${slot2}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot2}   firstName=${family_fname2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${family_fname3}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname3}
    ${family_lname3}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname3}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname3}  ${family_lname3}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor3}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
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
    Set Suite Variable   ${slot3}   ${slots[${j}]}
    
    ${apptfor}=  Create Dictionary  id=${cidfor3}   apptTime=${slot3}   firstName=${family_fname3}
    ${apptfor}=   Create List  ${apptfor}
   
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
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
    Set Suite Variable   ${slot4}   ${slots[${j}]}
    
    ${apptfor}=  Create Dictionary  id=${self}   apptTime=${slot4}   
    ${apptfor}=   Create List  ${apptfor}
  
    ${DAY5}=  db.add_timezone_date  ${tz}   5
    Set Suite Variable   ${DAY5}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME51}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['firstName']}' == '${f_Name}'
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

    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=    Get Consumer Appointments Today  
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
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
            Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}  
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}           
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
            Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
            Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
            Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
            Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
        END
    END