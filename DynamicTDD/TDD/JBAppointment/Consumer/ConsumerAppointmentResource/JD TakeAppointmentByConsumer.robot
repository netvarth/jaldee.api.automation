*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}




*** Test Cases ***

JD-TC-Take Appointment-1

    [Documentation]  Consumer takes appointment for a valid Provider

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_B}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    clear_appt_schedule   ${PUSERNAME_B}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

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

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-2

    [Documentation]  Consumer takes appointment with AppointmentMode is ONLINE Appointment
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
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

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY3}=  db.add_timezone_date  ${tz}  3  
    ${cnote}=   FakerLibrary.name
    ${resp}=    Take Appointment with ApptMode For Provider    ${appointmentMode[2]}   ${pid}  ${s_id2}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}  appointmentMode=${appointmentMode[2]}    uid=${apptid2}  appmtDate=${DAY3}  appmtTime=${slot3}  
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY3}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot3}

JD-TC-Take Appointment-3

    [Documentation]  Consumer added family member and takes appointment for a valid Provider

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
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
    Set Test Variable   ${slot3}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-UH13

    [Documentation]   able to take duplicate multiple appointments with same account same family member

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${family_fname1}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname1}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname1}  ${family_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
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
    Set Test Variable   ${slot3}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
    
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-Take Appointment-4

    [Documentation]  Consumer cancel an Appointment for a service and consumer takes appointment of the same service and same schedule again

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}
    
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid4}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-5

    [Documentation]   Consumer takes multiple appointments for same service.
   
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
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

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot1}   firstName=${family_fname2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid5}  ${apptid[0]} 

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}  

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid6}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid5}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid6}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-6

    [Documentation]  Add Consumer To future Appointment 

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY3}=   db.add_timezone_date  ${tz}   3
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid7}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY3}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-7

    [Documentation]  Add Consumer's family member To future Appointment 

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}    firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY5}=   db.add_timezone_date  ${tz}   5
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY5}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-8

    [Documentation]   Consumer takes Future appointment for same service in diffrent Appointment Schedule
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   

    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cid}=  get_id  ${CUSERNAME8}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY4}=   db.add_timezone_date  ${tz}   4
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY4}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
    
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY3}=   db.add_timezone_date  ${tz}   3
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY3}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

JD-TC-Take Appointment-9

	[Documentation]  provider have two location, consumer takes Appointment with same service in different Location
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_X}=  Evaluate  ${PUSERNAME}+5566078
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_X}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_X}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_X}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_X}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_X}${\n}
    Set Suite Variable  ${PUSERNAME_X}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_X}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_X}+25566122
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_X}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME_X}
    clear_location  ${PUSERNAME_X}
    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid01}=  get_acc_id  ${PUSERNAME_X}
    Set Suite Variable   ${pid01}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  5  00  
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME_X}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}   ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id11}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id11}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_time   ${sTime1}  ${delta}
    ${eTime1}=  add_timezone_time  ${tz}  4  15  

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id21}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id21}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cid}=  get_id  ${CUSERNAME9}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s1}  ${sch_id11}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id11}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]} 
    
    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l2}

JD-TC-Take Appointment-10

    [Documentation]  same family member takes Appointment with  diffrent service and different Appointment Schedule

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable   ${phno}    ${resp.json()['primaryPhoneNumber']}
    ${cid}=  get_id  ${CUSERNAME4}   

    ${family_fname1}=  FakerLibrary.first_name
    ${family_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname1}  ${family_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname1}
    ${apptfor}=   Create List  ${apptfor1}
  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s1}  ${sch_id11}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor2}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}    firstName=${family_fname1}
    ${apptfor2}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${DAY1}  ${cnote}   ${apptfor2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]} 
    
    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id11}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1} 

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l2}

JD-TC-Take Appointment-11
    [Documentation]  same family member takes Appointment with same service and diffrent Appointment Schedule
    
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable   ${phno}    ${resp.json()['primaryPhoneNumber']}
    ${cid}=  get_id  ${CUSERNAME11}   

    ${family_fname1}=  FakerLibrary.first_name
    ${family_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname1}  ${family_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname1}
    ${apptfor}=   Create List  ${apptfor1}
  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id11}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor2}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}    firstName=${family_fname1}
    ${apptfor2}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${DAY1}  ${cnote}   ${apptfor2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]} 
    
    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id11}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1} 

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l2}

