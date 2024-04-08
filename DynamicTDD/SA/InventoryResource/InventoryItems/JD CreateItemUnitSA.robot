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

JD-TC-CreateItemUnitSA-1

    [Documentation]  SA Create Item Unit

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


JD-TC-CreateItemUnitSA-2

    [Documentation]  SA Create Item Unit - where unit name as empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Item Unit SA  ${account_id}  ${empty}  ${convertionQty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemUnitSA-UH1

    [Documentation]  SA Create Item Unit - where convertion qty is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Item Unit SA  ${account_id}  ${unitName}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     ${ENTER_VALID_CONVERTION_QTY}

# JD-TC-CreateItemUnitSA-UH2

#     [Documentation]  SA Create Item Unit - convertion qty is alphabet

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${qty}=     FakerLibrary.name

#     ${resp}=    Create Item Unit SA  ${account_id}  ${unitName}  ${qty}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemUnitSA-UH3

    [Documentation]  SA Create Item Unit - without login

    ${resp}=    Create Item Unit SA  ${account_id}  ${unitName}  ${convertionQty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateItemUnitSA-3

    [Documentation]  Provider login and get item unit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME269}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit by id  ${unit_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${unit_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}