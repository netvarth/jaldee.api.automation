*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot



*** Test Cases ***

JD-TC-Consumer_Lead_Status_Change-1

    [Documentation]   Consumer Lead Status Change - Active to inactive

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

    ${firstName}=   FakerLibrary.firstName
    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite variable   ${con_id}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['crmStatus']}     ${status[0]}

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['crmStatus']}     ${status[1]}


JD-TC-Consumer_Lead_Status_Change-2

    [Documentation]   Consumer Lead Status Change - inactive to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

JD-TC-Consumer_Lead_Status_Change-UH1

    [Documentation]   Consumer Lead Status Change - inactive to inactive

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[1]}

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CONSUMER_STATUS_INACTIVE}

JD-TC-Consumer_Lead_Status_Change-UH2

    [Documentation]   Consumer Lead Status Change - active to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CONSUMER_STATUS_ACTIVE}

JD-TC-Consumer_Lead_Status_Change-UH3

    [Documentation]   Consumer Lead Status Change - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Consumer Lead Status Change  ${inv}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${INVALID_CONSUMER_ID}

JD-TC-Consumer_Lead_Status_Change-UH4

    [Documentation]   Consumer Lead Status Change - without login

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

    
JD-TC-Consumer_Lead_Status_Change-UH5

    [Documentation]   Consumer Lead Status Change - trying to change status by another provider

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

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}         ${NO_PERMISSION}

JD-TC-Consumer_Lead_Status_Change-UH6

    [Documentation]   Consumer Lead Status Change - trying to change status where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
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

    ${resp}=    Consumer Lead Status Change  ${con_id}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}