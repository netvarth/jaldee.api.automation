
*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        service
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
${GoogleMeet_url}    https://meet.google.com/gif-pqrs-abc


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



Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}






*** Test Cases ***
JD-TC-TeleserviceWaitlist-(Billable Subdomain)-1
    [Documentation]  Create Teleservice meeting request for waitlist in WhatsApp (WALK-IN CHECKIN)

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${DAY}=  db.get_date_by_timezone  ${tz}    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${UserZOOM_id0}=  Format String  ${ZOOM_url}  ${CUSERNAME0}

    Set Suite Variable  ${ZOOM_id2}    ${UserZOOM_id0}
    Set Suite Variable  ${WHATSAPP_id2}   ${countryCodes[0]}${CUSERNAME0}
    
    

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1981891
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${accId}=  get_acc_id  ${PUSERPH0}

    
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
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  5  45  
    Set Suite Variable   ${eTime}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
    ${Note1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   countryCode=${countryCodes[0]}  status=${ModeStatus1}   instructions=${Note1}
    ${virtualCallingModes1}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes1}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}
    

    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}

    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Note2}=    FakerLibrary.sentence
    ${VScallingMode2}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Note2}
    ${virtualCallingModes2}=  Create List  ${VScallingMode2}


    ${Total2}=   Random Int   min=100   max=500
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE2}=    FakerLibrary.firstname
    ${description2}=    FakerLibrary.word
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total2}  ${bool[0]}   ${bool[0]}   ${vstype2}   ${virtualCallingModes2}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE2}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype2}
   
   
    # ######################################################################
    
    Set Test Variable  ${callingMode3}     ${CallingModes[2]}
    Set Test Variable  ${ModeId3}          ${PUSERPH_id0}
    Set Test Variable  ${ModeStatus3}      ACTIVE
    ${Note3}=    FakerLibrary.sentence
    ${VScallingMode3}=   Create Dictionary   callingMode=${callingMode3}   value=${ModeId3}   status=${ModeStatus3}   instructions=${Note3}
    ${virtualCallingModes3}=  Create List  ${VScallingMode3}

    ${SERVICE3}=    FakerLibrary.lastname
    Set Test Variable  ${vstype3}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE3}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total2}  ${bool[0]}   ${bool[0]}   ${vstype3}   ${virtualCallingModes3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id3}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE3}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype3}
    # ######################################################
    Set Test Variable  ${callingMode4}     ${CallingModes[3]}
    Set Test Variable  ${ModeId4}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus4}      ACTIVE
    ${Note4}=    FakerLibrary.sentence
    ${VScallingMode4}=   Create Dictionary   callingMode=${callingMode4}   value=${ModeId4}   status=${ModeStatus4}   instructions=${Note4}
    ${virtualCallingModes4}=  Create List  ${VScallingMode4}


    ${SERVICE4}=    FakerLibrary.name
    Set Test Variable  ${vstype4}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total2}  ${bool[0]}   ${bool[0]}   ${vstype4}   ${virtualCallingModes4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id4}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE4}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype4}
    # ####################################################


    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_s4}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE4}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p1_s3}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE3}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Suite Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}
    Set Suite Variable   ${p1_s1}   ${resp.json()[3]['id']}
    Set Suite Variable   ${P1SERVICE1}   ${resp.json()[3]['name']}
    Set Suite Variable   ${p1_s5}   ${resp.json()[4]['id']}
    Set Suite Variable   ${P1SERVICE5}   ${resp.json()[4]['name']}


    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  30
    ${eTime1}=  add_timezone_time  ${tz}  3  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}  ${p1_s5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId}  ${resp.json()}
    
    ${resp}=    Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s1}  ${queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}


    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-TeleserviceWaitlist-(Billable Subdomain)-2
    [Documentation]  Create Teleservice meeting request for waitlist in Zoom (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s2}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}


    ${resp}=  Create Waitlist Meeting Request   ${wid2}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid2}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-TeleserviceWaitlist-(Billable Subdomain)-3
    [Documentation]  Create Teleservice meeting request for waitlist in Phone (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${virtualService}=  Create Dictionary   ${CallingModes[2]}=${PUSERPH0}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s3}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${pwid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${pwid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}


    ${resp}=  Create Waitlist Meeting Request   ${pwid2}   ${CallingModes[2]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${pwid2}    ${CallingModes[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${pwid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-TeleserviceWaitlist-(Billable Subdomain)-4
    [Documentation]  Create Teleservice meeting request for waitlist in Googlemeet (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${virtualService}=  Create Dictionary   ${CallingModes[3]}=${GoogleMeet_url}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s4}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${cwid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}


    ${resp}=  Create Waitlist Meeting Request   ${cwid2}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${cwid2}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${cwid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Billable Subdomain)-UH1
    [Documentation]  Create Teleservice meeting request for waitlist (VirtualService callingmode is Whatsapp) in WhatsApp,Zoom,phone and Googlemeet (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

    # ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}  ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}

    ${resp}=  Create Waitlist Meeting Request   ${wid3}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid3}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid3}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid3}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid3}   ${CallingModes[2]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid3}    ${CallingModes[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid3}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid3}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Billable Subdomain)-5
    [Documentation]  Create Teleservice meeting request for waitlist in WhatsApp (ONLINE CHECKIN)

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}
    
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid4}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Waitlist Meeting Request   ${wid4}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid4}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Billable Subdomain)-6
    [Documentation]  Create Teleservice meeting request for waitlist in Zoom (ONLINE CHECKIN)

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME0}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pc_id1}  ${resp.json()[0]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Waitlist Meeting Request   ${wid5}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid5}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid5}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Billable Subdomain)-UH2
    [Documentation]  Create Teleservice meeting request for waitlist (VirtualService callingmode is Zoom) in WhatsApp,Zoom,phone and Googlemeet  (ONLINE CHECKIN)


    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME0}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid6}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request   ${wid6}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid6}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[2]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid6}    ${CallingModes[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid6}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid6}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-TeleserviceWaitlist-(Billable Subdomain)-7

    [Documentation]   Create waitlist teleservice Zoom meeting request Which  is already created
    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME0}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid7}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # step_1
    ${resp}=  Create Waitlist Meeting Request   ${wid7}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request   ${wid7}    ${CallingModes[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # step_2
    ${resp}=  Create Waitlist Meeting Request   ${wid7}   ${CallingModes[0]}  ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request   ${wid7}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid7}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Billable Subdomain)-8

    [Documentation]   Create waitlist teleservice Whatsapp meeting request Which  is already created
    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME0}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid8}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # step_1
    ${resp}=  Create Waitlist Meeting Request   ${wid8}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request   ${wid8}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # step_2
    ${resp}=  Create Waitlist Meeting Request   ${wid8}   ${CallingModes[1]}  ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request   ${wid8}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid8}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-TeleserviceWaitlist-UH3
    [Documentation]  Create waitlist teleservice meeting request without login
    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"



