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

JD-TC-UpdateItemCompositionSA-1

    [Documentation]  SA Update Item Composition - name updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME221}  ${PASSWORD}
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

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${comp_id}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}  

    ${compositionName2}=        FakerLibrary.name  

    ${resp}=    Update Item Composition SA  ${account_id}  ${compositionName2}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${comp_id}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName2}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}  


JD-TC-UpdateItemCompositionSA-2

    [Documentation]  SA Update Item Composition -  name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Composition SA  ${account_id}  ${empty}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${comp_id}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${empty}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}  

JD-TC-UpdateItemCompositionSA-UH1

    [Documentation]  SA Update Item Composition - composition code is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Composition code

    ${resp}=    Update Item Composition SA  ${account_id}  ${compositionName}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemCompositionSA-UH2

    [Documentation]  SA Update Item Composition - composition code is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Composition code

    ${inv}=     Random Int  min=0  max=10000

    ${resp}=    Update Item Composition SA  ${account_id}  ${compositionName}  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemCompositionSA-UH3

    [Documentation]  SA Update Item Composition - without login

    ${resp}=    Update Item Composition SA  ${account_id}  ${compositionName}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 