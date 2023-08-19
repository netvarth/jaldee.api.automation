*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ChangePassword
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${NEW_PASSWORD}       Netvarth321

*** Test Cases ***

JD-TC-ConsumerChangePassword-1
    [Documentation]   Change consumer's password
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ConsumerChangePassword-UH1
    [Documentation]   Change consumer's password without login
    ${resp}=  Consumer Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"       "${SESSION_EXPIRED}"
    
    
JD-TC-ConsumerChangePassword-UH2
    [Documentation]  Change consumer's password with wrong current password 
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Change Password  ${PASSWORD}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"      "${NEW_PASSWORD_CANNOT_BE_SAME_AS_OLD_PASSWORD}"

JD-TC-ConsumerChangePassword-UH3
    [Documentation]    Set new password as empty
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Change Password  ${NEW_PASSWORD}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"      "${PASSWORD_EMPTY}" 

JD-TC-Change To Old Password
    [Documentation]    Reset the password to old one to avoid errors in other test suites
    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${NEW_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Change Password  ${NEW_PASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

