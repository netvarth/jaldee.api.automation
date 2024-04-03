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

JD-TC-CreateItemUnit-1

    [Documentation]  Create Item Unit

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${unitName}=          FakerLibrary.name
    ${convertionQty}=     Random Int  min=0  max=200
    Set Suite Variable      ${unitName}
    Set Suite Variable      ${convertionQty}

    ${resp}=    Create Item Unit  ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${iu_id}  ${resp.json()}

    ${resp}=    Get Item Unit by id  ${iu_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}


JD-TC-CreateItemUnit-UH1

    [Documentation]  Create Item Unit - unit name is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Unit  ${empty}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemUnit-UH2

    [Documentation]  Create Item Unit - convertion Qty is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${unitName2}=          FakerLibrary.name

    ${resp}=    Create Item Unit  ${unitName2}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${CONVERSION_QTY_INVALID}

JD-TC-CreateItemUnit-UH3

    [Documentation]  Create Item Unit - convertion Qty is above 1000
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qty}=     Random Int  min=999  max=9999
    ${unitName3}=          FakerLibrary.name

    ${resp}=    Create Item Unit  ${unitName3}  ${qty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemUnit-UH4

    [Documentation]  Create Item Unit - without login

    ${resp}=    Create Item Unit  ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-CreateItemUnit-UH5

    [Documentation]  Create Item Unit - where same unit name is already used

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Unit  ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${CUSTOM_VIEW_NAME_EXIT}