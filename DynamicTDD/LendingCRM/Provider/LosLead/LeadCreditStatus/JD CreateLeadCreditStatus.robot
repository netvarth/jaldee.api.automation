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


*** Test Cases ***

JD-TC-CreateLeadCreditStatus-1

    [Documentation]             Create lead Credit Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD} 
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
    Set Suite Variable  ${name}

    ${resp}=    Create Lead Credit Status LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${status_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-CreateLeadCreditStatus-2

    [Documentation]             Create lead Credit Status where status name is number

    ${resp}=   Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${name2}=    Random Int  min=300  max=999

    ${resp}=    Create Lead Credit Status LOS  ${name2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${status_id2}      ${resp.json()['id']}

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()[1]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[1]['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()[1]['status']}       ${toggle[0]}

JD-TC-CreateLeadCreditStatus-UH1

    [Documentation]             Create lead Credit Status without status name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Lead Credit Status LOS  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${NAME_LENGTH_EXCEED}


JD-TC-CreateLeadCreditStatus-UH2

    [Documentation]             Create lead Credit Status without login

    ${resp}=    Create Lead Credit Status LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-CreateLeadCreditStatus-UH3

    [Documentation]             Create lead Credit Status - where Lending Lead is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD} 
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

    ${name2}=    Random Int  min=300  max=999

    ${resp}=    Create Lead Credit Status LOS  ${name2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${TASK_DISABLED}


JD-TC-CreateLeadCreditStatus-UH4

    [Documentation]             Create lead Credit Status - where jaldeeLending is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD} 
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

    ${name2}=    Random Int  min=300  max=999

    ${resp}=    Create Lead Credit Status LOS  ${name2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${TASK_DISABLED}