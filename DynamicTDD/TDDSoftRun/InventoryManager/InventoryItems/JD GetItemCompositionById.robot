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

JD-TC-GetItemComposition-1

    [Documentation]  Get Item Composition

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
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

    ${compositionName}=     FakerLibrary.name
    Set Suite Variable  ${compositionName}

    ${resp}=    Create Item Composition     ${compositionName} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${compositionCode}    ${resp.json()}

    ${resp}=    Get Item Composition by id   ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${compositionCode}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}

JD-TC-GetItemComposition-UH1

    [Documentation]  Get Item Composition - composition code is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=999  max=9999

    ${resp}=    Get Item Composition by id   ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Empty  ${resp.content}


JD-TC-GetItemComposition-UH2

    [Documentation]  Get Item Composition - without login

    ${resp}=    Get Item Composition by id   ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}       419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}


JD-TC-GetItemComposition-UH3

    [Documentation]  Get Item Composition - with another login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Composition by id   ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}            200
    Should Be Empty  ${resp.content}
