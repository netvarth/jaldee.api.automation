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

JD-TC-CreateTemplate-1

    [Documentation]  Create template for a provider with context signup.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
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

JD-TC-CreateTemplate-2

    [Documentation]  Create template for a provider with context Appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[1]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-3

    [Documentation]  Create template for a provider with context token.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-4

    [Documentation]  Create template for a provider with context order.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[3]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-5

    [Documentation]  Create template for a provider with context donation.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[4]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-6

    [Documentation]  Create template for a provider with context payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[5]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-7

    [Documentation]  Create template for a provider with context ALL.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[6]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-8

    [Documentation]  Create multiple templates. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME157}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name1}=    FakerLibrary.word
    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}

    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-9

    [Documentation]  Create template by two providers with same name. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME159}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    
    ${resp}=  Create Template   ${temp_name}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-10

    [Documentation]  Create template without comm channel. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME159}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-CreateTemplate-11

    [Documentation]  Create template without comm target. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-12

    [Documentation]  Create a template for signup context with email as the communication channel.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
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

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-13

    [Documentation]  Create a template for signup context with custom variable in content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
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

JD-TC-CreateTemplate-14

    [Documentation]  Create a template for signup context with multiple custom variables in content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD}
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
    ...             ${content_msg} ${custom_var1}.
    ...             ${custom_var2}
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

JD-TC-CreateTemplate-15

    [Documentation]  Create a template for signup context with custom variable in header.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
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
    ${tempheader_sub}=     Set Variable  ${content_msg} ${custom_var1}.
    ${salutation}=      FakerLibrary.word
    ${salutation}=     Set Variable  ${salutation} ${custom_var1}.
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-16

    [Documentation]  Create a template for signup context with multiple custom variables in header.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
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
    ...             ${tempheader_sub} ${custom_var1}.
    ...             ${custom_var2}
    ${salutation}=      FakerLibrary.word
    ${salutation}=     Set Variable   ${custom_var2} ${salutation} ${custom_var1}.
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-17

    [Documentation]  Create a template for signup context with dynamic variable in content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME280}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${context_id1}  ${resp.json()[0]['context']}

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[1]['name']}
    
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

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  

JD-TC-CreateTemplate-18

    [Documentation]  Create a template for signup context with email as the communication channel, excluding the template header.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_HEADER}

JD-TC-CreateTemplate-19

    [Documentation]    Create a template for signup context with email as the communication channel, excluding the template footer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  templateHeader=${temp_header}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_FOOTER}

JD-TC-CreateTemplate-20

    [Documentation]    Create a template with trigger point(send comm)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-CreateTemplate-21

    [Documentation]  Create a template for ALL context with channels :(telegram, email and whatsapp, App)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}   ${resp.json()[1]['id']}
    Set Test Variable   ${context_id1}  ${resp.json()[0]['context']}

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[1]['name']}
 
    ${temp_name}=    FakerLibrary.word
    ${details}=  Create Dictionary   JALDEE OTP=${EMPTY}
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Catenate   SEPARATOR=\n
    ...             ${content_msg} [${dynamic_var1}].
    ${content}=    Create Dictionary  intro=${content_msg}   cts=${EMPTY}  
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[1]}  ${CommChannel[2]}  ${CommChannel[3]}  ${CommChannel[4]}
    ${comm_target}=  Create List   ${CommTarget[1]}  
    ${signature}=   FakerLibrary.hostname
    ${salutation}=     Set Variable  ${salutation} [${dynamic_var1}].

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}  note=${EMPTY}
    ${temp_footer}=    Create Dictionary  closing=${EMPTY}   signature=${signature}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  

JD-TC-CreateTemplate-22

    [Documentation]  Create template without any channel.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-23

    [Documentation]  Create template without comm target.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-UH1

    [Documentation]  Create template with same template name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content_msg1}=      FakerLibrary.sentence
    ${content1}=    Create Dictionary  intro=${content_msg1}
    
    ${resp}=  Create Template   ${temp_name}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_NAME_EXISTS}

