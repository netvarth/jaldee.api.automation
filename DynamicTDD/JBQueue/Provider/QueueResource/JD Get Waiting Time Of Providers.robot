*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        WaitingTime
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
@{service_names}
${self}      0
@{service_names}

*** Test Cases ***

JD-TC-GetWaitingTimeOfProviders-1
    [Documentation]  Get Waiting Time Of 3 Providers with Provider Login
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    get_Host_name_IP
    # clear_service   ${HLPUSERNAME13}
    # clear_location  ${HLPUSERNAME13}
    # clear_queue  ${HLPUSERNAME13}
    clear_customer   ${HLPUSERNAME13}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${HLPUSERNAME11}
    # clear_location  ${HLPUSERNAME11}
    # clear_queue  ${HLPUSERNAME11}
    clear_customer   ${HLPUSERNAME11}
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz2}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz2}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz2}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz2}  0  30  
    Set Suite Variable   ${eTime1}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${HLPUSERNAME12}
    # clear_location  ${HLPUSERNAME12}
    # clear_queue  ${HLPUSERNAME12}

    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${DAY1}=  db.get_date_by_timezone  ${tz3}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz3}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz3}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz3}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()['id']}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()['id']}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()['id']}

    # ${id1}=  get_acc_id  ${HLPUSERNAME13}
    # ${id2}=  get_acc_id  ${HLPUSERNAME11}
    # ${id3}=  get_acc_id  ${HLPUSERNAME12}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}  ${id2}-${lid2}  ${id3}-${lid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['turnAroundTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['queueWaitingTime']}  4
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['turnAroundTime']}  2
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}  ${id3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['id']}  ${qid3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['queueWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['turnAroundTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['availableDate']}   ${DAY1}

JD-TC-GetWaitingTimeOfProviders-2
    [Documentation]  Get Waiting Time Of 3 Providers with consumer Login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_acc_id  ${HLPUSERNAME13}
    ${id2}=  get_acc_id  ${HLPUSERNAME11}
    ${id3}=  get_acc_id  ${HLPUSERNAME12}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Otp For Login    ${CUSERNAME1}    ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=  Verify Otp For Login   ${CUSERNAME1}   ${OtpPurpose['Authentication']}    JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME1}    ${id2}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}  ${id2}-${lid2}  ${id3}-${lid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['queueWaitingTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['turnAroundTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['id']}  ${qid2}
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['queueWaitingTime']}  4
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['turnAroundTime']}  2
    Should Be Equal As Strings  ${resp.json()[1]['nextAvailableQueue']['availableDate']}   ${DAY1}

    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}  ${id3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['id']}  ${qid3}
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['queueWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['turnAroundTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['nextAvailableQueue']['availableDate']}   ${DAY1}
    
JD-TC-GetWaitingTimeOfProviders-3
    [Documentation]  Get Waiting Time Of 3 Providers without login
    ${id1}=  get_acc_id  ${HLPUSERNAME13}
    ${id2}=  get_acc_id  ${HLPUSERNAME11}
    ${id3}=  get_acc_id  ${HLPUSERNAME12}
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
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${HLPUSERNAME11}
    # clear_location  ${HLPUSERNAME11}
    # clear_queue  ${HLPUSERNAME11}
    clear_customer   ${HLPUSERNAME11}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   1  58
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    # clear_queue  ${HLPUSERNAME11}
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
    ${id1}=  get_acc_id  ${HLPUSERNAME11}
    ${resp}=  Get Waiting Time Of Providers  ${id1}-${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  ${bool[0]}
    #${service_time}=  db.add_timezone_time  ${tz}  1  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['serviceTime']}   ${sTime1}
 
JD-TC-GetWaitingTimeOfProviders-5
    [Documentation]  Get Waiting Time Of current queue

    ${firstname}  ${lastname}  ${PUSERNAME}  ${LoginId}=  Provider Signup    
    Set Suite Variable  ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    
    
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   1  58
    Set Suite Variable   ${eTime1}
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
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['turnAroundTime']}  10
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  True

JD-TC-GetWaitingTimeOfProviders-6
    [Documentation]  Get Waiting Time Of future queue

    ${firstname}  ${lastname}  ${PUSERNAME}  ${LoginId}=  Provider Signup    
    Set Suite Variable  ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
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

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}
    
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
    Should Be Equal As Strings  ${resp.json()}    []
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['isAdmin']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ACCOUNT_NOT_EXIST}

JD-TC-GetWaitingTimeOfProviders-UH2
    [Documentation]  Get Waiting Time Of a valid provider  and invalid Provider
    ${resp}=  Get Waiting Time Of Providers  0-0  ${id1}-${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['message']}  ${ACCOUNT_NOT_EXIST}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['availableDate']}   ${FDAY}
    Should Be Equal As Strings  ${resp.json()[0]['nextAvailableQueue']['openNow']}  ${bool[0]}


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