JD-TC-TeleserviceWaitlist-UH4
    [Documentation]  Consumer try to create waitlist teleservice meeting request 
    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"



JD-TC-TeleserviceWaitlist-UH5
    [Documentation]    Create waitlist teleservice meeting request  with invalid  waitlist id 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable   ${INVALID_Wid}   0000
    ${resp}=  Create Waitlist Meeting Request   ${INVALID_Wid}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WTLST_ID}"



# JD-TC-TeleserviceWaitlist-UH4
#     [Documentation]    Create waitlist teleservice meeting request  with invalid  Calling mode 
#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[5]}   ${waitlistedby[1]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"


JD-TC-TeleserviceWaitlist-UH6
    [Documentation]    Create waitlist teleservice meeting request  for a cancelled waitlist 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Get Waitlist By Id  ${wid6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[4]}

    ${resp}=  Create Waitlist Meeting Request   ${wid6}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_IS_CANCELLED}"



JD-TC-TeleserviceWaitlist-(Non billable Subdomain)-9
    [Documentation]  Create Teleservice meeting request for waitlist  in Zoom,WhatsApp,phone and Googlemeet (Walk-in checkin)
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+1081081
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accId2}=  get_acc_id  ${PUSERPH2}
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
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}
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
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  25  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P1queueId}  ${resp.json()}





    # ${resp}=   Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid22}=  get_id  ${CUSERNAME22}    
    # ${accId2}=  get_acc_id  ${PUSERPH2}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${consumerNote1}=   FakerLibrary.word
    #  # ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   0
    # ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    # ${resp}=  Consumer Add To WL With Virtual Service  ${accId2}  ${P1queueId}  ${DAY}  ${p2_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid10}  ${wid[0]}
    # ${resp}=  Get consumer Waitlist By Id   ${wid10}  ${accId2}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    # Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid22}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  0
    # Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${P1queueId}
    
    # ${resp}=    Enable Search Data
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid0}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pc_id0}  ${resp.json()[0]['id']}


    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid0}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid9} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid0}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid0}

    ${resp}=  Create Waitlist Meeting Request   ${wid9}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid9}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid9}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid9}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid9}   ${CallingModes[2]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid9}    ${CallingModes[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Create Waitlist Meeting Request   ${wid9}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid9}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid9}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-TeleserviceWaitlist-(Non billable Subdomain)-10
    [Documentation]  Create Teleservice meeting request for waitlist  in Zoom,WhatsApp,phone and Googlemeet (Online checkin)
    ${resp}=   Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid22}=  get_id  ${CUSERNAME22}    
    ${accId2}=  get_acc_id  ${PUSERPH2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
     # ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   0
    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId2}  ${P1queueId}  ${DAY}  ${p2_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pc_id2}  ${resp.json()[0]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid10}  ${accId2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid22}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${P1queueId}


    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${desc}=   FakerLibrary.word
    # Set Suite Variable  ${desc}
    # ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}  ${CallingModes[0]}=${ZOOM_id2}

    # ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   0
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid9}  ${wid[0]}
    # ${resp}=  Get Waitlist By Id  ${wid9} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P2SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p2_s1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         0

    ${resp}=  Create Waitlist Meeting Request   ${wid10}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid10}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid10}   ${CallingModes[1]}    ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"

    ${resp}=  Get Waitlist Meeting Request    ${wid10}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VIRTUAL_CALLING_MODES_INVALID}"


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid10}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


