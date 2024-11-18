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

JD-TC-UpdateLeadStageStatus-1

    [Documentation]  Update Lead Stage Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

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

    ${Sname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[0]}

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[1]}


JD-TC-UpdateLeadStageStatus-2

    [Documentation]  Update Lead Stage Status - change disable to enable status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200


JD-TC-UpdateLeadStageStatus-UH1

    [Documentation]  Update Lead Stage Status - change status to enable which is already enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREADY_UPDATED}


JD-TC-UpdateLeadStageStatus-UH2

    [Documentation]  Update Lead Stage Status - change status to disable which is already disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREADY_UPDATED}


JD-TC-UpdateLeadStageStatus-UH3

    [Documentation]  Update Lead Stage Status - using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

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

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   stage

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}



JD-TC-UpdateLeadStageStatus-UH4

    [Documentation]  Update Lead Stage Status - without login

    ${resp}=    Update Los Lead Stage Status  ${stageuid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}