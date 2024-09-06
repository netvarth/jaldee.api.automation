** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading
${start}        90

*** Test Cases ***

JD-TC-UpdateQueue-1
    [Documentation]    Update a queue in a location with  new services
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${HLPUSERNAME4}
    clear_location  ${HLPUSERNAME4}
    clear_queue  ${HLPUSERNAME4}

    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id3}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    
    ${resp}=  Update Queue  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id2}  ${s_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

JD-TC-UpdateQueue-2
    [Documentation]    Update a queue in a location without location id and verify location id is the previous one
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update Queue  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${EMPTY}  ${s_id2}  ${s_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${qid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}
    
JD-TC-UpdateQueue-3
    [Documentation]    Update a queue in a location without service id and verify service id is the previous one
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update Queue without service  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  3  ${lid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${qid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  3
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

JD-TC-UpdateQueue-4
    [Documentation]    Update a queue in a location with  a service used in another disbled queue
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${HLPUSERNAME4}
    clear_location  ${HLPUSERNAME4}
    clear_queue  ${HLPUSERNAME4}
    
    ${lid1}=  Create Sample Location
    Set Suite Variable   ${lid1}
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id4}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id4}
    ${s_id5}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id5}

    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${eTime2}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}
    ${resp}=  Create Queue  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid1}  ${s_id4}  ${s_id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}
    sleep  2s

    ${resp}=  Enable Disable Queue  ${qid2}    ${toggleButton[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue_name1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}

    ${resp}=  Update Queue   ${qid1}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${EMPTY}  ${sTime1}  ${eTime1}  2  3  ${lid1}  ${s_id4}  ${s_id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1} 
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id5}

JD-TC-UpdateQueue-5
    [Documentation]  check overlapping of schedules in same location with disabled queue
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue   ${qid1}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${EMPTY}  ${sTime2}  ${eTime2}  2  3  ${lid1}  ${s_id4}  ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateQueue-UH1
    [Documentation]  Update queue to an already existing name in same location
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue   ${qid1}  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${EMPTY}  ${sTime2}  ${eTime2}  2  3  ${lid1}  ${s_id4}  ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_EXISTS}"
    
JD-TC-UpdateQueue-UH2
    [Documentation]  check overlapping of schedules in same location with enabled queue
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime3}=  add_timezone_time  ${tz}  3  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable   ${eTime3}
    ${queue_name2}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name2}
    ${resp}=  Create Queue  ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid1}  ${s_id4}  ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}
    ${resp}=  Get queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Update Queue   ${qid1}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${EMPTY}  ${sTime3}  ${eTime3}  2  3  ${lid1}  ${s_id4}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"

JD-TC-UpdateQueue-UH3
    [Documentation]    Update a queue in a location with another location id
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
    ${resp2}=   Get Domain Settings    ${domain}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${check}  ${resp2.json()['multipleLocation']}
    Exit For Loop IF     "${check}"=="True"
    END
    Set Suite Variable  ${a}
    clear_service   ${PUSERNAME${a}}
    clear_location  ${PUSERNAME${a}}
    clear_queue  ${PUSERNAME${a}}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
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
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
	${list}=  Create List  1  2  3  4  5  6  7
    ${sTime3}=  add_timezone_time  ${tz}  3  15  
    ${eTime3}=  add_timezone_time  ${tz}  3  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid3}  ${resp.json()}
    ${resp}=  Update Queue  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id2}  ${s_id3}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-UpdateQueue-UH4
    [Documentation]    Update a queue without queue id 
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue  ${EMPTY}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id2}  ${s_id3}
    Should Be Equal As Strings  ${resp.status_code}  404  
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"

JD-TC-UpdateQueue-UH5
    [Documentation]    Update a queue without queue name
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue  ${qid}  ${EMPTY}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NAME_REQUIRED}"

