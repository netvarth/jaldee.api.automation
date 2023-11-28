*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        MR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
@{gender}                 Female    Male
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${self}                   0


*** Test Cases ***

JD-TC-GetPatientPreviousVisit-1
    [Documentation]   Get patient previous visit for a walk-in check in.

    clear_queue      ${PUSERNAME111}
    clear_location   ${PUSERNAME111}
    clear_service    ${PUSERNAME111}
    clear_customer   ${PUSERNAME111}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME111}
    Set Suite Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY} 
    Set Suite Variable    ${ser_id1} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  3s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}


JD-TC-GetPatientPreviousVisit-2
    [Documentation]   Get patient previous visit for an online check in.
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}
    
    sleep   3s
    ${resp}=  Get Patient Previous Visit  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}

JD-TC-GetPatientPreviousVisit-3
    [Documentation]   Get patient previous visit for a future date walk in check in.

    clear_queue      ${PUSERNAME112}
    clear_location   ${PUSERNAME112}
    clear_service    ${PUSERNAME112}
    clear_customer   ${PUSERNAME112}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME112}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   2
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()}           []
   
JD-TC-GetPatientPreviousVisit-4
    [Documentation]   Get patient previous visit for a future date online check in.

    clear_queue      ${PUSERNAME112}
    clear_location   ${PUSERNAME112}
    clear_service    ${PUSERNAME112}
    clear_customer   ${PUSERNAME112}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME112}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cnote}=   FakerLibrary.word
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   2
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${FUT_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Get Patient Previous Visit  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Should Be Equal As Strings  ${resp.json()}           []

JD-TC-GetPatientPreviousVisit-5
    [Documentation]   Get patient previous visit having multiple walk in check ins.

    clear_queue      ${PUSERNAME144}
    clear_location   ${PUSERNAME144}
    clear_service    ${PUSERNAME144}
    clear_customer   ${PUSERNAME144}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME144}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['waitlist']['ynwUuid']}' == 'h_${wid1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['ynwUuid']}                               h_${wid2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END

JD-TC-GetPatientPreviousVisit-6
    [Documentation]   Get patient previous visit having multiple online check ins.

    clear_queue      ${PUSERNAME153}
    clear_location   ${PUSERNAME153}
    clear_service    ${PUSERNAME153}
    clear_customer   ${PUSERNAME153}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME153}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Get Patient Previous Visit  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['waitlist']['ynwUuid']}' == 'h_${wid1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['ynwUuid']}                               h_${wid2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END

JD-TC-GetPatientPreviousVisit-7
    [Documentation]   Get patient previous visit having both online checkin and walkin check in.

    clear_queue      ${PUSERNAME154}
    clear_location   ${PUSERNAME154}
    clear_service    ${PUSERNAME154}
    clear_customer   ${PUSERNAME154}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME154}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['waitlist']['ynwUuid']}' == 'h_${wid2}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['date']}                                       ${CUR_DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['ynwUuid']}                               h_${wid1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['name']}                       ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['service']['id']}                         ${ser_id2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END 

JD-TC-GetPatientPreviousVisit-8
    [Documentation]   Get patient previous visit of multiple consumers.

    clear_queue      ${PUSERNAME170}
    clear_location   ${PUSERNAME170}
    clear_service    ${PUSERNAME170}
    clear_customer   ${PUSERNAME170}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME170}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME170}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid2}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid3}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}

    ${resp}=  Get Patient Previous Visit  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid2}
    
    ${resp}=  Get Patient Previous Visit  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid3}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid3}

JD-TC-GetPatientPreviousVisit-9
    [Documentation]   Get patient previous visit of family members.

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME116}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${firstname0}=  FakerLibrary.first_name
    Set Test Variable   ${firstname0}
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid1}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id0}  ${resp.json()}

    ${resp}=  ListFamilyMemberByProvider  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id0} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

    ${resp}=  Get Patient Previous Visit  ${mem_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid}

JD-TC-GetPatientPreviousVisit-10
    [Documentation]   Get patient previous visit of both consumer and family members.

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME116}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${firstname0}=  FakerLibrary.first_name
    Set Test Variable   ${firstname0}
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid1}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id0}  ${resp.json()}

    ${resp}=  ListFamilyMemberByProvider  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid2}  ${resp.json()[0]['jaldeeId']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${mem_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid2}

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}


JD-TC-GetPatientPreviousVisit-11
    [Documentation]   Get patient previous visit after cancel checkin.

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME116}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
   
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      []
   
