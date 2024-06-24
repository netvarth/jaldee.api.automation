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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${GoogleMeet_url}    https://meet.google.com/gif-pqrs-abc
@{emptylist}

# ${JDN_AMT_INVALID}= Format String ${JDN_AMT_INVALID} ${jdn_disc_max[0]}


# ${Mode1}    Skype	   
# ${Mode2}	WhatsApp
# ${Mode3}    Imo




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

    

# Consumer Add To WL With Virtual Service

*** Test Cases ***

JD-TC-CreateVirtualService-(Billable Subdomain)-1

    [Documentation]   Create virtual service for a provider in billable domain with prepayment.

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+11810045
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

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # sleep   01s
    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ZOOM_id0}= Replace String ${ZOOM_url} [ZOOM_id] ${PUSERPH0}
    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERPH0}
    Set Suite Variable   ${ZOOM_id0}


    # Set Suite Variable   ${ZOOM_id0}    https://meet.google.com/cwo-tvub-uvs
    # Log  ${ZOOM_id0}

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

    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    


JD-TC-CreateVirtualService-(Billable Subdomain)-2
    [Documentation]   Create virtual service for a provider in billable domain with skype only active in Global level
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   status=INACTIVE    instructions=${instructions2} 
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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}



    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10102
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}


    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE2}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}



    



JD-TC-CreateVirtualService-(Billable Subdomain)-3
    [Documentation]   Create virtual service for a provider in billable domain with whatsapp only active in Global level
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=INACTIVE    instructions=${instructions1} 
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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10103
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    # Set Test Variable  ${whatsappId3}       ${PUSERPH_id}
    # Set Test Variable  ${whatsappStatus}   ACTIVE
    # ${Description2}=    FakerLibrary.word

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE3}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE3}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    



JD-TC-CreateVirtualService-(Billable Subdomain)-4
    [Documentation]   Create two virtual services for a provider in billable domain with and without prepayment using same virtual calling mode
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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



    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10106
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

  

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE6}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # ${vstype1}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype1}   ${virtualCallingModes}
    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE6}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    
  

    ${min_pre}=   Random Int   min=10   max=50
    ${Total2}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE7}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
  
    ${resp}=  Create virtual Service  ${SERVICE7}   ${description2}   3   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total2}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE7}  description=${description2}  serviceDuration=3   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${S_id1}  name=${SERVICE6}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Verify Response List  ${resp}  0  id=${S_id2}  name=${SERVICE7}  description=${description2}  serviceDuration=3   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}




JD-TC-CreateVirtualService-(Billable Subdomain)-5
    [Documentation]   Use different Zoom_id and  Different service type to create different Virtual services
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    # Set Suite Variable   ${PUSERPH0_id}  user_${PUSERPH0}_skype
    # Log  ${PUSERPH0_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


    ${Whatsapp_Pid1}=  Evaluate  ${PUSERNAME}+10107
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${Whatsapp_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes_list1}=  Create List  ${VirtualcallingMode1}


    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # Set Test Variable   ${vstype1}   audioService
    Set Test Variable  ${vstype1}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype1}   ${virtualCallingModes_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${Whatsapp_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


  
    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+80108
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}
    ${virtualCallingModes_list2}=  Create List  ${VirtualcallingMode2}

    ${min_pre2}=   Random Int   min=10   max=50
    ${Total2}=   Random Int   min=100   max=500
    ${min_pre2}=  Convert To Number  ${min_pre2}  1
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE9}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    # Set Test Variable   ${vstype2}   videoService
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE9}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes_list2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre2}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc2}




    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${S_id1}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Verify Response List  ${resp}  0  id=${S_id2}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre2}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}



JD-TC-CreateVirtualService-(Billable Subdomain)-6
    [Documentation]   Use different Zoom_id and  Same service type to create different Virtual services
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10108
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes_list1}=  Create List  ${VirtualcallingMode1}


    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # Set Test Variable   ${vstype}   audioService
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


    
    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+80108
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}
    ${virtualCallingModes_list2}=  Create List  ${VirtualcallingMode2}
    

    ${min_pre2}=   Random Int   min=10   max=50
    ${Total2}=   Random Int   min=100   max=500
    ${min_pre2}=  Convert To Number  ${min_pre2}  1
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE9}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    
    ${resp}=  Create virtual Service  ${SERVICE9}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes_list2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre2}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc2}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${S_id1}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Verify Response List  ${resp}  0  id=${S_id2}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre2}  totalAmount=${Total2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}

    


