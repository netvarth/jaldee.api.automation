*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        jaldeeInegration
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
${SERVICE1}     Radio Repdca111

*** Test Cases ***

JD-TC-WalkinConsumer1

    [Documentation]  Enable walkinConsumer and set a consumer  to jaldee consumer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME116}

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[0]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME116}
    clear_location  ${PUSERNAME116}
    clear_queue  ${PUSERNAME116}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable   ${eTime1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph1}=  Evaluate  ${CUSERNAME2}+123
    Set Test Variable  ${email2}  ${firstname}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph1}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}


    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   GetCustomer    phoneNo-eq=${ph1}  status-eq=ACTIVE 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}    ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}    ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['email']}   ${email2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}   ${ph1}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}   ${dob}

    


JD-TC-WalkinConsumer2

    [Documentation]  Disable walkinConsumer and set a consumer  to jaldee consumer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME16}

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[0]}  ${boolean[0]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME16}
    clear_location  ${PUSERNAME16}
    clear_queue  ${PUSERNAME16}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable   ${eTime1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph1}=  Evaluate  ${CUSERNAME2}+114
    Set Test Variable  ${email2}  ${firstname}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph1}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}


    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME118}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   GetCustomer    phoneNo-eq=${ph1}  status-eq=ACTIVE 
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
