*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${NEW_PASSWORD}       Netvarth007

*** Test Cases ***

JD-TC-ProviderChangePassword-1
    [Documentation]    Provider Change password

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ProviderChangePassword-UH1
    [Documentation]    Provider Change password without login

    ${resp}=  Provider Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}     ${SESSION_EXPIRED}

JD-TC-ProviderChangePassword-UH2
    [Documentation]    Provider Change password with current password 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}      ${NEW_PASSWORD_CANNOT_BE_SAME_AS_OLD_PASSWORD}
   
JD-TC-ProviderChangePassword-UH3
    [Documentation]    Set new password as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Change Password  ${NEW_PASSWORD}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}      ${ENTER_PASSWORD}
    


JD-TC-Change To Old Password
    [Documentation]    Reset the password to old one to avoid errors in other test suites

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Change Password  ${NEW_PASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

