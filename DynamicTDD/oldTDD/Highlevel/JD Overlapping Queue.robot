*** Settings ***
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

***Variables***
${SERVICE1}	   Bleach1
${SERVICE2}	   Bleach2
${SERVICE3}	   Bleach3
${SERVICE4}	   Bleach4
${SERVICE5}	   Bleach5
${SERVICE6}	   Bleach6


${queue1}   Queue1
${queue2}   Queue2
${queue3}   Queue3
${queue4}   Queue4
${queue5}   Queue5

***Test Cases***
Set Time
    [Documentation]  Create dynamic time variables.
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${stime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${etime}  ${etime}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    Set Suite Variable   ${etime1}  ${etime1}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${stime2}  ${stime2}
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${etime2}  ${etime2}
    ${stime3}=  add_timezone_time  ${tz}  1  45  
    Set Suite Variable   ${stime3}  ${stime3}
    ${etime3}=  add_timezone_time  ${tz}    2  0
    Set Suite Variable   ${etime3}  ${etime3}

# Populate Provider
#     [Documentation]  Create location and services for provider
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY1}

#     ${DAY2}=  db.add_timezone_date  ${tz}  10        
#     Set Suite Variable  ${DAY2}  ${DAY2}

#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}

#     ${resp}=  Create Location  Palakkad  ${longi}  ${latti}  www.sampleurl.com  680030  Palliyil House  free  True  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     ${loc_res,ult} = 	Convert To Integer 	 ${resp.json()}
#     Set Suite Variable  ${l_id}   ${loc_result}

#     ${resp}=  Create Service  ${SERVICE1}  Description   5  ACTIVE  Waitlist  True  email  45  500  True  False
#     Should Be Equal As Strings  ${resp.status_code}   200
#     ${srv_result} = 	Convert To Integer 	 ${resp.json()}
#     Set Suite Variable  ${s_id}  ${srv_result} 

#     ${resp}=  Create Service  ${SERVICE2}  Description   5  ACTIVE  Waitlist  True  email  45  500  True  False
#     Should Be Equal As Strings  ${resp.status_code}   200     
#     ${srv1_result} = 	Convert To Integer 	 ${resp.json()}
#     Set Suite Variable  ${s_id1}   ${srv1_result} 

#     @{EMPTY}=  Create List  @{EMPTY}
#     Set Suite Variable  @{EMPTY}

Jaldee-TC-OverlapQ-1
    [Documentation]    Create 2 queues with same time window but different services.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_location  ${PUSERNAME8}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${l_id}=  Create Sample Location
    Set Suite Variable  ${l_id}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${stime1}  ${etime1}  1  5  ${l_id}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${l_id}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   1
    Should Be Equal As Strings  ${resp.json()['capacity']}   5
    Should Be Equal As Strings  ${resp.json()['queueState']}   ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   False
    
    ${resp}=  Create Queue  ${queue2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${EMPTY}   ${stime1}  ${etime1}  1  5  ${l_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${q_id1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${l_id}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   1
    Should Be Equal As Strings  ${resp.json()['capacity']}   5
    Should Be Equal As Strings  ${resp.json()['queueState']}   ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}       ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   False

Jaldee-TC-OverlapQ-2
    [Documentation]    Create 2 instant queues with same time window but different services.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ri}=  Create List  @{EMPTY}
    # ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Create Instant Queue  ${queue3}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  1  5  ${l_id}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${q_id2}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id2}
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue3} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${l_id}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   1
    Should Be Equal As Strings  ${resp.json()['capacity']}   5
    Should Be Equal As Strings  ${resp.json()['queueState']}   ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   True
    
    ${resp}=  Create Instant Queue  ${queue4}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  1  5  ${l_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${q_id3}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id3}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue4} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${l_id}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   1
    Should Be Equal As Strings  ${resp.json()['capacity']}   5
    Should Be Equal As Strings  ${resp.json()['queueState']}   ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}       ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   True

Jaldee-TC-OverlapQ-UH-1
    [Documentation]     Update first queue with the service of 2nd queue also.   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue2} 
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    
    ${resp}=  Update Queue  ${q_id}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${stime1}  ${etime1}  1  5  ${l_id}  ${s_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"


Jaldee-TC-OverlapQ-UH-2
    [Documentation]     Update first instant queue with the service of 2nd instant queue also.   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queue ById  ${q_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue4} 
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    
    ${resp}=  Update Instant Queue  ${q_id2}  ${queue3}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  1  5  ${l_id}  ${s_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"

Jaldee-TC-OverlapQ-UH-3
    [Documentation]     Update first queue with the service of 2nd queue only.   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue2} 
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    
    ${resp}=  Update Queue  ${q_id}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${stime1}  ${etime1}  1  5  ${l_id}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"

Jaldee-TC-OverlapQ-UH-4
    [Documentation]     Update first instant queue with the service of 2nd instant queue only.   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queue ById  ${q_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue4} 
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${s_id1}
    
    ${ri}=  Create List  @{EMPTY}
    ${resp}=  Update Instant Queue  ${q_id2}  ${queue3}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  1  5  ${l_id}   ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"

    
    
