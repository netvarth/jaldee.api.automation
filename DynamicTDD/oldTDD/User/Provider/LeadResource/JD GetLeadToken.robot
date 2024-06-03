*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist} 
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${sample}                     4452135820
${self}               0


*** Test Cases ***

JD-TC-GetLeadToken-1

    [Documentation]  Create a lead  Token Then get the Token .

    clear_service    ${PUSERNAME63}
    clear_customer   ${PUSERNAME63}
    clear_location   ${PUSERNAME63}
    clear_queue      ${PUSERNAME63}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${p_id}    ${resp.json()['id']}
    # ${p_id}=  get_acc_id  ${PUSERNAME63}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  AddCustomer  ${CUSERNAME4}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lead_id1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=  Create Sample Location
    Set Suite Variable    ${loc_id4}   ${resp}
    ${ser_name3}=    FakerLibrary.name
    Set Suite Variable     ${ser_name3}
    ${resp}=  Create Sample Service   ${ser_name3}
    Set Suite Variable    ${ser_id4}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  
    
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}   ${resp.json()}

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${desc}=   FakerLibrary.word
    ${lead}=  Create Dictionary   id=${lead_id1}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${q_id4}  ${DAY4}  ${desc}  ${bool[1]}  ${cid}   lead=${lead}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=    Add Lead Token   ${leUid1}    ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}    ${bool[1]}


    ${resp}=  Get Lead Tokens   ${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['waitlistUid']}    ${wid}
    Should Be Equal As Strings    ${resp.json()[0]['token']}    1
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}    ${p_id}


    ${resp}=    Get Leads With Filter    id-eq=${lead_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['waitlistUid']}    ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['createdBy']}    ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['waitlistStatus']}    ${bool[1]}

JD-TC-GetLeadToken-2

    [Documentation]  Create Two lead Token with diffrent waitlist id Then get the Token .

    clear_queue      ${PUSERNAME63}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${p_id}    ${resp.json()['id']}
    ${resp}=  Create Sample Location
    Set Suite Variable    ${locid1}   ${resp}

    
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${PUSERNAME_U2}   ${resp.json()[0]['mobileNo']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME5}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id5}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locid1}    ${pcons_id5}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lead_id2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name4}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  
    
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name4}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${locid1}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id5}   ${resp.json()}
    
    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${desc}=   FakerLibrary.word
    ${lead}=  Create Dictionary   id=${lead_id2}
    ${resp}=  Add To Waitlist  ${pcons_id5}  ${ser_id4}  ${q_id5}  ${DAY4}  ${desc}  ${bool[1]}  ${pcons_id5}   lead=${lead}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${desc1}=   FakerLibrary.word
    ${lead}=  Create Dictionary   id=${lead_id2}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id4}  ${q_id5}  ${DAY4}  ${desc1}  ${bool[1]}  ${cid1}   lead=${lead}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=    Add Lead Token   ${leUid2}    ${wid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}    ${bool[1]}


    ${resp}=  Get Lead Tokens   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['waitlistUid']}    ${wid1}
    Should Be Equal As Strings    ${resp.json()[0]['token']}    1
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}    ${p_id}

    ${resp}=    Add Lead Token   ${leUid2}    ${wid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}    ${bool[1]}


    ${resp}=  Get Lead Tokens   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[1]['waitlistUid']}    ${wid2}
    Should Be Equal As Strings    ${resp.json()[1]['token']}    2
    Should Be Equal As Strings    ${resp.json()[1]['createdBy']}    ${p_id}


JD-TC-GetLeadToken-3

    [Documentation]  Create Two lead Token with diffrent waitlist id Then get the Token .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Lead Token   ${leUid2}    ${wid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422




JD-TC-GetLeadToken-UH1

    [Documentation]   Add Two times same Waitlist then get the token.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title1}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title1}    ${desc}    ${targetPotential}      ${locid1}    ${pcons_id5}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lead_id3}        ${resp.json()['id']}
    Set Suite Variable   ${leUid3}        ${resp.json()['uid']}

    ${DAY4}=  db.add_timezone_date  ${tz}  1  
    ${desc1}=   FakerLibrary.word
    ${lead}=  Create Dictionary   id=${lead_id3}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id4}  ${q_id5}  ${DAY4}  ${desc1}  ${bool[1]}  ${cid1}   lead=${lead}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}


    ${resp}=    Add Lead Token   ${leUid3}    ${wid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}    ${bool[1]}

    ${resp}=    Add Lead Token   ${leUid3}    ${wid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${TOKEN_ALREADY_ADDED}

    ${resp}=  Get Lead Tokens   ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['waitlistUid']}    ${wid3}
    Should Be Equal As Strings    ${resp.json()[0]['token']}    1
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}    ${p_id}

JD-TC-AddLeadToken-UH2
    [Documentation]  GetLeadToken without login.

    ${resp}=  Get Lead Tokens   ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-AddLeadToken-UH3
    [Documentation]  GetLeadToken with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Lead Tokens   ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"
