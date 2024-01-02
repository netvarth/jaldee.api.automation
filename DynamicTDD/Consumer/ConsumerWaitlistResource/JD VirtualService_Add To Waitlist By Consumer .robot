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
${digits}       0123456789
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

*** Test Case ***
JD-TC-VirtualService_Add To WaitlistByConsumer-1
    [Documentation]  Consumer joins to waitlist of a valid provider (Virtual service without prepayment)
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+22334455
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
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


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

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    # ${resp}=  pyproviderlogin  ${PUSERPH0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages
    # Should Be Equal As Strings  ${resp[1]}  200
    # ${resp}=  Get GalleryOrlogo image  logo
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

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

    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Enable Tax
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  payuVerify  ${accId}
    # Log  ${resp}
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${accId}  ${merchantid}

    # ${resp}=  Enable Future Checkin                                              
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+10101
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
    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
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
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId}  ${resp.json()}
    
    ${resp}=    Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}

    ${USERPH1_id}=  Evaluate  ${CUSERNAME2}+10001
    ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${USERPH1_id}

    Set Suite Variable  ${ZOOM_id}    ${ZOOM_Pid1}
    Set Suite Variable  ${WHATSAPP_id}   ${USERPH1_id}
    
    ${USERPH2_id}=  Evaluate  ${CUSERNAME2}+10111
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${USERPH2_id}

    Set Suite Variable  ${ZOOM_id2}    ${ZOOM_Pid2}
    Set Suite Variable  ${WHATSAPP_id2}   ${USERPH2_id}

    ${virtualService1}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    Set Suite Variable  ${virtualService1}
    ${virtualService2}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}
    Set Suite Variable  ${virtualService2}
        
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-2
	[Documentation]  Provider removes consumer waitlisted for a service and consumer joins the waitlist of the same service and another service of same queue
    
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

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME4}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s3}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid3}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1   appxWaitingTime=5  waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-3
	[Documentation]  consumer cancels the waitlist then consumer gets waitlisted for the same service again
   
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-4
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
    Set Suite Variable  ${queueId_2}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_2}  ${DAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_2}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-5
	[Documentation]  A Consumer Added To Waitlist for different services of different queue
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_2}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=0   waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_2}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-6
    [Documentation]  Add Consumer To future waitlist (Virtual service Without Prepayment)
      
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  3  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}" 

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-7
    [Documentation]  Add Consumer to Future waitlist of different queues for same service
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}  
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${Pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_2}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_2}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-8
    [Documentation]   Add Consumer to Future waitlist of different queues for different services
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_2}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=0   waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_2}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-9
    [Documentation]  provider have two location. Add same consumer to waitlist (same service in different Location)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}

    ${name_list}=  Create List
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${srv_length}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${srv_length}
        Append To List   ${name_list}  ${resp.json()[${i}]['name']}
    END
   
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    FOR  ${i}  IN RANGE   5
        ${SERVICE5}=  FakerLibrary.Word
        ${status1} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${name_list}  ${SERVICE5}
        Log Many  ${status1} 	${value}
        Continue For Loop If  '${status1}' == 'FAIL'
        Run Keyword If  '${status1}' == 'PASS'  Append To List   ${name_list}  ${SERVICE5}
        Exit For Loop IF   '${status1}' == 'PASS'
    END
    
    ${Total}=   Random Int   min=100   max=500
    ${Total}=  Convert To Number  ${Total}  1
    # ${SERVICE5}=    FakerLibrary.word
    ${description5}=    FakerLibrary.word
    # ${vstype1}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype1}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE5}   ${description5}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype1}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id5}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE5}  description=${description5}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Description1}
  
    FOR  ${i}  IN RANGE   5
        ${SERVICE6}=  FakerLibrary.Word
        ${status2} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${name_list}  ${SERVICE6}
        Log Many  ${status2} 	${value}
        Continue For Loop If  '${status2}' == 'FAIL'
        Run Keyword If  '${status2}' == 'PASS'  Append To List   ${name_list}  ${SERVICE6}
        Exit For Loop IF   '${status2}' == 'PASS'
    END

    # ${SERVICE6}=    FakerLibrary.word
    ${description6}=    FakerLibrary.word
    # ${vstype2}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype2}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description6}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype2}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${S_id6}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE6}  description=${description6}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype2}
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

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${q_list}=  Create List
    ${q_length}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${q_length}
        Append To List   ${q_list}  ${resp.json()[${i}]['name']}
    END
    FOR  ${i}  IN RANGE   5
        ${p1queue3}=  FakerLibrary.Word
        ${status1} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${q_list}  ${p1queue3}
        Log Many  ${status1} 	${value}
        Continue For Loop If  '${status1}' == 'FAIL'
        Run Keyword If  '${status1}' == 'PASS'  Append To List   ${q_list}  ${p1queue3}
        Exit For Loop IF   '${status1}' == 'PASS'
    END
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    # ${p1queue3}=    FakerLibrary.word
    ${capacity1}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity1}  ${p1_l1}  ${p1_s5}  ${p1_s6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId_3}  ${resp.json()}

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
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  45  
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l2}   ${resp.json()}

    FOR  ${i}  IN RANGE   5
        ${p1queue4}=  FakerLibrary.Word
        ${status1} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${q_list}  ${p1queue4}
        Log Many  ${status1} 	${value}
        Continue For Loop If  '${status1}' == 'FAIL'
        Run Keyword If  '${status1}' == 'PASS'  Append To List   ${q_list}  ${p1queue4}
        Exit For Loop IF   '${status1}' == 'PASS'
    END
    
    # ${p1queue4}=    FakerLibrary.word
    ${sTime2}=  add_timezone_time  ${tz}  0  50  
    ${eTime2}=  add_timezone_time  ${tz}  1  05  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity2}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity2}  ${p1_l2}  ${p1_s5}  ${p1_s6} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId_4}  ${resp.json()}

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  1  30  
    # ${eTime1}=  add_timezone_time  ${tz}  2  00  
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
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # ${eTime}=  add_timezone_time  ${tz}  3  15  
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p1_l2}   ${resp.json()}

    # ${p1queue4}=    FakerLibrary.word
    # ${sTime2}=  add_timezone_time  ${tz}  2  15  
    # ${eTime2}=  add_timezone_time  ${tz}  2  45  
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${capacity2}=  FakerLibrary.Numerify  %%
    # ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity2}  ${p1_l2}  ${p1_s1}  ${p1_s1} 
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${queueId_4}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    


    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_3}  ${DAY}  ${p1_s5}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  
    #  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE5}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s5}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_3}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_4}  ${DAY}  ${p1_s5}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=0   waitlistedBy=CONSUMER  
    # personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE5}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s5}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_4}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-10
    [Documentation]  in current day waitlist, add consumer and his Family Members
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}
    ${DAY}=  db.get_date_by_timezone  ${tz}    
    ${firstname}=  FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable   ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable   ${gender}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}


    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    
    # ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    # clear_customer   ${PUSERPH0}

    # ${resp}=  AddCustomer  ${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
    
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


   
JD-TC-VirtualService_Add To WaitlistByConsumer-11
    [Documentation]  in Future waitlist, add conumer and his family member
   
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  4  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid1}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid1}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}



