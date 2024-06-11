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

JD-TC-GetCustomVariableByFilter-1

    [Documentation]  Create custom variable for a provider then get it by filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}

JD-TC-GetCustomVariableByFilter-2

    [Documentation]  Create multiple custom variables then get it by filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}

    Should Be Equal As Strings  ${resp.json()[1]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[1]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[1]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['account']}         ${account_id}

JD-TC-GetCustomVariableByFilter-3

    [Documentation]  Create multiple custom variables then get it by variableName filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   variableName-eq=${name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id2} 
   
    ${resp}=  Get Custom Variable By Filter   variableName-eq=${name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id1} 

JD-TC-GetCustomVariableByFilter-4

    [Documentation]  Create multiple custom variables then get it by variableDisplayName filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   variableDisplayName-eq=${dis_name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id2} 
   
    ${resp}=  Get Custom Variable By Filter   variableDisplayName-eq=${dis_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id1} 

JD-TC-GetCustomVariableByFilter-5

    [Documentation]  Create multiple custom variables then get it by value filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   value-eq=${value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id2} 
   
    ${resp}=  Get Custom Variable By Filter   value-eq=${value1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id1} 

JD-TC-GetCustomVariableByFilter-6

    [Documentation]  Create multiple custom variables then get it by status filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
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

    ${resp}=  Get Custom Variable By Filter   status-eq=${VarStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id} 
    Should Be Equal As Strings  ${resp.json()[1]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[1]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[1]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['account']}         ${account_id}

    ${resp}=  Update Custom Variable Status  ${var_id1}   ${VarStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Filter   status-eq=${VarStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id1} 

JD-TC-GetCustomVariableByFilter-7

    [Documentation]  Create custom variable for a provider then get it by context filter and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
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
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}