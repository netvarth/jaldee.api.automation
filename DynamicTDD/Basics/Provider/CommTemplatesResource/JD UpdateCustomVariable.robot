*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{context}   ALL

*** Test Cases ***

JD-TC-UpdateCustomVariable-1

    [Documentation]  Create custom variable for a provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${type}=    FakerLibrary.sentence
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${type}  ${context[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.content}

    ${var_name}=    FakerLibrary.word
    ${vardis_name}=    FakerLibrary.word
    ${var_value}=   FakerLibrary.hostname
    ${resp}=  Update Custom Variable   ${var_id1}  ${var_name}  ${vardis_name}  ${var_value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
