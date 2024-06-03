*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Api Gateway
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{emptylist}

*** Test Cases ***

JD-TC-CreateUserToken-1

    [Documentation]   Create User Token For a service Provider with his own number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['isApiGateway']}==${bool[0]}   Enable Disable API gateway   ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Suite Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${PUSERNAME3}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateUserToken-UH1

    [Documentation]   Create User Token For a service Provider with another providers number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['isApiGateway']}==${bool[0]}   Enable Disable API gateway   ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}   ${bool[1]} 

    ${resp}=   Create User Token   ${PUSERNAME4}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_SP_TOKEN}"

JD-TC-CreateUserToken-UH2

    [Documentation]   Create User Token For a service Provider with different country code.

    ${resp}=   Create User Token   ${PUSERNAME3}  ${PASSWORD}   ${sp_token}   ${countryCodes[2]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  ${resp.content}   "${NOT_REGISTERED_PROVIDER}"

    
JD-TC-CreateUserToken-UH3

    [Documentation]   Create User Token For a service Provider without sp token.

    ${resp}=   Create User Token   ${PUSERNAME3}  ${PASSWORD}   ${EMPTY}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_SP_TOKEN}"

JD-TC-CreateUserToken-UH4

    [Documentation]   Create User Token For a service Provider with invalid sp token.

    ${invalid_sptoken1}=  FakerLibrary.word
    ${resp}=   Create User Token   ${PUSERNAME3}  ${PASSWORD}   ${invalid_sptoken1}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_SP_TOKEN}"

JD-TC-CreateUserToken-UH5

    [Documentation]   Create User Token For a service Provider with invalid password.

    ${invalid_pswd}=  FakerLibrary.word
    ${resp}=   Create User Token   ${PUSERNAME3}  ${invalid_pswd}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  ${resp.content}   "${LOGIN_INVALID_USERID_PASSWORD}"

JD-TC-CreateUserToken-UH6

    [Documentation]   Create User Token For a service Provider without loginid.

    ${resp}=   Create User Token   ${EMPTY}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}   "${ENTER_PHONE_EMAIL}"

JD-TC-CreateUserToken-UH7

    [Documentation]   Create User Token For a service Provider without password.

    ${resp}=   Create User Token   ${PUSERNAME3}  ${EMPTY}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  ${resp.content}   "${PASSWORD_EMPTY}"
    

JD-TC-CreateUserToken-UH8

    [Documentation]   Create User Token For a service Provider without enable API Gateway.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['isApiGateway']}==${bool[0]}   Enable Disable API gateway   ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}   ${bool[1]} 

    ${resp}=  Enable Disable API gateway   ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}   ${bool[0]} 

    ${resp}=   Create User Token   ${PUSERNAME6}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}   "${API_GATEWAY_NOT_ENABLED}"


