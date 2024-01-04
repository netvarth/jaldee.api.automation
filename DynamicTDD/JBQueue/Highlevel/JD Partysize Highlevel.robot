*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Partysize
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

***Variables***
${start}  90

*** Test Cases ***
JD-TC-High Level Test Case-1
	[Documentation]  try to take waitlist for family memebers when maxPartySize>1
    
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100244502
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${max_party}=  get_maxpartysize_subdomain
    Log    ${max_party}
    Set Suite Variable  ${d1}  ${max_party['domain']}
    Set Suite Variable  ${sd1}  ${max_party['subdomain']}

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

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+815
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+716
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
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
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
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
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${pid0}=  get_acc_id  ${PUSERPH0}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc1}  ${resp.json()[0]['id']} 
    
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${service_duration}=  Random Int  min=10  max=20
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${loc1}  ${s_id} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p_q1}  ${resp.json()}


    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cId}  ${resp.json()[0]['id']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cId}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cId}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${p_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${mem_id}  ${mem_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P1SERVICE1}  ${resp.json()['name']}
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cId}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${mem_id}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby[1]}  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cId}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${mem_id1}

JD-TC-High Level Test Case-UH1
    [Documentation]  try to take waitlist for family memebers when maxPartySize=1
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${start}  ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    
    ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${check}  ${resp2.json()['maxPartySize']}
    Exit For Loop IF     "${check}" == "1"
    END

    clear_location   ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}
    ${resp} =  Create Sample Queue
    Set Suite Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${DAY}=  db.get_date_by_timezone  ${tz}


    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    # ${cId}=  get_id  ${CUSERNAME5}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cId}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cId}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  ${cnote}  ${bool[1]}  ${mem_id}  ${mem_id1}
    
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PARTY_SIZE_GREATER}"
