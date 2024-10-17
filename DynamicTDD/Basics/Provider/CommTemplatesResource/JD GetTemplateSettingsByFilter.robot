*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetTemplateSettingsByFilter-1

    [Documentation]  create a template without trigger point(send comm) for signup, SMS, SPConsumer, then add that using template settings.
    
    comment   deprecated from rest side

    ${resp}=  Encrypted Provider Login  ${PUSERNAME310}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

*** Comments ***
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

    ${resp}=  Get All Settings By Filter  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateSettingsByFilter-2

    [Documentation]  create a template with trigger point(send comm) for signup, SMS, SPConsumer, then add another trigger point using template settings.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME311}  ${PASSWORD}
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

    ${resp}=  Get All Settings By Filter  context-eq=${VariableContext[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['sendCommId']}                  ${sendcomm_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[1]['templateId']}                  ${temp_id1}
    Should Be Equal As Strings  ${resp.json()[1]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['sendCommId']}                  ${sendcomm_id2} 
    Should Be Equal As Strings  ${resp.json()[1]['commTarget']}                  ${CommTarget[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['commChannel']}                 ${CommChannel[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['status']}                      ${VarStatus[0]} 

   