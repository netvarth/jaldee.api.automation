*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py



*** Test Cases ***

JD-TC-Update_Lead_Consumer-1

    [Documentation]   Update Lead Consumer - updating lastname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  phone=${CUSERNAME6}  countryCode=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite variable   ${con_id}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${con_id}
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstName}
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastName}
    Should Be Equal As Strings  ${resp.json()['crmStatus']}     ${status[0]}

    ${lastName2}=    FakerLibrary.lastName
    Set Suite Variable       ${lastName2}

    ${resp}=    Update Lead Consumer  ${con_id}  lastName=${lastName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastName2}

JD-TC-Update_Lead_Consumer-2

    [Documentation]   Update Lead Consumer - updating firstname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstName}

    ${firstName2}=    FakerLibrary.lastName
    Set Suite Variable      ${firstName2}

    ${resp}=    Update Lead Consumer  ${con_id}  firstName=${firstName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstName2}


JD-TC-Update_Lead_Consumer-3

    [Documentation]   Update Lead Consumer - updating firstname as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstName2}

    ${resp}=    Update Lead Consumer  ${con_id}  firstName=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${empty}


JD-TC-Update_Lead_Consumer-4

    [Documentation]   Update Lead Consumer - updating lastname as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastName2}

    ${resp}=    Update Lead Consumer  ${con_id}  lastName=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${empty}

JD-TC-Update_Lead_Consumer-5

    [Documentation]   Update Lead Consumer - updating phone

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone}=   Generate Random String    10    [NUMBERS]

    ${resp}=    Update Lead Consumer  ${con_id}  phone=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_Lead_Consumer-UH1

    [Documentation]   Update Lead Consumer - updating invalid phone phone bellow 10 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone}=   Random Int  min=111  max=999

    ${resp}=    Update Lead Consumer  ${con_id}  phone=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${MOBILE_NO_REQUIRED_LENGTH}


JD-TC-Update_Lead_Consumer-UH2

    [Documentation]   Update Lead Consumer - updating invalid phone phone above 15 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone}=   Generate Random String    16    [NUMBERS]

    ${resp}=    Update Lead Consumer  ${con_id}  phone=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${MOBILE_NO_REQUIRED_LENGTH}

JD-TC-Update_Lead_Consumer-UH3

    [Documentation]   Update Lead Consumer - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${resp}=    Update Lead Consumer  ${inv}  lastName=${lastName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_CONSUMER_ID}

JD-TC-Update_Lead_Consumer-UH4

    [Documentation]   Update Lead Consumer - without login

    ${resp}=    Update Lead Consumer  ${con_id}  lastName=${lastName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}     ${SESSION_EXPIRED}

JD-TC-Update_Lead_Consumer-UH5

    [Documentation]   Update Lead Consumer - another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${Name}=   generate_firstname

    ${resp}=    Update Lead Consumer  ${con_id}  firstName=${Name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}