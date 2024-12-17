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

JD-TC-Enable_Disable_CRM_Lead-1

    [Documentation]   Enable Disable CRM Lead

    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
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

JD-TC-Enable_Disable_CRM_Lead-UH1

    [Documentation]   Enable Disable CRM Lead - Enable already enabled crm lead  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ALREDY_ENABLED}=  format String   ${ALREDY_ENABLED}   Lead Manager

    ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${ALREDY_ENABLED}

JD-TC-Enable_Disable_CRM_Lead-UH2

    [Documentation]   Enable Disable CRM Lead - disabled crm lead disable again 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ALREDY_DISABLED}=  format String   ${ALREDY_DISABLED}   Lead Manager

    ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${ALREDY_DISABLED}

JD-TC-Enable_Disable_CRM_Lead-Uh3

    [Documentation]   Enable Disable CRM Lead - without login

    ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}