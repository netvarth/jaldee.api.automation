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
${SERVICE1}               MICRA  
${SERVICE2}               YOUNG

*** Test Cases ***

JD-TC-GetWaitlistEncryptedIDHistory-1

    [Documentation]   View Waitlist by Consumer EncodedID 

    change_system_date   -3

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${PUSERNAME132}
    clear_service   ${PUSERNAME132}
    clear_location  ${PUSERNAME132}
    clear_queue  ${PUSERNAME132}
    
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}

    ${SERVICE1}=   FakerLibrary.name
    Set Suite Variable  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  50  
    Set Suite Variable   ${eTime1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 

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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  ynwUuid=${uuid1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}  ${f_Name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}  
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME6}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${WEncId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${WEncId}

    ${resp}=   Get Waitlist By EncodedID    ${WEncId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId   ${WEncId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}


JD-TC-GetWaitlistEncryptedIDHistory-UH1

    [Documentation]   View Consumer Waitlist By Encoded Id

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId   ${WEncId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-GetWaitlistEncryptedIDHistory-UH2

    [Documentation]   View Consumer  Waitlist By Encoded Id is Zero    
   
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Consumer Waitlist By EncodedId   0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_CHECKIN_ID}