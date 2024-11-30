*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-Lead_Product_Status_Change-1

    [Documentation]   Lead Product Status Change - active to inactive

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
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
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[1]}

JD-TC-Lead_Product_Status_Change-2

    [Documentation]   Lead Product Status Change - inactive to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

JD-TC-Lead_Product_Status_Change-UH1

    [Documentation]   Lead Product Status Change - inactive to inactive

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[1]}

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${PRODUCT_STATUS_INACTIVE}

JD-TC-Lead_Product_Status_Change-UH2

    [Documentation]   Lead Product Status Change - active to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${PRODUCT_STATUS_ACTIVE}

JD-TC-Lead_Product_Status_Change-UH3

    [Documentation]   Lead Product Status Change - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Lead Product Status Change  ${inv}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${INVALID_PRODUCT_ID}

JD-TC-Lead_Product_Status_Change-UH4

    [Documentation]   Lead Product Status Change - without login

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

    
JD-TC-Lead_Product_Status_Change-UH5

    [Documentation]   Lead Product Status Change - trying to change status by another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD}
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

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}         ${NO_PERMISSION}

JD-TC-Lead_Product_Status_Change-UH6

    [Documentation]   Lead Product Status Change - trying to change status where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
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

    ${resp}=    Lead Product Status Change  ${lpid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}