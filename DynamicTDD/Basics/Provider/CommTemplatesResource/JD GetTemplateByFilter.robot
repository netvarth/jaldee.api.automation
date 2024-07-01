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
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
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
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateByFilter-2

    [Documentation]  Create multiple templates then get it by filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME241}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-3

    [Documentation]  Create multiple templates then get it by templateName filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME242}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   templateName-eq=${temp_name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 
    Should Not Contain          ${resp.json()}                       ${temp_id2} 
   
    ${resp}=  Get Template By Filter   templateName-eq=${temp_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 
    Should Not Contain          ${resp.json()}                       ${temp_id1} 

JD-TC-GetTemplateByFilter-4

    [Documentation]  Create multiple templates then get it by templateFormat filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME243}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   templateFormat-eq=${templateFormat[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-5

    [Documentation]  Create multiple templates then get it by status filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME244}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   status-eq=${VarStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

    ${resp}=  Update Template Status  ${temp_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Template By Filter   status-eq=${VarStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 
    Should Not Contain          ${resp.json()}                       ${temp_id1} 