JD-TC-GetPatientPreviousVisit-12
    [Documentation]   Get patient previous visit of family members after cancel check in of consumer.

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME116}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1} 
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    Set Test Variable    ${ser_id2}
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${firstname0}=  FakerLibrary.first_name
    Set Test Variable   ${firstname0}
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid1}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id0}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}   ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    
    ${resp}=  Get Patient Previous Visit  ${mem_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      []
    
JD-TC-GetPatientPreviousVisit-13
    [Documentation]   Get patient previous visit without any check in/appointment.

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      []
    
JD-TC-GetPatientPreviousVisit-14
    [Documentation]   Get patient previous visit having checkins in multiple queues with same service.
    
    clear_queue      ${PUSERNAME111}
    clear_location   ${PUSERNAME111}
    clear_service    ${PUSERNAME111}
    clear_customer   ${PUSERNAME111}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid0}=  get_acc_id  ${PUSERNAME111}
    Set Test Variable  ${pid0}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    # ${loc_id2}=   Create Sample Location
    # ${ser_id1}=   Create Sample Service  ${SERVICE1}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  2  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}

    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}

JD-TC-GetPatientPreviousVisit-15
    [Documentation]   Get patient previous visit for a walk-in appointment.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME103}
    clear_location  ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME103}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME17}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['appmtDate']}                       ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['apptStatus']}                      ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['apptBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['uid']}                             h_${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}

JD-TC-GetPatientPreviousVisit-16
    [Documentation]   Get patient previous visit for an online appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME186}
   
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME186}
    clear_location  ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME186}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    # ${cid}=  get_id  ${CUSERNAME7}   
    # Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['appmtDate']}                       ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['apptStatus']}                      ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['apptBy']}                          ${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['uid']}                             h_${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}

JD-TC-GetPatientPreviousVisit-17
    [Documentation]   Get patient previous visit for a future date walk in appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME103}
    clear_location  ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME103}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME17}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY}=  db.add_timezone_date  ${tz}   4  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()}           []


JD-TC-GetPatientPreviousVisit-18
    [Documentation]   Get patient previous visit for future date online appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME186}
   
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME186}
    clear_location  ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME186}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY}=  db.add_timezone_date  ${tz}  5    
    # ${cid}=  get_id  ${CUSERNAME7}   
    # Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()}           []

JD-TC-GetPatientPreviousVisit-19
    [Documentation]   Get patient previous visit having multiple walk in appointments.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME103}
    clear_location  ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    clear_appt_schedule   ${PUSERNAME103}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME17}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['appointmnet']['uid']}' == 'h_${apptid1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[2]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[2]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['uid']}                             h_${apptid2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END

JD-TC-GetPatientPreviousVisit-20
    [Documentation]   Get patient previous visit having multiple online appointments.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME186}
   
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME186}
    clear_location  ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME186}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    # ${cid}=  get_id  ${CUSERNAME7}   
    # Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    sleep   2s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['appointmnet']['uid']}' == 'h_${apptid1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['uid']}                             h_${apptid2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END
    
JD-TC-GetPatientPreviousVisit-21
    [Documentation]   Get patient previous visit having both online apointment and walkin appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME103}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME103}
    clear_location  ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME103}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME17}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    # ${cid}=  get_id  ${CUSERNAME7}   
    # Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    # Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
    
        Run Keyword IF  '${resp.json()[${i}]['appointmnet']['uid']}' == 'h_${apptid1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[2]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
            ...     ELSE 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtDate']}                            ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptStatus']}                      ${apptStatus[1]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['apptBy']}                          ${waitlistedby[0]}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['uid']}                             h_${apptid2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['name']}                 ${SERVICE2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['service']['id']}                   ${s_id1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    END
    
JD-TC-GetPatientPreviousVisit-22
    [Documentation]   Get patient previous visit having both waitlist and appointment.

    clear_queue      ${PUSERNAME150}
    clear_location   ${PUSERNAME150}
    clear_service    ${PUSERNAME150}
    clear_customer   ${PUSERNAME150}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME150}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldeeid1}  ${resp.json()[0]['jaldeeId']}

    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME150}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   1s
    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['date']}                                  ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistStatus']}                        ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistedBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['ynwUuid']}                               h_${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['service']['id']}                         ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlist']['waitlistingFor'][0]['memberJaldeeId']}   ${jaldeeid1}
    
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['appmtDate']}                       ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['apptStatus']}                      ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['apptBy']}                          ${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['uid']}                             h_${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()[1]['appointmnet']['appmtFor'][0]['memberJaldeeId']}   ${jaldeeid1}


JD-TC-GetPatientPreviousVisit-UH1
    [Documentation]   Get Patient previous visit without login.

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetPatientPreviousVisit-UH2
    [Documentation]   Get Patient previous visit with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetPatientPreviousVisit-UH3
    [Documentation]   Get Patient previous visit with invalid consumer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Patient Previous Visit  000
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CONSUMER_NOT_FOUND}"

JD-TC-GetPatientPreviousVisit-UH4
    [Documentation]   Get Patient previous visit for another provider's consumer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    clear_customer   ${PUSERNAME150}

    ${resp}=  Get Patient Previous Visit  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CONSUMER_NOT_FOUND}"



















