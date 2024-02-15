*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${PASSWORD2}          Netvarth56
${invalid_provider}   abd@in.in
@{emptylist}
${PASSWORD}               Netvarth12


*** Keywords ***

InvalidLoginAttempt
    [Arguments]    ${usname}  ${passwrd}    ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any
    RETURN  ${resp}

*** Test Cases ***

JD-TC-InvalidLoginAttempt-1
    [Documentation]    Login using valid userid and invalid password 3 times then verify error message , after 1 Minutes relogin.
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

    change_system_time  0  1

    ${resp}=  InvalidLoginAttempt  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200