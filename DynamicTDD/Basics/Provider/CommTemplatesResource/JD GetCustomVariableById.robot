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


*** Test Cases ***

JD-TC-GetCustomVariableById-1

    [Documentation]  Create custom variable for a provider then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.content['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.content}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.content['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.content['name']}            ${name}
    Should Be Equal As Strings  ${resp.content['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.content['value']}           ${value}
    Should Be Equal As Strings  ${resp.content['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.content['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.content['status']}          ${VariableStatus[0]} 
    Should Be Equal As Strings  ${resp.content['account']}         ${account_id}




