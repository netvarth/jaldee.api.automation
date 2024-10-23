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

JD-TC-GetLeadSourcingChannelCount-1

    [Documentation]  Get Lead Sourcing Channel Count

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

    ${resp}=    Get Los Sourcing Channel
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[0]}

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Sourcing Channel Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}