JD-TC-Take Appointment-12
    [Documentation]  Consumer takes future Appointment with diffrent location, same service and same provider

    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable   ${phno}    ${resp.json()['primaryPhoneNumber']}
    ${cid}=  get_id  ${CUSERNAME22}   

    ${family_fname1}=  FakerLibrary.first_name
    ${family_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname1}  ${family_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${FUT_DAY}=  db.add_timezone_date  ${tz}  4  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${FUT_DAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor2}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}    firstName=${family_fname1}
    ${apptfor2}=   Create List  ${apptfor2}
    
    ${FUT_DAY1}=  db.add_timezone_date  ${tz}  5  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${FUT_DAY1}  ${cnote}   ${apptfor2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]} 
    
    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${FUT_DAY}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l2} 

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${FUT_DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l2}

JD-TC-Take Appointment-13
    [Documentation]  Consumer takes future Appointment then cancel and again add for same service

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable   ${phno}    ${resp.json()['primaryPhoneNumber']}
    ${cid}=  get_id  ${CUSERNAME13}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}   
    ${apptfor}=   Create List  ${apptfor1}
    
    ${FUT_DAY}=  db.add_timezone_date  ${tz}  5  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id11}  ${FUT_DAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    sleep  2s
    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}
 
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}   
    ${apptfor}=   Create List  ${apptfor1}
    
    ${FUT_DAY}=  db.add_timezone_date  ${tz}  5  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id11}  ${FUT_DAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${phno}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id11}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${f_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${l_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${FUT_DAY}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1} 

JD-TC-Take Appointment-14
    [Documentation]  Consumer takes an appointment for service with prepayment, and then takes same appt again for same service

    ${billable_providers}=    Billable Domain Providers   min=55   max=65
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Account Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Take Appointment-15
    [Documentation]  Consumer takes an appointment for consumer and 2 family members, and then takes same appt again for same service with 1 family member

    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    
    
    ${pid}=  get_acc_id  ${billable_providers[3]}
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    clear_appt_schedule   ${billable_providers[3]}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=40  max=80
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${id}=  get_id  ${CUSERNAME10}
    clear_FamilyMember  ${id}
    
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${mem_fname1}=  FakerLibrary.first_name
    ${mem_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${mem_fname1}  ${mem_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${fmem1}   ${resp.json()}

    ${mem_fname2}=  FakerLibrary.first_name
    ${mem_lname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${mem_fname2}  ${mem_lname2}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${fmem2}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  user=${fmem1}  parent=${jdconID}
    # Verify Response List  ${resp}  1  user=${fmem2}  parent=${jdconID}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${random slots}=  Evaluate  random.sample(${slots},5)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}
    Set Test Variable   ${slot3}   ${random slots[2]}
    Set Test Variable   ${slot4}   ${random slots[3]}
    Set Test Variable   ${slot5}   ${random slots[4]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot2}   firstName=${mem_fname1}
    ${apptfor3}=  Create Dictionary  id=${fmem2}   apptTime=${slot3}   firstName=${mem_fname2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}  ${apptfor3}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid1}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}
    ${mem2_apptid1}=  Get From Dictionary  ${resp.json()}  ${mem_fname2}
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid1}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem2_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem2_apptid1}   appmtDate=${DAY1}   appmtTime=${slot3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot4}
    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot5}   firstName=${mem_fname1}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid2}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot4}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid2}   appmtDate=${DAY1}   appmtTime=${slot5}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot5}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem2_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Take Appointment-16
    [Documentation]  Consumer takes an appointment for consumer and 1 family member, and then takes same appt again for same service with 2 family members
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    
    ${pid}=  get_acc_id  ${billable_providers[3]}
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    clear_appt_schedule   ${billable_providers[3]}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=40  max=80
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${id}=  get_id  ${CUSERNAME10}
    clear_FamilyMember  ${id}
    
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${mem_fname1}=  FakerLibrary.first_name
    ${mem_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${mem_fname1}  ${mem_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${fmem1}   ${resp.json()}

    ${mem_fname2}=  FakerLibrary.first_name
    ${mem_lname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${mem_fname2}  ${mem_lname2}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${fmem2}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  user=${fmem1}  parent=${jdconID}
    # Verify Response List  ${resp}  1  user=${fmem2}  parent=${jdconID}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${random slots}=  Evaluate  random.sample(${slots},5)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}
    Set Test Variable   ${slot3}   ${random slots[2]}
    Set Test Variable   ${slot4}   ${random slots[3]}
    Set Test Variable   ${slot5}   ${random slots[4]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot2}   firstName=${mem_fname1}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid1}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid1}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot4}   firstName=${mem_fname1}
    ${apptfor3}=  Create Dictionary  id=${fmem2}   apptTime=${slot5}   firstName=${mem_fname2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}    ${apptfor3}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid2}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}
    ${mem2_apptid2}=  Get From Dictionary  ${resp.json()}  ${mem_fname2}
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid2}   appmtDate=${DAY1}   appmtTime=${slot4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot4}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem2_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem2_apptid2}   appmtDate=${DAY1}   appmtTime=${slot5}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot5}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Take Appointment-17
    [Documentation]  Consumer takes an appointment for consumer and 1 family member, and then takes same appt again for same service just for family member alone
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    clear_appt_schedule   ${billable_providers[3]}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=40  max=80
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${id}=  get_id  ${CUSERNAME10}
    clear_FamilyMember  ${id}
    
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${mem_fname1}=  FakerLibrary.first_name
    ${mem_lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${mem_fname1}  ${mem_lname1}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${fmem1}   ${resp.json()}

    ${resp}=  ListFamilyMember
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  user=${fmem1}  parent=${jdconID}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${random slots}=  Evaluate  random.sample(${slots},3)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}
    Set Test Variable   ${slot3}   ${random slots[2]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot2}   firstName=${mem_fname1}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid1}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid1}   appmtDate=${DAY1}   appmtTime=${slot2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${fmem1}   apptTime=${slot3}   firstName=${mem_fname1}
    ${apptfor}=   Create List  ${apptfor2}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${mem1_apptid2}=  Get From Dictionary  ${resp.json()}  ${mem_fname1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${mem1_apptid2}   appmtDate=${DAY1}   appmtTime=${slot3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${mem_fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${mem_lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${mem1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Take Appointment-UH1
	[Documentation]  Consumer takes an appointment for the Same Services Two Times

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pidUH1}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH1}
    ${cid5}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid5}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}
    ${resp}=   Get Location ById  ${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz2}  ${resp.json()['timezone']}
    clear_appt_schedule   ${PUSERNAME76}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cnote}=   FakerLibrary.word
    Set Suite Variable   ${cnote}
    ${resp}=   Take Appointment For Provider   ${pidUH1}  ${p1_s1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pidUH1}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid5}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1}

    ${resp}=   Take Appointment For Provider   ${pidUH1}  ${p1_s1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${APPOINTMET_AlREADY_TAKEN}" 

    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${pidUH1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Take Appointment-UH2
	[Documentation]  Consumer takes an appointment for the service but that service is not in Appoinment Schedule
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    clear_appt_schedule   ${PUSERNAME76}

    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}
    ${resp}=   Get Location ById  ${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz2}  ${resp.json()['timezone']}

    ${pidUH1}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH1}
    ${cid5}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid5}
    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=   FakerLibrary.name
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_idUH2}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_idUH2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_idUH2}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_idUH2}  ${DAY1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_idUH2}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH1}  ${p1_s2}  ${sch_idUH2}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${SERVICE_NOT_AVAILABLE_IN_SCHEDULE}"

