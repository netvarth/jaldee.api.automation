*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-Update_Product-1

    [Documentation]   Update Product - type name updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${typeName}=    FakerLibrary.Name

    ${resp}=    Create Lead Product  ${typeName}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['typeName']}      ${typeName}

    ${typeName2}=    FakerLibrary.Name
    Set Suite Variable      ${typeName2}

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['typeName']}      ${typeName2}

JD-TC-Update_Product-2

    [Documentation]   Update Product - where type name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Product  ${lpid}  ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${PRODUCT_NAME_EMPTY}

JD-TC-Update_Product-3

    [Documentation]   Update Product - update status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}  status=${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

JD-TC-Update_Product-4

    [Documentation]   Update Product - update status as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}  status=${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

JD-TC-Update_Product-5

    [Documentation]   Update Product - update with same type name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

JD-TC-Update_Product-UH1

    [Documentation]   Update Product - uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${typeName0}=    FakerLibrary.Name
    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Update Lead Product  ${inv}  ${typeName0}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${INVALID_PRODUCT_ID}

JD-TC-Update_Product-UH2

    [Documentation]   Update Product - without login

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

JD-TC-Update_Product-UH3

    [Documentation]   Update Product - updating useing another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}            ${NO_PERMISSION}


JD-TC-Update_Product-UH4

    [Documentation]   Update Product - creating two lead and updating second lead with the first lead type name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${typeName3}=    FakerLibrary.Name

    ${resp}=    Create Lead Product  ${typeName3}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid3}     ${resp.json()} 

    ${typeName4}=    FakerLibrary.Name

    ${resp}=    Create Lead Product  ${typeName4}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid4}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid4}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['typeName']}      ${typeName4}

    ${resp}=    Update Lead Product  ${lpid4}  ${typeName3}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${PRODUCT_NAME_CANT_BE_SAME}

JD-TC-Update_Product-UH5

    [Documentation]   Update Product - where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[1]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Update Lead Product  ${lpid}  ${typeName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CRM_LEAD_DISABLED}