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

JD-TC-GetCustomTemplatePreview-1

    [Documentation]  Get custom template preview for a provider with custom variable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME240}  ${PASSWORD}
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
    ${content_msg1}=     Set Variable  ${content_msg} [${custom_var1}].
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
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
    Should Be Equal As Strings  ${resp.json()['footer']['closing']}             ${closing}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg} ${SPACE}.
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetCustomTemplatePreview-2

    [Documentation]  Get custom template preview for a provider without any variable.

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
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
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
    Should Be Equal As Strings  ${resp.json()['footer']['closing']}             ${closing}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]}

JD-TC-GetCustomTemplatePreview-3

    [Documentation]  Create a template and disable it then try to get the preview.

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
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Update Template Status   ${temp_id1}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 
    
    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
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
    Should Be Equal As Strings  ${resp.json()['footer']['closing']}             ${closing}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[1]} 

JD-TC-GetCustomTemplatePreview-4

    [Documentation]  Create a template and update it then verify the preview.

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
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl} 

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
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
    Should Be Equal As Strings  ${resp.json()['footer']['closing']}             ${closing}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

    ${comm_chanl1}=  Create List   ${CommChannel[0]}   ${CommChannel[1]}    ${CommChannel[2]}  
    
    ${resp}=  Update Template  ${temp_id1}    commChannel=${comm_chanl1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl1} 
    
    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                     ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                  ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                       ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                   ${comm_chanl1} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['subject']}     ${tempheader_sub}
    Should Be Equal As Strings  ${resp.json()['templateHeader']['salutation']}  ${salutation}
    Should Be Equal As Strings  ${resp.json()['footer']['signature']}           ${signature}
    Should Be Equal As Strings  ${resp.json()['footer']['closing']}             ${closing}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}              ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                    ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                        ${VarStatus[0]} 

JD-TC-GetCustomTemplatePreview-5

    [Documentation]  Create template without content, then get the custom template preview by id, 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME244}  ${PASSWORD}
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

    ${resp}=  Get Custom Template Preview By Id    ${temp_id1}  
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

JD-TC-GetCustomTemplatePreview-6

    [Documentation]  Create template without content, 
    ...     context : Account, trigger : signup, commchannel : email , target : consumer.
    ...     then update it with content then get the template preview by id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME245}  ${PASSWORD}
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

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
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
    ${content_msg}=  Set Variable    I hope this message finds you well. 
    ${tempheader_sub}=    Set Variable    Cancellation of Booking
    ${salutation}=      Set Variable  Dear [${cons_name}] 
    ${signature}=   FakerLibrary.hostname
    ${salutation}=     Set Variable  ${salutation}.

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}  note=${EMPTY}
    ${temp_footer}=    Create Dictionary  closing=${EMPTY}   signature=${signature}  

    ${content1}=    Create Dictionary  intro=${content_msg}  details=${booking_details}   cts=${EMPTY}  

    ${resp}=  Update Template  ${temp_id1}  content=${content1}  templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Template Preview By Id  ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1}  
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 

JD-TC-GetCustomTemplatePreview-UH1

    [Documentation]  get custom template preview without login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCustomTemplatePreview-UH2

    [Documentation]  get custom template preview with provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
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
    ${closing}=    FakerLibrary.bs

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  closing=${closing}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

