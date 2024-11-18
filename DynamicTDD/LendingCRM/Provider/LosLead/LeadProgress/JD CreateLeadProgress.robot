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

JD-TC-CreateLeadProgress-1

    [Documentation]             Create lead Progress

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

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

    ${resp}=    Create Lead Progress LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${progress_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-CreateLeadProgress-2

    [Documentation]             Create lead Pregress where status name is number

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${name2}=    Random Int  min=300  max=999

    ${resp}=    Create Lead Progress LOS  ${name2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${progress_id2}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${progress_id2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()[1]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[1]['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()[1]['status']}       ${toggle[0]}

JD-TC-CreateLeadProgress-UH1

    [Documentation]             Create lead Pregress without status name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Lead Progress LOS  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${NAME_LENGTH_EXCEED}


JD-TC-CreateLeadProgress-UH2

    [Documentation]             Create lead Pregress without login

    ${resp}=    Create Lead Progress LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

