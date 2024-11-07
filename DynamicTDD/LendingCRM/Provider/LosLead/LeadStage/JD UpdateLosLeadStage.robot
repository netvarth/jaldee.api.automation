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

JD-TC-UpdateLosLeadStage -1

    [Documentation]  Update Lead Stage - updating Stage name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}

    ${Sname}=    FakerLibrary.name
    Set Suite Variable      ${Sname}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${Sname}

    ${Sname2}=    FakerLibrary.name
    Set Suite Variable      ${Sname2}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${Sname2}


JD-TC-UpdateLosLeadStage -2

    [Documentation]  Update Lead Stage - update with already updated stage name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-UpdateLosLeadStage -3

    [Documentation]  Update Lead Stage - update stage type as KYCVERIFICATION (not possible)

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[2]}  ${stageuid}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['stageType']}     ${stageType[1]}

JD-TC-UpdateLosLeadStage -4

    [Documentation]  Update Lead Stage - update stage with on proceed and on redirect

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[2]}  ${Sname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid22}     ${resp.json()['uid']}

    ${Sname33}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[3]}  ${Sname33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid33}     ${resp.json()['uid']}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[2]}  ${stageuid}  ${Sname2}  onProceed=${stageuid22}  onRedirect=${stageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}           200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid22}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid33}

JD-TC-UpdateLosLeadStage -UH1

    [Documentation]  Update Lead Stage - update los product enum ( we cant change it )

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage  ${losProduct[1]}  ${stageType[1]}  ${stageuid}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['uid']}         ${stageuid}
    Should Be Equal As Strings    ${resp.json()['account']}     ${account_id}
    Should Be Equal As Strings    ${resp.json()['name']}        ${Sname2}
    Should Be Equal As Strings    ${resp.json()['losProduct']}  ${losProduct[0]}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

JD-TC-UpdateLosLeadStage -UH2

    [Documentation]  Update Lead Stage - where uid is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_stageuid}=     Random Int  min=9999  max=99999

    ${INVALID_X_ID}=    Replace String  ${INVALID_X_ID}  {}   Stage

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${inv_stageuid}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLosLeadStage -UH3

    [Documentation]  Update Lead Stage - where stage name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}


JD-TC-UpdateLosLeadStage -UH4

    [Documentation]  Update Lead Stage - without login

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-UpdateLosLeadStage -UH5

    [Documentation]  Update Lead Stage - update using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname3}=    FakerLibrary.name

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   stage

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid}  ${Sname3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}


JD-TC-UpdateLosLeadStage -UH6

    [Documentation]  Update Lead Stage - provider create 2 stage and updating the first stage name same as the second stage name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid_11}     ${resp.json()['uid']}

    ${Sname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid_22}     ${resp.json()['uid']}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid_11}  ${Sname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}
