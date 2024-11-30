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

JD-TC-Create_Lead_Consumer-1

    [Documentation]   Create Lead Consumer - only with firstName and lastName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
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

    ${firstName_n}=   generate_firstname
    ${lastName_n}=    FakerLibrary.lastName
    Set Suite Variable      ${firstName_n}
    Set Suite Variable      ${lastName_n}

    ${resp}=    Create Lead Consumer  ${firstName_n}  ${lastName_n}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200
    
JD-TC-Create_Lead_Consumer-2

    [Documentation]   Create Lead Consumer - with dob,gender,cc,phone,address,email,city,state,country,pin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
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
    Set Test variable   ${con_id}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200

JD-TC-Create_Lead_Consumer-UH1

    [Documentation]   Create Lead Consumer - where firstname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${empty}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH2

    [Documentation]   Create Lead Consumer - where lastname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname

    ${resp}=    Create Lead Consumer  ${firstName}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH3

    [Documentation]   Create Lead Consumer - where firstname is alpha numeric

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   Generate Random String    10    [NUMBERS] [LETTERS]
    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH4

    [Documentation]   Create Lead Consumer - where firstname is less than 2 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   Generate Random String  2  [LETTERS]
    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH5

    [Documentation]   Create Lead Consumer - where firstname is grater than 100 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   Generate Random String  101  [LETTERS]
    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH6

    [Documentation]   Create Lead Consumer - where last name is alpha numeric

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname
    ${lastName}=    Generate Random String    10    [NUMBERS] [LETTERS]

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH7

    [Documentation]   Create Lead Consumer - where last name is less than 2 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname
    ${lastName}=    Generate Random String  2  [LETTERS]

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH8

    [Documentation]   Create Lead Consumer - where lastname is grater than 100 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname
    ${lastName}=    Generate Random String  101  [LETTERS]

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

JD-TC-Create_Lead_Consumer-UH9

    [Documentation]   Create Lead Consumer - without login

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-Create_Lead_Consumer-UH10

    [Documentation]   Create Lead Consumer - with existing firstname and lastname 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstNam_n}=   generate_firstname
    ${lastName_n}=    FakerLibrary.lastName

    ${resp}=    Create Lead Consumer  ${firstName_n}  ${lastName_n}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create_Lead_Consumer-UH11

    [Documentation]   Create Lead Consumer - where phone number is bellow 10 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName

    ${phone}=   Random Int  min=111  max=999

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  phone=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${MOBILE_NO_REQUIRED_LENGTH}

JD-TC-Create_Lead_Consumer-UH12

    [Documentation]   Create Lead Consumer - where phone number is above 15 digit

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName

    ${phone}=   Generate Random String    16    [NUMBERS]

    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  phone=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}        ${MOBILE_NO_REQUIRED_LENGTH}