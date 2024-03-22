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
Suite Setup     Run Keywords  clear_queue  ${PUSERNAME174}  AND  clear_location  ${PUSERNAME174}  AND  clear_service  ${PUSERNAME174}  

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Face Makeup  
${SERVICE4}  Facial

*** Test Cases ***

JD-TC-Available Queues-1
    [Documentation]   Checking Avalible queues
    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME174}
    clear_location  ${PUSERNAME174}
    clear_queue  ${PUSERNAME174}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name1}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${sTime2}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}   1  40
    Set Suite Variable   ${eTime2}
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    ${queue_name2}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Is Available Queue Now
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['timeRange']['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeRange']['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['availableNow']}  True

JD-TC-Available Queues-2
    [Documentation]   Checking avaliable queues when there is no queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME175}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME175}
    clear_location  ${PUSERNAME175}
    clear_queue  ${PUSERNAME175}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  15
    Set Suite Variable   ${sTime}
    ${eTime}=  db.subtract_timezone_time  ${tz}   0  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}

    ${resp}=  Is Available Queue Now
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['availableNow']}  False

JD-TC-Available Queues-3
    [Documentation]   Checking Avalible queues when there is some gaps between two queues
    ${resp}=  Encrypted Provider Login  ${PUSERNAME176}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME176}
    clear_location  ${PUSERNAME176}
    clear_queue  ${PUSERNAME176}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   0  05
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name1}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  40  
    Set Suite Variable   ${eTime2}
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    ${queue_name2}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}
    
    # ${Time}=  db.get_time_by_timezone  ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Is Available Queue Now
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['timeRange']['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeRange']['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['availableNow']}  True

JD-TC-Available Queues-UH1
    [Documentation]  Available Queues by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Is Available Queue Now
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Available Queues-UH2
    [Documentation]  Available Queues without login
    ${resp}=  Is Available Queue Now
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"