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

*** Variables ***

${country}        INDIA

*** Test Cases ***

JD-TC-Get_Lead_Consumer-1

    [Documentation]   Get Lead Consumer - consumer created only with firstname and lastname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
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

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  phone=${CUSERNAME3}  countryCode=${countryCodes[0]}
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

JD-TC-Get_Lead_Consumer-2

    [Documentation]   Get Lead Consumer - consumer created with all details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone}  555${PH_Number}

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${gender}=  Random Element    ${Genderlist}
    ${Address}=   FakerLibrary.address 
    ${email}=    FakerLibrary.Email
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  dob=${dob}  gender=${gender}  countryCode=${countryCodes[0]}  phone=${consumerPhone}  address=${Address}  email=${email}  city=${city}  state=${state}  country=${country}  pin=${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id2}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${con_id2}
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstName}
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastName}
    Should Be Equal As Strings  ${resp.json()['crmStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['dob']}           ${dob}
    Should Be Equal As Strings  ${resp.json()['gender']}        ${gender}
    Should Be Equal As Strings  ${resp.json()['countryCode']}   ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['phone']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['address']}       ${Address}
    Should Be Equal As Strings  ${resp.json()['email']}         ${email}
    Should Be Equal As Strings  ${resp.json()['state']}         ${state}
    Should Be Equal As Strings  ${resp.json()['city']}          ${city}
    Should Be Equal As Strings  ${resp.json()['country']}       ${country}
    Should Be Equal As Strings  ${resp.json()['pin']}           ${pin}

JD-TC-Get_Lead_Consumer-UH1

    [Documentation]   Get Lead Consumer - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Get Lead Consumer  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_CONSUMER_ID}

JD-TC-Get_Lead_Consumer-UH2

    [Documentation]   Get Lead Consumer - without login

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}        419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Get_Lead_Consumer-UH3

    [Documentation]   Get Lead Consumer - where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[1]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${CRM_LEAD_DISABLED}

JD-TC-Get_Lead_Consumer-UH4

    [Documentation]   Get Lead Consumer - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
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

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION}