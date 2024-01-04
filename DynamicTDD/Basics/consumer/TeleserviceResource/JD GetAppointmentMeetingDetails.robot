

*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Teleservice
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

${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09

${self}         0

&{Emptydict}

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
JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-1
    [Documentation]  Create Teleservice meeting request for Appointment in WhatsApp (ONLINE CHECKIN)
    
    ${UserZOOM_id0}=  Format String  ${ZOOM_url}  ${CUSERNAME0}

    Set Suite Variable  ${ZOOM_id2}    ${UserZOOM_id0}
    Set Suite Variable  ${WHATSAPP_id2}   ${countryCodes[0]}${CUSERNAME0}
    

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+338197451
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
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    clear_customer   ${PUSERPH0}
    
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Accountsettings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
  
    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}
    
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERPH0}.${test_mail}  ${views}
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
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+50505
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   countryCode=${countryCodes[0]}  status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes1}=  Create List  ${VScallingMode1}
    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    FakerLibrary.word
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
    ${SERVICE2}=    FakerLibrary.word
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
    clear_appt_schedule   ${PUSERPH0}
   

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
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor} 
      

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    
    
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
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}   ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}

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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid1}   ${CallingModes[1]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    
JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-2
    [Documentation]  Create Teleservice meeting request for Appointment in Zoom (ONLINE CHECKIN)

    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME6}    

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}   ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}

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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid2}    ${CallingModes[0]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   

JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-UH1
    [Documentation]  Create Teleservice meeting request for Appointment  in Zoom and WhatsApp (ONLINE CHECKIN)


    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME6}    

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}   ${WHATSAPP_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}   ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}

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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid3}   ${CallingModes[1]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid3}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    
JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-3
    [Documentation]  Create Teleservice meeting request for Appointment in Zoom (WALK-IN CHECKIN)

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    # Set Suite Variable  ${fname16}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname16}   ${resp.json()['lastName']}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME16}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['userProfile']['id']}
    Set Suite Variable  ${fname16}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname16}   ${resp.json()['userProfile']['lastName']}

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

    ${resp}=  AddCustomer  ${CUSERNAME16}   firstName=${fname16}   lastName=${lname16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()} 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor} 
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Virtual Service Appointment For Consumer  ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}   ${ZOOM_id2}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid4}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  label=${Emptydict}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    
    ${resp}=  Create Appointment Meeting Request   ${apptid4}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid4}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid4}   ${CallingModes[0]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid4}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-4
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

    # ${resp}=  AddCustomer  ${CUSERNAME16}   firstName=${fname16}   lastName=${lname16}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pcid1}  ${resp.json()} 

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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Virtual Service Appointment For Consumer  ${pcid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${WHATSAPP_id2}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid5}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  label=${Emptydict}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    
    ${resp}=  Create Appointment Meeting Request   ${apptid5}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Meeting Request    ${apptid5}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid5}   ${CallingModes[1]}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid5}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-UH2
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
      
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Virtual Service Appointment For Consumer  ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id2}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid6}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  label=${Emptydict}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    
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

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details   ${apptid6}   ${CallingModes[0]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid6}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   

JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-5

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
      

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Virtual Service Appointment For Consumer  ${pcid}  ${p1_s2}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id2}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid7}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  label=${Emptydict}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname16}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    

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

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details    ${apptid7}   ${CallingModes[0]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid7}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

 
JD-TC-GetAppointmentMeetingDetails-(Billable Subdomain)-6

    [Documentation]   Create Appointment teleservice Whatsapp meeting request Which  is already created
    
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME6}    

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}   ${WHATSAPP_id2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid8}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid8}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}   ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}

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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details    ${apptid8}    ${CallingModes[1]}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid8}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    


JD-TC-GetAppointmentMeetingDetails-UH3

    [Documentation]  Get Appointment teleservice meeting Details without login
    ${resp}=   Get Appointment Meeting Details   ${apptid1}    ${CallingModes[1]}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


# JD-TC-TeleserviceAppointment-UH5
#     [Documentation]    Create Appointment teleservice meeting request  with invalid  Appointment id 
#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Set Test Variable   ${INVALID_Wid}   0000
#     ${resp}=  Create Appointment Meeting Request   ${INVALID_Wid}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  404
#     Should Be Equal As Strings  "${resp.json()}"   "${INVALID_APPOINTMENT}"



# JD-TC-TeleserviceAppointment-UH4
#     [Documentation]    Create Appointment teleservice meeting request  with invalid  Calling mode 
#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Create Appointment Meeting Request   ${apptid8}   ${CallingModes[5]}  ${waitlistedby[1]} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"



JD-TC-GetAppointmentMeetingDetails-(Non billable Subdomain)-7
    [Documentation]  Create Teleservice meeting request for Appointment  in Zoom (Non billable Subdomain)
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${f_Name0}  ${resp.json()['firstName']}
    # Set Suite Variable  ${l_Name0}  ${resp.json()['lastName']}
    # Set Suite Variable  ${ph_no0}  ${resp.json()['primaryPhoneNumber']}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+1581851
    Set Suite Variable   ${PUSERPH2}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${d2}  ${domresp.json()[${pos}]['domain']}
        ${sd2}  ${check}=  Get Non Billable Subdomain  ${d2}  ${domresp}  ${pos}  
        Set Test Variable   ${sd2}
        Exit For Loop IF     '${check}' == '${bool[0]}'

    END
    
    Log  ${d2}
    Log  ${sd2}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d2}  ${sd2}  ${PUSERPH2}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    clear_customer   ${PUSERPH2}
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Accountsettings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERPH2}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH2}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
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
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d2}  ${sd2}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d2}  ${sd2}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH2}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

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
    ${SERVICE1}=    FakerLibrary.word
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
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}

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
    clear_appt_schedule   ${PUSERPH2}

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

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
    # Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}
    # Set Suite Variable   ${apptfor}

    ${resp}=  Get Consumer By Id  ${CUSERNAME0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID0}   ${resp.json()['userProfile']['id']}
    Set Suite Variable  ${f_Name0}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${l_Name0}   ${resp.json()['userProfile']['lastName']}
    
    ${resp}=  AddCustomer  ${CUSERNAME0}    firstName=${f_Name0}   lastName=${l_Name0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid0}  ${resp.json()} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${p2_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${pcid0}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}


    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pcid0}  ${resp.json()[0]['id']}
    # ${jdconID0}=  get_id  ${CUSERNAME0} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Virtual Service Appointment For Consumer  ${pcid0}  ${p2_s1}  ${sch_id2}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid9}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  label=${Emptydict}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID0}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${f_Name0}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${l_Name0}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${f_Name0}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${l_Name0}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p2_l1}
    

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

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Appointment Meeting Details    ${apptid9}    ${CallingModes[0]}     ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
