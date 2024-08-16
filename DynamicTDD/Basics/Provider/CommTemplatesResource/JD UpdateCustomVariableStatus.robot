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

JD-TC-UpdateCustomVariableStatus-1

    [Documentation]  Create custom variable and update the status as disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariableStatus-2

    [Documentation]  Create custom variable and update the status as disabled then enable it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariableStatus-UH1

    [Documentation]  Create a custom variable and update the status to enabled, even if it is already enabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${VARIABLE_STATUS}=  format String   ${VARIABLE_STATUS}   ${VarStatus[0]} 

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_STATUS}

JD-TC-UpdateCustomVariableStatus-UH2

    [Documentation]  Create a custom variable and update the status to disabled, even if it is already disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  1s
    ${resp}=  Get Custom Variable By Id   ${var_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${VARIABLE_STATUS}=  format String   ${VARIABLE_STATUS}   ${VarStatus[1]} 

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_STATUS} 
