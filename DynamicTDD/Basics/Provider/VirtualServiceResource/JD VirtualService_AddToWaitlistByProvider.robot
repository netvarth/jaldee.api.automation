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







*** Test Case ***
JD-TC-VirtualService_Add To WaitlistByProvider-1
    [Documentation]  Provider add Consumer and his family member to waitlist (Non billable Subdomain)

    # ${UserZOOM_id0}=  Format String  ${ZOOM_url}  ${CUSERNAME0}

    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+1591951
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
    Should Be Equal As Strings    ${resp.json()}    true
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

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

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


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
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  25  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P1queueId}  ${resp.json()}
    
    # ${resp}=    Enable Search Data
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cidfor}  ${resp.json()}
    Set Suite Variable  ${WHATSAPP_id2}   ${CUSERNAME0}

    ${virtualService1}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    Set Suite Variable  ${virtualService1}
    ${virtualService2}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}
    Set Suite Variable  ${virtualService2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}




    ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor}



    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-2
    [Documentation]  Provider add Consumer to waitlist (Virtual service without prepayment, Billable subdomain)

    ${PUSERPH0}=  Evaluate  ${PUSERNAME} + 1591952
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
    Should Be Equal As Strings    ${resp.json()}    true
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${PUSERPH0_id}  user_${PUSERPH0}_skype
    Log  ${PUSERPH0_id}
    ${accId}=  get_acc_id  ${PUSERPH0}

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




    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+50505
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}
    


    ${Total2}=   Random Int   min=100   max=500
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE2}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total2}  ${bool[0]}   ${bool[0]}   ${vstype2}   ${virtualCallingModes}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE2}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype2}
    
  
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Suite Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}


    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId}  ${resp.json()}
    
    # ${resp}=    Enable Search Data
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}


    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-VirtualService_Add To WaitlistByProvider-3
	[Documentation]  Provider removes consumer waitlisted for a service and again add to the waitlist of same service and another service from same queue
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 


    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
  
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
   
JD-TC-VirtualService_Add To WaitlistByProvider-4
	[Documentation]  consumer cancels the waitlist then provider add him again into that waitlist for the same service


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}  ${accId} 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
       
        
    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}


    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-5
	[Documentation]  A Consumer Added To Waitlist for same service in diffrent queue

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${p1queue2}=    FakerLibrary.word
    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity2}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity2}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId2}  ${resp.json()}



    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 
    
    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId2}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
  



JD-TC-VirtualService_Add To WaitlistByProvider-6
	[Documentation]  A Consumer Added To Waitlist for different services of different queue

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 


    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId2}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-7
    [Documentation]  Add Consumer To future waitlist (Virtual service Without Prepayment)
      
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  3  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-8
    [Documentation]  Add Consumer to Future waitlist of different queues for same service

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId2}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-9
    [Documentation]   future waitlist consumer waitlisted in diffrent service in diffrent queue

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId2}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-10
    [Documentation]  provider have two location. Add same consumer to waitlist (same service in different Location)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
   
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE5}=    FakerLibrary.word
    ${description5}=    FakerLibrary.word
    # ${vstype1}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE5}   ${description5}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype1}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id5}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE5}  description=${description5}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}
  
    ${SERVICE6}=    FakerLibrary.word
    ${description6}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description6}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id6}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE6}  description=${description6}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s5}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE5}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s6}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE6}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Suite Variable  ${p1_tz1}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue3}=    FakerLibrary.word
    ${capacity1}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity1}  ${p1_l1}  ${p1_s5}  ${p1_s6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId3}  ${resp.json()}
    

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${p1_tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${p1_tz2}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  45  
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l2}   ${resp.json()}

    ${p1queue4}=    FakerLibrary.word
    ${sTime2}=  add_timezone_time  ${tz}  0  50  
    ${eTime2}=  add_timezone_time  ${tz}  1  05  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity2}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity2}  ${p1_l2}  ${p1_s5}  ${p1_s6} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId4}  ${resp.json()}

    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s6}  ${queueId3}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE6}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s6}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s6}  ${queueId4}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE6}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s6}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-11
    [Documentation]  in current day waitlist, add consumer and his Family Members
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${C_fid2}   ${resp.json()}

    comment   Add same family member in Provider_consumer table
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid2}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cidfor2}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-12
    [Documentation]  in Future waitlist, add conumer and his family member

    # ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
       
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ['Male', 'Female']
    # ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # Set Suite Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-VirtualService_Add To WaitlistByProvider-13
    [Documentation]  same family member added to waitlist  (diffrent service,  same queue)
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-14
    [Documentation]  same family member added to waitlist  (same service,  diffrent queue)
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId2}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-15
    [Documentation]  Add Consumer to future waitlist  (diffrent location , same service ,same provider)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}
    
    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  add_time   2  10
    # ${eTime1}=  add_time   2  25
    # ${p1queue3}=    FakerLibrary.word
    # ${capacity1}=  FakerLibrary.Numerify  %%
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity1}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${queueId_3}  ${resp.json()}
    

    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  add_time   0  10
    # ${eTime}=  add_timezone_time  ${tz}  3  45  
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p1_l2}   ${resp.json()}

    # ${p1queue4}=    FakerLibrary.word
    # ${sTime2}=  add_timezone_time  ${tz}  2  30  
    # ${eTime2}=  add_timezone_time  ${tz}  2  45  
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${capacity2}=  FakerLibrary.Numerify  %%
    # ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity2}  ${p1_l2}  ${p1_s1}  ${p1_s1} 
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${queueId_4}  ${resp.json()}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId3}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId4}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-16
    [Documentation]  Consumer remove his own  future checkin from waitlist and again add for same service
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    # Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    # Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    # Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
       
        
    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-VirtualService_Add To WaitlistByProvider-17
    [Documentation]  Provider removes future checkin of a Consumer from waitlist after that provider add same consumer again in same service
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    # Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    # Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    # Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2} 

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-18
    [Documentation]  Consumer remove his family members  future checkin from waitlist and again add for same service
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    # Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    # Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    # Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
       
        
    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}


    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
 

