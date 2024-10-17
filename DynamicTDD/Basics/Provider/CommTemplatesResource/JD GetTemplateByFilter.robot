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

JD-TC-GetTemplateByFilter-6

    [Documentation]  Create a template with a name and update it with another name, then try to get the filter with old name.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME245}  ${PASSWORD}
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

    ${temp_name1}=    FakerLibrary.firstname
   
    ${resp}=  Update Template   ${temp_id1}  templateName=${temp_name1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter   templateName-eq=${temp_name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}                  []
   
    ${resp}=  Get Template By Filter   templateName-eq=${temp_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateByFilter-7

    [Documentation]  Create multiple templates for the context Appointment then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME246}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   context-eq=${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-8

    [Documentation]  Create multiple templates for the context Appointment then change one template context to signup and get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME247}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   context-eq=${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

    ${resp}=  Update Template   ${temp_id1}   context=${VariableContext[2]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter   context-eq=${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name1}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 
    Should Not Contain          ${resp.json()}                       ${temp_id1} 

JD-TC-GetTemplateByFilter-9

    [Documentation]  Create multiple templates for the context Appointment(email) then get it by filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME248}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${context_id1}  ${resp.json()[0]['context'][0]}

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[1]['name']}
    Set Test Variable   ${dynamic_var2}   ${resp.json()[2]['name']}
    
    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${dynamic_var1}].
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${cont_msg}=      FakerLibrary.sentence   
    ${content_msg1}=     Catenate   SEPARATOR=\n
    ...             ${cont_msg} [${dynamic_var2}].
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${tempheader_sub1}=      FakerLibrary.sentence   5
    ${salutation1}=      FakerLibrary.word
    ${comm_chanl1}=  Create List   ${CommChannel[2]}  
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    ${signature1}=   FakerLibrary.hostname

    ${temp_header1}=    Create Dictionary  subject=${tempheader_sub1}   salutation=${salutation1}
    ${temp_footer1}=    Create Dictionary  signature=${signature1}  

    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target1}    ${comm_chanl1}  
    ...    templateHeader=${temp_header1}  footer=${temp_footer1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Filter   context-eq=${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                     ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                  ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                       ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                   ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}                ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['subject']}     ${tempheader_sub}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['salutation']}  ${salutation}
            Should Be Equal As Strings  ${resp.json()[${i}]['footer']['signature']}           ${signature}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}              ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['variables']['content'][0]}       ${dynamic_var1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                    ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                        ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                     ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                  ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                       ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                   ${comm_chanl1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}                ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['subject']}     ${tempheader_sub1}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['salutation']}  ${salutation1}
            Should Be Equal As Strings  ${resp.json()[${i}]['footer']['signature']}           ${signature1}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}              ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['variables']['content'][0]}       ${dynamic_var2}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                    ${comm_target1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                        ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-10

    [Documentation]  Create multiple templates for the context Appointment(email) one is in disabled state then get it by filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${context_id1}  ${resp.json()[0]['context'][0]}

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[1]['name']}
    Set Test Variable   ${dynamic_var2}   ${resp.json()[2]['name']}
    
    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${dynamic_var1}].
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${new_content_msg}=      FakerLibrary.sentence   
    ${content_msg1}=     Catenate   SEPARATOR=\n
    ...             ${new_content_msg} [${dynamic_var2}].
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${tempheader_sub1}=      FakerLibrary.sentence   5
    ${salutation1}=      FakerLibrary.word
    ${comm_chanl1}=  Create List   ${CommChannel[2]}  
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    ${signature1}=   FakerLibrary.hostname

    ${temp_header1}=    Create Dictionary  subject=${tempheader_sub1}   salutation=${salutation1}
    ${temp_footer1}=    Create Dictionary  signature=${signature1}  

    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target1}    ${comm_chanl1}  
    ...    templateHeader=${temp_header1}  footer=${temp_footer1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Update Template Status   ${temp_id1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter   context-eq=${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${temp_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                     ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                  ${temp_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                       ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                   ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}                ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['subject']}     ${tempheader_sub}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['salutation']}  ${salutation}
            Should Be Equal As Strings  ${resp.json()[${i}]['footer']['signature']}           ${signature}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}              ${content_msg}
            Should Be Equal As Strings  ${resp.json()[${i}]['variables']['content'][0]}       ${dynamic_var1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                    ${comm_target} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                        ${VarStatus[1]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                     ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                  ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                       ${VariableContext[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                   ${comm_chanl1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}                ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['subject']}     ${tempheader_sub1}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateHeader']['salutation']}  ${salutation1}
            Should Be Equal As Strings  ${resp.json()[${i}]['footer']['signature']}           ${signature1}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}              ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['variables']['content'][0]}       ${dynamic_var2}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                    ${comm_target1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                        ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-11

    [Documentation]  Create multiple templates then get it by template name filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
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

    ${resp}=  Get Template By Filter   templateName-eq=${temp_name}, ${temp_name1}
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

JD-TC-GetTemplateByFilter-12

    [Documentation]  Create multiple templates then get it by template name filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME251}  ${PASSWORD}
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
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target1}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target2}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target2}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${temp_name2}=    FakerLibrary.word
    ${content_msg2}=      FakerLibrary.sentence
    ${content2}=    Create Dictionary  intro=${content_msg2}
    ${comm_chanl2}=  Create List   ${CommChannel[2]}    ${CommChannel[3]}
    ${comm_target3}=  Create List   ${CommTarget[1]}  
    
    ${resp}=  Create Template   ${temp_name2}  ${content2}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target3}    ${comm_chanl2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id3}  ${resp.content}

    ${resp}=  Get Template By Filter   templateName-eq=${temp_name}, ${temp_name1}  
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
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target2} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-13

    [Documentation]  Create multiple templates then get it by comm channel filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME252}  ${PASSWORD}
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
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target1}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl1}=  Create List   ${CommChannel[1]}   ${CommChannel[2]} 
    ${comm_target2}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target2}    ${comm_chanl1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${temp_name2}=    FakerLibrary.word
    ${content_msg2}=      FakerLibrary.sentence
    ${content2}=    Create Dictionary  intro=${content_msg2}
    ${comm_chanl2}=  Create List   ${CommChannel[2]}    ${CommChannel[3]}
    ${comm_target3}=  Create List   ${CommTarget[1]}  
    
    ${resp}=  Create Template   ${temp_name2}  ${content2}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target3}    ${comm_chanl2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id3}  ${resp.content}

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[1]}, ${CommChannel[3]}  
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
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target2} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                          ${temp_id3} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name2}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl2} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${content_msg2}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target3} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateByFilter-14

    [Documentation]  Create multiple templates then get it by comm target filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
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
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target1}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl1}=  Create List   ${CommChannel[1]}   ${CommChannel[2]} 
    ${comm_target2}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target2}    ${comm_chanl1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${temp_name2}=    FakerLibrary.word
    ${content_msg2}=      FakerLibrary.sentence
    ${content2}=    Create Dictionary  intro=${content_msg2}
    ${comm_chanl2}=  Create List   ${CommChannel[2]}    ${CommChannel[3]}
    ${comm_target3}=  Create List   ${CommTarget[1]}  
    
    ${resp}=  Create Template   ${temp_name2}  ${content2}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target3}    ${comm_chanl2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id3}  ${resp.content}

    ${resp}=  Get Template By Filter   commTarget-eq=${CommTarget[0]}, ${CommChannel[2]}  
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
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 

        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg1}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target2} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        
        ELSE IF     '${resp.json()[${i}]['id']}' == '${temp_id3}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}                   ${account_id} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}                ${temp_name2}
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}                     ${VariableContext[2]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['commChannel']}                 ${comm_chanl2} 
            Should Be Equal As Strings  ${resp.json()[${i}]['templateFormat']}              ${templateFormat[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['content']['intro']}            ${content_msg2}
            Should Be Equal As Strings  ${resp.json()[${i}]['commTarget']}                  ${comm_target3} 
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${VarStatus[0]} 
        END
    END

JD-TC-GetTemplateByFilter-15

    [Documentation]  Create template without content, then get the template by filter 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME255}  ${PASSWORD}
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
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[0]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[0]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[0]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[0]['variables']}

    ${temp_name}=    FakerLibrary.word
    ${content}=    Create Dictionary  intro=${EMPTY}
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    ...   sendComm=${sendcomm_list}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                             ${VarStatus[1]} 

