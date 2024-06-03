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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py

*** Variables ***

${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
# ${countryCode}   +91
${US_CC}   +1
${UAE_CC}   +971
${AE_tz}   Asia/Dubai

*** Keywords ***


# Consumer Login 
#     [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91   &{kwargs}  
#     ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}

#     FOR    ${key}    ${value}    IN    &{kwargs}
#         Set To Dictionary 	${cons_headers} 	${key}=${value}
#     END
#     # Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
#     ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}



*** Test Cases ***

JD-TC-Take Appointment in Different Timezone-1

	[Documentation]  provider have two location other than base location, consumer takes Appointment for same service in different Locations
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Test Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Test Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_X}=  Evaluate  ${PUSERNAME}+5566078
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_X}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_X}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_X}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_X}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_X}${\n}
    Set Test Variable  ${PUSERNAME_X}

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
    ${city}=   FakerLibrary.City
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${tz}  
    ${eTime}=  db.add_timezone_time  ${tz}  0  15  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.content}
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
    # clear_service   ${PUSERNAME_X}
    # clear_location  ${PUSERNAME_X}
    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Test Variable  ${lic2}  ${highest_package[0]}
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
    Set Test Variable   ${pid01}
    
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        

    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=   FakerLibrary.name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}
    Set Test Variable   ${p1_s1}

    ${SERVICE2}=   FakerLibrary.name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}
    Set Test Variable   ${p1_s2}

    ${p1_l1}=  Create Sample Location
    Set Test Variable   ${p1_l1}

    ${resp}=   Get Location By Id   ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  5  00  
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}=  FakerLibrary.latitude
    ${longi}=  FakerLibrary.longitude
    ${latti}=  Convert To String  ${latti} 
    ${longi}=  Convert To String  ${longi} 
    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz2}

    ${DAY1}=  db.get_date_by_timezone  ${tz2}
    ${DAY2}=  db.add_timezone_date  ${tz2}  10     
    ${sTime1}=  add_timezone_time  ${tz2}  0  30  
    ${eTime1}=  add_timezone_time  ${tz2}  1  00  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l2}  ${resp.json()}

    # clear_appt_schedule   ${PUSERNAME_X}

    ${DAY3}=  db.get_date_by_timezone  ${tz1}
    ${DAY4}=  db.add_timezone_date  ${tz1}  10  
    ${sTime2}=  add_timezone_time  ${tz1}  1  00  
    ${eTime2}=  add_timezone_time  ${tz1}  1  30  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}   ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id11}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id11}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id11}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${sTime3}=  add_timezone_time  ${tz2}  0  30
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_time   ${sTime1}  ${delta}
    ${eTime3}=  add_two   ${sTime3}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz2}
    ${DAY2}=  db.add_timezone_date  ${tz2}  10       
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id21}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id21}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Consumer Login   ${CUSERNAME9}  ${PASSWORD}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    ${cid}=  get_id  ${CUSERNAME9}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id11}   ${pid01}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id11}   ${pid01}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id11}    ${DAY3}   ${pid01}    location=${{str('${p1_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response  ${resp}  scheduleId=${sch_id11}
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
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s1}  ${sch_id11}  ${DAY3}  ${cnote}   ${apptfor}   location=${{str('${p1_l1}')}}
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
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id11}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${p1_l1}


    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id21}   ${pid01}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id21}   ${pid01}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id21}    ${DAY1}   ${pid01}    location=${{str('${p1_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response  ${resp}  scheduleId=${sch_id21}
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
    # ${{len('${VAR}')}}
    ${resp}=   Take Appointment For Provider   ${pid01}  ${p1_s2}  ${sch_id21}  ${DAY1}  ${cnote}   ${apptfor}   location=${{str('${p1_l2}')}}
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



JD-TC-Take Appointment in Different Timezone-2
    [Documentation]   take appointment for providers in different timezones with multiple timezone locations per provider

    ############################## US ##############################
    Comment  Provider in US
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${USProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${US_CC}=  Set Variable  ${Number.country_code}
    ${USProvider}=  Set Variable  ${Number.national_number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${US_P_Email}  Set Variable  ${P_Email}${USProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${US_P_Email}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}  countryCode=${US_CC}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${US_P_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${US_P_Email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}  countryCode=${US_CC}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${USProvider}+15566122
    ${ph2}=  Evaluate  ${USProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${US_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz_orig}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${US_tz}=  create_tz  ${US_tz_orig}
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${US_P_Email}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    FOR   ${i}  IN RANGE   5
        ${latti1}  ${longi1}  ${city1}  ${country_abbr1}  ${US_tz1_orig}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
        IF  '${US_tz_orig}' == '${US_tz1_orig}'
            Continue For Loop
        ELSE
            Exit For Loop
        END
    END
    ${US_tz1}=  create_tz  ${US_tz1_orig}
    ${address1} =  FakerLibrary.address
    ${postcode1}=  FakerLibrary.postcode
    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${DAY2}=  db.add_timezone_date  ${US_tz1}  10     
    ${sTime1}=  add_timezone_time  ${US_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${US_tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${url}  ${postcode1}  ${address1}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l2}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${p1_s1}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=   FakerLibrary.job
    ${p1_s2}=  Create Sample Service  ${SERVICE2}

    ${DAY3}=  db.get_date_by_timezone  ${US_tz}
    ${DAY4}=  db.add_timezone_date  ${US_tz}  10  
    ${sTime2}=  add_timezone_time  ${US_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${US_tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p1_sch1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${sTime3}=  add_timezone_time  ${US_tz1}  0  30
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_time   ${sTime1}  ${delta}
    ${eTime3}=  add_two   ${sTime3}  ${delta}
    ${sTime3}  ${eTime3}=  db.endtime_conversion  ${sTime3}  ${eTime3}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${DAY2}=  db.add_timezone_date  ${US_tz1}  10       
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sch2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_sch2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p1_sch2}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200


    ############################## UAE ##############################

    Comment  Provider in Middle East (UAE)
    # ${PO_Number}=  FakerLibrary.Numerify  %#######
    # ${MEProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${MEProvider}=  Set Variable  

    # ${Number}=  random_phone_num_generator
    # Log  ${Number}
    # ${CC1}=  Set Variable  ${Number.country_code}
    # ${MEProvider}=  Set Variable  ${Number.national_number}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    ${other_numbers}=   country_code_numbers  ${UAE_CC}
    Log List  ${other_numbers}
    ${unique_numbers}=    Remove Duplicates    ${other_numbers}
    ${MEProvider}=  Evaluate  random.choice($unique_numbers)  random
    # Remove Values From List  ${unique_numbers}  ${MEProvider}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${ME_P_Email}  Set Variable  ${P_Email}${MEProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${ME_P_Email}  ${domain}  ${subdomain}  ${MEProvider}  ${licpkgid}   countryCode=${UAE_CC}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${ME_P_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ME_P_Email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=  Encrypted Provider Login  ${MEProvider}  ${PASSWORD}  countryCode=${UAE_CC}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid1}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${MEProvider}+15566122
    ${ph2}=  Evaluate  ${MEProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${ME_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng  country_code=AE  coords_only=False
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng
    ${AE_tz}=  Set Variable  Asia/Dubai  
    ${DAY}=  db.get_date_by_timezone  ${AE_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${AE_tz}  
    ${eTime}=  db.add_timezone_time  ${AE_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}  timezone=${AE_tz}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng
    # ${AE_tz}=  Set Variable  Asia/Dubai
    # ${latti}=  Set Variable  25.243183780208067
    # ${longi}=  Set Variable  55.480148092471524
    # # ${AE_tz}=  FakerLibrary.Timezone
    # ${address1} =  FakerLibrary.address
    # ${postcode1}=  FakerLibrary.postcode
    # ${DAY1}=  db.get_date_by_timezone  ${AE_tz}
    # ${DAY2}=  db.add_timezone_date  ${AE_tz}  10     
    # ${sTime1}=  add_timezone_time  ${AE_tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${AE_tz}  1  00  
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode1}  ${address1}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  timezone=${AE_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p2_l1}  ${resp.json()}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id2}  ${resp.json()['id']}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${MEProvider}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${fname}  ${lname}   ${ME_P_Email}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}

    ${SERVICE1}=   FakerLibrary.job
    ${p2_s1}=  Create Sample Service  ${SERVICE1}

    ${DAY3}=  db.get_date_by_timezone  ${AE_tz}
    ${DAY4}=  db.add_timezone_date  ${AE_tz}  10  
    ${sTime2}=  add_timezone_time  ${AE_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${AE_tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p2_l1}  ${duration}  ${bool1}  ${p2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p2_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p2_sch1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200


    ############################## INDIA ##############################

    Comment  Provider in India (IN)
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${INProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    Set Test Variable  ${IN_P_Email}  ${P_Email}${INProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${INProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${INProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${INProvider}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=  Encrypted Provider Login  ${INProvider}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid1}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${INProvider}+15566122
    ${ph2}=  Evaluate  ${INProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${IN_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${IN_tz}=  FakerLibrary.Local Latlng  country_code=IN  coords_only=False
    ${DAY}=  db.get_date_by_timezone  ${IN_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${IN_tz}  
    ${eTime}=  db.add_timezone_time  ${IN_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id3}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Email   ${pid1}   ${fname}  ${lname}   ${IN_P_Email}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p3_l1}   ${resp.json()[0]['id']}

    ${SERVICE1}=   FakerLibrary.job
    ${p3_s1}=  Create Sample Service  ${SERVICE1}

    ${DAY3}=  db.get_date_by_timezone  ${IN_tz}
    ${DAY4}=  db.add_timezone_date  ${IN_tz}  10  
    ${sTime2}=  add_timezone_time  ${IN_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${IN_tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p3_l1}  ${duration}  ${bool1}  ${p3_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p3_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p3_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p3_sch1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    # USProvider- acc_id1, US_tz, p1_l1, p1_l2, p1_s1, p1_s2, p1_sch1, p1_sch2, 

    # MEProvider- acc_id2, AE_tz, p2_l1, p2_s1, p2_sch1

    # INProvider- acc_id3, IN_tz, p3_l1, p3_s1, p3_sch1

    ########################### Consumer 1- c1 ###########################
    
    Comment  Consumer 1- c1
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id1}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id1}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # # ${dob}=  FakerLibrary.Date Of Birth   minimum_age=18   maximum_age=55
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${primaryMobileNo}  ${EMPTY}  ${dob}  ${gender}  ${email}  countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${email}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${primaryMobileNo}  ${PASSWORD}   countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ############################## Take appt for USProvider ##############################
    # USProvider- acc_id1, US_tz, p1_l1, p1_l2, p1_s1, p1_s2, p1_sch1, p1_sch2
    
    Comment  Consumer 1- c1- US
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch1}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s1}  ${p1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch2}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch2}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s2}  ${p1_sch2}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c1_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid2}

    ############################## Take appt for MEProvider ##############################
    # MEProvider- acc_id2, AE_tz, p2_l1, p2_s1, p2_sch1

    Comment  Consumer 1- c1- UAE
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id2}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p2_sch1}   ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p2_sch1}   ${acc_id2}
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

    ${DAY1}=  db.get_date_by_timezone  ${AE_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id2}  ${p2_s1}  ${p2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p2_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id2}  ${c1_apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid3}

    ############################## Take appt for INProvider ##############################
    # INProvider- acc_id3, IN_tz, p3_l1, p3_s1, p3_sch1

    Comment  Consumer 1- c1- IN
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p3_sch1}   ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p3_sch1}   ${acc_id3}
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

    ${DAY1}=  db.get_date_by_timezone  ${IN_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id3}  ${p3_s1}  ${p3_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p3_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id3}  ${c1_apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid4}


    ########################### Consumer 2- c2 ###########################

    Comment  Consumer 2- c2
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id1}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id1}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

    # ${address}=  FakerLibrary.address
    # # ${dob}=  FakerLibrary.Date Of Birth   minimum_age=18   maximum_age=55
    # ${gender}    Random Element    ${Genderlist}
    # ${dob}=  FakerLibrary.Date
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${primaryMobileNo}  ${EMPTY}  ${dob}  ${gender}  ${email}  countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${email}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${primaryMobileNo}  ${PASSWORD}   countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ############################## Take appt for USProvider ##############################
    # USProvider- acc_id1, US_tz, p1_l1, p1_l2, p1_s1, p1_s2, p1_sch1, p1_sch2
    
    Comment  Consumer 2- c2- US
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch1}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s1}  ${p1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c2_apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c2_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c2_apptid1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch2}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch2}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s2}  ${p1_sch2}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c2_apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c2_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c2_apptid2}

    ############################## Take appt for MEProvider ##############################
    # MEProvider- acc_id2, AE_tz, p2_l1, p2_s1, p2_sch1

    Comment  Consumer 2- c2- ME

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id2}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p2_sch1}   ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p2_sch1}   ${acc_id2}
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

    ${DAY1}=  db.get_date_by_timezone  ${AE_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id2}  ${p2_s1}  ${p2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p2_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c2_apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id2}  ${c2_apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c2_apptid3}

    ############################## Take appt for INProvider ##############################
    # INProvider- acc_id3, IN_tz, p3_l1, p3_s1, p3_sch1

    Comment  Consumer 2- c2- IN

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p3_sch1}   ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p3_sch1}   ${acc_id3}
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

    ${DAY1}=  db.get_date_by_timezone  ${IN_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id3}  ${p3_s1}  ${p3_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p3_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c2_apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id3}  ${c2_apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c2_apptid4}


    ########################### Consumer 3- c3 ###########################

    Comment  Consumer 3- c3
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}   alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id1}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id1}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid2}    ${resp.json()['providerConsumer']}

    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # # ${dob}=  FakerLibrary.Date Of Birth   minimum_age=18   maximum_age=55
    # # ${dob}=  Convert To String  ${dob}
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${primaryMobileNo}  ${EMPTY}  ${dob}  ${gender}  ${email}  countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${email}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${primaryMobileNo}  ${PASSWORD}   countryCode=+${CountryCode}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ############################## Take appt for USProvider ##############################
    # USProvider- acc_id1, US_tz, p1_l1, p1_l2, p1_s1, p1_s2, p1_sch1, p1_sch2
    
    Comment  Consumer 3- c3- US
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch1}   ${acc_id1}
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
    ${k}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    Set Test Variable   ${slot2}   ${slots[${k}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s1}  ${p1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c3_apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c3_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c3_apptid1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch2}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch2}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s2}  ${p1_sch2}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c3_apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c3_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c3_apptid2}

    ############################## Take appt for MEProvider ##############################
    # MEProvider- acc_id2, AE_tz, p2_l1, p2_s1, p2_sch1

    Comment  Consumer 3- c3- ME
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}   alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id2}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid2}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p2_sch1}   ${acc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p2_sch1}   ${acc_id2}
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

    ${DAY1}=  db.get_date_by_timezone  ${AE_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id2}  ${p2_s1}  ${p2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p2_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c3_apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id2}  ${c3_apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c3_apptid3}

    ############################## Take appt for INProvider ##############################
    # INProvider- acc_id3, IN_tz, p3_l1, p3_s1, p3_sch1

    Comment  Consumer 3- c3- IN
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}   alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid2}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p3_sch1}   ${acc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p3_sch1}   ${acc_id3}
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

    ${DAY1}=  db.get_date_by_timezone  ${IN_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id3}  ${p3_s1}  ${p3_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p3_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c3_apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id3}  ${c3_apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c3_apptid4}


