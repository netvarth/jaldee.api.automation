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

JD-TC-UpdateLeadSourcingChannel-1

    [Documentation]  Update Lead Sourcing Channel - updating scouce channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}

    ${SCname}=    FakerLibrary.name
    Set Suite Variable      ${SCname}

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${SCname}

    ${SCname2}=    FakerLibrary.name
    Set Suite Variable      ${SCname2}

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid}  ${SCname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${SCname2}


JD-TC-UpdateLeadSourcingChannel-2

    [Documentation]  Update Lead Sourcing Channel - update with already updated chanel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid}  ${SCname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200


JD-TC-UpdateLeadSourcingChannel-UH1

    [Documentation]  Update Lead Sourcing Channel - where uid is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_sourcinguid}=     Random Int  min=9999  max=99999

    ${INVALID_X_ID}=    Replace String  ${INVALID_X_ID}  {}   Channel

    ${resp}=    Update Los Lead Sourcing Channel  ${inv_sourcinguid}  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLeadSourcingChannel-UH2

    [Documentation]  Update Lead Sourcing Channel - where channel name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${sourcinguid}=     Random Int  min=9999  max=99999

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-UpdateLeadSourcingChannel-UH3

    [Documentation]  Update Lead Sourcing Channel - without login

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid}  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-UpdateLeadSourcingChannel-UH4

    [Documentation]  Update Lead Sourcing Channel - update using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${SCname3}=    FakerLibrary.name

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   channel

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid}  ${SCname3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}


JD-TC-UpdateLeadSourcingChannel-UH5

    [Documentation]  Update Lead Sourcing Channel - provider create 2 channel and updating the first channel name same as the second channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${SCname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid_11}     ${resp.json()['uid']}

    ${SCname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid_22}     ${resp.json()['uid']}

    ${resp}=    Update Los Lead Sourcing Channel  ${sourcinguid_11}  ${SCname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}