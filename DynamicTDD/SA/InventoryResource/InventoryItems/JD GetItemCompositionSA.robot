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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-GetItemCompositionSA-1

    [Documentation]  SA Get Item Composition

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

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['compositionCode']}    ${comp_id}
    Should Be Equal As Strings    ${resp.json()['compositionName']}    ${compositionName}
    Should Be Equal As Strings    ${resp.json()['status']}             ${toggle[0]}    


JD-TC-GetItemCompositionSA-UH1

    [Documentation]  Get Item Composition - where item tax id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=9999  max=99999

    ${resp}=    Get Item Composition SA  ${account_id}  ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Empty  ${resp.content}

JD-TC-GetItemCompositionSA-UH2

    [Documentation]  Get Item Composition - withot login

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 

JD-TC-GetItemCompositionSA-UH3

    [Documentation]  Get Item Composition - with provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Composition SA  ${account_id}  ${comp_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 