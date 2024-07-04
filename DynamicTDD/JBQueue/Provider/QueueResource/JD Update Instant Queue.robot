*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        InstantQueue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 



*** Test Cases ***


Jaldee-TC-UpdateIQ-1
    [Documentation]    Update Name of Instant queue
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[0]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[0]['subdomains'][0]}
    ${PUSER_J}=  Evaluate  ${PUSERNAME}+224558
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSER_J}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSER_J}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSER_J}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSER_J}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSER_J}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz} 
    ${stime}=  add_timezone_time  ${tz}  0  15  
    ${etime}=  add_timezone_time  ${tz}  0  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_l1}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_s1}  ${srv_result} 

    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${nom}   ${resp.json()['name']}
    Set Test Variable  ${loc_id}   ${resp.json()['location']['id']}
    Set Test Variable  ${s_time}   ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${e_time}   ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${p_serv}   ${resp.json()['parallelServing']}
    Set Test Variable  ${cap}   ${resp.json()['capacity']}
    Set Test Variable  ${srv_id}   ${resp.json()['services'][0]['id']}

    ${p1queue2}=    FakerLibrary.word
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${s_time}  ${e_time}  ${p_serv}  ${cap}  ${loc_id}  ${srv_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${today}=   get_timezone_weekday  ${tz}
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${s_time}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${e_time}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${p_serv}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${cap}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${srv_id}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}


Jaldee-TC-UpdateIQ-2
    [Documentation]    Update start time and end time of Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}

    
    
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-3
    [Documentation]    Update instant queue time to a DISABLED instant queue's time
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings   ${resp.json()['instantQueue']}   ${bool[1]}

    ${stime4}=  add_timezone_time  ${tz}  2  15  
    ${etime4}=  add_timezone_time  ${tz}    2  30
    ${p1queue2}=    FakerLibrary.word
    ${capacity1}=  FakerLibrary.Numerify  %%%
    ${parallel1}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime4}  ${etime4}  ${parallel1}  ${capacity1}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['name']}     ${p1queue2}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime4}
    Should Be Equal As Strings   ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime4}
    Should Be Equal As Strings   ${resp.json()['parallelServing']}   ${parallel1}
    Should Be Equal As Strings   ${resp.json()['capacity']}   ${capacity1}
    Should Be Equal As Strings   ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings   ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings   ${resp.json()['instantQueue']}   ${bool[1]}

    
    
    ${resp}=  Disable Queue  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['name']}     ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    
    ${resp}=  Update Instant Queue  ${p1_q2}  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel1}  ${capacity1}  ${lid1}  ${sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Queue ById  ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity1}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-4
    [Documentation]    Update parallel serving of Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    
    ${parallel1}=  FakerLibrary.Numerify  %
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel1}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-5
    [Documentation]    Update capacity of Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    
    ${capacity1}=  FakerLibrary.Numerify  %%%
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity1}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity1}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-6
    [Documentation]    Update Service of Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_s2}  ${srv_result}
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-7
    [Documentation]    Add multiple services to Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sid2}   ${resp.json()[1]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}       
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}



Jaldee-TC-UpdateIQ-9
    [Documentation]    Update location of Instant queue
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    #clear_location  ${PUSER_J}
     
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0 
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime1}  ${etime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_l2}   ${loc_result}
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${p1_l2}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${p1_l2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-10
    [Documentation]    Update instant queue with multiple service list of same service
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sname1}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${length}=  Get Length  ${resp.json()['services']}
    should be equal as numbers  ${length}   1
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}      ${sname1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-UpdateIQ-UH-1
    [Documentation]    Update start time and end time of Instant queue to past time 
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sname1}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}

    ${old_stime}=  db.subtract_timezone_time  ${tz}   0  30
    Set Test Variable   ${old_stime}  
    ${old_etime}=  db.subtract_timezone_time  ${tz}   0  15
    Set Test Variable   ${old_etime}

    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${old_stime}  ${old_etime}  ${parallel}  ${capacity}  ${lid1}  ${sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${STARTTIMESHOULD_BEGREATERTHANCURRENTTIME}"

Jaldee-TC-UpdateIQ-UH-2
    [Documentation]    Update end time of Instant queue to time before start time. 
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sname1}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}

    ${etime1}=  add_timezone_time  ${tz}  1  0  
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${STARTTIMECANT_BEGREATERTHANENDTIME}"

Jaldee-TC-UpdateIQ-UH-3
    [Documentation]    Update name of instant queue to already existing queue name
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sname1}   ${resp.json()[0]['name']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}

    ${stime3}=  add_timezone_time  ${tz}  1  45  
    ${etime3}=  add_timezone_time  ${tz}    2  0
    ${p1queue2}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q2}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
    ${resp}=  Update Instant Queue  ${p1_q2}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${lid1}  ${sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_EXISTS}"

Jaldee-TC-UpdateIQ-UH-4
    [Documentation]    Update instant queue time to existing instant queue time
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
     
    ${stime2}=  add_timezone_time  ${tz}  1  15  
    ${etime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue2}=    FakerLibrary.word 
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q2}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q2}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
    ${resp}=  Update Instant Queue  ${p1_q2}  ${p1queue2}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_UPDATE}"

Jaldee-TC-UpdateIQ-UH-6
    [Documentation]    Update instant queue with non existant location
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
    ${rand_lid}=  FakerLibrary.Numerify  %%%%%%

    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${rand_lid}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_NOT_FOUND}"

Jaldee-TC-UpdateIQ-UH-7
    [Documentation]    Update instant queue with non existant service
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}

    ${rand_sid}=  FakerLibrary.Numerify  %%%%%%
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${rand_sid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"

Jaldee-TC-UpdateIQ-UH-8
    [Documentation]    Update instant queue with another provider's location
    [Setup]  Run Keywords  clear_queue  ${PUSERNAME178}  AND  clear_location  ${PUSERNAME178}  AND   clear_service   ${PUSERNAME178}  AND   clear_queue  ${PUSER_J} 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_location  ${PUSERNAME178}
    
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${stime}=  add_timezone_time  ${tz}  0  15  
    ${etime}=  add_timezone_time  ${tz}  0  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p2_l1}   ${loc_result} 

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p2_l1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

Jaldee-TC-UpdateIQ-UH-9
    [Documentation]    Update instant queue with another provider's service
    [Setup]   Run Keywords   clear_queue  ${PUSER_J}   AND   clear_service   ${PUSERNAME187}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${P2SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P2SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p2_s1}  ${srv_result}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    Should Not Contain   ${resp.json()}   id=${p2_s1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${p2_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"


# Jaldee-TC-UpdateIQ-11
#     [Documentation]    Update instant queue for Branch

# Jaldee-TC-UpdateIQ-12
#     [Documentation]    Update instant queue for user

*** Comments ***
Jaldee-TC-UpdateIQ-8
    [Documentation]    update recurring type to any type other than Once
    comment updating recurring type and not giving repeat intervals gives glitch and
    comment updating recuring type and repeat intervals will change this from instant queue to normal queue.
    [Setup]   clear_queue  ${PUSER_J}
    ${resp}=  Encrypted Provider Login  ${PUSER_J}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${ri}=  Create List  @{EMPTY}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1}
    Should Be Equal As Strings   ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    
    
    ${resp}=  Update Instant Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[1]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${lid1}  ${sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[1]}    
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}