#   WAITLIST ACTIONS  

JD-TC-TeleserviceWaitlist-11
    [Documentation]  Create Teleservice meeting request for a started waitlist in Zoom (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s2}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TeleserviceWaitlist-12
    [Documentation]  Create Teleservice meeting request for a started waitlist in Whats-app (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s1}  ${queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TeleserviceWaitlist-13
    [Documentation]  Create Teleservice meeting request for two waitlist(one is started) in Whats-app (WALK-IN CHECKIN)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${p1_s1}  ${queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid1}

    ${resp}=  Provider Add To WL With Virtual Service  ${pcid3}  ${p1_s1}  ${queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid3}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid2}   ${CallingModes[1]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TeleserviceWaitlist-14
    [Documentation]  Create Teleservice meeting request for a done waitlist in Zoom (WALK-IN CHECKIN)   done

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}

    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid3}  ${p1_s2}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pcid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid3}

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[0]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TeleserviceWaitlist-15
    [Documentation]   Create Teleservice meeting request for a  waitlist in google meet(online chekin).
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1981892
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${accId0}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId0}

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
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  5  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${callingMode4}     ${CallingModes[3]}
    Set Test Variable  ${ModeId4}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus4}      ACTIVE
    ${Note4}=    FakerLibrary.sentence
    ${VScallingMode4}=   Create Dictionary   callingMode=${callingMode4}   value=${ModeId4}   status=${ModeStatus4}   instructions=${Note4}
    ${virtualCallingModes4}=  Create List  ${VScallingMode4}

    ${Total4}=   Random Int   min=100   max=500
    ${Total4}=  Convert To Number  ${Total4}  1
    ${description2}=   FakerLibrary.word
    ${SERVICE4}=    FakerLibrary.word
    Set Test Variable  ${vstype4}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total4}  ${bool[0]}   ${bool[0]}   ${vstype4}   ${virtualCallingModes4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id4}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE4}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total4}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype4}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_s4}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE4}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  30
    ${eTime1}=  add_timezone_time  ${tz}  3  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}    ${p1_s4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId}  ${resp.json()}
    
    ${resp}=    Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME0} 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[3]}=${GoogleMeet_url}
    Set Suite Variable    ${virtualService}
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId0}  ${queueId}  ${DAY}  ${p1_s4}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pc_id}  ${resp.json()[0]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${accId0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s4}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pc_id}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Waitlist Meeting Request   ${wid5}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid5}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist Meeting Details   ${wid5}   ${CallingModes[3]}     ${accId0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Waitlist Action    ${waitlist_actions[1]}   ${wid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[2]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TeleserviceWaitlist-16
    [Documentation]  Create Teleservice meeting request for a  waitlisted consumer and before starting the service and taken waitlist for the same service with same consumer

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid5}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pc_id5}  ${resp.json()[0]['id']}


    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${pc_id5}  ${p1_s4}  ${queueId}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${pc_id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pc_id5}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pc_id5}

    
    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[3]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME5} 
       
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${virtualService}=  Create Dictionary   ${CallingModes[3]}=${GoogleMeet_url}
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId0}  ${queueId}  ${DAY1}  ${p1_s4}  ${consumerNote1}  ${bool[0]}  ${virtualService}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"