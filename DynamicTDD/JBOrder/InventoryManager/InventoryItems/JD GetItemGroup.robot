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
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-GetItemGroup-1

    [Documentation]   Get Item Group

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-GetItemGroup-Uh1

    [Documentation]   Get Item Group - with invalid item group id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=999  max=9999

    ${resp}=    Get Item group by id Provider  ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200

JD-TC-GetItemGroup-Uh2

    [Documentation]   Get Item Group - without login

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            419
    Should Be Equal As Strings    ${resp.json()}                 ${SESSION_EXPIRED}

JD-TC-GetItemGroup-UH3

    [Documentation]   Get Item Group - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200

