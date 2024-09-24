*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py

*** Test Cases ***

JD-TC-Enable OnlinePresence
    [Documentation]  Update a base location by provider login

    ${providers_list}=   Get File    ${var_file}
    ${pro_list}=   Split to lines  ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider}=  Remove String    ${provider}    ${SPACE}
        ${provider}  ${ph}=   Split String    ${provider}  =
        Set Test Variable  ${ph}

        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    
    END
    