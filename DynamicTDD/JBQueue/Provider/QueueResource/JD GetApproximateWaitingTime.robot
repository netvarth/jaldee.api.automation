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
${SERVICE3}  Makeup2 
${SERVICE4}  Hair makeup2
${self}      0

*** Test Cases ***

JD-TC-Approximate Waiting Time-1
    [Documentation]   Add a consumer to the waitlist for the current day when calculation mode as Fixed Then Verify all consumers approximate waiting time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME40}
    clear_location  ${PUSERNAME40}
    clear_queue  ${PUSERNAME40}
    clear_customer   ${PUSERNAME40}

    ${resp}=   Get upgradable license
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Test Variable  ${pkgid}  ${resp.json()[${len}]['pkgId']} 
    Set Test Variable  ${pkgname}  ${resp.json()[${len}]['pkgName']}
    ${resp}=  Change License Package  ${pkgid}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fixed_time}=   Random Int  min=1   max=10
    Set Suite Variable  ${fixed_time}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${fixed_time}  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1}  ${DAY1}
    # ${DAY2}=  add_date  70      
    # Set Suite Variable  ${DAY2}  ${DAY2}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # ${sTime1}=  add_time  2  00
    # Set Suite Variable   ${sTime1}
    # ${eTime1}=  add_time   3  30
    # Set Suite Variable   ${eTime1}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${lid1}    ${resp}  
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  add_timezone_date  ${tz}  7      
    Set Suite Variable  ${DAY2}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${sTime1}=  add_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time   ${tz}  3  30
    Set Suite Variable   ${eTime1}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=0

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}
 
JD-TC-Approximate Waiting Time-2

    [Documentation]   Add a consumer to the waitlist for future when calculation mode as Fixed Then Verify all consumers approximate waiting time
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME41}
    clear_location  ${PUSERNAME41}
    clear_queue  ${PUSERNAME41}
    clear_customer   ${PUSERNAME41}

    ${resp}=   Get upgradable license
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Test Variable  ${pkgid}  ${resp.json()[${len}]['pkgId']} 
    Set Test Variable  ${pkgname}  ${resp.json()[${len}]['pkgName']}
    ${resp}=  Change License Package  ${pkgid}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${fixed_time}  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${lid1}    ${resp}  
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  add_timezone_date  ${tz}  7      
    Set Suite Variable  ${DAY2}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${sTime1}=  add_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time   ${tz}  3  30
    Set Suite Variable   ${eTime1}


    # ${DAY1}=  add_date  30
    # Set Test Variable  ${DAY1}  ${DAY1}
    
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id4}
    ${queue_name}=  FakerLibrary.bs
    ${resp1}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${qid1}  ${resp1.json()}
  
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=0

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=${fixed_time}

JD-TC-Approximate Waiting Time-3
    [Documentation]   Add a consumer to the waitlist for the current day when calculation mode as NoCalc and verify all consumers approximate waiting time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME42}
    clear_location  ${PUSERNAME42}
    clear_queue  ${PUSERNAME42}
    clear_customer   ${PUSERNAME42}
    ${resp}=   Get upgradable license
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Test Variable  ${pkgid}  ${resp.json()[${len}]['pkgId']} 
    Set Test Variable  ${pkgname}  ${resp.json()[${len}]['pkgName']}
    ${resp}=  Change License Package  ${pkgid}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  10  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${lid1}    ${resp}  
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-Approximate Waiting Time-4
    [Documentation]   Add a consumer to the waitlist for the future when calculation mode as NoCalc and verify all consumers approximate waiting time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME43}
    clear_location  ${PUSERNAME43}
    clear_queue  ${PUSERNAME43}
    clear_customer   ${PUSERNAME43}
    ${resp}=   Get upgradable license
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Test Variable  ${pkgid}  ${resp.json()[${len}]['pkgId']} 
    Set Test Variable  ${pkgname}  ${resp.json()[${len}]['pkgName']}
    ${resp}=  Change License Package  ${pkgid}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${lid1}    ${resp}  
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${DAY2}=  db.add_timezone_date  ${tz}  20
    
    # ${DAY1}=  add_date  20
    # Set Test Variable  ${DAY1}  ${DAY1}
    
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id1}  ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200