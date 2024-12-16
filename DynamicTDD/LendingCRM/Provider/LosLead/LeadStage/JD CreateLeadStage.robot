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

*** Variables ***

@{sort_order}                   1  2  3  4  5  6  7  8  9

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
    Set Suite Variable  ${Sname}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname}
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

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid}     ${resp.json()['uid']}

    ${resp}=    Get Lead Stage By UID  ${stageuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

JD-TC-CreateLeadStage-UH

    [Documentation]  Create Lead Stage - where channel name is 1 digit

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${random_number}=    Random Number 	       digits=1

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_SUBCEED}

JD-TC-CreateLeadStage-4

    [Documentation]  Create Lead Stage - where los product is PROPERTYLOAN

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Sname2}=    Random Number 	       digits=5

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${leadstageType[1]}  ${Sname2}
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

    ${Sname2}=    Random Number 	       digits=5

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${leadstageType[2]}  ${Sname2}
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

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${random_number}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}

JD-TC-CreateLeadStage-UH2

    [Documentation]  Create Lead Stage - with existing channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}


JD-TC-CreateLeadStage-UH3

    [Documentation]  Create Lead Stage - where channel name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_LENGTH_EXCEED}


JD-TC-CreateLeadStage-UH4

    [Documentation]  Create Lead Stage - without login

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-CreateLeadStage-6

    [Documentation]  Create Lead Stage - creating 3 stages some of them with sort order, on proceed and on redirect

    ${resp}=   Encrypted Provider Login  ${PUSERNAME75}  ${PASSWORD} 
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

    ${Sname11}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname11}  sortOrder=${sort_order[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid11}     ${resp.json()['uid']}

    ${Sname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname22}  sortOrder=${sort_order[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid22}     ${resp.json()['uid']}

    ${Sname33}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadstageType[1]}  ${Sname33}  sortOrder=${sort_order[2]}  onProceed=${stageuid22}  onRedirect=${stageuid11}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${stageuid33}     ${resp.json()['uid']}