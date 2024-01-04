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
${digits}       0123456789
${self}        0

*** Test Cases ***

JD-TC-GetFutureAppointment-1

    [Documentation]  Get consumer's future appointments.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Q}=  Evaluate  ${PUSERNAME}+5566030
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_Q}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Q}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Q}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Q}${\n}
    Set Suite Variable  ${PUSERNAME_Q}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_Q}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_Q}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_Q}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_Q}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['enableAppt']}==${bool[0]}
        ${resp1}=  Enable Appointment
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${pid1}=  get_acc_id  ${PUSERNAME_Q}
    Set Suite Variable   ${pid1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    # Set Suite Variable   ${lid}
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id11}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id11}   name=${schedule_name}  apptState=${Qstate[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot11}   ${slots[${j}]}
    
    ${resp}=  AddCustomer  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot11}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid11}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid11}
    Log   ${resp.json()}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME25}
    Set Suite Variable   ${cid1}
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid1}
    Log   ${resp.json()}
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
    
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable   ${DAY2}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}
    
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

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot2}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot2}   firstName=${family_fname2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable   ${DAY3}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${family_fname3}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname3}
    ${family_lname3}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname3}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname3}  ${family_lname3}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor3}   ${resp.json()}

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot3}   ${slots[${j}]}
    
    ${apptfor}=  Create Dictionary  id=${cidfor3}   apptTime=${slot3}   firstName=${family_fname3}
    ${apptfor}=   Create List  ${apptfor}
    
    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable   ${DAY4}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot4}   ${slots[${j}]}
    
    ${apptfor}=  Create Dictionary  id=${self}   apptTime=${slot4}
    ${apptfor4}=   Create List  ${apptfor}
  
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id2}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['firstName']}' == '${f_Name}'
        ...   Set Suite Variable   ${cons_id1}   ${resp.json()[${i}]['id']}
        ...    ELSE IF     '${resp.json()[${i}]['firstName']}' == '${family_fname2}' 
        ...   Set Suite Variable   ${cons_id2}   ${resp.json()[${i}]['id']}
        ...    ELSE IF     '${resp.json()[${i}]['firstName']}' == '${family_fname3}' 
        ...   Set Suite Variable   ${cons_id3}   ${resp.json()[${i}]['id']}
    END

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid1}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid1}   

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid2}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid2} 

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid3}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid3} 

    ${resp}=   Get Appointment EncodedID    ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid4}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid4} 

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=    Get Consumer Future Appointments  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}   
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id3}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
    
    END

JD-TC-GetFutureAppointment-2

    [Documentation]  Get consumer's future appointments for multiple providers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid2}=  get_acc_id  ${PUSERNAME182}
    Set Suite Variable   ${pid2}
    clear_service   ${PUSERNAME182}
    clear_location  ${PUSERNAME182}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid2}=  Create Sample Location
    Set Suite Variable   ${lid2}

    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE3}=   FakerLibrary.name
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}

    ${DAY22}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY22}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id4}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id4}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules Consumer  ${pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id4}   ${pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id4}   ${pid2}
    Log   ${resp.json()}
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
    Set Suite Variable   ${apptfor}
    
    ${DAY5}=  db.add_timezone_date  ${tz}   5
    Set Suite Variable   ${DAY5}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid2}  ${s_id3}  ${sch_id4}  ${DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid5}  ${apptid[0]}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id2}   ${resp.json()[0]['id']}

    ${resp}=   Get Appointment EncodedID    ${apptid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid5}=  Set Variable   ${resp.json()}
    Set Suite Variable   ${A_uuid5} 

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  4

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid5}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid5}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY5}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id4}
    
    END

JD-TC-GetFutureAppointment-3

	[Documentation]  Filter future Appointment by service id.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments    service-eq=${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid2}'  
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}
    END
 
JD-TC-GetFutureAppointment-4

	[Documentation]  Filter future Appointment by appointmentEncId.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid5}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY5}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot4}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid5}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id4}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   appointmentEncId-eq=${A_uuid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}     []

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0

JD-TC-GetFutureAppointment-5

	[Documentation]  Filter future Appointment by first name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   firstName-eq=${f_Name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        # ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        # ...    Run Keywords
        # ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        # ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        # ...    Run Keywords
        # ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}       
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid5}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid5}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY5}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id4}
    
    END