JD-TC-Take Appointment-UH3
	[Documentation]  Consumer trying to take an Appointment ,When Provider is in holiday
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}
    ${resp}=   Get Location ById  ${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz2}  ${resp.json()['timezone']}
    
    ${pidUH1}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH1}
    ${cid5}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid5}
    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    clear_appt_schedule   ${PUSERNAME76}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_idUH3}  ${resp.json()}


    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    
    ${resp}=  Get Appointment Schedule ById  ${sch_idUH3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_idUH3}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_idUH3}  ${DAY1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_idUH3}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH1}  ${p1_s1}  ${sch_idUH3}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  424
    Should Be Equal As Strings  "${resp.json()}"      "${APPOINTMET_SLOT_NOT_AVAILABLE}"

JD-TC-Take Appointment-UH4
	[Documentation]  Consumer trying to take an Appointment, Service DISABLED
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${PUSERNAME76}

    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}
    ${resp}=   Get Location ById  ${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz2}  ${resp.json()['timezone']}
    
    ${pidUH1}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH1}
    ${cid5}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid5}
    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_idUH4}  ${resp.json()}

    ${resp}=  Disable service   ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Schedule ById  ${sch_idUH4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_idUH4}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_idUH4}  ${DAY1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_idUH4}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH1}  ${p1_s1}  ${sch_idUH4}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${SERVICE_NOT_AVAILABLE_IN_SCHEDULE}"


