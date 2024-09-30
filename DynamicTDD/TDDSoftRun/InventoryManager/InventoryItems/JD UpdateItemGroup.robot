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

JD-TC-UpdateItemGroup-1

    [Documentation]   Update Item Group - group name updated

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
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

    ${groupName2}=    FakerLibrary.name
    Set Suite Variable      ${groupName2}

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName2}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item group by id Provider  ${ig_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Equal As Strings    ${resp.json()['id']}           ${ig_id} 
    Should Be Equal As Strings    ${resp.json()['groupName']}    ${groupName2} 
    Should Be Equal As Strings    ${resp.json()['groupDesc']}    ${groupDesc} 
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]} 

JD-TC-UpdateItemGroup-UH1

    [Documentation]   Update Item Group - update the existing name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName2}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${GROUP_NAME_ALREADY_EXIST}

JD-TC-UpdateItemGroup-2

    [Documentation]   Update Item Group - update group code

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${groupCode3}=   FakerLibrary.Sentence   nb_words=3

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName3}  ${groupCode3}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemGroup-3

    [Documentation]   Update Item Group - update group des

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupDesc2}=    FakerLibrary.name
    ${groupName3}=    FakerLibrary.name

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName3}  ${groupCode}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemGroup-4

    [Documentation]   Update Item Group - group name is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${resp}=    Update Item group Provider  ${ig_id}  ${empty}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_GROUP_NAME}
    

JD-TC-UpdateItemGroup-5

    [Documentation]   Update Item Group - group code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName3}  ${empty}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemGroup-6

    [Documentation]   Update Item Group - group des is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName3}  ${groupCode}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemGroup-7

    [Documentation]   Update Item Group - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Group code

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName3}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_FIELD}


JD-TC-UpdateItemGroup-UH2

    [Documentation]   Update Item Group - group id is inv

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999  max=9999
    ${groupName3}=    FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Group code

    ${resp}=    Update Item group Provider  ${inv}  ${groupName3}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_FIELD}

JD-TC-UpdateItemGroup-UH3

    [Documentation]   Update Item Group - group id is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Group code

    ${resp}=    Update Item group Provider  ${empty}  ${groupName3}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_FIELD}

JD-TC-UpdateItemGroup-UH4

    [Documentation]   Update Item Group - without login

    ${resp}=    Update Item group Provider  ${ig_id}  ${groupName2}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}