JD-TC-VirtualService_Add To WaitlistByProvider-19
    [Documentation]  Provider removes future checkin of a Consumer (FAMILY MEMBER) from waitlist and again consumer add again in same service
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    # Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    # Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    # Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc2}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}


    ${desc3}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc3}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-20
    [Documentation]  Provider add a consumer, after that consumer try to take checkin for that same service again for his family member
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    # Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    # Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    # Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid10} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${C_fid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid11}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cidfor2}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeId']}  ${C_fid2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid10}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid11}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-21
    [Documentation]  Provider add a consumer, after that consumer try add his family member to waitlist for that same service again
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  7  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[1]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=5  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByProvider-UH1
    [Documentation]  Add to waitlist for a Virtual_service without login
    
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  6  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-VirtualService_Add To WaitlistByProvider-UH2
    [Documentation]  the consumer get added to waitlist for a Virtual_service  , try to change Checkin status to STARTED  

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accId}=  get_acc_id  ${PUSERPH0}

    
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
   
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE7}=    FakerLibrary.word
    ${description7}=    FakerLibrary.word
    # ${vstype1}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE7}   ${description7}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype1}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id7}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE7}  description=${description7}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}
  
    ${SERVICE8}=    FakerLibrary.word
    ${description8}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description8}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id6}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description8}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}


    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s7}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE7}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s8}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE8}   ${resp.json()[0]['name']}
    


    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue5}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s7}  ${p1_s8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId_5}  ${resp.json()}



    # ${min_pre}=   Random Int   min=10   max=50
    # ${Total}=   Random Int   min=100   max=500
    # ${min_pre}=  Convert To Number  ${min_pre}  1
    # ${Total}=  Convert To Number  ${Total}  1
    # ${SERVICE4}=    FakerLibrary.word
    # ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    # Set Test Variable  ${vstype}  ${vservicetype[1]}
    # ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Suite Variable  ${S_id}  ${resp.json()} 
    # ${resp}=   Get Service By Id  ${S_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}


    # ${resp}=  Get Service
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    # Set Suite Variable   ${p1_s4}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${P1SERVICE4}   ${resp.json()[0]['name']}
 
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s7}  ${queueId_5}  ${DAY}  ${desc1}  ${bool[0]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[2]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-UH3
    [Documentation]  the consumer get added to waitlist for a Virtual_service  , try to change Checkin status to arrived  
    clear_queue    ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accId}=  get_acc_id  ${PUSERPH0}

    
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
   
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE7}=    FakerLibrary.word
    ${description7}=    FakerLibrary.word
    # ${vstype1}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE7}   ${description7}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype1}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id7}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE7}  description=${description7}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}
  
    ${SERVICE8}=    FakerLibrary.word
    ${description8}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description8}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id6}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description8}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s7}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE7}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s8}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE8}   ${resp.json()[0]['name']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue5}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s7}  ${p1_s8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId_5}  ${resp.json()}
 
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s7}  ${queueId_5}  ${DAY}  ${desc1}  ${bool[0]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***
JD-TC-VirtualService_Add To WaitlistByProvider-UH4
	[Documentation]  Add Comsumer To Waitlist for the Same Services Two Times
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-VirtualService_Add To WaitlistByProvider-UH5
    [Documentation]  Reaches the waitlist  maximum capacity and check it
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  
    ${p1queue6}=    FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue6}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${p1_l1}  ${p1_s7}  ${p1_s8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_6}  ${resp.json()}
    
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s8}  ${queueId_6}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE8}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s8}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s7}  ${queueId_6}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200  

