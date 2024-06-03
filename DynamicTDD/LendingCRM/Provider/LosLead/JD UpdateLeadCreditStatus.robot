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

JD-TC-UpdateLeadCreditStatus-1

    [Documentation]             Update lead Credit Status with name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD} 
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

    ${name2}=    FakerLibrary.name
    Set Suite Variable      ${name2}

    ${resp}=    Update Lead Credit Status LOS    ${creditstatus}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${creditstatus}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${name2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

JD-TC-UpdateLeadCreditStatus-2

    [Documentation]             Update lead Credit Status where status is Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Credit Status LOS    ${creditstatus}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-UpdateLeadCreditStatus-UH1

    [Documentation]             Update lead Credit Status where credit status id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999
    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   Credit Status

    ${resp}=    Update Lead Credit Status LOS    ${fake}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLeadCreditStatus-UH2

    [Documentation]             Update lead Credit Status where name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Lead Credit Status LOS    ${creditstatus}   ${empty}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-UpdateLeadCreditStatus-UH3

    [Documentation]             Update lead Credit Status witout login

    ${resp}=    Update Lead Credit Status LOS    ${creditstatus}   ${name2}   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-UpdateLeadCreditStatus-UH4

    [Documentation]             Update lead Credit Status with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME65}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   credit status

    ${resp}=    Update Lead Credit Status LOS    ${creditstatus}   ${name2}   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}