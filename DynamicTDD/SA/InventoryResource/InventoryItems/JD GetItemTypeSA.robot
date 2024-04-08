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

JD-TC-GetItemType-1

    [Documentation]  SA Get Item Type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
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

    ${typeName}=    FakerLibrary.name
    Set Suite Variable  ${typeName}

    ${resp}=  Create Item Type SA   ${account_id}  ${typeName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${type_Id}   ${resp.json()}

    ${resp}=    Get Item Type SA  ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}             200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[0]}


JD-TC-GetItemType-UH1

    [Documentation]  SA Get Item Type. - type id is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Type SA    ${account_id}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetItemType-UH2

    [Documentation]  SA Get Item Type. - type id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=999  max=9999

    ${resp}=    Get Item Type SA    ${account_id}  ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Empty   ${resp.content}

JD-TC-GetItemType-UH3

    [Documentation]  SA Get Item Type. - without login

    ${resp}=    Get Item Type SA    ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 


JD-TC-GetItemType-uH4

    [Documentation]  SA Get Item Type - get from provider side

    ${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Type   ${type_Id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${type_Id}   