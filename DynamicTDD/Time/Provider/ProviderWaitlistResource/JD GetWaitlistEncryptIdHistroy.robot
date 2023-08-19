*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
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
${SERVICE1}               MICRA  
${SERVICE2}               YOUNG

*** Test Cases ***
JD-TC-GetWaitlistEncryptedIDHistory-1
    [Documentation]   View Waitlist by Provider login

    clear_queue      ${PUSERNAME68}
    clear_location   ${PUSERNAME68}
    clear_service    ${PUSERNAME68}
    clear_waitlist   ${PUSERNAME68}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id1}   
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${s_id2} 
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
    Set Suite Variable    ${end_time} 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}  ${s_id2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}   ${resp.json()} 
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PC_number}=   Random Int  min=100   max=1000
    ${ph1}=  Evaluate  ${CUSERNAME2}+${PC_number}
    Set Test Variable  ${email2}  ${firstname}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph1}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${waitlist_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${waitlist_id}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${WEncId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${WEncId}

    ${resp}=   Get Waitlist By EncodedID    ${WEncId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date   3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist History
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}   0   date=${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['firstName']}           ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['lastName']}            ${lastName}
    
JD-TC-GetWaitlistEncryptedIDHistory-UH1

    [Documentation]   View Waitlist Encoded Id
    change_system_date   3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${waitlist_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

   ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PAST_WAITLIST_NO_ENCODED_ID}"

JD-TC-GetWaitlistEncryptedIDHistory-UH2

    [Documentation]   View Waitlist Encoded Id is Zero
    change_system_date   3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${waitlist_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

   ${resp}=   Get Waitlist EncodedId    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PAST_WAITLIST_NO_ENCODED_ID}"