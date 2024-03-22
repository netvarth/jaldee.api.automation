*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Schedule Slots
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py



*** Variables ***

${SERVICE1}  Consultation 
${SERVICE2}  Scanning

${self}     0
${Empty_list}  []
${def_sch_id}     1
${def_sch_name}   Schedule 1



*** Test Cases ***    

JD-TC-GetNextAvailableAppointmentSlotByConsumer-1

    [Documentation]   When provider create appointment schedules
    
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5563098
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable  ${PUSERNAME_B_id}   ${accId}

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    # ${resp}=   Get Service
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    ${p1_s2}=  Create Sample Service  ${SERVICE2}

    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}
    Set Suite Variable  ${P1_sch_name1}  ${resp.json()['name']}
    Set Suite Variable  ${list}          ${resp.json()['apptSchedule']['repeatIntervals']}
    Set Suite Variable  ${DAY1}          ${resp.json()['apptSchedule']['startDate']}
    Set Suite Variable  ${DAY2}          ${resp.json()['apptSchedule']['terminator']['endDate']}
    Set Suite Variable  ${sTime1}        ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${eTime1}        ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${p1_s2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}
    Set Suite Variable  ${P1_sch_name2}  ${resp.json()['name']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetNextAvailableAppointmentSlotByConsumer-2

    [Documentation]   When provider Disable appointment schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME_B}

    ${resp}=  Disable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetNextAvailableAppointmentSlotByConsumer-3

    [Documentation]   When provider Enable Disabled appointment schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accId}=  get_acc_id  ${PUSERNAME_B}

    ${resp}=  Enable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetNextAvailableAppointmentSlotByConsumer-4

    [Documentation]   When same provider try to get his own Appointment Schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Enable Appointment Schedule  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}  ${PUSERNAME_B_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${sch_id1}     name=${P1_sch_name1}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${PUSERNAME_B_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  id=${sch_id2}     name=${P1_sch_name2}   apptState=${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}   ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
   

JD-TC-GetNextAvailableAppointmentSlotByConsumer-UH1

    [Documentation]   Get Appointment without consumer login

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${PUSERNAME_B_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetNextAvailableAppointmentSlotByConsumer-UH3

    [Documentation]   A provider try to get Appointment Schedules of another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}  ${PUSERNAME_B_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
