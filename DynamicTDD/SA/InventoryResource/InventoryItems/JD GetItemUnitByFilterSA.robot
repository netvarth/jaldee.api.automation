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

JD-TC-GetItemUnitByFilterSA-1

    [Documentation]  SA Get Item Unit By Filter

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

    ${resp}=    Get Item Unit By Filter SA  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}



JD-TC-GetItemUnitByFilterSA-2

    [Documentation]  SA Get Item Unit By Filter - status

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit By Filter SA  ${account_id}  status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetItemUnitByFilterSA-3

    [Documentation]  SA Get Item Unit By Filter SA - category code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit By Filter SA   ${account_id}  unitCode-eq=${unit_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

JD-TC-GetItemUnitByFilterSA-4

    [Documentation]  SA Get Item Unit By Filter - categoryName

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Unit By Filter SA  ${account_id}  unitName-eq=${unitName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

JD-TC-GetItemUnitByFilterSA-5

    [Documentation]  SA Get Item Unit By Filter SA - without login

    ${resp}=    Get Item Unit By Filter SA   ${account_id} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422