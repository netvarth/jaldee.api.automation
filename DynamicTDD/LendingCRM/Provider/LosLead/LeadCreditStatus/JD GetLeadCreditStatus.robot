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
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py

*** Variables ***



*** Test Cases ***

JD-TC-GetLeadCreditStatus-1

    [Documentation]             Get lead Credit Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200
    Should Be Equal As Strings  ${resp2.json()['jaldeeLending']}         ${bool[0]}
    Should Be Equal As Strings  ${resp2.json()['losLead']}               ${bool[0]}

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id1}       ${resp.json()['id']}

    ${name}=    FakerLibrary.name

    ${resp}=    Create Lead Credit Status LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${creditstatus}      ${resp.json()['id']}

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${creditstatus}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-GetLeadCreditStatus-UH1

    [Documentation]             Get lead Credit Status without login

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetLeadCreditStatus-UH2

    [Documentation]             Get lead Credit Status with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200
    Should Be Equal As Strings  ${resp2.json()['jaldeeLending']}         ${bool[0]}
    Should Be Equal As Strings  ${resp2.json()['losLead']}               ${bool[0]}

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-GetLeadCreditStatus-U3

    [Documentation]             Get lead Credit Status - where Lending Lead is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[1]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${TASK_DISABLED}=  format String   ${TASK_DISABLED}   Jaldee Lending AI

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${TASK_DISABLED}


JD-TC-GetLeadCreditStatus-U4

    [Documentation]             Get lead Credit Status - where jaldeeLending is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[1]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${TASK_DISABLED}=  format String   ${TASK_DISABLED}   Lending Lead

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${TASK_DISABLED}