JD-TC-VirtualService_Add To WaitlistByConsumer-12
    [Documentation]  same family member added to waitlist  for diffrent services of same queue
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid2}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid2}   ${resp.json()['waitlistingFor'][0]['id']}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid2}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}



JD-TC-VirtualService_Add To WaitlistByConsumer-13
    [Documentation]  same family member added to waitlist  for same service of diffrent queues
    
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid3}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_2}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_2}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid3}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-VirtualService_Add To WaitlistByConsumer-14
    [Documentation]  add consumer to future waitlist  (same provider, diffrent location , same service)
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  8  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_3}  ${FUTURE_DATE}  ${p1_s6}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE6}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s6}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_3}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_4}  ${FUTURE_DATE}  ${p1_s6}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=0   waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE6}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s6}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_4}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-15
    [Documentation]  Consumer remove his own  future checkin from waitlist and again add for same service
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  3  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}


    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-16
    [Documentation]  Provider removes future checkin of a Consumer from waitlist and consumer again add himself into that same service
        
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME2}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  6  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons__id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid3}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid4}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1   appxWaitingTime=5  waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid4}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid5}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-17
    [Documentation]  Consumer remove his family members  future checkin from waitlist and consumer again add himself for same service
    
    ${resp}=   Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME10}
   
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}    

    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  3  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid0}   ${resp.json()['waitlistingFor'][0]['id']}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  AddCustomer  ${CUSERNAME10}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid0}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid0}  ${resp.json()[1]['id']}
    ${resp}=  ListFamilyMemberByProvider  ${cid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid0}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-VirtualService_Add To WaitlistByConsumer-18
    [Documentation]  Provider removes future checkin of a Consumer (FAMILY MEMBER) from waitlist and consumer add himself again in same service
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2} 

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor1}   ${resp.json()}
   
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  6  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}
    Set Test Variable  ${cfid5}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1   appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s3}  ${consumerNote}  ${bool[0]}  ${virtualService1}   ${cidfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid3}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${cidfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1   appxWaitingTime=5  waitlistedBy=CONSUMER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1    appxWaitingTime=5   waitlistedBy=CONSUMER  personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[2]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${cfid5}
    Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
    Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}


