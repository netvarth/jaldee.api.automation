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

Update Template  

    [Arguments]  ${temp_id}  ${temp_name}  ${context}  ${temp_format}  ${temp_type}  ${temp}   ${comm_chanl}  ${spec_id} 
    ${recipient}=  Create Dictionary  userType=${userType[0]}  sendCategory=${sendCategory[0]}  specificID=${spec_id} 
    ${data}=  Create Dictionary  name=${temp_name}  context=${context}  templateFormat=${temp_format}  templateType=${temp_type}  
    ...   template=${temp}  commChannel=${comm_chanl}  recipient=${recipient}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/comm/template/${temp_id}  data=${data}  expected_status=any
    RETURN  ${resp} 


*** Test Cases ***

JD-TC-UpdateTemplate-1

    [Documentation]  Create template for a provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${temp_name}=    FakerLibrary.word
    ${comm_chanl}=  Create List   ${notifytype[2]}  ${notifytype[1]}
    ${spec_id}=  Create List   1  23

    ${resp}=  Create Template   ${temp_name}  ${context[1]}  ${templateFormat[0]}  ${notifytype[2]}  ${temp}  ${comm_chanl}  ${userType[0]}   
    ...      ${sendCategory[0]}   ${spec_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Update Template   ${temp_id1}  ${temp_name}  ${context[1]}  ${templateFormat[0]}  ${notifytype[2]}  ${temp}  ${comm_chanl}  ${userType[0]}   
    ...      ${sendCategory[0]}   ${spec_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