JD-TC-Take Appointment in Different Timezone-3
    [Documentation]   Take appointment for a provider and rechedule the appointment to a different timezone.

    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${SProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${SProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${SProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${SProvider}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${SProvider}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${SProvider}+1
    ${ph2}=  Evaluate  ${SProvider}+2
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    Set Test Variable  ${email_id}  ${P_Email}${SProvider}.${test_mail}
    ${emails1}=  Emails  ${name3}  Email  ${email_id}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${tz}  
    ${eTime}=  db.add_timezone_time  ${tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${SProvider}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${email_id}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    FOR   ${i}  IN RANGE   5
        ${latti1}  ${longi1}  ${city1}  ${country_abbr1}  ${tz1}=  FakerLibrary.Local Latlng  
        IF  '${tz}' == '${tz1}'
            Continue For Loop
        ELSE
            Exit For Loop
        END
    END
    ${address1} =  FakerLibrary.address
    ${postcode1}=  FakerLibrary.postcode
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10     
    ${sTime1}=  add_timezone_time  ${tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${url}  ${postcode1}  ${address1}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l2}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.street name
    ${p1_s1}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=   FakerLibrary.street name
    ${p1_s2}=  Create Sample Service  ${SERVICE2}

    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${DAY4}=  db.add_timezone_date  ${tz}  10  
    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p1_sch1}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${sTime3}=  add_timezone_time  ${tz1}  0  30
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime3}  ${delta}
    ${sTime3}  ${eTime3}=  db.endtime_conversion  ${sTime3}  ${eTime3}
    ${schedule_name}=  FakerLibrary.administrative unit
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10       
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sch2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_sch2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${p1_sch2}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id1}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id1}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_sch1}   ${acc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_sch1}   ${acc_id1}
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

    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${acc_id1}  ${p1_s1}  ${p1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_l1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${acc_id1}  ${c1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid1}



JD-TC-Take Appointment in Different Timezone-4
    [Documentation]  4 multiuser acccounts- 2 in US- different time zones, 1 in ME, 1 in India, each MU has 2 users each in different locations
                ...    same for consumers, and the consumer tries to take appointment for these users

    
    ############################## US ##############################
    Comment  Multi User Account in US
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${US_MultiUser}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${CC1}  country_calling_code
    # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC1}=  Set Variable  ${Number.country_code}
    ${US_MultiUser}=  Set Variable  ${Number.national_number}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings  ${licresp.status_code}  200
    # ${liclen}=  Get Length  ${licresp.json()}
    # Set Test Variable  ${licpkgid}  ${licresp.json()[0]['pkgId']}
    # Set Test Variable  ${licpkgname}  ${licresp.json()[0]['displayName']}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    FOR  ${domindex}  IN RANGE  ${dom_len}
        ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        FOR  ${subindex}  IN RANGE  ${sdom_len}
            ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
            ${is_corp}=  check_is_corp  ${subdomain}
            Exit For Loop If  '${is_corp}' == 'True'
        END
        Log   ${subdomain}
        Exit For Loop If  '${is_corp}' == 'True'
    END

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${US_M_Email}  Set Variable  ${P_Email}${US_MultiUser}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${US_M_Email}  ${domain}  ${subdomain}  ${US_MultiUser}  ${licpkgid}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${US_M_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${US_M_Email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${US_MultiUser}  ${PASSWORD}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${PO_Sec_Num}=  FakerLibrary.Numerify  %#####
    ${ph1}=  Evaluate  ${US_MultiUser}+${PO_Sec_Num}
    ${PO_ter_Num}=  FakerLibrary.Numerify  %#####
    ${ph2}=  Evaluate  ${US_MultiUser}+${PO_ter_Num}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${US_M_Email}  ${views}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${US_tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    Log  ${spec}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${specials}=  Random Elements   elements=${spec['specialization']}  length=${rand_len}  unique=True
    Log  ${specials}
    Set To Dictionary    ${spec}    specialization    ${specials}
    # IF  ${spec_len}>3
    #     ${specials}=  Random Elements   elements=${spec['specialization']}  length=${rand_len}  unique=True
    #     Log  ${specials}
    #     Set To Dictionary    ${spec}    specialization    ${specials}
    # END
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${US_MultiUser}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${US_M_Email}
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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_us_l1}   ${resp.json()[0]['id']}

    
    FOR   ${i}  IN RANGE   5
        ${latti1}  ${longi1}  ${city1}  ${country_abbr1}  ${US_tz1_orig}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
        IF  '${US_tz}' == '${US_tz1_orig}'
            Continue For Loop
        ELSE
            Exit For Loop
        END
    END
    ${US_tz1}=  create_tz  ${US_tz1_orig}
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz1}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${US_tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${DAY2}=  db.add_timezone_date  ${US_tz1}  10     
    ${sTime1}=  add_timezone_time  ${US_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${US_tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_us_l2}  ${resp.json()}

    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz2}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${US_tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${US_tz2}
    ${DAY2}=  db.add_timezone_date  ${US_tz2}  10     
    ${sTime1}=  add_timezone_time  ${US_tz2}  0  30  
    ${eTime1}=  add_timezone_time  ${US_tz2}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_us_l3}  ${resp.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    # ${UO_Number}=  FakerLibrary.Numerify  %#####
    # ${US_User_U1}=  Evaluate  ${PUSERNAME}+${UO_Number}
    # ${CC1}  country_calling_code
    # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC1}=  Set Variable  ${Number.country_code}
    ${US_User_U1}=  Set Variable  ${Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${pin}=  FakerLibrary.postcode
    ${user_dis_name}=  FakerLibrary.last_name
    ${employee_id}=  FakerLibrary.Random Number
    ${U1_emailid}=  Set Variable   ${P_Email}${US_User_U1}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${U1_emailid}   ${userType[0]}  ${EMPTY}  ${CC1}  ${US_User_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname}  employeeId  ${employee_id}
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${us_uid1}  ${resp.json()}

    ${resp}=  Get User By Id  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC2}=  Set Variable  ${Number.country_code}
    ${US_User_U2}=  Set Variable  ${Number.national_number}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  FakerLibrary.address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  FakerLibrary.postcode
    ${user_dis_name2}=  FakerLibrary.last_name
    ${employee_id2}=  FakerLibrary.Random Number
    ${U2_emailid}=  Set Variable   ${P_Email}${US_User_U2}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${U2_emailid}   ${userType[0]}  ${EMPTY}  ${CC2}  ${US_User_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname2}  employeeId  ${employee_id2}
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${us_uid2}  ${resp.json()}

    ${resp}=  Get User By Id  ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}

    ${userIds}=  Create List  ${us_uid1}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p1_us_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${us_uid2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p1_us_l3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    #-------------------- First user login - US_User_U1-------------------------
    Comment  First user login - US_User_U1

    ${resp}=  SendProviderResetMail  ${US_User_U1}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${US_User_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${US_User_U1}  ${PASSWORD}  countryCode=${CC1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${rand_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${us_upid1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()['services'][0]['id']}

    ${P1_U1_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P1_U1_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_u1_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p1_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${DAY3}=  db.get_date_by_timezone  ${US_tz1}
    ${DAY4}=  db.add_timezone_date  ${US_tz1}  10  
    ${sTime2}=  add_timezone_time  ${US_tz1}  1  00  
    ${eTime2}=  add_timezone_time  ${US_tz1}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${us_uid1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_us_l1}  ${duration}  ${bool1}  ${p1_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_u1_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_u1_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}

    #-------------------- Second user login - US_User_U2-------------------------
    Comment  Second user login - US_User_U2

    ${resp}=  SendProviderResetMail  ${US_User_U2}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${US_User_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${US_User_U2}  ${PASSWORD}  countryCode=${CC2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${rand_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${us_upid1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()['services'][0]['id']}

    ${P1_U2_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P1_U2_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_u2_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p1_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.get_date_by_timezone  ${US_tz2}
    ${DAY4}=  db.add_timezone_date  ${US_tz2}  10  
    ${sTime2}=  add_timezone_time  ${US_tz2}  1  00  
    ${eTime2}=  add_timezone_time  ${US_tz2}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${us_uid2}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p1_us_l2}  ${duration}  ${bool1}  ${p1_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_u2_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p1_u2_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}



    ############################## ME ##############################
    # Saudi Arabia
    Comment  Multi User Account in Middle East - Saudi Arabia
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${ME_MultiUser}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${CC1}  country_calling_code
    # # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC1}=  Set Variable  ${Number.country_code}
    ${ME_MultiUser}=  Set Variable  ${Number.national_number}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    FOR  ${domindex}  IN RANGE  ${dom_len}
        ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        FOR  ${subindex}  IN RANGE  ${sdom_len}
            ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
            ${is_corp}=  check_is_corp  ${subdomain}
            Exit For Loop If  '${is_corp}' == 'True'
        END
        Log   ${subdomain}
        Exit For Loop If  '${is_corp}' == 'True'
    END

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${ME_M_Email}  Set Variable  ${P_Email}${ME_MultiUser}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${ME_M_Email}  ${domain}  ${subdomain}  ${ME_MultiUser}  ${licpkgid}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${ME_M_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ME_M_Email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${ME_MultiUser}  ${PASSWORD}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${PO_Sec_Num}=  FakerLibrary.Numerify  %#####
    ${ph1}=  Evaluate  ${ME_MultiUser}+${PO_Sec_Num}
    ${PO_ter_Num}=  FakerLibrary.Numerify  %#####
    ${ph2}=  Evaluate  ${ME_MultiUser}+${PO_ter_Num}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${ME_M_Email}  ${views}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${ME_tz}=  FakerLibrary.Local Latlng  country_code=SA  coords_only=False
    ${ME_tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY}=  db.get_date_by_timezone  ${ME_tz}
    ${sTime}=  db.get_time_by_timezone  ${ME_tz}  
    ${eTime}=  db.add_timezone_time  ${ME_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id2}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    Log  ${spec}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${specials}=  Random Elements   elements=${spec['specialization']}  length=${rand_len}  unique=True
    Log  ${specials}
    Set To Dictionary    ${spec}    specialization    ${specials}
    # IF  ${spec_len}>3
    #     ${specials}=  Random Elements   elements=${spec['specialization']}  length=3  unique=True
    #     Log  ${specials}
    #     Set To Dictionary    ${spec}    specialization    ${specials}
    # END
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${US_MultiUser}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${ME_M_Email}
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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_me_l1}   ${resp.json()[0]['id']}

    
    #------------------------- location 2- Yemen -----------------------------------
    
    comment  locaton in Yemen
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${ME_tz1}=  FakerLibrary.Local Latlng  country_code=YE  coords_only=False
    ${ME_tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${ME_tz1}
    ${DAY2}=  db.add_timezone_date  ${ME_tz1}  10     
    ${sTime1}=  add_timezone_time  ${ME_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${ME_tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_me_l2}  ${resp.json()}

    #------------------------- location 3- Egypt -----------------------------------
    comment  locaton in Egypt
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${ME_tz2}=  FakerLibrary.Local Latlng  country_code=EG  coords_only=False
    ${ME_tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${ME_tz2}
    ${DAY2}=  db.add_timezone_date  ${ME_tz2}  10     
    ${sTime1}=  add_timezone_time  ${ME_tz2}  0  30  
    ${eTime1}=  add_timezone_time  ${ME_tz2}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_me_l3}  ${resp.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    # ${UO_Number}=  FakerLibrary.Numerify  %#####
    # ${US_User_U1}=  Evaluate  ${PUSERNAME}+${UO_Number}
    # ${CC1}  country_calling_code
    # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC1}=  Set Variable  ${Number.country_code}
    ${ME_User_U1}=  Set Variable  ${Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${pin}=  FakerLibrary.postcode
    ${user_dis_name}=  FakerLibrary.last_name
    ${employee_id}=  FakerLibrary.Random Number
    ${MEU1_emailid}=  Set Variable   ${P_Email}${ME_User_U1}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${MEU1_emailid}   ${userType[0]}  ${EMPTY}  ${CC1}  ${ME_User_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname}  employeeId  ${employee_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${me_uid1}  ${resp.json()}

    ${resp}=  Get User By Id  ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC2}=  Set Variable  ${Number.country_code}
    ${ME_User_U2}=  Set Variable  ${Number.national_number}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  FakerLibrary.address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  FakerLibrary.postcode
    ${user_dis_name2}=  FakerLibrary.last_name
    ${employee_id2}=  FakerLibrary.Random Number
    ${MEU2_emailid}=  Set Variable   ${P_Email}${ME_User_U2}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${MEU2_emailid}   ${userType[0]}  ${EMPTY}  ${CC2}  ${ME_User_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname2}  employeeId  ${employee_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${me_uid2}  ${resp.json()}

    ${resp}=  Get User By Id  ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}

    ${userIds}=  Create List  ${me_uid1}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p2_me_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${me_uid2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p2_me_l3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    #-------------------- First user login - ME_User_U1-------------------------
    Comment  First user login - ME_User_U1

    ${resp}=  SendProviderResetMail  ${ME_User_U1}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${ME_User_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${ME_User_U1}  ${PASSWORD}  countryCode=${CC1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${rand_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${us_upid1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()['services'][0]['id']}

    ${P2_U1_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P2_U1_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_u1_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p2_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.get_date_by_timezone  ${ME_tz}
    ${DAY4}=  db.add_timezone_date  ${ME_tz}  10  
    ${sTime2}=  add_timezone_time  ${ME_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${ME_tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${me_uid1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p2_me_l1}  ${duration}  ${bool1}  ${p2_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_u1_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p2_u1_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}

    #-------------------- Second user login - ME_User_U2-------------------------
    Comment  Second user login - ME_User_U2

    ${resp}=  SendProviderResetMail  ${ME_User_U2}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${ME_User_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${ME_User_U2}  ${PASSWORD}  countryCode=${CC2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${rand_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${me_upid2}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()['services'][0]['id']}

    ${P2_U2_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P2_U2_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_u2_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p2_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.get_date_by_timezone  ${US_tz2}
    ${DAY4}=  db.add_timezone_date  ${US_tz2}  10  
    ${sTime2}=  add_timezone_time  ${US_tz2}  1  00  
    ${eTime2}=  add_timezone_time  ${US_tz2}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${me_uid2}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p2_me_l2}  ${duration}  ${bool1}  ${p2_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_u2_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p2_u2_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}

    ############################## IN ##############################
    # India
    Comment  Multi User Account in Asia - India
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${IN_MultiUser}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${CC1}  Set Variable   ${countryCodes[0]}
    # # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    # ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    # ${CC1}=  Set Variable  ${splitCC}[0]

    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings  ${licresp.status_code}  200
    # ${liclen}=  Get Length  ${licresp.json()}
    # Set Test Variable  ${licpkgid}  ${licresp.json()[0]['pkgId']}
    # Set Test Variable  ${licpkgname}  ${licresp.json()[0]['displayName']}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    FOR  ${domindex}  IN RANGE  ${dom_len}
        ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        FOR  ${subindex}  IN RANGE  ${sdom_len}
            ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
            ${is_corp}=  check_is_corp  ${subdomain}
            Exit For Loop If  '${is_corp}' == 'True'
        END
        Log   ${subdomain}
        Exit For Loop If  '${is_corp}' == 'True'
    END

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${IN_MU_Email}  Set Variable  ${P_Email}${IN_MultiUser}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${IN_MU_Email}  ${domain}  ${subdomain}  ${IN_MultiUser}  ${licpkgid}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${IN_MU_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${IN_MU_Email}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${IN_MultiUser}  ${PASSWORD}  countryCode=${CC1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${PO_Sec_Num}=  FakerLibrary.Numerify  %#####
    ${ph1}=  Evaluate  ${IN_MultiUser}+${PO_Sec_Num}
    ${PO_ter_Num}=  FakerLibrary.Numerify  %#####
    ${ph2}=  Evaluate  ${IN_MultiUser}+${PO_ter_Num}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${IN_MU_Email}  ${views}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.catch_phrase
    ${url}=   FakerLibrary.url
    ${bs}=  FakerLibrary.bs
    ${shortname}=  FakerLibrary.company
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${IN_tz}=  FakerLibrary.Local Latlng  country_code=IN  coords_only=False
    ${IN_tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY}=  db.get_date_by_timezone  ${IN_tz}
    ${sTime}=  db.get_time_by_timezone  ${IN_tz}  
    ${eTime}=  db.add_timezone_time  ${IN_tz}  0  30  
    ${sTime}  ${eTime}=  db.endtime_conversion  ${sTime}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}  ${shortname}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id3}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    Log  ${spec}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${specials}=  Random Elements   elements=${spec['specialization']}  length=${rand_len}  unique=True
    Log  ${specials}
    Set To Dictionary    ${spec}    specialization    ${specials}
    # IF  ${spec_len}>3
    #     ${specials}=  Random Elements   elements=${spec['specialization']}  length=3  unique=True
    #     Log  ${specials}
    #     Set To Dictionary    ${spec}    specialization    ${specials}
    # END
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${IN_MU_Email}
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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p3_in_l1}   ${resp.json()[0]['id']}

    
    #------------------------- location 2- India -----------------------------------
    
    comment  locaton in India
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${IN_tz1}=  FakerLibrary.Local Latlng  country_code=IN  coords_only=False
    ${IN_tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${IN_tz1}
    ${DAY2}=  db.add_timezone_date  ${IN_tz1}  10     
    ${sTime1}=  add_timezone_time  ${IN_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${IN_tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p3_in_l2}  ${resp.json()}

    #------------------------- location 3- Indonesia -----------------------------------
    comment  locaton in Indonesia
    ${city}=   FakerLibrary.City
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${ID_tz1}=  FakerLibrary.Local Latlng  country_code=ID  coords_only=False
    ${ID_tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${DAY1}=  db.get_date_by_timezone  ${ID_tz1}
    ${DAY2}=  db.add_timezone_date  ${ID_tz1}  10     
    ${sTime1}=  add_timezone_time  ${ID_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${ID_tz1}  1  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime1}  ${eTime1}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p3_in_l3}  ${resp.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    # ${UO_Number}=  FakerLibrary.Numerify  %#####
    # ${US_User_U1}=  Evaluate  ${PUSERNAME}+${UO_Number}
    # ${CC1}  country_calling_code
    # ${CC1}=    Remove String    ${CC1}    ${SPACE}
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC1}=  Set Variable  ${Number.country_code}
    ${IN_User_U1}=  Set Variable  ${Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${pin}=  FakerLibrary.postcode
    ${user_dis_name}=  FakerLibrary.last_name
    ${employee_id}=  FakerLibrary.Random Number
    ${MEU1_emailid}=  Set Variable   ${P_Email}${IN_User_U1}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${MEU1_emailid}   ${userType[0]}  ${EMPTY}  ${CC1}  ${IN_User_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname}  employeeId  ${employee_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${In_uid1}  ${resp.json()}

    ${resp}=  Get User By Id  ${In_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CC2}=  Set Variable  ${Number.country_code}
    ${IN_User_U2}=  Set Variable  ${Number.national_number}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  FakerLibrary.address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  FakerLibrary.postcode
    ${user_dis_name2}=  FakerLibrary.last_name
    ${employee_id2}=  FakerLibrary.Random Number
    ${MEU2_emailid}=  Set Variable   ${P_Email}${IN_User_U2}.${test_mail}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${MEU2_emailid}   ${userType[0]}  ${EMPTY}  ${CC2}  ${IN_User_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${firstname2}  employeeId  ${employee_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${In_uid2}  ${resp.json()}

    ${resp}=  Get User By Id  ${In_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}

    ${userIds}=  Create List  ${In_uid1}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p2_me_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${In_uid2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${p2_in_l3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    #-------------------- First user login - IN_User_U1-------------------------
    Comment  First user login - IN_User_U1

    ${resp}=  SendProviderResetMail  ${IN_User_U1}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${IN_User_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC1}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${IN_User_U1}  ${PASSWORD}  countryCode=${CC1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${rand_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${In_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${in_upid1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${In_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()['services'][0]['id']}

    ${P3_U1_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P3_U1_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${In_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p3_u1_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p3_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.get_date_by_timezone  ${ME_tz}
    ${DAY4}=  db.add_timezone_date  ${ME_tz}  10  
    ${sTime2}=  add_timezone_time  ${ME_tz}  1  00  
    ${eTime2}=  add_timezone_time  ${ME_tz}  1  30  
    ${sTime2}  ${eTime2}=  db.endtime_conversion  ${sTime2}  ${eTime2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${In_uid1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p3_in_l2}  ${duration}  ${bool1}  ${p3_u1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p3_u1_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p3_u1_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}

    #-------------------- Second user login - IN_User_U2-------------------------
    Comment  Second user login - IN_User_U2

    ${resp}=  SendProviderResetMail  ${IN_User_U2}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${IN_User_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  countryCode=${CC2}
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${IN_User_U2}  ${PASSWORD}  countryCode=${CC2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec['specialization']}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${spec_len}  unique=True
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${In_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${me_upid2}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${In_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()['services'][0]['id']}

    ${P3_U2_SERVICE1}=   FakerLibrary.job
    ${desc}=  FakerLibrary.sentence
    ${service_duration}=  FakerLibrary.Random Int  min=2  max=5
    ${servicecharge}=  FakerLibrary.Random Int  min=100  max=500
    # ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P3_U2_SERVICE1}  ${desc}  ${service_duration}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${In_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p3_u2_s1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${p3_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  db.get_date_by_timezone  ${US_tz2}
    ${DAY4}=  db.add_timezone_date  ${US_tz2}  10  
    ${sTime2}=  add_timezone_time  ${US_tz2}  1  00  
    ${eTime2}=  add_timezone_time  ${US_tz2}  1  30  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${In_uid2}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}  ${p3_in_l2}  ${duration}  ${bool1}  ${p3_u2_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p3_u2_sch1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${p3_u2_sch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  apptState=${Qstate[0]}

    # USProvider-  ${acc_id1}	${us_uid1}, ${us_uid2}, 	 ${US_tz1}, 	${p1_us_l2},  	${p1_us_l3},  ${p1_u1_s1},  ${p1_u2_s1}, p1_u1_sch1, p1_u2_sch2, 

    # MEProvider- acc_id2, p2_me_l2,me-uid1, p2_u1_s1, p2_u1_sch1,p2_me_l3,me-uid2, p2_u2_s1, p2_u2_sch1,

    # INProvider- acc_id3, p3_in_l2,In-uid1, p3_u1_s1, p3_u1_sch1,p3_in_l3,In-uid2, p3_u2_s1, p3_u2_sch1,

    ########################### Consumer 1- c1(Us region) ###########################
    
    Comment  Consumer 1- c1
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id1}  countryCode=${CountryCode}  timeZone=${US_tz1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id1}  ${token}  countryCode=${CountryCode}   timeZone=${US_tz1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ############################## Take appt for USProvider user1 ##############################
    # USProvider-  ${acc_id1}	${us_uid1}, ${us_uid2}, 	${US_tz1}, 	${p1_us_l2},  	${p1_us_l3},  ${p1_u1_s1},  ${p1_u2_s1}, p1_u1_sch1, p1_u2_sch2, 
    
    Comment  Consumer 1- c1- US
    ${resp}=  Get Appointment Schedules Consumer  ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_u1_sch1}   ${us_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_u1_sch1}   ${us_uid1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${us_uid1}  ${p1_u1_s1}  ${p1_u1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_us_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${us_uid1}  ${c1_apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid1}

    ############################## Take appt for USProvider user2 ##############################
    # USProvider-  ${acc_id1}	${us_uid1}, ${us_uid2}, 	${US_tz1}, 	${p1_us_l2},  	${p1_us_l3},  ${p1_u1_s1},  ${p1_u2_s1}, p1_u1_sch1, p1_u2_sch2,  

    ${resp}=  Get Appointment Schedule ById Consumer  ${p1_u2_sch1}   ${us_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p1_u2_sch1}   ${us_uid2}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${us_uid2}  ${p1_u2_s1}  ${p1_u2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p1_us_l3}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${us_uid2}  ${c1_apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid2}

    ############################## Take appt for MEProvider user1 ##############################
    # MEProvider- acc_id2, p2_me_l2,me-uid1, p2_u1_s1, p2_u1_sch1,p2_me_l3,me-uid2, p2_u2_s1, p2_u2_sch1,
    
    Comment  Consumer 1- c1- UAE
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id2}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p2_u1_sch1}   ${me_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p2_u1_sch1}   ${me_uid1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${me_uid1}  ${p2_u1_s1}  ${p2_u1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p2_me_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${me_uid1}  ${c1_apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid3}

    ############################## Take appt for MEProvider user2 ##############################
    # MEProvider- acc_id2, p2_me_l2,me-uid1, p2_u1_s1, p2_u1_sch1,p2_me_l3,me-uid2, p2_u2_s1, p2_u2_sch1,
    
    Comment  Consumer 1- c1- US
    ${resp}=  Get Appointment Schedules Consumer  ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p2_u2_sch1}   ${me_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p2_u2_sch1}   ${me_uid2}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${me_uid2}  ${p2_u2_s1}  ${p2_u2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p2_me_l3}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid4}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${me_uid2}  ${c1_apptid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid4}

    ############################## Take appt for INProvider user1 ##############################
    # INProvider- acc_id3, p3_in_l2,In-uid1, p3_u1_s1, p3_u1_sch1,p3_in_l3,In-uid2, p3_u2_s1, p3_u2_sch1,
    
    Comment  Consumer 1- c1- IN
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${IN_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p3_u1_sch1}   ${IN_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p3_u1_sch1}   ${IN_uid1}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${IN_uid1}  ${p3_u1_s1}  ${p3_u1_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p3_in_l2}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid5}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${IN_uid1}  ${c1_apptid5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid5}

   ############################## Take appt for INProvider user2 ##############################
    # INProvider- acc_id3, p3_in_l2,In-uid1, p3_u1_s1, p3_u1_sch1,p3_in_l3,In-uid2, p3_u2_s1, p3_u2_sch1,
    
     Comment  Consumer 1- c1- IN
    ${resp}=  Get Appointment Schedules Consumer  ${IN_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${p3_u2_sch1}   ${IN_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${p3_u2_sch1}   ${IN_uid2}
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

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${IN_uid2}  ${p3_u2_s1}  ${p3_u2_sch1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${p3_in_l3}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${c1_apptid6}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${IN_uid2}  ${c1_apptid6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${c1_apptid6}
    
    