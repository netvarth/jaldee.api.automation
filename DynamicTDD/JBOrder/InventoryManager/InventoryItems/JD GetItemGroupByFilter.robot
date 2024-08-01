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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetItemGroupByFilter-1

    [Documentation]   Get Item Group By Filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
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


    ${groupName2}=    FakerLibrary.name
    Set Suite Variable      ${groupName2}

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName2}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200

    ${resp}=    Get Item group Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()[0]['groupName']}    ${groupName2} 
    Should Be Equal As Strings    ${resp.json()[0]['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}


JD-TC-GetItemGroupByFilter-2

    [Documentation]  Get Item group Filter - groupName

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Filter    groupName-eq=${groupName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetItemGroupByFilter-3

    [Documentation]  Get Item group Filter - groupDesc

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Filter    description-eq=${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()[0]['groupName']}    ${groupName2} 
    Should Be Equal As Strings    ${resp.json()[0]['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-GetItemGroupByFilter-4

    [Documentation]  Get Item group Filter - status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Filter    status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()[0]['groupName']}    ${groupName2} 
    Should Be Equal As Strings    ${resp.json()[0]['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-GetItemGroupByFilter-UH1

    [Documentation]  Get Item group Filter - without login

    ${resp}=    Get Item group Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-GetItemGroupByFilter-5

    [Documentation]  Get Item group Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}    []