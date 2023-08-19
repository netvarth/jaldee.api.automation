***Settings***
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
Variables         /ebs/TDD/varfiles/musers.py


***Test Cases***

Jaldee-TC-CreateIQ-1
    [Documentation]  Create an instant queue for a valid provider with multiple services
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_location  ${PUSERPH0}   AND   clear_service  ${PUSERPH0}
    # 185
    # ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100987
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_service  ${PUSERPH0}  AND  clear_location  ${PUSERPH0}
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
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    clear_queue  ${PUSERPH0}
    clear_location  ${PUSERPH0}
    clear_service  ${PUSERPH0}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_s1}  ${srv_result} 

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200     
    ${srv1_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_s2}   ${srv1_result} 
    ${ri}=  Create List  @{EMPTY}
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${stime1}=  add_time  0  45
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${today}=   get_weekday
    ${today}=   Convert To String  ${today}
    ${ri_today}=  Create List  ${today}
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri_today}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}


Jaldee-TC-CreateIQ-2
    [Documentation]     Create Instant queue with repeat intervals
    [Setup]  clear_queue  ${PUSERPH0} 
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue   ${p1queue1}  ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    ${ri}=  Create List  @{EMPTY}
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-3
    [Documentation]     Create Instant queue with future Start date
    [Setup]  clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${ri}=  Create List  @{EMPTY}
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY2}  ${EMPTY}   ${stime}  ${etime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-4
    [Documentation]     Create Instant queue with future end date
    [Setup]  clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${ri}=  Create List  @{EMPTY}
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${DAY2}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}



Jaldee-TC-CreateIQ-5
    [Documentation]  Create an instant queue with details same as that of another provider
    [Setup]   Run Keywords  clear_service  ${PUSERNAME112}  AND  clear_queue  ${PUSERNAME112}  AND  clear_location  ${PUSERNAME112}  AND  clear_queue  ${PUSERPH0}
    
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p2_l1}   ${loc_result}
    ${P2SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P2SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE1}  ${desc}   5   ${status[0]}   ${btype}   ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p2_s1}  ${srv_result} 
    
    ${P2SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P2SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   5  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200     
    ${srv1_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p2_s2}   ${srv1_result} 
    Log  ${p1_s1}

    ${ri}=  Create List  @{EMPTY}
    ${queue5}=    FakerLibrary.word
    Set Suite Variable  ${queue5}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue5}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p2_q1}  ${resp.json()}
    Log  ${p2_q1}
    ${resp}=  Get Queue ById  ${p2_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue5} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p2_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}   ${p2_s2}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    ${resp}=  Provider Logout

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Instant Queue  ${queue5}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${queue5} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-6
    [Documentation]  Create a second instant queue to the same location with more services
    [Setup]  Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_location  ${PUSERPH0}   AND   clear_service  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_s1}  ${srv_result} 
    
    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_s2}  ${srv_result} 
    
    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   5  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_s3}  ${srv_result}  
    
    ${ri}=  Create List  @{EMPTY}
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${stime1}=  add_time  0  45
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable  ${p1queue2}
    ${stime2}=  add_time  1  15
    Set Suite Variable   ${stime2}  ${stime2}
    ${etime2}=  add_time  1  30
    Set Suite Variable   ${etime2}  ${etime2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue2}    ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime2}  ${etime2}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s2}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_q2}  ${resp.json()}
    ${resp}=  Get Queue ById  ${p1_q2}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}   ${p1_s3}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}


Jaldee-TC-CreateIQ-7
    [Documentation]  Create an instant queue in different location with already existing name
    [Setup]  Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_location  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3  0
    Set Suite Variable   ${etime5}  ${etime5}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti1}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi1}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi1}  ${latti1}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}
    
    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3  0
    Set Suite Variable   ${etime5}  ${etime5}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti1}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi1}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi1}  ${latti1}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l2}   ${loc_result}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ri}=  Create List  @{EMPTY}
    ${stime3}=  add_time  1  45
    ${etime3}=  add_time    2  0
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${q_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_q1}  ${q_result}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${q_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_q2}  ${q_result}
    
    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}


