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

JD-TC-CreateLeadSourcingChannel-1

    [Documentation]  Create Lead Sourcing Channel

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    ${SCname}=    FakerLibrary.name
    Set Suite Variable  ${SCname}

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200


JD-TC-CreateLeadSourcingChannel-2

    [Documentation]  Create Lead Sourcing Channel - where channel name as  number

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=8

    ${resp}=    Create Los Lead Sourcing Channel  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadSourcingChannel-UH1

    [Documentation]  Create Lead Sourcing Channel - where channel name is 1 digit

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=1

    ${resp}=    Create Los Lead Sourcing Channel  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_SUBCEED}


JD-TC-CreateLeadSourcingChannel-UH2

    [Documentation]  Create Lead Sourcing Channel - where channel name is above 250 digit

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=251

    ${resp}=    Create Los Lead Sourcing Channel  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}

JD-TC-CreateLeadSourcingChannel-UH3

    [Documentation]  Create Lead Sourcing Channel - with existing channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}


JD-TC-CreateLeadSourcingChannel-UH4

    [Documentation]  Create Lead Sourcing Channel - where channel name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Sourcing Channel  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-CreateLeadSourcingChannel-UH5

    [Documentation]  Create Lead Sourcing Channel - without login

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}