JD-TC-CreateVirtualService-(Billable Subdomain)-7
    [Documentation]   Use TWO virtual calling modes to create a single virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    # Set Suite Variable   ${PUSERPH_id}  user_${PUSERPH0}_skype
    # Log  ${PUSERPH_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20108
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${ZOOM_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${WHATSAPP_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    # Set Test Variable   @{VirtualcallingMode1}    ${SKYPE_details}   ${WHATSAPP_details}
    ${virtualCallingModes}=  Create List  ${ZOOM_details}   ${WHATSAPP_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # Set Test Variable   ${vstype}   audioService
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}


JD-TC-CreateVirtualService-(Billable Subdomain)-N1
    [Documentation]   Use TWO virtual calling modes to create a single virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20108
    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${GoogleMeet_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${GoogleMeet_details}   ${Whatsapp_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}



JD-TC-CreateVirtualService-(Billable Subdomain)-8
    [Documentation]   Use Google_meet and Whatsapp virtual calling modes to create a video services
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+105
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20118
    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${GoogleMeet_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${GoogleMeet_details}   ${Whatsapp_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}

 


JD-TC-CreateVirtualService-(Billable Subdomain)-9
    [Documentation]   Use Phone_call and Whatsapp virtual calling modes to create a audio services
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+110
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERPH0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20128
    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${Phone_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${Phone_details}   ${Whatsapp_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}




JD-TC-CreateVirtualService-(Non-Billable Subdomain)-10

    [Documentation]   Create virtual service for a provider in Non-billable domain.
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+1582
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

    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}



    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10109
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}


    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


   
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${Service_id1}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}






JD-TC-CreateVirtualService-(Non-Billable Subdomain)-11
    [Documentation]   Create virtual service for a provider in Non-billable domain  with Zoom only active in Global level
    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH2}
    clear_service  ${PUSERPH2}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=INACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10110
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE2}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    


    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${Service_id2}  name=${SERVICE2}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}




JD-TC-CreateVirtualService-(Non-Billable Subdomain)-12
    [Documentation]   Create virtual service for a provider in Non-billable domain with whatsapp only active in Global level
    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH2}
    clear_service  ${PUSERPH2}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=INACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10111
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}


    # Set Test Variable  ${skypeId3}          ${PUSERPH_id}
    # Set Test Variable  ${skypeStatus}      ACTIVE
    # ${Description1}=    FakerLibrary.word

    # Set Test Variable  ${whatsappId3}       ${PUSERPH_id}
    # Set Test Variable  ${whatsappStatus}   ACTIVE
    # ${Description2}=    FakerLibrary.word


    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE3}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE3}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id3}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${Service_id3}  name=${SERVICE3}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}




JD-TC-CreateVirtualService-(Non-Billable Subdomain)-13
    [Documentation]   Use different zoom_id and Different service type to create different Virtual services
    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH2}
    clear_service  ${PUSERPH2}
    Set Suite Variable   ${PUSERPH2_id}  user_${PUSERPH2}_skype
    Log  ${PUSERPH2_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH2}+111
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10114
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes_list1}=  Create List  ${VirtualcallingMode1}



    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # Set Test Variable   ${vstype1}   audioService
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype1}   ${virtualCallingModes_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id8}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


  
    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+41114
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}
    ${virtualCallingModes_list2}=  Create List  ${VirtualcallingMode2}

    ${min_pre2}=   Random Int   min=10   max=50
    ${Total2}=   Random Int   min=100   max=500
    ${min_pre2}=  Convert To Number  ${min_pre2}  1
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE9}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    # Set Test Variable   ${vstype2}   videoService
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE9}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes_list2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id9}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc2}


    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${Service_id8}  name=${SERVICE8}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Verify Response List  ${resp}  0  id=${Service_id9}  name=${SERVICE9}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype2}



JD-TC-CreateVirtualService-(Non-Billable Subdomain)-14
    [Documentation]   Use different  Zoom_id and Same service type to create different Virtual services
    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH2}
    clear_service  ${PUSERPH2}
    Set Suite Variable   ${PUSERPH2_id}  user_${PUSERPH2}_skype
    Log  ${PUSERPH2_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH2}+111
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10115
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes_list1}=  Create List  ${VirtualcallingMode1}




    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE10}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    # Set Test Variable   ${vstype}   audioService
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE10}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id10}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE10}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}




    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+81118
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Test Variable  ${callingMode2}     ${CallingModes[0]}
    Set Test Variable  ${ModeId2}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}
    ${virtualCallingModes_list2}=  Create List  ${VirtualcallingMode2}


    ${min_pre2}=   Random Int   min=10   max=50
    ${Total2}=   Random Int   min=100   max=500
    ${min_pre2}=  Convert To Number  ${min_pre2}  1
    ${Total2}=  Convert To Number  ${Total2}  1
    ${SERVICE11}=    FakerLibrary.word
    ${description2}=    FakerLibrary.word
    
    ${resp}=  Create virtual Service  ${SERVICE11}   ${description2}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes_list2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id11}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE11}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc2}


    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${Service_id10}  name=${SERVICE10}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
    Verify Response List  ${resp}  0  id=${Service_id11}  name=${SERVICE11}  description=${description2}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=0.0  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}

    



