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

JD-TC-CreateTemplatePreview-1

    [Documentation]  Create template preview for a provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${content_msg}=      FakerLibrary.sentence
    ${content}=    Create Dictionary  intro=${content_msg}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    
JD-TC-CreateTemplatePreview-2

    [Documentation]  Create template preview for context signup with one dynamic variable otp(will return a space).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${context_id1}  ${resp.json()[0]['context'][0]}

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[0]['name']}
    Set Test Variable   ${sample_otp}     ${resp.json()[0]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${sample_otp}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${out_content} 
    
JD-TC-CreateTemplatePreview-3

    [Documentation]  Create template preview for context signup with one dynamic variable consumer name(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[1]['name']}
    Set Test Variable   ${scons_name}     ${resp.json()[1]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${scons_name}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 
 
JD-TC-CreateTemplatePreview-4

    [Documentation]  Create template preview for context signup with one dynamic variable business name(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[2]['name']}
    Set Test Variable   ${sbus_name}      ${resp.json()[2]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${sbus_name}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 
   
JD-TC-CreateTemplatePreview-5

    [Documentation]  Create template preview for context SIGNUP with one dynamic variable provider name(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[3]['name']}
    Set Test Variable   ${sprov_name}     ${resp.json()[3]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${sprov_name}
    
    ${resp}=  Create Template Preview  ${VariableContext[3]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[3]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 

JD-TC-CreateTemplatePreview-6

    [Documentation]  Create template preview for context signup with one dynamic variable user id(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[4]['name']}
    Set Test Variable   ${suser_id}       ${resp.json()[4]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${suser_id}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 

JD-TC-CreateTemplatePreview-7

    [Documentation]  Create template preview for context signup with one dynamic variable user name(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[5]['name']}
    Set Test Variable   ${suser_name}     ${resp.json()[5]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${suser_name}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 

JD-TC-CreateTemplatePreview-8

    [Documentation]  Create template preview for context SIGNUP with one dynamic variable mobile number(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[6]['name']}
    Set Test Variable   ${smob_no}        ${resp.json()[6]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${smob_no}
    
    ${resp}=  Create Template Preview  ${VariableContext[3]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[3]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 

JD-TC-CreateTemplatePreview-9

    [Documentation]  Create template preview for context signup with one dynamic variable date(will return a sample value).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[7]['name']}
    Set Test Variable   ${sdate}          ${resp.json()[7]['sampleValue']}

    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${sdate}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 

JD-TC-CreateTemplatePreview-10

    [Documentation]  Create template preview for context CHECKIN with one dynamic variable which is not in that context(will rerurn a space)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Dynamic Variable List By Context   ${context_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${dynamic_var1}   ${resp.json()[3]['name']}
    
    ${content_msg}=      FakerLibrary.sentence
    ${content_msg1}=     Set Variable  ${content_msg} [${dynamic_var1}]
    ${content}=    Create Dictionary  intro=${content_msg1}
    ${out_content}=  Set Variable   ${content_msg} ${SPACE}
    
    ${resp}=  Create Template Preview  ${VariableContext[0]}  ${content}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['context']}           ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['content']['intro']}  ${out_content} 
