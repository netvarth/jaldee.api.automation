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

    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${var_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['name']}            ${name}
            Should Be Equal As Strings  ${resp.json()[${i}]['displayName']}     ${dis_name} 
            Should Be Equal As Strings  ${resp.json()[${i}]['value']}           ${value}
            Should Be Equal As Strings  ${resp.json()[${i}]['type']}            ${VariableValueType[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}         ${VariableContext[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}          ${VarStatus[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['account']}         ${account_id}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${var_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['name']}            ${name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['displayName']}     ${dis_name1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['value']}           ${value1}
            Should Be Equal As Strings  ${resp.json()[${i}]['type']}            ${VariableValueType[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}         ${VariableContext[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}          ${VarStatus[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['account']}         ${account_id}
        END
    END

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

    ${name1}=    generate_firstname
    ${dis_name1}=    FakerLibrary.lastname
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
    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${var_id1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['name']}            ${name}
            Should Be Equal As Strings  ${resp.json()[${i}]['displayName']}     ${dis_name} 
            Should Be Equal As Strings  ${resp.json()[${i}]['value']}           ${value}
            Should Be Equal As Strings  ${resp.json()[${i}]['type']}            ${VariableValueType[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}         ${VariableContext[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}          ${VarStatus[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['account']}         ${account_id}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${var_id2}'            
            Should Be Equal As Strings  ${resp.json()[${i}]['name']}            ${name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['displayName']}     ${dis_name1} 
            Should Be Equal As Strings  ${resp.json()[${i}]['value']}           ${value1}
            Should Be Equal As Strings  ${resp.json()[${i}]['type']}            ${VariableValueType[1]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['context']}         ${VariableContext[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}          ${VarStatus[0]} 
            Should Be Equal As Strings  ${resp.json()[${i}]['account']}         ${account_id}
        END
    END

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
    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name1}  ${value1}  ${VariableValueType[1]}  ${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Filter   context-eq=${VariableContext[0]}
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

    ${resp}=  Get Custom Variable By Filter   context-eq=${VariableContext[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}              [] 

    ${name2}=    FakerLibrary.word
    ${dis_name2}=    FakerLibrary.word
    ${value2}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name2}  ${dis_name2}  ${value2}  ${VariableValueType[1]}  ${VariableContext[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id3}  ${resp.json()}

    ${resp}=  Get Custom Variable By Filter   context-eq=${VariableContext[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}              ${var_id3} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}            ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}     ${dis_name2} 
    Should Be Equal As Strings  ${resp.json()[0]['value']}           ${value2}
    Should Be Equal As Strings  ${resp.json()[0]['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['context']}         ${VariableContext[2]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['account']}         ${account_id}
    Should Not Contain          ${resp.json()}                       ${var_id2} 
    Should Not Contain          ${resp.json()}                       ${var_id1} 

JD-TC-GetCustomVariableByFilter-8

    [Documentation]  Get the filter by name after updating the custom variable name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
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

    ${name1}=    FakerLibrary.word
   
    ${resp}=  Update Custom Variable   ${var_id1}  ${name1}  ${dis_name}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get Custom Variable By Filter   variableName-eq=${name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}              [] 

JD-TC-GetCustomVariableByFilter-9

    [Documentation]  Get the filter by name after updating the custom variable display name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
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

    ${dis_name1}=    FakerLibrary.word
   
    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name1}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Filter   variableName-eq=${dis_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}              [] 

JD-TC-GetCustomVariableByFilter-10

    [Documentation]  Get the filter by name after updating the custom value.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
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

    ${value1}=   FakerLibrary.hostname

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${value1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Custom Variable By Filter   variableName-eq=${value1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}              [] 

JD-TC-GetCustomVariableByFilter-UH1

    [Documentation]  Get Custom variable by filter without login

    ${resp}=  Get Custom Variable By Filter
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCustomVariableByFilter-UH2

    [Documentation]  Get Custom variable by filter with provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
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

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Custom Variable By Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetCustomVariableByFilter-UH3

    [Documentation]   get the filter using a variable name associated with a different provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Filter   variableName-eq=${name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}             []

JD-TC-GetCustomVariableByFilter-UH4

    [Documentation]   get the filter using a variable display name associated with a different provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Filter   variableDisplayName-eq=${dis_name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}             []

JD-TC-GetCustomVariableByFilter-UH5

    [Documentation]   get the filter using a value associated with a different provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Filter   value-eq=${value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}             []
    
    