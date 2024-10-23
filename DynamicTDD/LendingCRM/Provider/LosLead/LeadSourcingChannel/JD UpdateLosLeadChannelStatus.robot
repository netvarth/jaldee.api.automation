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

JD-TC-UpdateLeadSourcingChannelStatus-1

    [Documentation]  Update Lead Sourcing Channel Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    ${SCname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[0]}

    ${resp}=    Update Los Lead Channel Status  ${sourcinguid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[1]}