JD-TC-VirtualService_Add To WaitlistByProvider-UH6
	[Documentation]  Add Consumer To Future Waitlist ,provider in holiday
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    ${P0Queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${P0Queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s7}  ${p1_s8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P0QueueId}  ${resp.json()}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${description}=   FakerLibrary.word
    # ${resp}=  Create Holiday  ${FUTURE_DATE}  ${holidayname}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${hId}  ${resp.json()}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${FUTURE_DATE}  ${FUTURE_DATE}  ${EMPTY}  ${sTime1}  ${eTime1}  ${description}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s8}  ${P0QueueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}" 

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
      

JD-TC-VirtualService_Add To WaitlistByProvider-UH7
	[Documentation]  invalid provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${INVALID_Consumer_ID}=  get_acc_id  ${Invalid_CUSER}
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${INVALID_Consumer_ID}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ID}"    
    
JD-TC-VirtualService_Add To WaitlistByProvider-UH8 
    [Documentation]   Add to waitlist After Business time
   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Update Waitlist Settings  ${calc_mode [0]}  0  true  true  true  true  ${Empty}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Suite Variable  ${p1_tz1}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    ${eTime1}=  db.subtract_timezone_time  ${tz}   0  20

    ${p1queue8}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_8}  ${resp.json()}

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId_8}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId_8}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${desc2}=   FakerLibrary.word
    # ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId_8}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${WHATSAPP_id2}  ${ZOOM_id2}   ${cidfor2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s2}  ${queueId_8}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

JD-TC-VirtualService_Add To WaitlistByProvider-UH9
    [Documentation]  add to waitlist w1 and try to change previously cancelled checkin into CHECKIN status of a single consumer
    Comment  step 1:Cancel one checkin
    Comment  step 2:add to waitlist w2  same service again
    Comment  step 3:change waitlist status  from cancell to checkin
   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${DAY}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-UH10
    [Documentation]  add to Future waitlist w1 and try to change previously cancelled checkin into CHECKIN status of a single consumer
    Comment  step 1:Cancel one checkin from future waitlist
    Comment  step 2:add to future waitlist w2  same service again
    Comment  step 3:change waitlist status  from cancell to checkin
   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc2}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc2}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cidfor2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidfor2}

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-UH11
    [Documentation]  Provider add a consumer, after that consumer try to take checkin for that same service again
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  7  
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid6}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid6}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-UH12
    [Documentation]  Consumer takes checkin, after that provider try to add that customer again for that same service
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[1]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cid2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${desc1}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid2}  ${p1_s1}  ${queueId}  ${FUTURE_DATE}  ${desc1}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByProvider-UH13
    [Documentation]  Add consumer to waitlist with an invalid Zoom url.
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${PUSERPH2}

    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid4}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid4}  ${resp.json()[0]['id']}
 
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p2_s1}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P2SERVICE1}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p2_s2}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P2SERVICE2}   ${resp.json()[1]['name']}
   
    Set Test Variable   ${INVALID_ZOOM_id2}   ${PUSERPH2}
    ${Invalid_VS}=  Create Dictionary   ${CallingModes[0]}=${INVALID_ZOOM_id2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid4}  ${p2_s1}  ${P1queueId}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${Invalid_VS}   ${cid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ZOOM_ID}"

# JD-TC-Add To WaitlistByConsumer-CLEAR
#     [Documentation]  Clear location, Queue, Waitlist
#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
#     clear_location  ${PUSERPH0}

#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings  ${resp.status_code}  200
