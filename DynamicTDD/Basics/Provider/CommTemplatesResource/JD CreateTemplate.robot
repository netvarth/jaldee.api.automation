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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name1}=    FakerLibrary.word
    ${content1}=    FakerLibrary.sentence
    
    ${resp}=  Create Template   ${temp_name1}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-9

    [Documentation]  Create template by two providers with same name. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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

    ${content1}=    FakerLibrary.sentence
    
    ${resp}=  Create Template   ${temp_name}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateTemplate-10

    [Documentation]  Create template without comm channel. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME159}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content}=    FakerLibrary.sentence
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-CreateTemplate-UH1

    [Documentation]  Create template with same template name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content1}=    FakerLibrary.sentence
    
    ${resp}=  Create Template   ${temp_name}  ${content1}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_NAME_EXISTS}

JD-TC-CreateTemplate-UH2

    [Documentation]  Create template without name. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  
    
    ${resp}=  Create Template   ${temp_name}  ${EMPTY}  ${templateFormat[0]}  ${VariableContext[2]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_CONTENT}

JD-TC-CreateTemplate-UH4

    [Documentation]  Create template without login

    ${temp_name}=    FakerLibrary.word
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
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
    ${content}=    FakerLibrary.sentence
    ${comm_chanl}=  Create List   ${CommChannel[0]}  
    ${comm_target}=  Create List   ${CommTarget[0]}  

    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}   ${VariableContext[0]}  ${comm_target}    ${comm_chanl} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

