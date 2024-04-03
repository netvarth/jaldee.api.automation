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

JD-TC-UpdateItemComposition-1

    [Documentation]  Update Item Composition - updated name

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME38}  ${PASSWORD}
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

    ${compositionName3}=     FakerLibrary.name

    ${resp}=    Update Item Composition     ${compositionName3}  ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Composition by id   ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${compositionCode}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName3}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}





JD-TC-UpdateItemComposition-UH1

    [Documentation]  Update Item Composition - where composition name is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME38}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Composition     ${empty}  ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemComposition-UH2

    [Documentation]  Update Item Composition - where compositionCode is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME38}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Composition code

    ${resp}=    Update Item Composition     ${compositionName}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FIELD}

JD-TC-UpdateItemComposition-UH3

    [Documentation]  Update Item Composition - where compositionCode is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME38}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Composition code

    ${resp}=    Update Item Composition     ${compositionName}  ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FIELD}

JD-TC-UpdateItemComposition-UH4

    [Documentation]  Update Item Composition - without Login

    ${resp}=    Update Item Composition     ${compositionName}  ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-UpdateItemComposition-UH5

    [Documentation]  Update Item Composition - where another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Composition code

    ${resp}=    Update Item Composition     ${compositionName}  ${compositionCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FIELD}