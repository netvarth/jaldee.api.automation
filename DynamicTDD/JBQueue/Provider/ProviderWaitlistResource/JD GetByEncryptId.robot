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
${waitlistedby}           PROVIDER

*** Test Cases ***    
JD-TC-GetEncryptedID-1
    [Documentation]   Get By Encrypted ID 
    
    ${resp}=  ProviderLogin  ${PUSERNAME125}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME125}

    clear_service   ${PUSERNAME125}
    clear_location  ${PUSERNAME125}
    clear_queue  ${PUSERNAME125}
    # clear waitlist   ${PUSERNAME125}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${SERVICE1}=   FakerLibrary.name
    Set Suite Variable  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  subtract_time  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   3  30
    Set Suite Variable   ${eTime1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PC_number}=   Random Int  min=100   max=1000
    ${ph1}=  Evaluate  ${CUSERNAME2}+${PC_number}
    Set Test Variable  ${email2}  ${firstname}${C_Email}.${test_mail}
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

    ${resp}=  Get Waitlist By Id  ${waitlist_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${waitlist_id}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
    Log   ${resp.json()}
    #Set Suite Variable   ${W_Enc_Id}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By EncodedID    ${encId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${waitlist_id}

JD-TC-GetEncryptedID-2
    [Documentation]   Get Encrypted ID of a future day
    ${resp}=  ProviderLogin  ${PUSERNAME125}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  add_date  2
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${waitlist_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${waitlist_id2}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id2}
    Log   ${resp.json()}
    #Set Suite Variable   ${encId2}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By EncodedID    ${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response    ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${waitlist_id2}

JD-TC-GetEncryptedID-UH1
    [Documentation]    Get Waitlist Encrypted ID of another provider
    ${resp}=  ProviderLogin  ${PUSERNAME129}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By EncodedID     ${encId2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-GetEncryptedID-UH2
    [Documentation]   Get Waitlist By Encrypted Id without login
    ${resp}=   Get Waitlist By EncodedID   ${encId2}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-GetEncryptedID-UH3
    [Documentation]     Passing Encrypeted ID is Empty in the Get Encrypted ID 
    ${resp}=  ProviderLogin  ${PUSERNAME125}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Waitlist By EncodedID    ${empty}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_WAITLIST}"

JD-TC-GetEncryptedID-UH4
    [Documentation]     Passing Encrypted ID is Zero in the Get Encrypted ID 
    ${resp}=  ProviderLogin  ${PUSERNAME125}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Waitlist By EncodedID    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_CHECKIN_ID}"

JD-TC-GetEncryptedID-UH5
    [Documentation]  Get  Waitlist By Id by consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    ${resp}=  Get Waitlist By EncodedID   ${encId2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"