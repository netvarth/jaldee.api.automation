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

JD-TC-UpdateLeadProductStatus-1

    [Documentation]  Update Lead Product Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    ${Pname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid}     ${resp.json()['uid']}

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[0]}

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[1]}


JD-TC-UpdateLeadProductStatus-2

    [Documentation]  Update Lead Product Status - change disable to enable status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200


JD-TC-UpdateLeadProductStatus-UH1

    [Documentation]  Update Lead Product Status - change status to enable which is already enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREADY_UPDATED}


JD-TC-UpdateLeadProductStatus-UH2

    [Documentation]  Update Lead Product Status - change status to disable which is already disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREADY_UPDATED}


JD-TC-UpdateLeadProductStatus-UH3

    [Documentation]  Update Lead Product Status - using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   product

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}



JD-TC-UpdateLeadProductStatus-UH4

    [Documentation]  Update Lead Product Status - without login

    ${resp}=    Update Los Lead Product Status  ${productuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}