JD-TC-VirtualService_Add To WaitlistByConsumer-UH1
    [Documentation]  Add to waitlist for a Virtual_service without login
    
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  6  
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-VirtualService_Add To WaitlistByConsumer-UH2
    [Documentation]   Add a provider to the waitlist
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  6  
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NO_ACCESS_TO_URL}"

JD-TC-VirtualService_Add To WaitlistByConsumer-UH3
    [Documentation]  the consumer add to waitlist for a Virtual_service with prepayment  , try to change prepaymentPending to STARTED 
    
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
    ${SERVICE4}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}

    ${SERVICE5}=    FakerLibrary.word
    ${resp}=  Create virtual Service  ${SERVICE5}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s7}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE7}   ${resp.json()[1]['name']}
    Set Suite Variable   ${p1_s8}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE8}   ${resp.json()[0]['name']}
   
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p1_l3}   ${resp.json()}


    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${eTime1}=  add_timezone_time  ${tz}  0  30  
    # ${p1queue5}=    FakerLibrary.word
    # ${capacity}=  FakerLibrary.Numerify  %%
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${resp}=  Create Queue  ${p1queue5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l3}  ${p1_s3}  ${p1_s4}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${queueId_5}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${p1queue5}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s7}  ${p1_s8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${queueId_5}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id}   ${resp.json()[1]['id']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME10}

    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s7}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cons_id}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Waitlist Today  
    Log   ${resp.json()}
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Waitlist Action  STARTED  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${WAITLIST_STATUS_NOT_CHANGEABLE}=  Format String  ${WAITLIST_STATUS_NOT_CHANGEABLE}  ${wl_status[3]}   ${wl_status[2]}
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

    ${resp1}=  Get Waitlist Today  
    Log   ${resp1.json()}
    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    