JD-TC-UpdateQueue-6
    [Documentation]  check overlapping of schedules in different locations with disabled queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Enable Disable Queue  ${qid}    ${toggleButton[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sTime5}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime5}
    ${eTime5}=  add_timezone_time  ${tz}   5  30
    Set Suite Variable   ${eTime5}
    ${queue_name5}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name5}
    ${resp}=  Create Queue  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime5}  ${eTime5}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid5}  ${resp.json()}
    ${list}=  Create List  3  5  6  7
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateQueue-UH6
    [Documentation]  Update another provider's queue
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-UpdateQueue-UH7
    [Documentation]  Update queue using consumer login
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME4}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateQueue-UH8
    [Documentation]  Update queue without login
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-UpdateQueue-UH9
    [Documentation]  Update queue with another provider's location
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-UpdateQueue-UH10
    [Documentation]  Update queue with another provider's services
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue  ${qid5}  ${queue_name5}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid3}  ${s_id4}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-UpdateQueue-7
    [Documentation]  Update Queue for Branch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UpdateQueue-8
    [Documentation]  Update Queue for User

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    
*** Comments ***
#Update Queue With Timeinterval and Appointment

JD-TC-Update Queue with timeinterval-7
    [Documentation]    Update Queue with timeInterval value when Appointment is Enable in the Create Queue and Update Queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME173}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME173}
    clear_location  ${PUSERNAME173}
    clear_queue  ${PUSERNAME173}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[0]}
    
    ${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['timeInterval']}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update Queue with timeinterval-8
    [Documentation]    Update Queue with timeInterval value when Appointment is Disable in the Create Queue and Then Appointment is Enable in the Update Queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME177}
    clear_location  ${PUSERNAME177}
    clear_queue  ${PUSERNAME177}
    
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[1]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    
    ${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}


JD-TC-Update Queue with timeinterval-9
    [Documentation]    Create Queue Appointment is Disable and Update Queue Appointment also Disable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME174}
    clear_location  ${PUSERNAME174}
    clear_queue  ${PUSERNAME174}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[1]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    
    ${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[1]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update Queue with timeinterval-10
    [Documentation]    Create Queue Appointment is Disable and Update Queue Appointment also Enable and with Negative TimeInterval value
    ${resp}=  Encrypted Provider Login  ${PUSERNAME175}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME175}
    clear_location  ${PUSERNAME175}
    clear_queue  ${PUSERNAME175}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=-10   max=-5
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}
    Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${qid}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${TIME_INTERVAL_NOT_NEG}"

    # ${resp}=  Get Queue ById  ${qid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[1]}
    
    # ${timeInterval}=   Random Int  min=-25   max=-15
    # ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[0]}  ${s_id1}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200   
    
    # ${resp}=  Get Queue ById  ${qid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    # Should Be Equal As Strings  ${resp.json()['capacity']}  5
    # Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    # Should Not Contain  ${resp.json()}  ${timeInterval}
    # Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[1]}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1} 

JD-TC-Update Queue with timeinterval-11
    [Documentation]    Create Queue Appointment is Disable and Update Queue with Empty Timeinterval and Appointment is Enable and Taking turnAroundTime Value
    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME171}
    clear_location  ${PUSERNAME171}
    clear_queue  ${PUSERNAME171}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${turnAroundTime}=   Random Int  min=5   max=10
    Set Suite variable  ${turnAroundTime}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${turnAroundTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${turnAroundTime}  ${appointmentMode[1]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[1]}
    
    #${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${Empty}  ${appointmentMode[0]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    Should Be Equal As Strings  ${resp.json()['turnAroundTime']}  ${turnAroundTime}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update Queue with timeinterval-12
    [Documentation]    Calculation Mode is ML, Update Queue with timeInterval value when Appointment is Enable Update Queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME181}
    clear_location  ${PUSERNAME181}
    clear_queue  ${PUSERNAME181}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[1]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[1]}
    
    ${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Update Queue with timeinterval-13
    [Documentation]    Calculation Mode is NoCal, Update Queue with timeInterval value when Appointment is Enable Update Queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME189}
    clear_location  ${PUSERNAME189}
    clear_queue  ${PUSERNAME189}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[1]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    
    ${timeInterval}=   Random Int  min=15   max=25
    ${resp}=  Update Queue TimeInterval  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointmentMode[0]}  ${s_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointmentMode[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
