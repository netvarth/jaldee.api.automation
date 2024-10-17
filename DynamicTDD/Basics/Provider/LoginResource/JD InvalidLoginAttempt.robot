*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${PASSWORD2}          Netvarth56
${invalid_provider}   abd@in.in
@{emptylist}
&{headers}                Content-Type=application/json
&{headers1}		          Content-Type=multipart/form-data
${SUSERNAME}              admin.support@jaldee.com
${SPASSWORD}              Netvarth1

*** Keywords ***
# Login
#     [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
#     ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
#     ${log}=    json.dumps    ${login}
#     Check And Create YNW Session    
#     # ${BASE_URL}  headers=${headers}
#     RETURN  ${log}

InvalidLoginAttempt
    [Arguments]    ${usname}  ${passwrd}    ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any
    RETURN  ${resp}

*** Test Cases ***
JD-TC-InvalidLoginAttempt-1
    [Documentation]    Login using valid userid and invalid password 2 times(multiFactorAuthenticationRequired is false)
    Check And Create YNW Session

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${MULTIPLE_LOGIN_ATTEMPTS}

# JD-TC-InvalidLoginAttempt-2
#     [Documentation]    Login using valid userid and invalid password 2 times(multiFactorAuthenticationRequired is true)
#     Check And Create YNW Session
    
#     ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   401
#     Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

#     ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   401
#     Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

#     ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   401
#     Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

#     ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   401
#     Should Be Equal As Strings    ${resp.json()}     ${MULTIPLE_LOGIN_ATTEMPTS}

JD-TC-InvalidLoginAttempt-3
    [Documentation]    Provider Login and  invalid password 3 times.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME73}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME73}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME73}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME73}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${MULTIPLE_LOGIN_ATTEMPTS}
*** Comments ***
JD-TC-InvalidLoginAttempt-4
    [Documentation]    Login using valid userid and invalid password 3 times then verify error message , after 1 Minutes relogin.


    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${MULTIPLE_LOGIN_ATTEMPTS}