JD-TC-VirtualService_Add To WaitlistByConsumer-UH4
	[Documentation]  the consumer add to waitlist for a service with prepayment , try to change prepaymentPending to Cancel 
    
    ${resp}=   Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME3}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s8}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE8}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s8}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id3}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-UH5
    [Documentation]  the consumer add to waitlist for a Virtual_service with prepayment  , try to change prepaymentPending to checkedIn 
    
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME4}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s8}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE8}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s8}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id4}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Waitlist Action  CHECK_IN  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PAYMENT_NOT_DONE}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH6
    [Documentation]  the consumer add to waitlist for a Virtual_service with prepayment  , try to change prepaymentPending to arrived. 
    
    ${resp}=   Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME5}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s7}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id5}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s7}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id5}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${WAITLIST_STATUS_NOT_CHANGEABLE}=  Format String  ${WAITLIST_STATUS_NOT_CHANGEABLE}  ${wl_status[3]}   ${wl_status[1]}
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH7
	[Documentation]  Add To Waitlist By Consumer for the Same Services Two Times
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}" 

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH8
	[Documentation]  Add To Waitlist By Consumer ,provider  disable online Checkin
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}

    ${resp}=  Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ONLINE_CHECKIN_OFF}"

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}

    ${resp}=  Enable Online Checkin                                              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH9 
	[Documentation]  Add To Waitlist By Consumer ,provider  disable Waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    

    ${resp}=  Disable Waitlist
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2} 
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_NOT_ENABLED}"
    ${resp}=  Enable Waitlist                                              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}" 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    
    ${resp}=  Enable Waitlist                                              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH10
	[Documentation]  Add to Waitlist By Consumer into Disabled Queue
 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    
    ${resp}=  Disable Queue  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${QUEUE_DISABLED}"

    ${resp}=  Enable Queue  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Queue  ${queueId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-UH11
	[Documentation]  Add To Waitlist By Consumer ,provider  disable Future Checkin
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}

    ${resp}=  Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${TOMORROW}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${FUTURE_CHECKIN_DISABLED}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Future Checkin                                              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-UH12
	[Documentation]  Add To Waitlist By Consumer ,service and queue are diffrent
    
	${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s7}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_NOT_AVAILABLE}" 


JD-TC-VirtualService_Add To WaitlistByConsumer-UH13
    [Documentation]  Reaches waitlist  maximum capacity and check it
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${p1queue6}=    FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue6}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_6}  ${resp.json()}
    
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}    

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_6}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_6}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_6}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}" 

    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-VirtualService_Add To WaitlistByConsumer-UH14
    [Documentation]  Add To Waitlist By Consumer service DISABLED 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Disable service   ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SERVICE}"  
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Enable service  ${p1_s1}                                              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

          
JD-TC-VirtualService_Add To WaitlistByConsumer-UH15
	[Documentation]  Add To Waitlist By Consumer (provider in holiday)
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  4  10
    ${eTime1}=  add_timezone_time  ${tz}  4  30  
    ${P0Queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${P0Queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P0QueueId}  ${resp.json()}

    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${P0QueueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${HOLIDAY_NON_WORKING_DAY}" 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
JD-TC-VirtualService_Add To WaitlistByConsumer-UH16
	[Documentation]  invalid provider
    ${INVALID_PROVIDER_ID}=  get_acc_id  ${Invalid_CUSER}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${INVALID_PROVIDER_ID}  ${queueId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"   "${ACCOUNT_NOT_EXIST}"    
    Should Be Equal As Strings  ${resp.status_code}  404
   

JD-TC-VirtualService_Add To WaitlistByConsumer-UH17
    [Documentation]  Add To Waitlist By Consumer, Location Disabled  
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERPH0}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    
    ${sTime1}=  add_timezone_time  ${tz}  4  35
    ${eTime1}=  add_timezone_time  ${tz}  5  00  
    ${p1queue7}=  FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l2}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_7}  ${resp.json()}

    ${resp}=  Disable Location  ${p1_l2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_7}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Enable Location  ${p1_l2}                                          
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-VirtualService_Add To WaitlistByConsumer-UH18  
    [Documentation]   Add to waitlist After Business time
   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERPH0}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Suite Variable  ${p1_tz1}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    ${eTime1}=  db.subtract_timezone_time  ${tz}   0  10
    ${p1queue8}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_8}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${CUSER_FOR}   ${resp.json()}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_8}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_BUS_HOURS_END}"

