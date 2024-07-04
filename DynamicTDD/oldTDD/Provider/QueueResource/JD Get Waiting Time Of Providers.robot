*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        WaitingTime
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
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${self}      0

*** Test Cases ***

JD-TC-GetWaitingTimeOfProviders-1
    [Documentation]  Get Waiting Time Of 3 Providers with Provider Login
    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME155}
    clear_location  ${PUSERNAME155}
    clear_queue  ${PUSERNAME155}
    clear_customer   ${PUSERNAME155}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()}  10
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME156}
    clear_location  ${PUSERNAME156}
    clear_queue  ${PUSERNAME156}
    clear_customer   ${PUSERNAME156}
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid2}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}
  
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue Waiting Time  ${qid2}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()}  4
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME157}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME157}
    clear_location  ${PUSERNAME157}
    clear_queue  ${PUSERNAME157}
    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_acc_id  ${PUSERNAME155}
    ${id2}=  get_acc_id  ${PUSERNAME156}
    ${id3}=  get_acc_id  ${PUSERNAME157}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}  ${id2}-${lid2}  ${id3}-${lid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['queueWaitingTime']}  4
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}  ${id3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['id']}  ${qid3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['queueWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['availableDate']}   ${DAY1}

JD-TC-GetWaitingTimeOfProviders-2
    [Documentation]  Get Waiting Time Of 3 Providers with consumer Login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_acc_id  ${PUSERNAME155}
    ${id2}=  get_acc_id  ${PUSERNAME156}
    ${id3}=  get_acc_id  ${PUSERNAME157}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}  ${id2}-${lid2}  ${id3}-${lid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['queueWaitingTime']}  4
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}  ${id3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['id']}  ${qid3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['queueWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['availableDate']}   ${DAY1}
    
JD-TC-GetWaitingTimeOfProviders-3
    [Documentation]  Get Waiting Time Of 3 Providers without login
    ${id1}=  get_acc_id  ${PUSERNAME155}
    ${id2}=  get_acc_id  ${PUSERNAME156}
    ${id3}=  get_acc_id  ${PUSERNAME157}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}  ${id2}-${lid2}  ${id3}-${lid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['queueWaitingTime']}  4
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}  ${id3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['id']}  ${qid3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['queueWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['availableDate']}   ${DAY1}

JD-TC-GetWaitingTimeOfProviders-4
    [Documentation]  Get Waiting Time Of a provider when queue capacity is 1, checking that provider available only at next day
    ${resp}=  Encrypted Provider Login  ${PUSERNAME159}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME159}
    clear_location  ${PUSERNAME159}
    clear_queue  ${PUSERNAME159}
    clear_customer   ${PUSERNAME159}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   1  58
    Set Suite Variable   ${eTime1}
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    clear_queue  ${PUSERNAME159}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_acc_id  ${PUSERNAME159}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  ${bool[0]}
    #${service_time}=  add_time  1  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['serviceTime']}   ${sTime1}
 
JD-TC-GetWaitingTimeOfProviders-5
    [Documentation]  Get Waiting Time Of current queue
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+89899
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n} 
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
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
    ${24hours}    Random Element    ['True','${bool[0]}']
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
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
    
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   1  58
    Set Suite Variable   ${eTime1}
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid1}  ${s_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  True

JD-TC-GetWaitingTimeOfProviders-6
    [Documentation]  Get Waiting Time Of future queue
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+89895
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}    ${highest_package[0]}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n} 
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking_type}    Random Element     ${parkingType}
    ${24hours}    Random Element    ['True','${bool[0]}']
    ${DAY}=  db.get_date_by_timezone  ${tz}
	${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  6  15
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()} 

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${resp}=  Get queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${queue_id}  ${resp.json()[0]['id']}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  db.subtract_timezone_time  ${tz}   0  58
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${id1}=  get_acc_id  ${PUSERNAME}
    Set Suite Variable  ${id1}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${FDAY}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${FDAY}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${FDAY}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  ${bool[0]} 
    ${resp}=  Get queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetWaitingTimeOfProviders-UH1
    [Documentation]  Get Waiting Time Of an invalid Provider
    ${resp}=  Get Waiting Time Of Providers  0-0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['isAdmin']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  0
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ACCOUNT_NOT_EXIST}

JD-TC-GetWaitingTimeOfProviders-UH2
    [Documentation]  Get Waiting Time Of a valid provider  and invalid Provider
    ${resp}=  Get Waiting Time Of Providers  0-0  ${id1}-${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ACCOUNT_NOT_EXIST}
    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${FDAY}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['openNow']}  ${bool[0]}


JD-TC-GetWaitingTimeOfProviders-UH3
    [Documentation]  Get Waiting Time Of a invalid provider id and valid location id
    ${resp}=  Get Waiting Time Of Providers  0-${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['isAdmin']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  0
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ACCOUNT_NOT_EXIST}
    

JD-TC-GetWaitingTimeOfProviders-UH4
    [Documentation]  Get Waiting Time Of a valid provider id and invalid location id
    ${resp}=  Get Waiting Time Of Providers   ${id1}-0
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${LOCATION_NOT_FOUND}
    

JD-TC-GetWaitingTimeOfProviders-UH5
    [Documentation]  Get Waiting Time Of provider url using all queue is disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Queue  ${qid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Disable Queue  ${queue_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waiting Time Of Providers   ${id1}-${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ONLINE_CHECKIN_NOT_AVAILABLE}    
    # Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ONLINE_CHECK_IN_ARE_OFF}

*** Comments ***
NW-TC-GetWaitingTimeOfProviders-UH6
    [Documentation]  Get Waiting Time Of provider url using location disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking_type}    Random Element     ${parkingType}
    ${24hours}    Random Element    ['True','${bool[0]}']
    ${DAY}=  db.get_date_by_timezone  ${tz}
	${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()} 
    ${resp}=  UpdateBaseLocation  ${lid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Location  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waiting Time Of Providers   ${id1}-${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message']}  Location is disabled