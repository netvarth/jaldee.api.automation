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

JD-TC-UpdateCustomVariableStatus-1

    [Documentation]  Create custom variable for a provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${type}=    FakerLibrary.sentence
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${type}  ${context[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}
   
    ${resp}=  Update Custom Variable Status  ${var_id1}  ${toggle[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${type} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${context[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