JD-TC-VirtualService_Add To WaitlistByConsumer-UH19
    [Documentation]  add to waitlist w1 and cancell the waitlist
    Comment  add to waitlist w2  same service again
    Comment  change waitlist status  from cancell to checkin
   
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${TODAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER 

    ${resp}=  Cancel Waitlist  ${uuid}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[4]}  partySize=1  waitlistedBy=CONSUMER 

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${TODAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid1}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER  

    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  CHECK_IN  ${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-VirtualService_Add To WaitlistByConsumer-UH20
    [Documentation]  add to waitlist for future w1 and cancell the waitlist
    Comment  add to waitlist w2 for futur same service again
    Comment  change waitlist status  from cancell to checkin

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${CUSER_FOR}   ${resp.json()}  
    ${FUTURE_DATE}=  db.add_timezone_date  ${tz}  5  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER 

    ${resp}=  Cancel Waitlist  ${uuid}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[4]}  partySize=1  waitlistedBy=CONSUMER 

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid1}  ${accId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_DATE}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER  

    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  CHECK_IN  ${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-VirtualService_Add To WaitlistByConsumer-UH21
    [Documentation]  Add consumer to waitlist when service time exceeds queue time.
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Waitlist Settings  ${calc_mode [0]}  0  true  true  true  true  ${Empty}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    ${accId}=  get_acc_id  ${PUSERPH0}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Suite Variable  ${p1_tz1}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  5  50
    ${eTime1}=  add_timezone_time  ${tz}   6  00
    ${p1queue9}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue9}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${queueId_9}  ${resp.json()}

    # ${resp}=  Get Waitlist Today  service-eq=${p1_s3}
    # Log  ${resp.json()}
    # ${len}=  Get Length  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${cid}=  get_id  ${CUSERNAME30}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${CUSER_FOR}   ${resp.json()}
    
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_9}  ${DAY}  ${p1_s3}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${CUSER_FOR}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_9}
    Set Test Variable  ${cfid30}   ${resp.json()['waitlistingFor'][0]['id']}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_9}  ${DAY}  ${p1_s2}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${CUSER_FOR}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_9}

    ${consumerNote3}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_9}  ${DAY}  ${p1_s1}  ${consumerNote3}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}" 

   
    ${resp}=  Cancel Waitlist  ${wid1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME30}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid30}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-VirtualService_Add To WaitlistByConsumer-UH22
    [Documentation]  Add consumer to waitlist with an invalid Zoom url.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${INVALID_ZOOM_Cid}=  Create Dictionary   ${CallingModes[0]}=${CUSERNAME10}
    Set Suite Variable  ${virtualService1}
    ${FUTURE_DATE}=  db.db.add_timezone_date  ${tz}  10  
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${FUTURE_DATE}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${INVALID_ZOOM_Cid}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_ZOOM_ID}"

