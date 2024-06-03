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
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/hl_providers.py

*** Variables ***



*** Test Cases ***

JD-TC-GetLeadStatusByID-1

    [Documentation]             Get Lead Status By Id 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id1}       ${resp.json()['id']}

    ${name}=    FakerLibrary.name

    ${resp}=    Create Lead Status LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${status_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Status by id LOS  ${status_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}


JD-TC-GetLeadStatusByID-UH1

    [Documentation]             Get lead Status  by id without login

    ${resp}=    Get Lead Status by id LOS   ${Status_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetLeadStatusByID-UH2

    [Documentation]             Get lead Status by id where Status is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999

    ${resp}=    Get Lead Status by id LOS   ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetLeadStatusByID-UH3

    [Documentation]             Get lead Status by id with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Status by id LOS   ${status_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200