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

JD-TC-GetItemGroupCount-1

    [Documentation]   Create Item Group

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
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

    ${resp}=    Get Item group Count Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}         1


JD-TC-GetItemGroupCount-2

    [Documentation]  Get Item group Count Filter - groupName

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Count Filter    groupName-eq=${groupName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}              1

JD-TC-GetItemGroupCount-3

    [Documentation]  Get Item group Count Filter - groupDesc

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Count Filter    groupDesc-eq=${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}              1

JD-TC-GetItemGroupCount-4

    [Documentation]  Get Item group Count Filter - status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Count Filter    status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}              1

JD-TC-GetItemGroupCount-UH1

    [Documentation]  Get Item group Count Filter - without login

    ${resp}=    Get Item group Count Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-GetItemGroupCount-5

    [Documentation]  Get Item group Count Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Count Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}    0