JD-TC-Take Appointment-UH5
	[Documentation]  Consumer takes an appointment, But Appointment Disabled  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${pidUH5}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH1}
    ${cid5}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid5}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    
    clear_appt_schedule   ${PUSERNAME76}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}   ${s_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_idUH5}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_idUH5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_idUH5}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Disable Appointment Schedule  ${sch_idUH5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_idUH5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_idUH5}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_idUH5}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_idUH5}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH5}  ${s_id}  ${sch_idUH5}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${SCHEDULE_DISABLED}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Enable Appointment Schedule   ${sch_idUH5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Take Appointment-UH6
    [Documentation]  Consumer trying to take future Appointment, But Future appointment is Disable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}
    clear_appt_schedule   ${PUSERNAME76}

    ${pidUH7}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH7}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[1]}

    ${resp}=   Disable Future Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[0]}

    clear_appt_schedule   ${PUSERNAME76}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${DAY3}=  db.add_timezone_date  ${tz}  5   
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}     

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH7}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${FUTURE_APPOINTMET_DISABLED}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Enable Future Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Take Appointment-UH7
    [Documentation]  Consumer trying to take Today Appointment, But Today appointment is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pidUH8}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH8}
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}
    clear_appt_schedule   ${PUSERNAME76}

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

    ${resp}=   Disable Today Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[0]} 

    clear_appt_schedule   ${PUSERNAME76} 

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}   

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH8}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${TODAY_APPOINTMET_DISABLED}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Enable Today Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Take Appointment-UH8
	[Documentation]  Consumer takes an appointment but provider disable Appointment Schedule
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pidUH6}=  get_acc_id  ${PUSERNAME76}
    Set Suite Variable   ${pidUH6}
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME76}
    clear_location  ${PUSERNAME76}
    clear_appt_schedule   ${PUSERNAME76}

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

    ${resp}=   Disable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}

    # clear_appt_schedule   ${PUSERNAME76}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}         

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pidUH6}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${APPT_NOT_ENABLED}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
  
