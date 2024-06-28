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

    [Documentation]  Get custom template preview for a provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${out_content}=  Set Variable   ${content_msg} ${name}
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
    
    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200