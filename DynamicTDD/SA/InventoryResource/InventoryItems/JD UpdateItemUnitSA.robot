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

JD-TC-UpdateItemUnitSA-1

    [Documentation]  SA Update Item Unit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD}
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

    ${unitName}=        FakerLibrary.name
    ${convertionQty}=   Random Int  min=1  max=1000
    Set Suite Variable  ${unitName}
    Set Suite Variable  ${convertionQty}

    ${resp}=    Create Item Unit SA  ${account_id}  ${unitName}  ${convertionQty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${unit_id}      ${resp.json()}

    ${resp}=    Get Item Unit SA  ${account_id}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

    ${unitName2}=        FakerLibrary.name

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName2}  ${convertionQty}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit SA  ${account_id}  ${unit_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName2}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}


JD-TC-UpdateItemUnitSA-2

    [Documentation]  SA Update Item Unit - unit name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Unit SA  ${account_id}  ${empty}  ${convertionQty}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit SA  ${account_id}  ${unit_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${empty}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

JD-TC-UpdateItemUnitSA-3

    [Documentation]  SA Update Item Unit - convertion quantity is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName}  ${empty}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit SA  ${account_id}  ${unit_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

JD-TC-UpdateItemUnitSA-4

    [Documentation]  SA Update Item Unit - convertion quantity is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     Random Int  min=10  max=10000

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName}  ${inv}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit SA  ${account_id}  ${unit_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

JD-TC-UpdateItemUnitSA-UH1

    [Documentation]  SA Update Item Unit - unit id is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Unit code

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName}  ${convertionQty}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemUnitSA-UH2

    [Documentation]  SA Update Item Unit - unit id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Unit code

    ${inv}=     Random Int  min=10  max=10000

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName}  ${convertionQty}  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemUnitSA-UH3

    [Documentation]  SA Update Item Unit - without login

    ${resp}=    Update Item Unit SA  ${account_id}  ${unitName}  ${convertionQty}  ${unit_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 