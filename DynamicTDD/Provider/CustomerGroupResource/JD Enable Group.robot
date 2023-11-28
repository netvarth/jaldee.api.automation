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

JD-TC-EnableGroup-1
    [Documentation]  Enable a disabled group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME95}
    clear_customer   ${PUSERNAME95}

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

    ${resp}=  Disable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[1]}  description=${desc}  consumerCount=0

    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0


JD-TC-EnableGroup-UH1
    [Documentation]  Enable an already Enabled group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME95}
    clear_customer   ${PUSERNAME95}

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

    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_ALREDY_ENABLED}"


JD-TC-EnableGroup-UH2
    [Documentation]  Enable a group without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${groupid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-EnableGroup-UH3
    [Documentation]  Enable a group by consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${groupid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-EnableGroup-UH4
    [Documentation]  Enable an non existant group

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupid}=  FakerLibrary.Numerify  %%%
    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"


JD-TC-EnableGroup-UH5
    [Documentation]  Enable another provider's group

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${groupid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401 
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    