JD-TC-Take Appointment-UH9
	[Documentation]  Passing Invalid provider in the Take an appointment
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid2}=  get_acc_id  ${Invalid_CUSER}
    ${pid3}=  get_acc_id  ${PUSERNAME104}
    Set Suite Variable   ${pid3}
    ${cid4}=  get_id  ${CUSERNAME4}

    clear_service   ${PUSERNAME104}
    clear_location  ${PUSERNAME104}
    clear_appt_schedule   ${PUSERNAME104}

    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    reset_queue_metric  ${pid3}

    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}

    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${Empty}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}   

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

	${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid2}  ${p1_s1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  "${resp.json()}"   "${ACCOUNT_NOT_EXIST}"    
    Should Be Equal As Strings  ${resp.status_code}  404

JD-TC-Take Appointment-UH10    
    [Documentation]   Consumer trying to take an Appointment without login

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid3}  ${p1_s1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Take Appointment-UH11
    [Documentation]  Consumer takes an appointment, When provider location Disabled  
    
    clear_service   ${PUSERNAME77}
    clear_location  ${PUSERNAME77}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid_11}=  get_acc_id  ${PUSERNAME77}
    ${cid4}=  get_id  ${CUSERNAME4}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    reset_queue_metric  ${pid_11}

    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}
    ${resp}=   Get Location ById  ${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz2}  ${resp.json()['timezone']}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${PUSERNAME77}

    ${resp}=  Disable Location  ${p1_l2}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    Set Suite Variable   ${DAY2}   
 
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${Empty}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l2}  ${duration}  ${bool1}   ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid_11}  ${p1_s1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Enable Location  ${p1_l2}                                          
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

JD-TC-Take Appointment-UH12
    [Documentation]   Consumer takes an Appointment, When non scheduled day
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_W}=  Evaluate  ${PUSERNAME}+5566045
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_W}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_W}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_W}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_W}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_W}${\n}
    Set Suite Variable  ${PUSERNAME_W}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${pid_12}=  get_acc_id  ${PUSERNAME_W}
    ${cid4}=  get_id  ${CUSERNAME4}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_W}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_W}+25566122
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_W}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    clear_service   ${PUSERNAME_W}
    clear_location  ${PUSERNAME_W}
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}

    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  3   15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    Set Suite Variable   ${bool1}
    ${list}=  Create List  1  2  3  4  5  6
    Set Suite Variable   ${list}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    Set Suite Variable   ${DAY2}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}   ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    FOR   ${i}  IN RANGE   1   3
        ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
        ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
        Continue For Loop If   '${DAYQ_weekday}' == '7'
        Exit For Loop If  '${DAYQ_weekday}' != '7'
    END
    # ${DAYQ}=  db.add_timezone_date  ${tz}  2       
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAYQ}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor1}  
   
    ${resp}=  ProviderLogout    
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable   ${phno02}    ${resp.json()['primaryPhoneNumber']}

    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}        

    ${curr_weekday}=  get_timezone_weekday  ${tz}
    ${daygap}=  Evaluate  7-${curr_weekday}
    ${DAYUH12}=  db.add_timezone_date  ${tz}  ${daygap}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid_12}  ${p1_s1}  ${sch_id1}  ${DAYUH12}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPOINTMET_SLOT_NOT_AVAILABLE}" 


