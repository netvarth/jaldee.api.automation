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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{emptylist}


*** Test Cases ***

JD-TC-GetSPToken-1

    [Documentation]  Get SP Token for a service provider after enabling the api gateway.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp}=   Enable Disable API gateway   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[1]}

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}

JD-TC-GetSPToken-2

    [Documentation]  Get SP Token for a branch(account level) after enabling the api gateway.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp}=   Enable Disable API gateway   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[1]}

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}

JD-TC-GetSPToken-UH1

    [Documentation]  Get SP Token for a service provider after disabling the api gateway.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[1]}
        ${resp}=   Enable Disable API gateway   ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[0]}

    # ${resp}=  Enable Disable API gateway   ${toggle[1]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}     "${API_GATEWAY_NOT_ENABLED}"


JD-TC-GetSPToken-UH2

    [Documentation]   Get SP Token by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetSPToken-UH3

    [Documentation]   Get SP Token without login.

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-GetSPToken-UH4

    [Documentation]  Get SP Token for a branch(account level) after disabling the api gateway.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[1]}
        ${resp}=   Enable Disable API gateway   ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[0]}

    # ${resp}=  Enable Disable API gateway   ${toggle[1]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}     "${API_GATEWAY_NOT_ENABLED}"