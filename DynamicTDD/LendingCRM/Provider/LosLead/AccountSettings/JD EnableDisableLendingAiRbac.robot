*** Settings ***

Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         LOS Lead
Library            Collections
Library            String
Library            json
Library            FakerLibrary
Library            /ebs/TDD/db.py
Library            /ebs/TDD/excelfuncs.py
Resource           /ebs/TDD/ProviderKeywords.robot
Resource           /ebs/TDD/ConsumerKeywords.robot
Resource           /ebs/TDD/ProviderConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-EnableDisableLendingAIRBAC-1

    [Documentation]  Enable Disable Lending AI RBAC

    ${resp}=   Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeLendingRbac']}         ${bool[0]}

    ${resp}=    Enable Disable Main RBAC  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Lending AI RBAC   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-EnableDisableLendingAIRBAC-UH1

    [Documentation]  Enable Disable Lending AI RBAC - which is already enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ALREDY_ENABLED}=  format String   ${ALREDY_ENABLED}   Jaldee LOS RBAC

    ${resp}=    Enable Disable Lending AI RBAC  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREDY_ENABLED}

JD-TC-EnableDisableLendingAIRBAC-2

    [Documentation]  Enable Disable Lending AI RBAC - disabled which is enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Lending AI RBAC  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-EnableDisableLendingAIRBAC-UH2

    [Documentation]  Enable Disable Lending AI RBAC - disable already disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ALREDY_DISABLED}=  format String   ${ALREDY_DISABLED}   Jaldee LOS RBAC

    ${resp}=    Enable Disable Lending AI RBAC  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREDY_DISABLED}


JD-TC-EnableDisableLendingLead-UH3

    [Documentation]  Enable Disable Lending AI RBAC - ebanle where Main RBAC is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Main RBAC  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ENABLE_RBAC_TO_UPDATE}=  format String   ${ENABLE_RBAC_TO_UPDATE}   Jaldee LOS

    ${resp}=    Enable Disable Lending AI RBAC  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ENABLE_RBAC_TO_UPDATE}

JD-TC-EnableDisableLendingAIRBAC-UH4

    [Documentation]  Enable Disable Lending AI RBAC - without Login

    ${resp}=    Enable Disable Lending AI RBAC  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}