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
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***
JD-TC-ProviderLogout-1
    [Documentation]    Logout from a valid user session

    ${resp}=   Encrypted Provider Login      ${PUSERNAME36}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ProviderLogout-2
    [Documentation]  Logout and try to call a url

    ${resp}=   Encrypted Provider Login      ${PUSERNAME36}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=   Get Locations
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}     ${SESSION_EXPIRED}

JD-TC-ProviderLogout-UH1
    [Documentation]  Logout without login

    ${resp}=   Encrypted Provider Login      ${PUSERNAME36}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 

*** Comments ***
JD-TC-ProviderLogout-3
    Comment  check Logout after email login
    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Approximate Waiting Time
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}      "Session expired."

