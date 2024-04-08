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

JD-TC-UpdateItemTypeStatus-1

    [Documentation]  SA Update Item Type Status

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

    ${resp}=    Update Item Type Status SA   ${account_id}  ${type_Id}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}             200

    ${resp}=    Get Item Type SA  ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}             200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[1]}


JD-TC-UpdateItemTypeStatus-UH1

    [Documentation]  SA JD Update Item Type Status - disable to disable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Type SA    ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[1]}

    ${resp}=    Update Item Type Status SA   ${account_id}  ${type_Id}   ${Toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemTypeStatus-UH2

    [Documentation]  SA JD Update Item Type Status - disable to enable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Type SA    ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[1]}

    ${resp}=    Update Item Type Status SA   ${account_id}  ${type_Id}   ${Toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Type SA    ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[0]}

JD-TC-UpdateItemTypeStatus-UH3

    [Documentation]  SA JD Update Item Type Status - enable to enable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Type SA    ${account_id}  ${type_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}      ${type_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}      ${typeName}
    Should Be Equal As Strings    ${resp.json()['status']}        ${toggle[0]}

    ${resp}=    Update Item Type Status SA   ${account_id}  ${type_Id}   ${Toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemTypeStatus-UH4

    [Documentation]  SA JD Update Item Type Status - without login

    ${resp}=    Update Item Type Status SA   ${account_id}  ${type_Id}   ${Toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 
