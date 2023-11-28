
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


*** Variables ***
${self}     0



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
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}



Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}







*** Test Cases ***

JD-TC-Get locations by service-1
    [Documentation]  Consumer get location by service.

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+290092
    Set Suite Variable   ${PUSERPH0}
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable   ${PUSERPH0_id}  user_${PUSERPH0}_skype
    Log  ${PUSERPH0_id}
    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable   ${accId}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}




    clear_service   ${PUSERPH0}
    clear_location  ${PUSERPH0}
    ${pid}=  get_acc_id  ${PUSERPH0}
    ${DAY}=  db.add_timezone_date  ${tz}  0   
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${sTime}=  db.db.get_time_by_timezone  ${tz}
    ${eTime}=  db.add_timezone_time  ${tz}  0  30
    ${city}=   fakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}
    
    ${sTime1}=  db.add_timezone_time  ${tz}  0  30
    ${eTime1}=  db.add_timezone_time  ${tz}  1  00
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}
    clear_appt_schedule   ${PUSERPH0}
        


    ${service_duration}=   Random Int   min=5   max=10
    Set Suite Variable    ${service_duration}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}    
 
    ${P1SERVICE2}=    FakerLibrary.lastname
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.firstname
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${sTime1}=  db.add_timezone_time  ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}   ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${sTime1}=  db.add_timezone_time  ${tz}  0  35
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name2}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}   ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get locations by service   ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${p1_s1}
   
     Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}   ${eTime}
     Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}   ${sTime}
    


JD-TC-Get locations by service-2
    [Documentation]  Consumer get location by service (Another Location)
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Verify Response List   ${resp}   0    id=${p1_s2}   name=${P1SERVICE2}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
    Verify Response List   ${resp}   1    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}

     ${resp}=    Get locations by service   ${p1_s2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
   Should Be Equal As Strings  ${resp.json()[0]['id']}   ${p1_s2}

    
JD-TC-Get locations by service-3
    [Documentation]   Consumer get location by service When Services are disabled
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s1}
    Should Not Contain  ${resp.json()}  ${p1_s3}

     ${resp}=    Get locations by service   ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
     Should Be Equal As Strings  ${resp.json()[0]['id']}   ${p1_s1}




    ${resp}=  Get Appmt Schedule By ServiceId_LocationId and Date   ${accId}   ${p1_l1}  ${p1_s1}  ${DAY1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}   0  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}


    ${resp}=  Get Appmt Schedule By ServiceId_LocationId and Date   ${accId}   ${p1_l1}  ${p1_s3}  ${DAY1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}   0  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get locations by service-4

    [Documentation]  Consumer get location by service When Services are disabled (Another Location)
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s2}
    Should Not Contain  ${resp.json()}  ${p1_s3}

     ${resp}=    Get locations by service   ${p1_s3}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    # Should Be Equal As Strings  ${resp.json()[1]['id']}   ${p1_s3}
  


    ${resp}=  Get Appmt Schedule By ServiceId_LocationId and Date   ${accId}   ${p1_l2}  ${p1_s2}  ${DAY1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}   0  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}


    ${resp}=  Get Appmt Schedule By ServiceId_LocationId and Date   ${accId}   ${p1_l2}  ${p1_s3}  ${DAY1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}   0  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable service  ${p1_s2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Get locations by service-UH1
    [Documentation]  Consumer trying to get location by service, using invalid service id id 
    
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${invalid}=   Random Int  min=100  max=500
     ${resp}=    Get locations by service   ${invalid}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}       []



JD-TC-Get locations by service-UH2
    [Documentation]  Consumer trying to get location by service, When Location are disabled 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"       "${LOCATION_DISABLED}"

     ${resp}=    Get locations by service   ${p1_s3}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  422

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get locations by service-UH3
    [Documentation]  Without Login, trying to get location by service

       ${resp}=    Get locations by service   ${p1_s3}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"       "${SESSION_EXPIRED}"


