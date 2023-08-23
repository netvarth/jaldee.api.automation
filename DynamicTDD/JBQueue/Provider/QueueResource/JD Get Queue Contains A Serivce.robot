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
# Suite Setup     Run Keywords  clear_queue  ${PUSERNAME_G}  AND  clear_location  ${PUSERNAME_G}  AND  clear_service  ${PUSERNAME_G}   AND  clear_queue  ${PUSERNAME13}  AND  clear_location  ${PUSERNAME13}  AND  clear_service  ${PUSERNAME13} 

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Bridal makeup

*** Test Cases ***

JD-TC-GetQueueService-1
    [Documentation]    Get queue that contains a service

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+55102073
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_G}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_G}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_G}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_G}${\n}
    Set Suite Variable  ${PUSERNAME_G}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_G}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_G}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_G}.${test_mail}  ${views}
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
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${c}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable  ${eTime}
    ${resp}=  Create Location   ${c}    ${longi}  ${latti}  www.${c}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Create Sample Location
    Set Suite Variable  ${lid1}  ${resp.json()}
    
JD-TC-GetQueueService-UH1
    [Documentation]    search with another Provider's service and location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GIVEN_SERVICE_NOT_FOUND_IN_LOCATION}"

JD-TC-GetQueueService-UH2
    [Documentation]    search using consumer login
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetQueueService-UH3
    [Documentation]    search without login
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetQueueService-UH4
    [Documentation]    search on a non scheduled day
    
    clear_location   ${PUSERNAME13}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id5}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id5}
    ${list}=  Create List  1  2  3  4  5  6
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable  ${sTime}
    ${eTime5}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable  ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${queue2}=    FakerLibrary.name
    Set Suite Variable    ${queue2} 
    ${list}=  Create List  1  2  3  4  5  6
    ${stime}=   subtract_timezone_time  ${tz}   2   00  
    Set Suite Variable   ${stime}
    ${etime}=   add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${etime}
    ${resp}=  Create Queue   ${queue2}   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1   5   ${lid}  ${s_id5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   


JD-TC-VerifyGetQueueService-1
    [Documentation]    Verification of Get queue that contains a service(case1)
    # 32
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable  ${eTime1}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}
    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}
    ${sTime3}=  add_timezone_time  ${tz}  4  15  
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  4  30  
    Set Suite Variable  ${eTime3}
    ${queue_name2}=  FakerLibrary.bs
     Set Suite Variable  ${queue_name2}
    ${resp}=  Create Queue  ${queue_name2}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid1}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2 

    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1} 

    Should Be Equal As Strings  ${resp.json()[1]['name']}   ${queue_name2}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[1]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[1]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[1]['services'][0]['id']}  ${s_id}

    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id1}  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
   
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}

JD-TC-GetQueueService-2
    [Documentation]    Get queue that contains a service for a future date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1} 

    Should Be Equal As Strings  ${resp.json()[1]['name']}   ${queue_name2}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[1]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[1]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[1]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[1]['services'][0]['id']}  ${s_id}

    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id1}  ${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals'][6]}  7
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}

JD-TC-GetQueueService-UH5
    [Documentation]    Get queue that contains a service for a non scheduled past date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  db.add_timezone_date  ${tz}  -1
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NON_SCHEDULE_DAY}"

JD-TC-Verify GetQueueService-UH4
    [Documentation]    Verification of search on a non scheduled day(case UH4)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Queues
    Log  ${resp.json()}
    ${d}=  get_timezone_weekday  ${tz}
    ${d}=  Evaluate  7-${d}
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d}  
    ${resp}=  Get Queue Of A Service  ${lid}  ${s_id5}  ${DAY3}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${NON_SCHEDULE_DAY}"

JD-TC-GetQueueService-UH6
    [Documentation]    search with a location and a non-associated service
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id2}  ${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GIVEN_SERVICE_NOT_FOUND_IN_LOCATION}"


*** Comment ***

JD-TC-GetQueueService-UH6
    [Documentation]    search on a holiday
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Holiday  ${DAY1}  Vishu  ${LsTime}  ${LeTime} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hid}  ${resp.json()}

    ${resp}=  Create Holiday  ${DAY1}  Vishu  ${sTime}  ${eTime} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hid1}  ${resp.json()}

    ${resp}=  Create Holiday  ${DAY1}  Vishu  ${sTime1}  ${eTime1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hid2}  ${resp.json()}

    ${resp}=  Create Holiday  ${DAY1}  Vishu  ${sTime2}  ${eTime2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hid2}  ${resp.json()}
    ${resp}=  Get Holidays
    Log  ${resp.json()}
    sleep  4s
    ${resp}=  Get Queue Of A Service  ${lid1}  ${s_id}  ${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Sorry, today is not a working day !!!"
    ${resp}=   Delete Holiday  ${hid}
    Should Be Equal As Strings  ${resp.status_code}  200




