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

JD-TC-UpdateTemplate-1

    [Documentation]  Create template update it with same details then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
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

    ${resp}=  Update Template   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-UpdateTemplate-2

    [Documentation]  Create template update it different name then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
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

    ${temp_name1}=    FakerLibrary.word

    ${resp}=  Update Template   ${temp_id1}  templateName=${temp_name1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name1}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-UpdateTemplate-3

    [Documentation]  Create template update it different content then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME232}  ${PASSWORD}
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

    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}

    ${resp}=  Update Template   ${temp_id1}   content=${content1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

JD-TC-UpdateTemplate-4

    [Documentation]  Create template update it without template name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
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

    ${resp}=  Update Template   ${temp_id1}  templateName=${EMPTY} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-UpdateTemplate-5

    [Documentation]  Create template update it without content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
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

    ${content}=    Create Dictionary  intro=${EMPTY}

    ${resp}=  Update Template   ${temp_id1}   content=${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-UpdateTemplate-6

    [Documentation]  Create a template for signup context with email as the communication channel then update the header with another subject.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD}
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
    
    ${tempheader_sub1}=      FakerLibrary.sentence   5
    ${temp_header1}=    Create Dictionary  subject=${tempheader_sub1}  salutation=${salutation} 
    
    ${resp}=  Update Template  ${temp_id1}   templateHeader=${temp_header1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub1}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-7

    [Documentation]  Create a template for signup context with email as the communication channel then update the header with another salutation.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME236}  ${PASSWORD}
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
    
    ${salutation1}=      FakerLibrary.word
    ${temp_header1}=    Create Dictionary   subject=${tempheader_sub}  salutation=${salutation1}
    
    ${resp}=  Update Template  ${temp_id1}  templateHeader=${temp_header1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation1}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-8

    [Documentation]  Create a template for signup context with email as the communication channel then update the footer with another signature.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME237}  ${PASSWORD}
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
    
    ${signature1}=   FakerLibrary.hostname
    ${temp_footer1}=    Create Dictionary  signature=${signature1}  

    ${resp}=  Update Template  ${temp_id1}  footer=${temp_footer1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature1}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-9

    [Documentation]  Create a template for signup context with email as the communication channel then update the header without subject.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME238}  ${PASSWORD}
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
    
    ${temp_header1}=    Create Dictionary  subject=${EMPTY}   salutation=${salutation}
    
    ${resp}=  Update Template  ${temp_id1}   templateHeader=${temp_header1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-10

    [Documentation]  Create a template for signup context with email as the communication channel then update the header without salutation.

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
    
    ${tempheader_sub1}=      FakerLibrary.sentence   5
    ${temp_header1}=    Create Dictionary  subject=${tempheader_sub1}   salutation=${EMPTY}
    
    ${resp}=  Update Template  ${temp_id1}  templateHeader=${temp_header1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub1}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-11

    [Documentation]  Create a template for signup context with email as the communication channel then update the footer without signature.

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
    
    ${temp_footer1}=    Create Dictionary  signature=${EMPTY}  
    
    ${resp}=  Update Template  ${temp_id1}    footer=${temp_footer1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-12

    [Documentation]  Create a template for signup context without custom variable in content then update it with custom variable..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME252}  ${PASSWORD}
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

    ${content_msg1}=     Set Variable  ${content_msg} [${custom_var1}].
    ${content1}=    Create Dictionary  intro=${content_msg1}

    ${resp}=  Update Template   ${temp_id1}   content=${content1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg1}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${custom_var1}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-13

    [Documentation]  Create a template for signup context without dynamic variable in content then update it with dynamic variable..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
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
    Set Test Variable   ${dynamic_var3}   ${resp.json()[2]['name']}
    Set Test Variable   ${dynamic_var4}   ${resp.json()[3]['name']}

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

    ${content_msg1}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${dynamic_var1}].
    ...             [${dynamic_var2}]
    ...             [${dynamic_var3}]
    ...             [${dynamic_var4}]  
    ${content1}=    Create Dictionary  intro=${content_msg1}
    
    ${resp}=  Update Template   ${temp_id1}   content=${content1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg1}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][0]}       ${dynamic_var1}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][1]}       ${dynamic_var2}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][2]}       ${dynamic_var3}
    Should Be Equal As Strings  ${resp.json()['variables']['content'][3]}       ${dynamic_var4}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-UpdateTemplate-14

    [Documentation]  Create a template for signup context with email as the communication channel then update it without header.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME239}  ${PASSWORD}
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
    
    ${resp}=  Update Template  ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-UpdateTemplate-UH1

    [Documentation]  Update custom variable with provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
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

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Template   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateTemplate-UH2

    [Documentation]  Update custom variable without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME168}  ${PASSWORD}
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

    ${resp}=  Update Template   ${temp_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateTemplate-UH3

    [Documentation]  update custom variable using another providers variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME169}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Template   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NOT_FOUND}

JD-TC-UpdateTemplate-UH4

    [Documentation]  get a default template and try to update that template.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${sendcomm_id1}   ${resp.json()[0]['id']}

    ${resp}=  Get Default Template List by sendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${deftemp_id1}   ${resp.json()['templates'][0]['id']}

    ${resp}=  Get Default Template Preview   ${sendcomm_id1}  ${deftemp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}   ${resp.json()['id']}

    ${resp}=  Update Template   ${temp_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NOT_FOUND}