Jaldee-TC-CreateIQ-8
    [Documentation]     Instant Queue with same time schedule as another DISABLED queue
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${ri}=  Create List  @{EMPTY}
    ${stime3}=  add_time  1  45
    ${etime3}=  add_time    2  0
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${q_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_q1}  ${q_result}

    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['name']}   ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}   ${recurringtype[4]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}   ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}   ${etime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${resp}=  Disable Queue  ${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime3}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    
    ${ri}=  Create List  @{EMPTY}
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable  ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    
    ${resp}=  Create Instant Queue  ${p1queue2}    ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-9
    [Documentation]     create an instant queue whose time overlaps with two other queues
    
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${ri}=  Create List  @{EMPTY}
    ${resp}=  ProviderKeywords.Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()[0]['id']}
    Set Test Variable  ${p2q1name}  ${resp.json()[0]['name']}
    
    ${resp}=  Disable Queue  ${p2_q1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p2_q1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p2q1name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_l1}
    Should Be Equal As Strings  ${resp.json()['id']}  ${p2_q1}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}

    ${p2queue3}=    FakerLibrary.word
    Set Suite Variable  ${p2queue3}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %

    ${resp}=  Create Instant Queue  ${p2queue3}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime}  ${etime1}  ${parallel}  ${capacity}  ${p2_l1}  ${p2_s1}
    Log   ${resp.json()}
    Set Suite Variable  ${p2_q3}  ${resp.json()}
    ${resp}=  Get Queue ById  ${p2_q3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p2queue3} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-10
    [Documentation]    Create an instant queue with multiple services of same service id
    clear_queue  ${PUSERNAME112}
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${ri}=  Create List  @{EMPTY}
    ${p2queue1}=    FakerLibrary.word
    Set Suite Variable  ${p2queue1}
    ${stime4}=  add_time  2  15
    Set Suite Variable   ${stime4}
    ${etime4}=  add_time    2  30
    Set Suite Variable   ${etime4}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue   ${p2queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime4}  ${etime4}  ${parallel}  ${capacity}  ${p2_l1}   ${p2_s1}   ${p2_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${length}=  Get Length  ${resp.json()['services']}
    Log  ${length}
    should be equal as numbers  ${length}   1
    Should Be Equal As Strings  ${resp.json()['name']}   ${p2queue1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p2_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime4}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime4}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}   ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-11
    [Documentation]     Create an instant queue in a location with same queue name and different time
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ri}=  Create List  @{EMPTY}

    ${stime1}=  add_time  0  45
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %

    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

    ${stime3}=  add_time  1  45
    Set Suite Variable   ${stime3}
    ${etime3}=  add_time    2  0
    Set Suite Variable   ${etime3}

    ${resp}=  Create Instant Queue  ${p1queue1}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${stime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${etime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}

Jaldee-TC-CreateIQ-UH-1
    [Documentation]     Create an instant queue in a past time window
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${time_now}=  db.get_time
    Log  ${time_now}
    ${ri}=  Create List  @{EMPTY}
    ${queue11}=    FakerLibrary.word
    Set Suite Variable  ${queue11}
    ${old_stime}=  subtract_time   0  30
    Set Suite Variable   ${old_stime}  
    ${old_etime}=  subtract_time   0  15
    Set Suite Variable   ${old_etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %

    ${resp}=  Create Instant Queue  ${queue11}    ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${old_stime}  ${old_etime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${TIME_WINDOW_BEFORE_SCHEDULE}"
    
Jaldee-TC-CreateIQ-UH-2
    [Documentation]     Create an instant queue to the same location with overlapping time
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Queue Location   ${p1_l1}
    Log   ${resp.json()}
    Set Suite Variable  ${s_time}   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${e_time}   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}
    ${ri}=  Create List  @{EMPTY}
    ${queue12}=    FakerLibrary.word
    Set Suite Variable  ${queue12}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue12}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${s_time}   ${e_time}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"

Jaldee-TC-CreateIQ-12
    [Documentation]    Create an instant queue in different location with overlapping time
    [Setup]  Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_location  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${stime4}=  add_time  2  15
    Set Suite Variable   ${stime4}
    ${etime4}=  add_time    2  30
    Set Suite Variable   ${etime4}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti2}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi2}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi2}  ${latti2}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}  ${loc_result}

    ${ri}=  Create List  @{EMPTY}
    ${stime3}=  add_time  1  45
    ${etime3}=  add_time    2  0
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable  ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue1}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}   ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${q_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_q1}  ${q_result}

    ${resp}=  Get Queue Location   ${p1_l1}
    Log   ${resp.json()}
    Set Suite Variable  ${s_time}   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${e_time}   ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}

    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3  0
    Set Suite Variable   ${etime5}  ${etime5}
    ${city}=   FakerLibrary.state
    Set Suite Variable  ${city}
    ${latti2}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi2}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi2}  ${latti2}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l2}  ${loc_result}
    
    
    ${ri}=  Create List  @{EMPTY}
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable  ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${p1queue2}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${s_time}   ${e_time}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${q_result} = 	Convert To Integer 	 ${resp.json()}
    Set Test Variable  ${p1_q2}  ${q_result}

    ${resp}=  Get Queue ById  ${p1_q2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${p1queue2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    Comment  Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${s_time}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${e_time}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  ${parallel}
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['instantQueue']}   ${bool[1]}
    


Jaldee-TC-CreateIQ-UH-4
    [Documentation]    Create an instant queue in a location without service details
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ri}=  Create List  @{EMPTY}
    ${queue14}=    FakerLibrary.word
    Set Suite Variable  ${queue14}
    ${stime3}=  add_time  1  45
    Set Suite Variable   ${stime3}
    ${etime3}=  add_time    2  0
    Set Suite Variable   ${etime3}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue without Service  ${queue14}    ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime3}  ${etime3}  ${parallel}  ${capacity}  ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SERVICES_REQUIRED}"

