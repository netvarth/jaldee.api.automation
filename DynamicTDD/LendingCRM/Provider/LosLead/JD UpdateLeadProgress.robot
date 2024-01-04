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

JD-TC-UpdateLeadProgress-1

    [Documentation]             Update lead Progress

    ${resp}=   Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD} 
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

    ${resp}=    Create Lead Progress LOS  ${name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${progress_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress by id LOS   ${progress_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()['name']}         ${name}
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}

    ${name2}=    FakerLibrary.name
    Set Suite Variable      ${name2}

    ${resp}=    Update Lead Progress LOS    ${progress_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Progress by id LOS   ${progress_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()['name']}         ${name2}
    Should Be Equal As Strings    ${resp.json()['status']}       ${toggle[0]}


JD-TC-UpdateLeadProgress-2

    [Documentation]             Update lead Progress where status is Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Progress LOS    ${progress_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-UpdateLeadProgress-UH1

    [Documentation]             Update lead Progress where Progress id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999
    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   Lead Progress

    ${resp}=    Update Lead Progress LOS    ${fake}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLeadProgress-UH2

    [Documentation]             Update lead Progress where name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Progress LOS    ${progress_id}   ${empty}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-UpdateLeadProgress-UH3

    [Documentation]             Update lead Progress witout login

    ${resp}=    Update Lead Progress LOS    ${progress_id}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-UpdateLeadProgress-UH4

    [Documentation]             Update lead Progress with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Progress LOS    ${progress_id}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422