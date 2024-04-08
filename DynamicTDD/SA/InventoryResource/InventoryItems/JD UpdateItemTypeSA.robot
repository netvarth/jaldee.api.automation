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

JD-TC-UpdateItemType-1

    [Documentation]  SA Update Item Type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME261}  ${PASSWORD}
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

    ${typeName2}=    FakerLibrary.name
    Set Suite Variable  ${typeName2}

    ${resp}=    Update Item Type SA   ${account_id}  ${typeName2}   ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}             200

    ${resp}=    Get Item Type SA  ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}             200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName2}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[0]}

JD-TC-UpdateItemType-UH1

    [Documentation]  SA Update a Item Type - category name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Type name${space}

    ${resp}=    Update Item Type SA   ${account_id}  ${empty}   ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}      ${INVALID_FIELD}

JD-TC-UpdateItemType-UH2

    [Documentation]  SA Update a Item Type - category id is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Type code

    ${resp}=    Update Item Type SA   ${account_id}  ${typeName2}   ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}      ${INVALID_FIELD}

JD-TC-UpdateItemType-UH3

    [Documentation]  SA Update a Item Type - category id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     Random Int  min=999     max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Type code

    ${resp}=    Update Item Type SA   ${account_id}  ${typeName2}   ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}      ${INVALID_FIELD}

JD-TC-UpdateItemType-Uh4

    [Documentation]  SA Update a Item Type - without login

    ${resp}=    Update Item Type SA   ${account_id}  ${typeName2}   ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 

