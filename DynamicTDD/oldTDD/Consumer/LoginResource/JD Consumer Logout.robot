*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        ConsumerLogout
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-ConsumerLogout-1
    [Documentation]   Logout from a valid user session
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ConsumerLogout-2
    [Documentation]   Logout and get waitlist details
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Waitlist Consumer
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"     "Session expired."
    
JD-TC-ConsumerLogout-3
    [Documentation]   check logout using email  login
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Waitlist Consumer
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    "Session expired."

JD-TC-ConsumerLogout-UH1
    [Documentation]   Check logout without login
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    

    



