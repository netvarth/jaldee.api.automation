*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Groups
Library           String
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


***Test Cases***

JD-TC-GetGroups-1
    [Documentation]  Get customer groups of a provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME93}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME93}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0


    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${groupid}'  
        ...    Verify Response List  ${resp}  ${i}  id=${groupid}  groupName=${groupName}  
        ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${groupid1}'   
        ...    Verify Response List  ${resp}  ${i}  id=${groupid1}  groupName=${groupName1}  
        ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0   

    END


JD-TC-GetGroups-2
    [Documentation]  Get customer groups of a provider without creating groups 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME93}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME93}   

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0


JD-TC-GetGroups-UH1
    [Documentation]  Get customer groups of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME93}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME93}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME92}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME92}

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0


JD-TC-GetGroups-UH2
    [Documentation]  Get customer groups without login

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetGroups-UH3
    [Documentation]  Get customer groups by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

    