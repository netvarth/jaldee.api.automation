*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-GetTemplateById-1

    [Documentation]  Create template for a provider with context signup then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
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

JD-TC-GetTemplateById-2

    [Documentation]  Create multiple template then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
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

    ${temp_name2}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content2}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl2}=  Create List   ${CommChannel[1]}  
    ${comm_target2}=  Create List   ${CommTarget[1]}  
    
    ${resp}=  Create Template   ${temp_name2}  ${content2}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target2}    ${comm_chanl2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id2}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target1} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 
    
    ${resp}=  Get Template By Id   ${temp_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name2}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl2} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target2} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-3

    [Documentation]  Create template for a provider with context appointment then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME202}  ${PASSWORD}
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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[1]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-4

    [Documentation]  Create template for a provider with context token then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

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

JD-TC-GetTemplateById-5

    [Documentation]  Create template for a provider with context order then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[3]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[3]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-6

    [Documentation]  Create template for a provider with context donation then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[4]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[4]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-7

    [Documentation]  Create template for a provider with context payment then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[5]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[5]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-8

    [Documentation]  Create template for a provider with context ALL then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME207}  ${PASSWORD}
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
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[6]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[6]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-9

    [Documentation]  Create template for two providers with same name then get by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME208}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME209}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    ${comm_chanl1}=  Create List   ${CommChannel[1]}  
    ${comm_target1}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content1}  ${templateFormat[0]}  ${VariableContext[6]}  ${comm_target1}    ${comm_chanl1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id1} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[6]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl1} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target1} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-GetTemplateById-10

    [Documentation]  Create a template for signup context with email as the communication channel then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-11

    [Documentation]  Create a template for signup context with custom variable in content then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Set Variable  ${content_msg} [${custom_var1}].
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg} 
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-12

    [Documentation]  Create a template for signup context with multiple custom variables in content then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME212}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${name1}=    FakerLibrary.word
    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name1}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${resp}=  Get Custom Variable By Id   ${var_id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var2}   ${resp.json()['internalName']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${custom_var1}].
    ...             [${custom_var2}]
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][1]}       ${custom_var2}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-13

    [Documentation]  Create a template for signup context with custom variable in header then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${tempheader_sub}=     Set Variable  ${content_msg} [${custom_var1}].
    ${salutation}=      FakerLibrary.word
    ${salutation}=     Set Variable  ${salutation} [${custom_var1}].
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['variables']['subject'][0]}       ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['variables']['salutation'][0]}    ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-14

    [Documentation]  Create a template for signup context with multiple custom variables in header then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${name1}=    FakerLibrary.word
    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name1}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${resp}=  Get Custom Variable By Id   ${var_id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${custom_var2}   ${resp.json()['internalName']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${tempheader_sub}=     Catenate   SEPARATOR=\n
    ...             ${tempheader_sub} [${custom_var1}].
    ...             [${custom_var2}]
    ${salutation}=      FakerLibrary.word
    ${salutation}=     Set Variable   [${custom_var2}] ${salutation} [${custom_var1}].
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['variables']['subject'][0]}       ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['variables']['subject'][1]}       ${custom_var2}
    Should Be Equal As Strings  ${resp.json()['variables']['salutation'][0]}    ${custom_var2}
    Should Be Equal As Strings  ${resp.json()['variables']['salutation'][1]}    ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-15

    [Documentation]    Create a template with trigger point(send comm) then get it and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD}
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

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...       templateHeader=${temp_header}   sendComm=${sendcomm_list}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-16

    [Documentation]  Create a template for signup context with dynamic variable in content then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
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
  
    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Set Variable  ${content_msg} [${dynamic_var1}].
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg} 
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${dynamic_var1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-17

    [Documentation]  Create a template for signup context with multiple dynamic variables in content then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME212}  ${PASSWORD}
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
    Set Test Variable   ${dynamic_var1}   ${resp.json()[0]['name']}
    Set Test Variable   ${dynamic_var2}   ${resp.json()[1]['name']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${dynamic_var1}].
    ...             [${dynamic_var2}]
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${dynamic_var1}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][1]}       ${dynamic_var2}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetTemplateById-18

    [Documentation]  Create template without content, then get the template by id, 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

JD-TC-GetTemplateById-19

    [Documentation]  Create template without content, then get the template by id, 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    ...     then update the template with content and verify by id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD}
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

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Test Variable   ${business1}        ${resp.json()[1]['name']}
    Set Test Variable   ${prov_name}        ${resp.json()[2]['name']}

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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

    ${booking_details}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Business': [${business1}],
    ...                   'Provider Name': [${prov_name}]
    ${content1}=    Create Dictionary  intro=${booking_details} 

    ${resp}=  Update Template   ${temp_id1}   content=${content1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${booking_details}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

JD-TC-GetTemplateById-20

    [Documentation]  Create template without content, then get the template by id, 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    ...     then update the template with content and another sendcomm id then verify by id.
    ...     context : Account, trigger : signup complete, commchannel : email , target : consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME219}  ${PASSWORD}
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

    Set Test Variable   ${sendcomm_id2}   ${resp.json()[1]['id']}
    Set Test Variable   ${sendcomm_name2}       ${resp.json()[1]['name']}
    Set Test Variable   ${sendcomm_disname2}    ${resp.json()[1]['displayName']}
    Set Test Variable   ${sendcomm_vars2}       ${resp.json()[1]['variables']}

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Test Variable   ${business1}        ${resp.json()[1]['name']}
    Set Test Variable   ${prov_name}        ${resp.json()[2]['name']}

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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

    ${booking_details}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Business': [${business1}],
    ...                   'Provider Name': [${prov_name}]
    ${content1}=    Create Dictionary  intro=${booking_details} 
    ${sendcomm_list1}=  Create List   ${sendcomm_id2}

    ${resp}=  Update Template   ${temp_id1}   sendComm=${sendcomm_list1}  content=${content1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${booking_details}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id2}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name2}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname2}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars2} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

JD-TC-GetTemplateById-UH1

    [Documentation]  Get template by id with invalid variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
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

    ${invalidtemp_id1}=     Random Int  min=100   max=999

    ${resp}=  Get Template By Id   ${invalidtemp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NOT_FOUND}
   
JD-TC-GetTemplateById-UH2

    [Documentation]  Get template by id with another providers variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NOT_FOUND}

JD-TC-GetTemplateById-UH3

    [Documentation]  Get template by id without login

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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetTemplateById-UH4

    [Documentation]  Get template by id with consumer login.

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

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
