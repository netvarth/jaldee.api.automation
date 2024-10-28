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

JD-TC-CreateLeadStage-1

    [Documentation]  Create Lead Stage

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    ${Sname}=    FakerLibrary.name
    Set Suite Variable  ${Sname}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-CreateLeadStage-2

    [Documentation]  Create Lead Stage - where channel name as  number

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=8

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadStage-3

    [Documentation]  Create Lead Stage - where channel name is 1 digit

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=1

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadStage-4

    [Documentation]  Create Lead Stage - where los product is PROPERTYLOAN

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname2}=    Random Number 	       digits=1

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${stageType[1]}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadStage-5

    [Documentation]  Create Lead Stage - where stage type is KYC

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname2}=    Random Number 	       digits=1

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${stageType[2]}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadStage-UH1

    [Documentation]  Create Lead Stage - where channel name is above 250 digit

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=251

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}

JD-TC-CreateLeadStage-UH2

    [Documentation]  Create Lead Stage - with existing channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}


JD-TC-CreateLeadStage-UH3

    [Documentation]  Create Lead Stage - where channel name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}


JD-TC-CreateLeadStage-UH4

    [Documentation]  Create Lead Stage - without login

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}