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

JD-TC-Get_Lead_Consumer_Count_By_Filter-1

    [Documentation]   Get Lead Consumer Count By Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
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

    ${firstName1}=   generate_firstname
    ${lastName1}=    FakerLibrary.lastName

    Set Suite Variable      ${firstName1}
    Set Suite variable      ${lastName1} 

    ${resp}=    Create Lead Consumer  ${firstName1}  ${lastName1}  phone=${CUSERNAME5}  countryCode=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite variable   ${con_id1}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}

    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.lastName
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${gender}=  Random Element    ${Genderlist}
    ${Address}=   FakerLibrary.address 
    ${email}=    FakerLibrary.Email
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}
    Set Suite Variable      ${dob}
    Set Suite Variable      ${gender}
    Set Suite Variable      ${Address}
    Set Suite Variable      ${email}
    Set Suite Variable      ${pin}
    Set Suite Variable      ${city}
    Set Suite Variable      ${district}
    Set Suite Variable      ${state}


    ${resp}=    Create Lead Consumer  ${firstName}  ${lastName}  dob=${dob}  gender=${gender}  countryCode=${countryCodes[0]}  phone=${consumerPhone}  address=${Address}  email=${email}  city=${city}  state=${state}  country=${country}  pin=${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite variable   ${con_id2}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200

    ${resp}=    Get Lead Consumer By Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                200
    ${length}=  Get Length  ${resp.json()}

    ${resp}=    Get Lead Consumer Count By Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          ${length}

JD-TC-Get_Lead_Consumer_Count_By_Filter-2

    [Documentation]   Get Lead Consumer Count By Filter - uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  uid-eq=${con_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-3

    [Documentation]   Get Lead Consumer Count By Filter - firstName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter   firstName-eq=${firstName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-4

    [Documentation]   Get Lead Consumer Count By Filter - lastName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  lastName-eq=${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-5

    [Documentation]   Get Lead Consumer Count By Filter - uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  crmStatus-eq=${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          2

JD-TC-Get_Lead_Consumer_Count_By_Filter-6

    [Documentation]   Get Lead Consumer Count By Filter - dob

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  dob-eq=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-7

    [Documentation]   Get Lead Consumer Count By Filter - gender

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  gender-eq=${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-8

    [Documentation]   Get Lead Consumer Count By Filter - countryCode

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  countryCode-eq=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          2

JD-TC-Get_Lead_Consumer_Count_By_Filter-9

    [Documentation]   Get Lead Consumer Count By Filter - phone

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  phone-eq=${consumerPhone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1


JD-TC-Get_Lead_Consumer_Count_By_Filter-10

    [Documentation]   Get Lead Consumer Count By Filter - email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  email-eq=${email}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-11

    [Documentation]   Get Lead Consumer Count By Filter - state

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  state-eq=${state}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-12

    [Documentation]   Get Lead Consumer Count By Filter - city

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  city-eq=${city}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-13

    [Documentation]   Get Lead Consumer Count By Filter - country

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  country-eq=${country}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-14

    [Documentation]   Get Lead Consumer Count By Filter - pin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  pin-eq=${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-15

    [Documentation]   Get Lead Consumer Count By Filter - firstName1

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  firstName-eq=${firstName1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-16

    [Documentation]   Get Lead Consumer Count By Filter - lastName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Consumer Count By Filter  lastName-eq=${lastName1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()}          1

JD-TC-Get_Lead_Consumer_Count_By_Filter-UH1

    [Documentation]   Get Lead Consumer Count By Filter - without login

    ${resp}=    Get Lead Consumer Count By Filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-Get_Lead_Consumer_Count_By_Filter-UH2

    [Documentation]   Get Lead Consumer Count By Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
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

    ${resp}=    Get Lead Consumer Count By Filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings    ${resp.json()}        0

JD-TC-Get_Lead_Consumer_Count_By_Filter-UH3

    [Documentation]   Get Lead Consumer Count By Filter - where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
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

    ${resp}=    Get Lead Consumer Count By Filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}      422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}