JD-TC-VirtualService_Add To WaitlistByConsumer-19
	[Documentation]  Consumer joins waitlist of a valid provider after completing prepayment (Virtual service with prepayment)

    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id1}=  get_id  ${CUSERNAME8}

    ${resp}=  Get consumer Waitlist   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s8}  ${consumerNote}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE8}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s8}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${c_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id8}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}
    Set Test Variable   ${Total}   ${resp.json()['service']['minPrePaymentAmount']}
    Set Test Variable   ${PC_id}   ${resp.json()['consumer']['id']}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${uuid1}   ${resp.json()['uuid']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${wid5}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Make payment Consumer Mock  ${accId}  ${Total}  ${purpose[0]}  ${wid5}  ${p1_s8}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock   ${Total}      ${bool[1]}  ${wid5}  ${accId}  ${purpose[0]}  ${PC_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${accId}   
    Log  ${resp.json()}

    ${resp}=   Get Payment Details By UUId   ${wid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${Total}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid5}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${Total}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid5}

    ${resp}=  Cancel Waitlist  ${wid5}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-VirtualService_Add To WaitlistByConsumer-20
	[Documentation]  Consumer joins Futurem waitlist of a valid provider after completing prepayment (Virtual service with prepayment)

    ${resp}=   Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME10}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${CUSER_FOR}   ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumerNote}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId_5}  ${DAY}  ${p1_s8}  ${consumerNote}  ${bool[0]}  ${virtualService1}   ${CUSER_FOR}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    


    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid6}  ${accId}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE8}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s8}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${CUSER_FOR}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${queueId_5}
    Set Test Variable   ${Total}   ${resp.json()['service']['minPrePaymentAmount']}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${uuid2}   ${resp.json()['uuid']}


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${accId}  ${Total}  ${purpose[0]}  ${wid6}  ${p1_s8}  ${bool[0]}   ${bool[1]}  ${c_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock   ${Total}      ${bool[1]}  ${wid6}  ${accId}  ${purpose[0]}  ${c_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Get consumer Waitlist By Id   ${wid6}  ${accId}   
    Log  ${resp.json()}
    ${resp}=   Get Payment Details By UUId   ${wid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${Total}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid6}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${Total}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid6}

JD-TC-VirtualService_Add To WaitlistByProvider-21
    [Documentation]  Consumer joins to waitlist of a valid provider (Non billable Subdomain)


    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+1800081
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
    # ${Pid}=  get_acc_id  ${PUSERPH2}


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
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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

    ${resp}=  Update Email   ${pid}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  pyproviderlogin  ${PUSERPH2}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages
    # Should Be Equal As Strings  ${resp[1]}  200
    # ${resp}=  Get GalleryOrlogo image  logo
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

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

    # ${resp}=  Enable Disable Virtual Service  Enable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH2}
    Set Suite Variable   ${ZOOM_Pid2}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_Pid2}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH2}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_Pid2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+14141
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
    Set Suite Variable   ${ZOOM_Pid2}
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
  
    ${Total}=   Random Int   min=100   max=500
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}    totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Suite Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Suite Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Suite Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_l1}   ${resp.json()[0]['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  6  10
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${QId}  ${resp.json()}
    
    ${resp}=    Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME2}
    ${DAY}=  db.get_date_by_timezone  ${tz}    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${Pid}  ${QId}  ${DAY}  ${p1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id}  ${resp.json()[0]['id']}

    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${Pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${QId}

    ${consumerNote2}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${Pid}  ${QId}  ${DAY}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${virtualService1}   ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${Pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER 
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${cidfor}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${QId}
    Set Test Variable  ${cfid6}   ${resp.json()['waitlistingFor'][0]['id']}


    ${resp}=  Cancel Waitlist  ${wid1}  ${Pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${Pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid6}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-Add To WaitlistByConsumer-CLEAR
    [Documentation]  Clear location, Queue, Waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    clear_location  ${PUSERPH0}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200



# JD-TC-VirtualService_Add To WaitlistByConsumer-UH21
#     [Documentation]   Add to waitlist on a non scheduled day
#     ${resp}=   Run Keywords   clear_queue  ${PUSERPH3}  AND  clear waitlist   ${PUSERPH3}
#     ${resp}=  Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${accId}=  get_acc_id  ${PUSERPH3}
#     ${DAY}=  db.get_date_by_timezone  ${tz}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
#     Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
#     Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
#     Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
#     Set Test Variable   ${p1_s3}   ${resp.json()[2]['id']}
#     Set Test Variable   ${P1SERVICE3}   ${resp.json()[2]['name']}

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
#     Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

#     ${p1queue1}=    FakerLibrary.word
#     ${sTime1}=  add_timezone_time  ${tz}  4  15  
#     ${eTime1}=  add_timezone_time  ${tz}  6  30  

#     ${d}=  get_timezone_weekday  ${tz}
#     ${d1}=  Evaluate  ${d}+1
#     ${DAY}=  db.get_date_by_timezone  ${tz}
#     ${DAY1}=  db.add_timezone_date  ${tz}  1  
#     ${list1}=  Create List  ${d}
#     ${capacity}=  FakerLibrary.Numerify  %%
#     ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${queueId}  ${resp.json()}

#     ${resp}=  ProviderLogout    
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
    
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Set Test Variable  ${CUSER_FOR}   ${resp.json()}

#     # ${d}=  get_timezone_weekday  ${tz}
#     # ${d}=  Evaluate  7-${d}

#     ${DAY2}=  db.add_timezone_date  ${tz}  5  
#     ${consumerNote2}=   FakerLibrary.word
#     ${resp}=  Consumer Add To WL With Virtual Service  ${accId}  ${queueId}  ${DAY1}  ${p1_s1}  ${consumerNote2}  ${bool[0]}  ${WHATSAPP_id}  ${SKYPE_id}   ${CUSER_FOR}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"    


