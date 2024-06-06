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

JD-TC-GetCustomVariableByFilter-1

    [Documentation]  Create custom variable for a provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${type}=    FakerLibrary.sentence
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${type}  ${context[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Filter   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${type} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${context[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}