JD-TC-GetTemplateByFilter-16

    [Documentation]  Create template without content, then get the template by filter and
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    ...     update the channel and get by filter
    ...     context : Account, trigger : signup, commchannel : whatsapp , target : consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
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
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[0]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[0]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[0]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[0]['variables']}

    ${temp_name}=    FakerLibrary.word
    ${content}=    Create Dictionary  intro=${EMPTY}
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    ...   sendComm=${sendcomm_list}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                             ${VarStatus[1]} 

    ${comm_chanl1}=  Create List   ${CommChannel[1]}  

    ${resp}=  Update Template   ${temp_id1}   commChannel=${comm_chanl1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl1} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                             ${VarStatus[1]} 

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}            []

JD-TC-GetTemplateByFilter-17

    [Documentation]  Create template without content, then get the template by filter and
    ...     context : appointment, trigger : appnt Reconfirm, commchannel : email , target : consumer.
    ...     update the template with content and get by filter
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[56]['id']}
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[56]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[56]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[56]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[56]['variables']}

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Test Variable   ${book_enid}        ${resp.json()[15]['name']}
    Set Test Variable   ${book_date}        ${resp.json()[16]['name']}

    ${temp_name}=    FakerLibrary.word
    ${content}=    Create Dictionary  intro=${EMPTY}
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    ...   sendComm=${sendcomm_list}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                             ${VarStatus[1]} 

    ${booking_details}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Booking Reference Number': [${book_enid}],
    ...                   'Check-in Date': [${book_date}],
    ...                   'Check-out Date': [${book_date}]
    ${content1}=    Create Dictionary  intro=${booking_details} 

    ${resp}=  Update Template   ${temp_id1}   content=${content1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter   commChannel-eq=${CommChannel[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()[0]['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()[0]['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()[0]['content']['intro']}            ${booking_details}
    Should Be Equal As Strings  ${resp.json()[0]['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()[0]['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()[0]['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                             ${VarStatus[1]} 

JD-TC-GetTemplateByFilter-UH1

    [Documentation]  Get template by filter without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME202}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetTemplateByFilter-UH2

    [Documentation]  Get template by filter with consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Template By Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
