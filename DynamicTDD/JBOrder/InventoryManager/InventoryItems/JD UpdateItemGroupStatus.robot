*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-UpdateItemGroupStatus-1
    [Documentation]   Update Item Group Status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${groupName}=    FakerLibrary.name
    Set Suite Variable      ${groupName}

    ${groupDesc}=    FakerLibrary.name
    Set Suite Variable  ${groupDesc}

    ${groupCode}=   FakerLibrary.Sentence   nb_words=3
    Set Suite Variable  ${groupCode}

    ${resp}=    Create Item group Provider  ${groupName}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${ig_id}   ${resp.json()}

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]} 

    ${resp}=    Update Item group Status  ${ig_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[1]}


JD-TC-UpdateItemGroupStatus-2
    [Documentation]  Update Item group Status - Disable to Disable

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200

    ${resp}=    Update Item group Status  ${ig_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateItemGroupStatus-3
    [Documentation]  Update Item group Status - Disable to Enable

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[1]}

    ${resp}=    Update Item group Status  ${ig_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}

JD-TC-UpdateItemGroupStatus-4
    [Documentation]  Update Item group Status - Enable to Enable

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}

    ${resp}=    Update Item group Status  ${ig_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemGroupStatus-5
    [Documentation]  Update Item group Status - without login

    ${resp}=    Update Item group Status  ${ig_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}