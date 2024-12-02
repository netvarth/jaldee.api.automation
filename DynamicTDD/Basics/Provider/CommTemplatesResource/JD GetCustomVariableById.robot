*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-GetCustomVariableById-1

    [Documentation]  Create custom variable for a provider then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
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

JD-TC-GetCustomVariableById-2

    [Documentation]  Create multiple custom variables then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Get Custom Variable By Id   ${var_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-3

    [Documentation]  Create custom variable for the context appointment then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[1]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[1]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-4

    [Documentation]  Create custom variable for the context token then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[2]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[2]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-5

    [Documentation]  Create custom variable for the context order then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[3]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[3]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-6

    [Documentation]  Create custom variable for the context donation then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME74}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[4]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[4]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-7

    [Documentation]  Create custom variable for the context payment then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME75}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[5]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[5]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-8

    [Documentation]  Create custom variable for the context ALL then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[6]}
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
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[6]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-9

    [Documentation]  Create custom variable with name as integer then get it by id and verify..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${int_name}=    Random Int  min=1001  max=9000
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${int_name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${int_name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-GetCustomVariableById-10

    [Documentation]  Create custom variable with display name as integer then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${intdis_name}=    Random Int  min=1001  max=9000
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${intdis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${intdis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}


JD-TC-GetCustomVariableById-11

    [Documentation]  Create custom variable for two providers with same name then get by id and verify.

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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name1}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id1}

JD-TC-GetCustomVariableById-12

    [Documentation]  Create custom variable for two providers with same display name then get by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id1}

JD-TC-GetCustomVariableById-13

    [Documentation]  Create custom variable for two providers with same value then get by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
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

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${name1}=    FakerLibrary.word
    ${dis_name1}=    FakerLibrary.word

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name1}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id2}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id2} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name1} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id1}

JD-TC-GetCustomVariableById-UH1

    [Documentation]  Get custom variable by id with invalid variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${invalidvar_id1}=     Random Int  min=100   max=999

    ${resp}=  Get Custom Variable By Id   ${invalidvar_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${VARIABLE_NOT_FOUND}
    
JD-TC-GetCustomVariableById-UH2

    [Documentation]  Get custom variable by id with another providers variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${VARIABLE_NOT_FOUND}

JD-TC-GetCustomVariableById-UH3

    [Documentation]  Get custom variable by id without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME74}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCustomVariableById-UH4

    [Documentation]  Get custom variable by id with consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME75}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
