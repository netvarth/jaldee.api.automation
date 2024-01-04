*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      gmap
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${self}     0
${service_duration}   5

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

*** Test Cases ***

JD-TC-Share consumer location-1
    [Documentation]  Consumer joins waitlist and enables location sharing at 1 hour before start time mode
    # ${resp}=   Run Keywords   clear_queue  ${PUSERNAME174}  AND  clear waitlist   ${PUSERNAME174}
    # ${pid0}=  get_acc_id  ${PUSERNAME174}
    # ${cid}=  get_id  ${CUSERNAME14}
    # # clear_service    ${PUSERNAME85}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comment ***
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100319
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_location  ${PUSERPH0}   AND   clear_service   ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    
    ${pkg_id}=   get_highest_license_pkg

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}    ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30   
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s

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
    

    ${pid0}=  get_acc_id  ${PUSERPH0}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${city}=   db.get_place
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
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}

    ${words}=    FakerLibrary.Words    nb=${10}
    ${unique_words}=    Remove Duplicates    ${words}
    
    # ${P1SERVICE1}=    FakerLibrary.word
    ${P1SERVICE1}=  Set Variable  ${unique_words[0]}
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}


    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=  Enable Disbale Service Livetrack   ${p1_s1}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer  ${pid0}   ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[0]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#*** Comment ***

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeelTravelTime']['travelMode']}   ${travelMode[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Share consumer location-2
    [Documentation]  Consumer joins waitlist and enables location sharing for after start mode
    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer   ${pid0}  ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[2]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable tracking by consumer  ${wid1}   ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Share consumer location-3
    [Documentation]  update consumer's location
    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer  ${pid0}  ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[0]}   ${latti}  ${longi}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeelTravelTime']['travelMode']}   ${travelMode[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Update consumer location  ${pid0}  ${wid1}   ${latti}  ${longi}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeelTravelTime']['travelMode']}   ${travelMode[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Share consumer location-4
    [Documentation]  update consumer's travelmode
    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer  ${pid0}   ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[0]}   ${latti}  ${longi}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeelTravelTime']['travelMode']}   ${travelMode[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   update consumer travelmode  ${pid0}  ${wid1}   ${travelMode[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeelTravelTime']['travelMode']}   ${travelMode[1]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Share consumer location-UH1
    [Documentation]  Consumer joins waitlist and does not allow location sharing 
    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer  ${pid0}   ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[2]}   ${latti}  ${longi}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  check start status  ${pid0}   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   False

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Share consumer location-UH2
    [Documentation]  Consumer joins waitlist and disables location sharing 
    ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME14}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable location sharing by consumer  ${pid0}   ${wid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[0]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Disable location sharing by consumer   ${wid1}   ${pid0}
    Log  ${resp}
    Log  ${resp.status_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Locate consumer   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200