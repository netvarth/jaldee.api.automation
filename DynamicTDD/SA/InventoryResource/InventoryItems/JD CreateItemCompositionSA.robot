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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-CreateItemCompositionSA-1

    [Documentation]  SA Create Item Composition

    ${resp}=  Encrypted Provider Login  ${PUSERNAME269}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${compositionName}=        FakerLibrary.name
    Set Suite Variable          ${compositionName}

    ${resp}=    Create Item Composition SA  ${account_id}  ${compositionName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${comp_id}      ${resp.json()}


JD-TC-CreateItemCompositionSA-2

    [Documentation]  SA Create Item Composition - composition name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Item Composition SA  ${account_id}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemCompositionSA-3

    [Documentation]  SA Create Item Composition - composition name is same

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Item Composition SA  ${account_id}  ${compositionName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${NAME_ALREADY_EXIST}

JD-TC-CreateItemCompositionSA-UH1

    [Documentation]  SA Create Item Composition - without Login

    ${resp}=    Create Item Composition SA  ${account_id}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateItemCompositionSA-4

    [Documentation]  Provider Get Item Composition

    ${resp}=  Encrypted Provider Login  ${PUSERNAME269}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Composition by id   ${comp_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${comp_id}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}