Jaldee-TC-CreateIQ-UH-5
    [Documentation]    Create an instant queue in a location without location details
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ri}=  Create List  @{EMPTY}
    ${queue15}=    FakerLibrary.word
    Set Suite Variable  ${queue15}
    ${stime1}=  add_time  0  45
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue15}  ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime1}  ${etime1}  ${parallel}  ${capacity}  ${EMPTY}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_LOCATION_REQUIRED}"

Jaldee-TC-CreateIQ-UH-6
    [Documentation]    Create an instant queue with another providers location details
    [Setup]     Run Keywords   clear_service   ${PUSERNAME189}   AND  clear_location  ${PUSERNAME189}
    ${resp}=  Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6
    Set Suite Variable  ${list}  ${list}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti2}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi2}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element     ${parkingType} 
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi2}  ${latti2}  ${url}  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p3_l1}  ${loc_result}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${P3SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P3SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P3SERVICE1}  ${desc}   5  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p3_s1}  ${srv_result}
    ${ri}=  Create List  @{EMPTY}
    ${queue16}=    FakerLibrary.word
    Set Suite Variable  ${queue16}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue16}    ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${p3_l1}  ${p3_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

Jaldee-TC-CreateIQ-UH-7
    [Documentation]    Create an instant queue with another providers service  details
    
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid}   ${resp.json()[0]['id']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${ri}=  Create List  @{EMPTY}
    ${queue17}=    FakerLibrary.word
    Set Suite Variable  ${queue17}
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue17}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${lid}  ${sid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"
 
    
Jaldee-TC-CreateIQ-UH-8
    [Documentation]    Create an instant queue with end time less than start time
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ri}=  Create List  @{EMPTY}
    
    ${queue18}=    FakerLibrary.word
    Set Suite Variable  ${queue18}
    ${stime4}=  add_time  2  15
    Set Suite Variable   ${stime4}
    ${etime4}=  add_time    2  30
    Set Suite Variable   ${etime4}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue  ${queue18}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${etime4}  ${stime4}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STARTTIMECANT_BEGREATERTHANENDTIME}"

