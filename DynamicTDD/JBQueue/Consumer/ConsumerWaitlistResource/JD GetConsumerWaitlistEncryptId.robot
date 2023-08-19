*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
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
${waitlistedby}           CONSUMER
                            

*** Test Cases ***    
JD-TC-GetWaitlistByEncryptedID-1
    [Documentation]   Get Waitlist details By Encrypted ID
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME202}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${PUSERNAME202}
    clear_service   ${PUSERNAME202}
    clear_location  ${PUSERNAME202}
    clear_queue  ${PUSERNAME202}
    clear waitlist   ${PUSERNAME202}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${SERVICE1}=   FakerLibrary.name
    Set Suite Variable  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  50  
    Set Suite Variable   ${eTime1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    
    ${cid}=  get_id  ${CUSERNAME6}   
    Set Suite Variable   ${cid}

    ${firstname}=  FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${f1}   ${resp.json()}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY1}  ${s_id1}  ${cnote}  ${bool[0]}  ${f1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER   ynwUuid=${uuid1}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1} 
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${c_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}  ${f_Name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}  
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}   ${f1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME6}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME202}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_uuid1}  ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${uuid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   checkinEncId=${W_uuid1}

    ${resp}=  Get Waitlist By EncodedID    ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}    personsAhead=0  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}            ${c_id}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
    
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId   ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}     personsAhead=0 
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}            ${c_id}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
    
JD-TC-GetWaitlistByEncryptedID-2
    [Documentation]   Consumer without login Get Encrypted ID
 
    ${resp}=   Get Consumer Waitlist By EncodedId   ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}    personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}            ${c_id}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
    
JD-TC-GetWaitlistByEncryptedID-3
    [Documentation]    Get Consumer Encrypted ID of another consumer
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Waitlist By EncodedId     ${W_uuid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}            ${c_id}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
   

JD-TC-GetWaitlistByEncryptedID-UH1
    [Documentation]     Passing Consumer Encrypted ID is Empty 
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId    ${empty}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-GetWaitlistByEncryptedID-UH2
    [Documentation]     Passing Consumer Encrypted ID is Zero 
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_CHECKIN_ID}"

