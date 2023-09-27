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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91
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
#     [Return]  ${resp}



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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_X}${\n}
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
    
    ${resp}=  ProviderLogout
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
    ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id11}    ${DAY1}   ${pid01}    location=${{str('${p1_l1}')}}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response  ${resp}  scheduleId=${sch_id11}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response  ${resp}  scheduleId=${sch_id21}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${USProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

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
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${USProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${USProvider}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${USProvider}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  0  30  
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

    Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

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
        ${latti1}  ${longi1}  ${city1}  ${country_abbr1}  ${US_tz1}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
        IF  '${US_tz}' == '${US_tz1}'
            Continue For Loop
        ELSE
            Exit For Loop
        END
    END
    ${address1} =  FakerLibrary.address
    ${postcode1}=  FakerLibrary.postcode
    ${DAY1}=  db.get_date_by_timezone  ${US_tz1}
    ${DAY2}=  db.add_timezone_date  ${US_tz1}  10     
    ${sTime1}=  add_timezone_time  ${US_tz1}  0  30  
    ${eTime1}=  add_timezone_time  ${US_tz1}  1  00  
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
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    ############################## UAE ##############################

    Comment  Provider in Middle East (UAE)
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${MEProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

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
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${MEProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${MEProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${MEProvider}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=  Encrypted Provider Login  ${MEProvider}  ${PASSWORD}
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${MEProvider}.${test_mail}  ${views}
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

    Set Test Variable  ${email_id}  ${P_Email}${MEProvider}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${fname}  ${lname}   ${email_id}
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
    
    ${resp}=  ProviderLogout
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${INProvider}.${test_mail}  ${views}
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

    Set Test Variable  ${email_id}  ${P_Email}${INProvider}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${fname}  ${lname}   ${email_id}
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
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    # USProvider- acc_id1, US_tz, p1_l1, p1_l2, p1_s1, p1_s2, p1_sch1, p1_sch2, 

    # MEProvider- acc_id2, AE_tz, p2_l1, p2_s1, p2_sch1

    # INProvider- acc_id3, IN_tz, p3_l1, p3_s1, p3_sch1

    ########################### Consumer 1- c1 ###########################
    
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${acc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id1}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id2}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${acc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id1}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id2}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id3}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${acc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id1}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id2}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${acc_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id2}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id3}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${acc_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${acc_id3}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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

    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${DAY4}=  db.add_timezone_date  ${tz}  10  
    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
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
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number.country_code}
    ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${acc_id1}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${acc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${acc_id1}  ${token} 
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
    [Documentation]  4 multiuser acccounts- 2 in US- different time zones, 1 in ME, 1 in India, each mu has 2 users each in different locations
                ...    same for consumers, and the consumer tries to take appointment for these users

    
    ############################## US ##############################
    Comment  Multi User Account in US
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${US_MultiUser}=  Evaluate  ${PUSERNAME}+${PO_Number}

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

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${USProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${USProvider}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${USProvider}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  0  30  
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

    Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

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

    ${UO_Number}=  FakerLibrary.Numerify  %#####
    ${US_User_U1}=  Evaluate  ${PUSERNAME}+${UO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${pin}=  FakerLibrary.postcode
    ${user_dis_name}=  FakerLibrary.last_name
    ${employee_id}=  FakerLibrary.last_name

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${US_User_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${US_User_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[0]}  ${US_User_U1}  ${countryCodes[0]}  ${US_User_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${us_uid1}  ${resp.json()}

    ${resp}=  Get User By Id  ${us_uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${us_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${us_upid1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${us_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}

    