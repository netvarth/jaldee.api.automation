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


*** Variables ***

@{context}   ALL  Signup
@{userType}             spConsumer
@{sendCategory}   ALL
@{templateFormat}   html
${template_html}     /ebs/TDD/template.html

*** Keywords ***

Get Template By Filter

    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/comm/template  params=${param}  expected_status=any
    RETURN  ${resp}

*** Test Cases ***

JD-TC-GetTemplateByFilter-1

    [Documentation]  Create template for a provider then get it and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${comm_chanl}=  Create List   ${notifytype[2]}  ${notifytype[1]}
    ${spec_id}=  Create List   1  23

    ${resp}=  Create Template   ${temp_name}  ${context[1]}  ${templateFormat[0]}  ${notifytype[2]}  ${${template_html}}  ${comm_chanl}  ${userType[0]}   
    ...      ${sendCategory[0]}   ${spec_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Filter   context-eq=${context[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.content['name']}                        ${temp_name} 
    Should Be Equal As Strings  ${resp.content['context']}                     ${context[1]}
    Should Be Equal As Strings  ${resp.content['templateFormat']}              ${templateFormat[0]} 
    Should Be Equal As Strings  ${resp.content['templateType']}                ${notifytype[2]}
    Should Be Equal As Strings  ${resp.content['template']}                    ${template_html} 
    Should Be Equal As Strings  ${resp.content['cocommChannelntext']}          ${comm_chanl}
    Should Be Equal As Strings  ${resp.content['recipient']['userType']}       ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['sendCategory']}   ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['specificID']}     ${Qstate[0]} 
   
    ${resp}=  Get Template By Filter   sendComm-eq=${context[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.content['name']}                        ${temp_name} 
    Should Be Equal As Strings  ${resp.content['context']}                     ${context[1]}
    Should Be Equal As Strings  ${resp.content['templateFormat']}              ${templateFormat[0]} 
    Should Be Equal As Strings  ${resp.content['templateType']}                ${notifytype[2]}
    Should Be Equal As Strings  ${resp.content['template']}                    ${template_html} 
    Should Be Equal As Strings  ${resp.content['cocommChannelntext']}          ${comm_chanl}
    Should Be Equal As Strings  ${resp.content['recipient']['userType']}       ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['sendCategory']}   ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['specificID']}     ${Qstate[0]} 
    
    ${resp}=  Get Template By Filter   commChannel-eq=${context[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.content['name']}                        ${temp_name} 
    Should Be Equal As Strings  ${resp.content['context']}                     ${context[1]}
    Should Be Equal As Strings  ${resp.content['templateFormat']}              ${templateFormat[0]} 
    Should Be Equal As Strings  ${resp.content['templateType']}                ${notifytype[2]}
    Should Be Equal As Strings  ${resp.content['template']}                    ${template_html} 
    Should Be Equal As Strings  ${resp.content['cocommChannelntext']}          ${comm_chanl}
    Should Be Equal As Strings  ${resp.content['recipient']['userType']}       ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['sendCategory']}   ${Qstate[0]} 
    Should Be Equal As Strings  ${resp.content['recipient']['specificID']}     ${Qstate[0]} 
   