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

JD-TC-UpdateLeadProduct-1

    [Documentation]  Update Lead Product - updating scouce channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}

    ${Pname}=    FakerLibrary.name
    Set Suite Variable      ${Pname}

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid}     ${resp.json()['uid']}

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${Pname}

    ${Pname2}=    FakerLibrary.name
    Set Suite Variable      ${Pname2}

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid}  ${Pname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['name']}     ${Pname2}


JD-TC-UpdateLeadProduct-2

    [Documentation]  Update Lead Product - update with already updated chanel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid}  ${Pname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200


JD-TC-UpdateLeadProduct-3

    [Documentation]  Update Lead Product - update los product enum

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product  ${losProduct[1]}  ${productuid}  ${Pname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['uid']}         ${productuid}
    Should Be Equal As Strings    ${resp.json()['account']}     ${account_id}
    Should Be Equal As Strings    ${resp.json()['name']}        ${Pname2}
    Should Be Equal As Strings    ${resp.json()['losProduct']}  ${losProduct[1]}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

JD-TC-UpdateLeadProduct-UH1

    [Documentation]  Update Lead Product - where uid is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_productuid}=     Random Int  min=9999  max=99999

    ${INVALID_X_ID}=    Replace String  ${INVALID_X_ID}  {}   Product

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${inv_productuid}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}


JD-TC-UpdateLeadProduct-UH2

    [Documentation]  Update Lead Product - where channel name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${productuid}=     Random Int  min=9999  max=99999

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NAME_REQUIRED}


JD-TC-UpdateLeadProduct-UH3

    [Documentation]  Update Lead Product - without login

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-UpdateLeadProduct-UH4

    [Documentation]  Update Lead Product - update using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Pname3}=    FakerLibrary.name

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   product

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid}  ${Pname3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}


JD-TC-UpdateLeadProduct-UH5

    [Documentation]  Update Lead Product - provider create 2 channel and updating the first channel name same as the second channel name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Pname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid_11}     ${resp.json()['uid']}

    ${Pname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid_22}     ${resp.json()['uid']}

    ${resp}=    Update Los Lead Product  ${losProduct[0]}  ${productuid_11}  ${Pname22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${DUPLICATE_NAME_INPUT}
