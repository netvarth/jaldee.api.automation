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
    ${content_msg}=     Set Variable  ${content_msg} [${custom_var1}].
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

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