Jaldee-TC-CreateIQ-UH-9
    [Documentation]    Create an instant queue with time different from service time
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${SERVICE11}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE11}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE11}  ${desc}   30  ${status[0]}   ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${srv_result} = 	Convert To Integer 	 ${resp.json()}     
    Set Suite Variable  ${p1_s11}  ${srv_result} 
    ${ri}=  Create List  @{EMPTY}
    ${queue19}=    FakerLibrary.word
    Set Suite Variable  ${queue19}
    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3   0
    Set Suite Variable   ${etime5}  ${etime5}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Instant Queue   ${queue19}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime5}  ${etime5}  ${parallel}  ${capacity}  ${p2_l1}   ${p1_s11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_DURATION_LIMIT_REACHED_INSTANCE}"

Jaldee-TC-CreateIQ-UH-10
    [Documentation]    Create an instant queue with non existant service id
    ${resp}=  Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Service
    Log   ${resp.json()}
    ${DAY1}=  get_date
    ${ri}=  Create List  @{EMPTY}
    ${queue20}=    FakerLibrary.word
    Set Suite Variable  ${queue20}
    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3  0
    Set Suite Variable   ${etime5}  ${etime5}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${rand_sid}=  FakerLibrary.Numerify  %%%%%%
    ${resp}=  Create Instant Queue   ${queue20}   ${recurringtype[4]}  ${ri}  ${DAY1}  ${EMPTY}  ${stime5}  ${etime5}  ${parallel}  ${capacity}  ${p2_l1}   ${rand_sid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"


Jaldee-TC-CreateIQ-13
    [Documentation]  Create Instant Queue for Branch

    ${resp}=  Provider Login  ${MUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200


Jaldee-TC-CreateIQ-14
    [Documentation]  Create Instant Queue for User
    
    ${resp}=  Provider Login  ${MUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
*** comment ***

    Set Time
    [Documentation]  Create dynamic time variables.
    ${Time}=  db.get_time
    ${stime}=  add_time  0  15
    Set Suite Variable   ${stime}  ${stime}
    ${etime}=  add_time   0  30
    Set Suite Variable   ${etime}  ${etime}
    ${stime1}=  add_time  0  45
    Set Suite Variable   ${stime1}  ${stime1}
    ${etime1}=  add_time  1  0
    Set Suite Variable   ${etime1}  ${etime1}
    ${stime2}=  add_time  1  15
    Set Suite Variable   ${stime2}  ${stime2}
    ${etime2}=  add_time  1  30
    Set Suite Variable   ${etime2}  ${etime2}
    ${stime3}=  add_time  1  45
    Set Suite Variable   ${stime3}  ${stime3}
    ${etime3}=  add_time    2  0
    Set Suite Variable   ${etime3}  ${etime3}
    ${stime4}=  add_time  2  15
    Set Suite Variable   ${stime4}  ${stime4}
    ${etime4}=  add_time    2  30
    Set Suite Variable   ${etime4}  ${etime4}
    ${stime5}=  add_time  2  45
    Set Suite Variable   ${stime5}  ${stime5}
    ${etime5}=  add_time    3  0
    Set Suite Variable   ${etime5}  ${etime5}
    ${stime6}=  add_time  0  47
    Set Suite Variable   ${stime6}  ${stime6}
    ${etime6}=  add_time  1  0
    Set Suite Variable   ${etime6}  ${etime6}



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