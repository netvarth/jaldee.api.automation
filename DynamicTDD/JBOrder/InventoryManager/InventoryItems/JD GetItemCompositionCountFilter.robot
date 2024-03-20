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

JD-TC-GetItemCompositionCountFilter-1

    [Documentation]  Get Item Composition Count Filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${compositionName2}=     FakerLibrary.name
    Set Suite Variable  ${compositionName2}

    ${resp}=    Create Item Composition     ${compositionName2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${compositionCode2}    ${resp.json()}

    ${resp}=    Get Item Composition by id   ${compositionCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${compositionCode2}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName2}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}

    ${compositionName3}=     FakerLibrary.name
    Set Suite Variable  ${compositionName3}

    ${resp}=    Update Item Composition     ${compositionName3}  ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Composition by id   ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${compositionCode}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName3}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}

    ${resp}=    Get Item Composition Count Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        2