JD-TC-CreateVirtualService-UH1
    [Documentation]   Create virtual service without Provider Login

    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10116
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE2}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 



JD-TC-CreateVirtualService-UH2
    [Documentation]   Use Virtual calling mode as EMPTY while the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


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



    ${virtualCallingModes}=  Create List  @{EMPTY}
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${VIRTUAL_SERVICE_MODE_REQUIRED}"



JD-TC-CreateVirtualService-UH3
    [Documentation]   Use Virtual calling mode VALUE of ZOOM as EMPTY while the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${EMPTY}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ZOOM_ID_REQUIRED}"
    

JD-TC-CreateVirtualService-UH4
    [Documentation]   Use Virtual calling mode VALUE of WHATSAPP as EMPTY while the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${EMPTY}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}


    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WHATSAPP_NUMBER_REQUIRED}"
    


JD-TC-CreateVirtualService-UH5
    [Documentation]   Use Virtual calling mode VALUE of PHONE as EMPTY while the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${EMPTY}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PHONE_NUMBER_REQUIRED}"
    



JD-TC-CreateVirtualService-UH6
    [Documentation]   Use Virtual calling mode VALUE of GOOGLE_MEET as EMPTY while the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${EMPTY}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GOOGLEMEET_ID_REQUIRED}"
    


JD-TC-CreateVirtualService-UH7
    [Documentation]   Create Virtual Service for provider in billable domain without enabling virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10105
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}


    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE6}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${VIRTUAL_SERVICES_NOT_ENABLED}"

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateVirtualService-UH9
    [Documentation]   Use Zoom (Video Service Type) to create an Audio service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    # Set Suite Variable   ${PUSERPH_id}  user_${PUSERPH0}_skype
    # Log  ${PUSERPH_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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



    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+40108
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    ${Zoom_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${virtualCallingModes}=  Create List  ${Zoom_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable   ${vstype}   audioService
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${AUDIO_SERVICE_MODE_REQUIRED}"
  



JD-TC-CreateVirtualService-UH10
    [Documentation]   Use Phone_or_Whatsapp (Audio Service Type) to create a Video service

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    # Set Suite Variable   ${PUSERPH_id}  user_${PUSERPH0}_skype
    # Log  ${PUSERPH_id}
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERPH0}   status=ACTIVE    instructions=${instructions2} 
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

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}



    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+40108
    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${Phone_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${virtualCallingModes}=  Create List  ${Phone_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE8}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable   ${vstype}   videoService
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    ${resp}=  Create virtual Service  ${SERVICE8}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${VIDEO_SERVICE_MODE_REQUIRED}"




JD-TC-CreateVirtualService-(Billable Subdomain)-15
    [Documentation]   Use Google_meet and Whatsapp virtual calling modes to create a video services with lead time
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+105
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20118
    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${GoogleMeet_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${GoogleMeet_details}   ${Whatsapp_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}

 


JD-TC-CreateVirtualService-(Billable Subdomain)-16
    [Documentation]   Use Phone_call and Whatsapp virtual calling modes to create a audio services with lead time
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+110
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERPH0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20128
    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${Phone_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${Phone_details}   ${Whatsapp_details}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}



JD-TC-CreateVirtualService-(Billable Subdomain)-17
    [Documentation]   create virtual service for a user
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # delete_virtual_service  ${PUSERNAME27}
    # clear_service  ${PUSERNAME27}
    reset_user_metric  ${account_id}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[1]}

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

    ${u_id1}=  Create Sample User

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${USER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${USER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USER_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME5}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${USER_U1}   countryCode=${countryCodes[0]}   status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${USER_U1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id}=  Evaluate  ${USER_U1}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Suite Variable   ${ZOOM_Pid0}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    # ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${instructions1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Virtual Service For User  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  ${dep_id}  ${u_id1}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    # Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    # Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    # Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    # Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}



JD-TC-CreateVirtualService-(Billable Subdomain)-18
    [Documentation]   create virtual service for a user with lead time
    
    ${resp}=  Encrypted Provider Login  ${USER_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service  ${PUSERNAME27}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERPH_id}=  Evaluate  ${USER_U1}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Suite Variable   ${ZOOM_Pid0}


    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Virtual Service For User  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  ${dep_id}  ${u_id1}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


JD-TC-CreateVirtualService-(Billable Subdomain)-19
    [Documentation]   Use Google_meet and Whatsapp virtual calling modes to create a video services with internationalAmount with prepayment
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+105
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20118
    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${GoogleMeet_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${GoogleMeet_details}   ${Whatsapp_details}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id20}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}


JD-TC-CreateVirtualService-(Billable Subdomain)-20
    [Documentation]   Use Google_meet and Whatsapp virtual calling modes to create a video services with internationalAmount without prepayment
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+105
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20118
    Set Test Variable  ${callingMode1}     ${CallingModes[3]}
    Set Test Variable  ${ModeId1}          ${GoogleMeet_url}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${GoogleMeet_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${GoogleMeet_details}   ${Whatsapp_details}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[0]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id20}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${GoogleMeet_url}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}

    Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount



JD-TC-CreateVirtualService-(Billable Subdomain)-21
    [Documentation]   Use Phone_call and Whatsapp virtual calling modes to create a audio services with internationalAmount with prepayment
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+110
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERPH0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20128
    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${Phone_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${Phone_details}   ${Whatsapp_details}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}


JD-TC-CreateVirtualService-(Billable Subdomain)-22
    [Documentation]   Use Phone_call and Whatsapp virtual calling modes to create a audio services with internationalAmount without prepayment
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    
    ${PUSERPH1}=  Evaluate  ${PUSERPH0}+110
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERPH0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20128
    Set Test Variable  ${callingMode1}     ${CallingModes[2]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence

    Set Test Variable  ${callingMode2}     ${CallingModes[1]}
    Set Test Variable  ${ModeId2}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus2}      ACTIVE
    ${Desc2}=    FakerLibrary.sentence

    ${Phone_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}   

    ${Whatsapp_details}=   Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}   instructions=${Desc2}

    
    ${virtualCallingModes}=  Create List  ${Phone_details}   ${Whatsapp_details}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[0]}
    ${resp}=  Create virtual Service  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[0]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}
    Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount
    


JD-TC-CreateVirtualService-(Billable Subdomain)-23
    [Documentation]   create virtual service for a user with internationalAmount with prepayment
    
    ${resp}=  Encrypted Provider Login  ${USER_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    delete_virtual_service  ${PUSERNAME27}
    clear_service  ${PUSERNAME27}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERPH_id}=  Evaluate  ${USER_U1}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Suite Variable   ${ZOOM_Pid0}


    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create Virtual Service For User  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  ${dep_id}  ${u_id1}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}


JD-TC-CreateVirtualService-(Billable Subdomain)-24
    [Documentation]   create virtual service for a user with internationalAmount without prepayment
    
    ${resp}=  Encrypted Provider Login  ${USER_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    delete_virtual_service  ${PUSERNAME27}
    clear_service  ${PUSERNAME27}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERPH_id}=  Evaluate  ${USER_U1}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
    Set Suite Variable   ${ZOOM_Pid0}


    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create Virtual Service For User  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[0]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  ${dep_id}  ${u_id1}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=${servicecharge}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[1]}   virtualServiceType=${vstype}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount
  

*** Comments ***
### zoomurl validation removed

JD-TC-CreateVirtualService-UH8
    [Documentation]   Use invalid zoom url for the creation of a Virtual service
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    delete_virtual_service  ${PUSERPH0}
    clear_service  ${PUSERPH0}
    ${resp}=  Enable Disable Virtual Service  Disable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


    ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10111
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${PUSERPH_id}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ZOOM_ID}"
    





# JD-TC-CreateVirtualService-UH6
#     [Documentation]   Use virtual calling modes not present in Global level to create virtual service
#     ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     delete_virtual_service  ${PUSERPH0}
#     clear_service  ${PUSERPH0}
    
#     ${PUSERPH1}=  Evaluate  ${PUSERPH0}+101
#     ${resp}=  Enable Disable Virtual Service  Disable
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Enable Disable Virtual Service  Enable
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${instructions1}=   FakerLibrary.sentence
    # ${instructions2}=   FakerLibrary.sentence

    # ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    # ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    # ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    # ${resp}=  Update Virtual Calling Mode   ${vcm1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Virtual Calling Mode
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH0}
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
#     Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}


#     ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+30108
#     Set Test Variable  ${callingMode1}     ${CallingModes[4]}
#     Set Test Variable  ${ModeId1}          ${PUSERPH_id}
#     Set Test Variable  ${ModeStatus1}      ACTIVE
#     ${Description1}=    FakerLibrary.sentence

   

#     ${IMO_details}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}   

#     ${virtualCallingModes}=  Create List  ${IMO_details}

#     ${min_pre1}=   Random Int   min=10   max=50
#     ${Total1}=   Random Int   min=100   max=500
#     ${min_pre1}=  Convert To Number  ${min_pre1}  1
#     ${Total1}=  Convert To Number  ${Total1}  1
#     ${SERVICE8}=    FakerLibrary.word
#     ${description1}=    FakerLibrary.word
#     Set Test Variable   ${vstype}   audioService
   
#     ${resp}=  Create virtual Service  ${SERVICE8}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422 
#     Should Be Equal As Strings  "${resp.json()}"  "${VIRTUAL_CALLING_MODES_INVALID}"
   


