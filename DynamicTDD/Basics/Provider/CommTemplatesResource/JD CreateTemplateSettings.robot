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

JD-TC-CreateSendCommSettings-1

    [Documentation]  Create template for a provider with context signup and create send comm settings.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.json()}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}

    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${resp}=  Create Send Comm Settings   ${temp_id1}  ${VariableContext[0]}  ${sendcomm_id1}  ${CommTarget[0]}    ${CommChannel[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[2]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 