JD-TC-Take Appointment-18
    [Documentation]  consumer takes appt for a slot with another appt taken by provider when parallen serving >1
    ${billable_providers}=    Billable Domain Providers   min=90   max=100
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    # ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    Set Test Variable  ${accountId1}  ${resp.json()['accountId']}

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=    FakerLibrary.Word
    ${min_pre}=   Random Int   min=10   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Account Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=2  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME25}  firstName=${fname1}  lastName=${lname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount
    ${min_pre}=  Convert To Number  ${min_pre}  1
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    
    sleep   1s
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    FOR   ${i}  IN RANGE   0   ${num_slots}
        Run Keyword If  '${resp.json()['availableSlots'][${i}]['time']}' == '${slot1}' 
        ...   Run Keywords  
        ...   Set Test Variable   ${slot2}    ${resp.json()['availableSlots'][${i}]['time']}   
        ...   AND  Exit For Loop
    END
    # ${j}=  Random Int  max=${num_slots-1}
    
    # Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # # Set Test Variable   ${slot1}   ${Keys[0]}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}  apptStatus=${apptStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}  ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}  ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}  ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid2}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid2}  ${pid} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}  
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  
    
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    sleep  2s
    ${resp}=  Get Appointments Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[1]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   paymentStatus-eq=${paymentStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Take Appointment-19
    [Documentation]  Consumer takes appointment for a valid Provider with different phone number for notification
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME149}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}
    
    clear_service   ${PUSERNAME149}
    clear_location  ${PUSERNAME149}
    clear_customer   ${PUSERNAME149}
    clear_appt_schedule   ${PUSERNAME149}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=    Get Appmt Service By LocationId   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${apptTime}=  db.get_tz_time_secs  ${tz} 
    ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
    ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH7}=  Evaluate  ${CUSERNAME7}+${PO_Number}
    ${resp}=   Take Appointment For Provider with Phone no   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${CUSERPH7}  ${apptfor}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Take Appointment-20
    [Documentation]  Consumer takes appointment for a branch

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}
    
    clear_service   ${PUSERNAME72}
    clear_location  ${PUSERNAME72}
    clear_customer   ${PUSERNAME72}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    clear_appt_schedule   ${PUSERNAME72}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${DAY3}=  db.add_timezone_date  ${tz}  4  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=    Get Appmt Service By LocationId   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Take Appointment-21
    [Documentation]  Consumer takes appointment for a user

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${P_Sector}  ${decrypted_data['sector']}
    # Set Test Variable  ${P_Sector}   ${resp.json()['sector']}

    clear_Department    ${PUSERNAME72}
    clear_service   ${PUSERNAME72}
    # clear_location  ${PUSERNAME72}
    # clear_customer   ${PUSERNAME72}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${BUSERPH0}=  Evaluate  ${PUSERNAME}+${dep_code1}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    # Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}

    ${number}=  Random Int  min=1000  max=2000
    ${whpnum}=  Evaluate  ${BUSERPH0}+${number}
    ${number}=  Random Int  min=1000  max=2000
    ${tlgnum}=  Evaluate  ${BUSERPH0}+${number}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${length}=  Get Length  ${iscorp_subdomains}
    FOR  ${i}  IN RANGE  ${length}
        Set Suite Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
        Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
        Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
        Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
    END

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${BUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${BUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    
    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
	
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}

    # ${lid}=  Create Sample Location  

    clear_appt_schedule   ${PUSERNAME72}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=    Get Appmt Service By LocationId   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${u_id}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Take Appointment-UH14

    [Documentation]  Consumer takes appointment for a valid Provider

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+5566054
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_D}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566165
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566165
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_D}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    clear_service   ${PUSERNAME_D}
    clear_location  ${PUSERNAME_D}    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME_D}
    Set Suite Variable   ${pid}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    clear_appt_schedule   ${PUSERNAME_D}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

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

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
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

    ${cid}=  get_id  ${CUSERNAME9}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
   
    # ${f_Name1}=   FakerLibrary.name
    # ${l_Name2}=   FakerLibrary.name
    ${alternativeNo} =    FakerLibrary.Phone Number
    ${email12} =  FakerLibrary.email
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob12}=  FakerLibrary.Date
   
    ${resp}=   Update Consumer Profile     ${f_Name}     ${lastname}    ${address}       ${dob12}   ${Genderlist[1]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"

JD-TC-Take Appointment-UH15
    [Documentation]  Two Consumer takes future Appointments, Provider parallelServing is one.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_appt_schedule   ${PUSERNAME_X}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${p1_s1}
    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${p1_s2}
    ${p1_l1}=  Create Sample Location
    Set Suite Variable   ${p1_l1}
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${pid01}=  get_acc_id  ${PUSERNAME_X}
    Set Suite Variable   ${pid01}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}   ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id21}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id11}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id11}   name=${schedule_name}  apptState=${Qstate[0]}
    
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # # ${eTime1}=  add_time   ${sTime1}  ${delta}
    # ${eTime1}=  add_timezone_time  ${tz}  4  15  

    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${DAY2}=  db.add_timezone_date  ${tz}  10       
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sch_id21}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id21}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cid}=  get_id  ${CUSERNAME11}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
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
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s1}  ${sch_id21}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY3}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id21}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${f_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${l_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1}


    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cid}=  get_id  ${CUSERNAME10}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
        #     Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        # END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${slot1}   ${slots[${j}]}

    # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}

    ${DAY3}=  db.add_timezone_date  ${tz}  5  
    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s1}  ${sch_id21}  ${DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  424
    Should Be Equal As Strings  ${resp.json()}  ${APPOINTMET_SLOT_NOT_AVAILABLE}
          
    # ${apptid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=   Get consumer Appointment By Id   ${pid01}  ${apptid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY3}   appmtTime=${slot1}
  
*** Comments ***

JD-TC-Take Appointment-22
    [Documentation]  International Consumer takes appointment for a provider


JD-TC-Take Appointment-23
    [Documentation]  International Consumer takes appointment for a branch


JD-TC-Take Appointment-24
    [Documentation]  International Consumer takes appointment for a user