JD-TC-CreateTemplate-UH2

    [Documentation]  Create template without name. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${EMPTY}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_NAME_SHOULD_NOT_BE_NULL}

JD-TC-CreateTemplate-UH3

    [Documentation]  Create template without content. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content}=    Create Dictionary  intro=${EMPTY}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_CONTENT}

JD-TC-CreateTemplate-UH4

    [Documentation]  Create template without login

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}   ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateTemplate-UH5

    [Documentation]  Create template with provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    ${comm_chanl}=  Create List   ${CommChannel[1]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}   ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-CreateTemplate-UH6

    [Documentation]  Create a template for signup context with a disabled custom variable in content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Set Variable  ${content_msg} ${custom_var1}.
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${VARIABLE_STATUS_DISABLED}=  format String   ${VARIABLE_STATUS_DISABLED}   ${custom_var1} 

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_STATUS_DISABLED}

JD-TC-CreateTemplate-UH7

    [Documentation]    Create a template for signup context with multiple custom variables, one of which is disabled in the content.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME109}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 

    ${resp}=  Get Custom Variable By Id   ${var_id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Set Test Variable   ${custom_var2}   ${resp.json()['internalName']}

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Set Variable  ${content_msg} ${custom_var1} ${custom_var2}.
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${VARIABLE_STATUS_DISABLED}=  format String   ${VARIABLE_STATUS_DISABLED}   ${custom_var1} 

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_STATUS_DISABLED}

JD-TC-CreateTemplate-UH8

    [Documentation]  Create a template for signup context with a disabled custom variable in content, then enable it and try to add in template.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Set Test Variable   ${custom_var1}   ${resp.json()['internalName']}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 

    ${temp_name}=    FakerLibrary.word
    ${content_msg}=      FakerLibrary.sentence   
    ${content_msg}=     Set Variable  ${content_msg} ${custom_var1}.
    ${content}=    Create Dictionary  intro=${content_msg}
    ${tempheader_sub}=      FakerLibrary.sentence   5
    ${salutation}=      FakerLibrary.word
    ${comm_chanl}=  Create List   ${CommChannel[2]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${signature}=   FakerLibrary.hostname

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}
    ${temp_footer}=    Create Dictionary  signature=${signature}  

    ${VARIABLE_STATUS_DISABLED}=  format String   ${VARIABLE_STATUS_DISABLED}   ${custom_var1} 

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_STATUS_DISABLED}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl}  
    ...    templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-UH9

    [Documentation]  get a default template and try to create a template with a new content for SMS.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
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
    Set Test Variable   ${temp_name1}   ${resp.json()['templateName']}
    Set Test Variable   ${content1}    ${resp.json()['content']['intro']}
    Set Test Variable   ${dyn_var1}    ${resp.json()['variables']['content'][0]}
    Set Test Variable   ${dyn_var2}    ${resp.json()['variables']['content'][1]}

    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content1} ${content_msg}
    ${new_content}=    Create Dictionary  intro=${content_msg1}

    ${resp}=  Create Template   ${temp_name1}  ${new_content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${SMS_TEMPLATE_NOT_ALLOWED}

JD-TC-CreateTemplate-UH10

    [Documentation]  get a default template and try to create a template with same content for SMS.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
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
    Set Test Variable   ${temp_name1}   ${resp.json()['templateName']}
    Set Test Variable   ${content1}    ${resp.json()['content']['intro']}
    Set Test Variable   ${dyn_var1}    ${resp.json()['variables']['content'][0]}
    Set Test Variable   ${dyn_var2}    ${resp.json()['variables']['content'][1]}

    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    ${content_msg1}=     Set Variable  ${content1} 
    ${new_content}=    Create Dictionary  intro=${content_msg1}

    ${resp}=  Create Template   ${temp_name1}  ${new_content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   Template Already Exists