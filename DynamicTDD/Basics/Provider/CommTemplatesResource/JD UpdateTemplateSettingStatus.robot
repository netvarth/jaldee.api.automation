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

JD-TC-UpdateTemplateSettingStatus-1

    [Documentation]  create a template without trigger point(send comm) for signup, SMS, SPConsumer, then add that using template settings and set it status as disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME285}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=   Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.json()}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}

    ${resp}=  Create Template Settings   ${temp_id1}  ${VariableContext[0]}  ${sendcomm_id1}  ${CommTarget[0]}    ${CommChannel[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_setid1}  ${resp.json()}

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 

JD-TC-UpdateTemplateSettingStatus-2

    [Documentation]  create template settings, then update it status as disabled, then enable it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME286}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sendcomm_id2}   ${resp.json()[1]['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=   Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  sendComm=${sendcomm_list} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.json()}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['sendComm']}                    ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Create Template Settings   ${temp_id1}  ${VariableContext[0]}  ${sendcomm_id2}  ${CommTarget[0]}    ${CommChannel[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_setid1}  ${resp.json()}

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id2} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id2} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id2} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-UpdateTemplateSettingStatus-UH1

    [Documentation]  Create a template settings and update the status to enabled, even if it is already enabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}
    Set Test Variable   ${sendcomm_id2}   ${resp.json()[1]['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=   Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  sendComm=${sendcomm_list} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.json()}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['sendComm']}                    ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Create Template Settings   ${temp_id1}  ${VariableContext[0]}  ${sendcomm_id2}  ${CommTarget[0]}    ${CommChannel[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_setid1}  ${resp.json()}

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id2} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${TEMPLATE_SETTINGS_STATUS}=  format String   ${TEMPLATE_SETTINGS_STATUS}   ${VarStatus[0]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_SETTINGS_STATUS}

JD-TC-UpdateTemplateStatus-UH2

    [Documentation]  Create a template settings and update the status to disabled, even if it is already disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME288}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=   Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.json()}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}

    ${resp}=  Create Template Settings   ${temp_id1}  ${VariableContext[0]}  ${sendcomm_id1}  ${CommTarget[0]}    ${CommChannel[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_setid1}  ${resp.json()}

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template Settings By Id   ${temp_setid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 

    ${TEMPLATE_SETTINGS_STATUS}=  format String   ${TEMPLATE_SETTINGS_STATUS}   ${VarStatus[1]} 

    ${resp}=  Update Template Settings Status   ${temp_setid1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_SETTINGS_STATUS}