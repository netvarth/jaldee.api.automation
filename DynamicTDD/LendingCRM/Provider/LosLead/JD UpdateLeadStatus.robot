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
Variables          /ebs/TDD/varfiles/musers.py
Variables          /ebs/TDD/varfiles/hl_musers.py

*** Variables ***



*** Test Cases ***

JD-TC-UpdateLeadStatusByID-1

    [Documentation]             Update Lead Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD} 
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

    ${name2}=    FakerLibrary.name
    Set Suite Variable      ${name2}

    ${resp}=    Update Lead Status LOS   ${status_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Status by id LOS  ${status_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()['name']}         ${name2}
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}


JD-TC-UpdateLeadStatusByID-2

    [Documentation]             Update lead Status where status is Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Status LOS    ${status_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-UpdateLeadStatusByID-UH1

    [Documentation]             Update lead Status where Status id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999
    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   Lead Status

    ${resp}=    Update Lead Status LOS    ${fake}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLeadStatusByID-UH2

    [Documentation]             Update lead Status where name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Status LOS    ${status_id}   ${empty}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-UpdateLeadStatusByID-UH3

    [Documentation]             Update lead Status witout login

    ${resp}=    Update Lead Status LOS    ${status_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-UpdateLeadStatusByID-UH4

    [Documentation]             Update lead Status with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   lead

    ${resp}=    Update Lead Status LOS    ${status_id}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}