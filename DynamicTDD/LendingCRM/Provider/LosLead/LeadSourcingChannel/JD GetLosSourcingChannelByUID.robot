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

JD-TC-GetLeadSourcingChannelByUid-1

    [Documentation]  Get Lead Sourcing Channel By Uid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}

    ${SCname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[0]}

JD-TC-GetLeadSourcingChannelByUid-UH1

    [Documentation]  Get Lead Sourcing Channel By Uid - with invalid uid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_uid}=     Random Int  min=9999  max=99999

    ${resp}=    Get Los Sourcing Channel By UID  ${inv_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.content}    ${empty}


JD-TC-GetLeadSourcingChannelByUid-UH2

    [Documentation]  Get Lead Sourcing Channel By Uid - without login

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-GetLeadSourcingChannelByUid-UH3

    [Documentation]  Get Lead Sourcing Channel By Uid - with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   channel

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}