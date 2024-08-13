*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Basics
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***

# ${number}   5553643640
${number}   archie68
# ${PASSWORD}  Jaldee01
${PASSWORD}  Jaldee12

*** Test Cases ***

JD-TC-Change Password-1
    [Documentation]  check basic functionalities of a provider

    ${resp}=   Provider Login  ${number}  ${PASSWORD} 
    Log  ${resp.content}
    Run Keyword And Continue On Failure  Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Run Keyword And Continue On Failure  Should Be Equal As Strings    ${resp.status_code}    200

    