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

JD-TC-GetTemplateByFilter-1

    [Documentation]  Create template for a provider with context signup then get it by filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME240}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']}                     ${content}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 