JD-TC-GetFutureAppointment-6

	[Documentation]  Filter future Appointment by last name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Consumer Future Appointments   lastName-eq=${l_Name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        # ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        # ...    Run Keywords
        # ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        # ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        # ...    Run Keywords
        # ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}       
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        # ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid5}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid5}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY5}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id4}
    
    END

JD-TC-GetFutureAppointment-7

	[Documentation]  Filter future Appointment by schedule id.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   schedule-eq=${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   schedule-eq=${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid5}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY5}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot4}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid5}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id4}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-8

	[Documentation]  Get consumer's future appointments where appointment taken by consumer(apptBy).

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   apptBy-eq=CONSUMER
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  4

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id3}

        ...   ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid3}' 
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid5}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY5}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot4}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id4}
    
    END

JD-TC-GetFutureAppointment-9

	[Documentation]  Filter consumer future appointmens by appointment time.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   apptTime-eq=${slot1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Future Appointments   apptTime-eq=${slot3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY4}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id3}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-10

	[Documentation]  Filter consumer future Appointments by paymentstatus(partially paid).

    ${billable_doms}=  get_billable_domain
    Log  ${billable_doms}
    Set Suite Variable  ${dom}  ${billable_doms[0][0]}
    Set Suite Variable  ${sub_dom}  ${billable_doms[1][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5566031
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_C}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_C}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY2}=  db.add_timezone_date  ${tz}  9      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  5  00  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${prov_id}=  get_acc_id  ${PUSERNAME_C}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${loc_id1}=  Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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

    clear_appt_schedule   ${PUSERNAME_C}

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
    Log   ${resp.json()}
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

    ${resp}=  Get Appointment Schedule ById  ${schedule_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${schedule_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${prov_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${schedule_id1}   ${prov_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${schedule_id1}   ${prov_id}
    Log   ${resp.json()}
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

    ${DAY6}=  db.add_timezone_date  ${tz}   6
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
   
    ${resp}=  Make payment Consumer Mock  ${prov_id}  ${min_pre}  ${purpose[0]}  ${apptid6}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid6}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id3}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment EncodedID   ${apptid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId21}=  Set Variable   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   paymentStatus-eq=${paymentStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${encId21}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id3}
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

JD-TC-GetFutureAppointment-11

	[Documentation]  Filter consumer future Appointments by location.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   location-eq=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['id']}                      ${cons_id1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id1}

        ...    ELSE IF     '${resp.json()[${i}]['uid']}' == '${apptid2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['appointmentEncId']}                       ${A_uuid2}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmentMode']}                        ${appointmentMode[2]}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptStatus']}                             ${apptStatus[1]}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtDate']}                              ${DAY3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['appmtTime']}                              ${slot2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['apptBy']}                                 CONSUMER
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['paymentStatus']}                          ${paymentStatus[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['firstName']}   ${f_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['consumer']['userProfile']['lastName']}    ${l_Name}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['location']['id']}                         ${lid}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['service']['id']}                          ${s_id2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['schedule']['id']}                         ${sch_id2}

    END
   
JD-TC-GetFutureAppointment-12

	[Documentation]  Filter consumer future Appointments by appointment start time.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${slot1_time}=  Get Substring   ${slot1}  0  5

    ${resp}=    Get Consumer Future Appointments   apptstartTime-eq=${slot1_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-13

	[Documentation]  Filter future Appointment by Appointment status Arrived.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[2]}
    Should Contain  "${resp.json()}"  ${apptStatus[2]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-14

	[Documentation]  Filter future Appointment by Appointment status Canceled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid2}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[4]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot2}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id2}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-15

	[Documentation]  Filter future Appointment by Appointment status Rejected.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Reject Appointment  ${apptid3}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}
    Should Contain  "${resp.json()}"  ${apptStatus[5]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   apptStatus-eq=${apptStatus[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid3}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[5]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['jaldeeFamilyMemberId']}    ${cidfor3}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY4}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot3}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid3}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id3}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-16

	[Documentation]  Filter consumer future Appointments by appointment Date.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Consumer Future Appointments   date-eq=${DAY2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}                       ${A_uuid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmentMode']}                        ${appointmentMode[2]}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}                             ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['id']}                      ${cons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}                              ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}                              ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['apptBy']}                                 CONSUMER
    Should Be Equal As Strings  ${resp.json()[0]['paymentStatus']}                          ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${f_Name}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}    ${l_Name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}                         ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                          ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}                         ${sch_id1}
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

JD-TC-GetFutureAppointment-17

    [Documentation]  Get consumer's future appointments with provider login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Q}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${NO_ACCESS_TO_URL}

JD-TC-GetFutureAppointment-18

    [Documentation]  Get consumer's future appointments when today date given.
    
    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Future Appointments    date-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.json()}     ${INCORRECT_DATE}

JD-TC-GetFutureAppointment-UH1

    [Documentation]  Get consumer's future appointments without consumer login
    
    ${resp}=  Get Consumer Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
